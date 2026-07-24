local cascade, _types = require("@packages/cascade"), require("@packages/cascade/types")

return function(name: string, tab: _types.Tab, titledRow: _types.Row, app: _types.App)
	--// Imports
	local console = require("@dependencies/ui/console")
	local views = require("@self/views")
	local gameRefs = require("@gameRefs")
	local crypt = require("@dependencies/crypt/crypt")
	local config = require("@config")
	local keybind = require("@modules/keybind")
	local debugLogger = require("@modules/debugLogger")
	local fallbackResult = require("@self/result")
	local moduleFactories = {
		Services = require("@self/services"),
		Executor = require("@self/executor"),
		Leaks = require("@self/leaks"),
		Escapes = require("@self/escapes"),
	}

	--// Variables
	local copyButton = nil
	local output = nil
	local currentTask = nil
	local currentLogger = nil
	local testingState = nil
	local builtViews = {}

	local testConfig = {
		checkpointDelay = 0,
		showSafe = true,
		includeMetadata = false,
		testTimeout = 5,
		excludedTests = "",
		includedTests = "",
		writeDebugLogs = config.logging.debugLogs.Value,
	}

	local uni = {
		bullet = "•",
	}
	local statusCodes = require("@modules/statusCodes").Vulnerabilities

	--// Private Methods
	local printc = function(...)
		output:AppendText(table.concat({ ... }, " "))
	end

	local warnc = function(...)
		output:AppendText(`<font color="#FFA500">{table.concat({ ... }, " ")}</font>`)
	end

	local function buildChecks()
		local checks = {}

		for moduleName, factory in pairs(moduleFactories) do
			local success, moduleChecks = pcall(factory)

			if success and type(moduleChecks) == "table" then
				for _, check in ipairs(moduleChecks) do
					check.module = moduleName
					table.insert(checks, check)
				end
			else
				table.insert(checks, {
					id = `module.{moduleName}.load`,
					name = `{moduleName} module loaded`,
					category = "Module Loading",
					module = moduleName,
					run = function()
						return fallbackResult.ambiguous("Module failed to build checks", tostring(moduleChecks))
					end,
				})
			end
		end

		return checks
	end

	local function parseFilter(value)
		local filter = {}
		local hasFilter = false

		if value and value ~= "" then
			for _, item in ipairs(string.split(value, ",")) do
				local cleaned = item:gsub("^%s*(.-)%s*$", "%1")
				if cleaned ~= "" then
					filter[string.lower(cleaned)] = true
					hasFilter = true
				end
			end
		end

		return filter, hasFilter
	end

	local function checkMatchesFilter(check, filter)
		return filter[string.lower(check.id or "")]
			or filter[string.lower(check.name or "")]
			or filter[string.lower(check.module or "")]
			or filter[string.lower(check.category or "")]
	end

	local function filterChecks(checks, logger)
		local exclusions = parseFilter(testConfig.excludedTests)
		local inclusions, hasInclusions = parseFilter(testConfig.includedTests)
		local filtered = {}
		local excludedCount = 0

		for _, check in ipairs(checks) do
			if checkMatchesFilter(check, exclusions) then
				excludedCount += 1
				logger:write(`Skipped vulnerability check: {check.id}, reason: excluded`)
				continue
			end

			if hasInclusions and not checkMatchesFilter(check, inclusions) then
				excludedCount += 1
				logger:write(`Skipped vulnerability check: {check.id}, reason: not included`)
				continue
			end

			table.insert(filtered, check)
		end

		return filtered, excludedCount
	end

	local function runCheck(check)
		local success, checkResult
		local done = false
		local startTime = os.clock()

		local thread = task.spawn(function()
			success, checkResult = pcall(check.run)
			done = true
		end)

		local elapsed = 0
		while not done and elapsed < testConfig.testTimeout do
			task.wait(0.061)
			elapsed = os.clock() - startTime
		end

		if not done then
			task.cancel(thread)
			return fallbackResult.ambiguous(`Timed out after {testConfig.testTimeout}s`), os.clock() - startTime
		end

		if not success then
			return fallbackResult.ambiguous("Check errored", tostring(checkResult)), os.clock() - startTime
		end

		if type(checkResult) ~= "table" or type(checkResult.status) ~= "number" then
			return fallbackResult.ambiguous("Check returned an invalid result"), os.clock() - startTime
		end

		return checkResult, os.clock() - startTime
	end

	local function shouldDisplay(result)
		return testConfig.showSafe or result.status ~= 200
	end

	local function runTests()
		if currentTask then
			if currentLogger then
				currentLogger:finish("Vulnerability test cancelled by a new run")
			end

			task.cancel(currentTask)
		end

		currentTask = task.spawn(function()
			local logger = debugLogger.new(testConfig.writeDebugLogs)
			currentLogger = logger
			logger:start()
			logger:write("User started vulnerability test")

			tab.Selected = true
			logger:write("Selected vulnerability tab")

			if testingState then
				logger:write("Initializing testing state")
				testingState.Visible = true
				testingState.Passed = 0
				testingState.Failed = 0
				testingState.CurrentTest = "Initializing..."
				testingState.NextTest = "None"
				testingState.TotalElapsed = 0
				testingState.CheckElapsed = 0
			end

			if output then
				logger:write("Hiding previous output")
				output.__instance.Visible = false
				output:Clear()
			end
			if copyButton then
				copyButton.__instance.Visible = false
			end

			local targetY = 0
			if testingState and testingState.__container then
				targetY = testingState.__container.AbsolutePosition.Y
			elseif output and output.__instance then
				targetY = output.__instance.AbsolutePosition.Y
			end

			game:GetService("TweenService")
				:Create(
					tab.Structures.Page.__instance,
					TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
					{
						CanvasPosition = Vector2.new(
							0,
							targetY
								- tab.Structures.Page.__instance.AbsolutePosition.Y
								+ tab.Structures.Page.__instance.CanvasPosition.Y
						),
					}
				)
				:Play()

			local startTime = time()
			local totals = { checked = 0, secured = 0, vulnerable = 0, ambiguous = 0 }
			local results = {}
			local builtChecks = buildChecks()
			logger:write(`Built {#builtChecks} vulnerability checks`)
			local checks, excludedCount = filterChecks(builtChecks, logger)
			logger:write(`Selected {#checks} vulnerability checks, excluded {excludedCount}`)

			for i, check in ipairs(checks) do
				local nextCheck = checks[i + 1]
				logger:write(`Running vulnerability check: {check.id}, next check: {nextCheck and nextCheck.id or "None"}`)

				if testingState then
					testingState.CurrentTest = check.name
					testingState.NextTest = nextCheck and nextCheck.name or "None"
				end

				local checkResult, elapsed = runCheck(check)
				logger:write(`Ran vulnerability check: {check.id}, result: {checkResult.status}, message: {checkResult.message}, elapsed: {elapsed}s`)

				totals.checked += 1
				if checkResult.status == 200 then
					totals.secured += 1
				elseif checkResult.status == 400 then
					totals.vulnerable += 1
				else
					totals.ambiguous += 1
				end

				table.insert(results, {
					id = check.id,
					name = check.name,
					module = check.module,
					category = check.category,
					status = checkResult.status,
					message = checkResult.message,
					details = checkResult.details,
					elapsedTestTime = elapsed,
				})

				if testingState then
					testingState.Passed = totals.secured
					testingState.Failed = totals.vulnerable
					testingState.TotalElapsed = time() - startTime
					testingState.CheckElapsed = elapsed
				end

				if testConfig.checkpointDelay > 0 then
					task.wait(testConfig.checkpointDelay)
				end
			end

			if testingState then
				logger:write("Finished running vulnerability checks")
				testingState.Visible = false
			end
			if output then
				logger:write("Showing output console")
				output.__instance.Visible = true
			end
			if copyButton then
				copyButton.__instance.Visible = true
			end

			if output and output.__instance then
				local consoleY = output.__instance.AbsolutePosition.Y
				game:GetService("TweenService")
					:Create(
						tab.Structures.Page.__instance,
						TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
						{
							CanvasPosition = Vector2.new(
								0,
								consoleY
									- tab.Structures.Page.__instance.AbsolutePosition.Y
									+ tab.Structures.Page.__instance.CanvasPosition.Y
							),
						}
					)
					:Play()
			end

			local renderedCategories = {}
			for _, result in ipairs(results) do
				if shouldDisplay(result) then
					if not renderedCategories[result.category] then
						logger:write(`Rendering output category: {result.category}`)
						printc(`\n{result.category}:`)
						renderedCategories[result.category] = true
					end

					local displayFunc = result.status == 200 and printc or warnc
					displayFunc(`{uni.bullet} {statusCodes[result.status]} {result.name}: {result.message}`)
				end
			end

			--// Summary
			local endTime = math.floor((time() - startTime) * 10 ^ 2 + 0.5) / 10 ^ 2
			local rate = totals.checked > 0 and math.round((totals.secured / totals.checked) * 100) or 0
			local executor, version = identifyexecutor()
			logger:write(`Finished vulnerability test. Took: {endTime}s, executor: {executor or "Unknown"}, version: {version or "Unknown"}, checked: {totals.checked}, secured: {totals.secured}, vulnerable: {totals.vulnerable}, ambiguous: {totals.ambiguous}`)

			printc(`\nSummary:`)
			printc(`{uni.bullet} Took: {endTime}s`)
			printc(`{uni.bullet} Executor: {executor or "Unknown"}`)
			printc(`{uni.bullet} Checked: {totals.checked}`)
			printc(`{uni.bullet} Secured: <font color="#55FF55">{totals.secured}</font>`)
			printc(`{uni.bullet} Vulnerable: <font color="#FF5555">{totals.vulnerable}</font>`)
			printc(`{uni.bullet} Ambiguous: {totals.ambiguous}`)
			printc(`{uni.bullet} Security Rating: {rate}%`)
			if excludedCount > 0 then
				printc(`{uni.bullet} Excluded: {excludedCount} tests`)
			end

			local resultsData = {
				checked = totals.checked,
				secured = totals.secured,
				vulnerable = totals.vulnerable,
				ambiguous = totals.ambiguous,
				excludedCount = excludedCount,
				results = results,
			}

			if testConfig.includeMetadata then
				logger:write("Adding metadata to output")
				local input = output:GetValue()

				local metaBlock = string.format(
					'@metadata {\n  "generated": "%s",\n  "executor": "%s",\n  "version": "%s",\n  "rating": "%d%%"\n} \n\n',
					DateTime.now():ToIsoDate(),
					executor or "Unknown",
					version or "N/A",
					rate
				)

				output:SetValue(metaBlock .. input)
			end

			local metadata = {
				["executor"] = executor or "Unknown",
				["executorVersion"] = version or "N/A",
				["rating"] = rate,
				["testTime"] = endTime,
				["generated"] = DateTime.now():ToIsoDate(),
			}

			local signatureId = ""
			local headers = ""
			local resultHash = ""

			pcall(function()
				logger:write("Requesting result signature")
				local ReqFunc = request or http_request or (http and http.request)
				if ReqFunc then
					local response = ReqFunc({
						Url = "https://myriad.tools/api/gensignature",
						Method = "GET",
					})

					if response and response.StatusCode == 200 then
						local HttpService = game:GetService("HttpService")
						local data = HttpService:JSONDecode(response.Body)
						signatureId = data.signatureId
						headers = data.obfuscatedHeaders

						resultHash = crypt.hash(HttpService:JSONEncode(resultsData) .. data.challenge)
						logger:write(`Generated result signature: {signatureId}`)
					end
				end
			end)

			logger:write("Submitting vulnerability results")
			gameRefs.res:FireServer("v", resultsData, metadata, signatureId, headers, resultHash)
			logger:finish("Vulnerability test complete")
			if logger.path and not logger.writeFailure then
				app:Notification({
					App = "MYRIAD",
					Title = "Debug log finalized",
					Subtitle = `Saved to {logger:getWorkspacePath()}`,
					Icon = cascade.Symbols.docText,
				})
			end
			currentLogger = nil
		end)
	end

	--// UI
	do -- Test Options
		local form = tab:PageSection({ Title = "Test Options", Subtitle = "Configure the tests" }):Form()

		titledRow(form, "Options"):Right():Button({
			Label = "Configure",
			State = "Secondary",
			Pushed = function()
				builtViews.Settings.Selected = true
			end,
		})
	end

	do -- Output
		-- Output section
		do
			local section = tab:PageSection({ Title = "Output", Subtitle = "View the results of the tests" })

			-- Form 1
			do
				local form = section:Form()

				titledRow(form, "Run Test"):Right():Button({
					Label = "Run",
					Pushed = runTests,
				})

				-- Keybind
				do
					local keybindRow = form:Row()

					local keybindField = keybindRow:Right():KeystrokeField({
						Keys = config.keybinds.runVulnerabilityTest.Value,
						ValueChanged = function(_self, newKeys)
							config.keybinds.runVulnerabilityTest.Value = newKeys
						end,
					})

					config.keybinds.runVulnerabilityTest.Changed:Connect(function(newKeys)
						keybindField.Keys = newKeys
					end)

					keybind
						.new(config.keybinds.runVulnerabilityTest, { sink = true })
						:Connect(function(inputComplete: boolean)
							if not inputComplete then
								return
							end

							coroutine.wrap(runTests)()
						end)
				end
			end

			-- Form 2
			do
				local form = section:Form()
				copyButton = form

				form:Row():Right():Button({
					Label = "Copy results",
					Pushed = function(self)
						if output then
							if setclipboard or toclipboard then
								(setclipboard or toclipboard)(output:GetValue())
								app:Notification({
									App = "MYRIAD",
									Title = "Copied output",
									Subtitle = "Output copied to clipboard.",
									Icon = cascade.Symbols.link,
								})
							else
								app:Notification({
									App = "MYRIAD",
									Title = "Failed to copy Output",
									Icon = cascade.Symbols.exclamationmarkTriangle,
								})
							end
						elseif output:GetValue() == "" then
							app:Notification({
								App = "MYRIAD",
								Title = "There is no output.",
								Icon = cascade.Symbols.exclamationmarkTriangle,
							})
						else
							app:Notification({
								App = "MYRIAD",
								Title = "Output dosen't exist. Was the UI initialized properly?",
								Icon = cascade.Symbols.exclamationmarkTriangle,
							})
						end
					end,
				})

				form.__instance.Visible = false
			end
		end

		testingState = tab:TestingState({
			Visible = false,
			Passed = 0,
			Failed = 0,
			CurrentTest = "Initializing....",
			NextTest = "None",
		})

		output = console.new(tab.__container, {
			ReadOnly = true,
			RichText = true,
			LineHeight = 1.3,
			Fill = true,
		})

		output.__instance.Visible = false

		output:Clear()
		output:AppendText("")
	end

	do -- Subtabs
		for viewName, viewSettings in views do
			local viewTab = tab:Tab({
				Title = viewName,
				Icon = viewSettings.Icon,
			})

			builtViews[viewName] = viewTab
			viewSettings.Init(name, viewTab, titledRow, app, testConfig)
		end
	end

	return { passed = 0, failed = 0 }
end
