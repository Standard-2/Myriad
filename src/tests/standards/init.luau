--!nocheck

local cascade, _types = require("@packages/cascade"), require("@packages/cascade/types")

return function(name: string, tab: types.Tab, titledRow: types.Row, app: types.App)
	--// Imports
	local checks = require("@checks/init")
	local views = require("@self/views")
	local gameRefs = require("@gameRefs")
	local crypt = require("@dependencies/crypt/crypt")
	local config = require("@config")
	local keybind = require("@modules/keybind")
	local debugLogger = require("@modules/debugLogger")

	--// Variables
	local currentTask = nil
	local currentLogger = nil
	local testResults = nil
	local testingState = nil
	local lastEntreePerGroup = {}
	local results = {}
	local builtViews = {}

	local testConfig = {
		checkpointDelay = 0,
		excludedTests = "",
		includedTests = "",
		testTimeout = 8,
		writeDebugLogs = config.logging.debugLogs.Value,
	}

	local function test()
		if currentTask then
			if currentLogger then
				currentLogger:finish("Standards test cancelled by a new run")
			end

			task.cancel(currentTask)
		end

		currentTask = task.spawn(function()
			local logger = debugLogger.new(testConfig.writeDebugLogs)
			currentLogger = logger
			logger:start()
			logger:write("User started standards test")

			tab.Selected = true
			logger:write("Selected standards tab")

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

			if testResults then
				logger:write("Hiding previous results")
				testResults.Visible = false
			end

			local targetY = 0
			if testingState and testingState.__container then
				targetY = testingState.__container.AbsolutePosition.Y
			elseif testResults and testResults.__container then
				targetY = testResults.__container.AbsolutePosition.Y
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
			local passed = 0
			local failed = 0
			local numStandards = 0
			local excludedCount = 0
			logger:write("Initialized standards counters")

			local exclusions = {}
			if testConfig.excludedTests and testConfig.excludedTests ~= "" then
				logger:write(`Parsing excluded tests: {testConfig.excludedTests}`)
				for _, ex in ipairs(string.split(testConfig.excludedTests, ",")) do
					exclusions[ex:gsub("^%s*(.-)%s*$", "%1")] = true
				end
			end

			local inclusions = {}
			local hasInclusions = false
			if testConfig.includedTests and testConfig.includedTests ~= "" then
				logger:write(`Parsing included tests: {testConfig.includedTests}`)
				hasInclusions = true
				for _, inc in ipairs(string.split(testConfig.includedTests, ",")) do
					inclusions[inc:gsub("^%s*(.-)%s*$", "%1")] = true
				end
			end

			for groupName, group in checks do
				lastEntreePerGroup[groupName] = nil
				results[groupName] = {}
				logger:write(`Initializing result group: {groupName}`)

				for name in group do
					numStandards += 1
					lastEntreePerGroup[groupName] = name
				end
			end

			local flattened = {}
			for groupName, group in checks do
				for name, test in group do
					table.insert(flattened, {
						groupName = groupName,
						name = name,
						test = test,
					})
				end
			end
			logger:write(`Flattened {#flattened} standards tests`)

			for i, entry in ipairs(flattened) do
				local groupName = entry.groupName
				local name = entry.name
				local test = entry.test
				local testId = `{groupName}.{name}`

				if exclusions[groupName] or exclusions[name] or exclusions[groupName .. "." .. name] then
					excludedCount += 1
					logger:write(`Skipped test: {testId}, reason: excluded`)
					continue
				end

				if hasInclusions then
					if not (inclusions[groupName] or inclusions[name] or inclusions[groupName .. "." .. name]) then
						excludedCount += 1
						logger:write(`Skipped test: {testId}, reason: not included`)
						continue
					end
				end

				local nextEntry = flattened[i + 1]
				local nextTestId = nextEntry and `{nextEntry.groupName}.{nextEntry.name}` or "None"
				logger:write(`Running test: {testId}, next test: {nextTestId}`)

				if testingState then
					testingState.CurrentTest = name
					testingState.NextTest = nextEntry and nextEntry.name or "None"
				end

				local startTestTime = os.clock()
				local success, result

				do
					local done = false
					local thread = task.spawn(function()
						success, result = pcall(test)
						done = true
					end)

					local elapsed = 0
					while not done and elapsed < testConfig.testTimeout do
						task.wait(0.061)
						elapsed = os.clock() - startTestTime
						if testingState then
							testingState.TotalElapsed = time() - startTime
							testingState.CheckElapsed = elapsed
						end
					end

					if not done then
						task.cancel(thread)
						success = false
						result = `Timed out after {testConfig.testTimeout}s`
						logger:write(`Test timed out: {testId}, timeout: {testConfig.testTimeout}s`)
					end
				end

				local checkElapsed = os.clock() - startTestTime
				local status, message

				if not success then
					status = 0
					message = result
					failed += 1
				elseif result.status == 200 then
					status = result.status
					message = result.message
					passed += 1
				else
					status = result.status
					message = result.message
					failed += 1
				end
				logger:write(
					`Ran test: {testId}, result: {status}, message: {message}, elapsed: {checkElapsed}s, next test: {nextTestId}`
				)

				if testingState then
					testingState.Passed = passed
					testingState.Failed = failed
					testingState.TotalElapsed = time() - startTime
					testingState.CheckElapsed = checkElapsed
				end

				if testConfig.checkpointDelay ~= 0 then
					logger:write(`Waiting checkpoint delay: {testConfig.checkpointDelay}s`)
					task.wait(testConfig.checkpointDelay)
				end

				table.insert(results[groupName], {
					name = name,
					status = status,
					message = message,
					elapsedTestTime = checkElapsed,
				})
			end

			if testingState then
				logger:write("Finished running standards tests")
				testingState.Visible = false
			end

			local endTime = math.floor((time() - startTime) * 10 ^ 2 + 0.5) / 10 ^ 2
			local executor, executorVers = identifyexecutor()
			local tested = numStandards - excludedCount
			local rate = tested > 0 and math.round(passed / tested * 100) or 0
			logger:write(
				`Finished standards test. Took: {endTime}s, executor: {executor or "Unknown"}, version: {executorVers or "Unknown"}, tested: {tested}, passed: {passed}, failed: {failed}`
			)

			local groups = {}
			for groupName, groupResults in results do
				logger:write(`Rendering result group: {groupName}`)
				table.insert(groups, {
					name = groupName,
					entries = groupResults,
				})
			end

			if testResults then
				logger:write("Showing test results")
				testResults.Report = {
					summary = {
						took = endTime,
						executor = executor or "Unknown",
						version = executorVers or "Unknown",
						tested = tested,
						passed = passed,
						failed = failed,
						excluded = excludedCount,
						rate = rate,
						passedLabel = "passed",
						failedLabel = "failed",
						ambiguousLabel = "ambiguous",
					},
					groups = groups,
				}
				testResults.Visible = true

				task.defer(function()
					local resultsY = testResults.__container.AbsolutePosition.Y
					game:GetService("TweenService")
						:Create(
							tab.Structures.Page.__instance,
							TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
							{
								CanvasPosition = Vector2.new(
									0,
									resultsY
										- tab.Structures.Page.__instance.AbsolutePosition.Y
										+ tab.Structures.Page.__instance.CanvasPosition.Y
								),
							}
						)
						:Play()
				end)
			end

			--[[ local signatureId = ""
			local challenge = ""
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
						challenge = data.challenge
						headers = data.obfuscatedHeaders

						resultHash = crypt.hash(HttpService:JSONEncode(results) .. challenge)
						logger:write(`Generated result signature: {signatureId}`)
					end
				end
			end)

			logger:write("Submitting standards results")
			gameRefs.res:FireServer("s", results, {
				["testBuildMetadata"] = _P,
				["executor"] = executor,
				["executorVersion"] = executorVers,
				["tested"] = numStandards,
				["passed"] = passed,
				["failed"] = failed,
				["testTime"] = endTime,
				["generated"] = DateTime.now():ToIsoDate(),
				["excludedCount"] = excludedCount,
			}, signatureId, headers, resultHash) ]]

			logger:finish("Standards test complete")
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

	--// Initialize
	do -- About
		local form = tab:Form()

		titledRow(form, "Scope", "Formally named 'Myriad Environment Specification'. It is an adaptation of the original UNC standard specification.")
	end

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

	-- Output
	do
		-- Output section
		do
			local section = tab:PageSection({ Title = "Output", Subtitle = "View the results of the tests" })

			-- Form 1
			do
				local form = section:Form()

				titledRow(form, "Run Test"):Right():Button({
					Label = "Run",
					Pushed = function(self)
						coroutine.wrap(test)()
					end,
				})

				-- Show keybind
				do
					local keybindRow = form:Row()

					local keybindField = keybindRow:Right():KeystrokeField({
						Keys = config.keybinds.runStandardsTest.Value,
						ValueChanged = function(_self, newKeys)
							config.keybinds.runStandardsTest.Value = newKeys
						end,
					})

					config.keybinds.runStandardsTest.Changed:Connect(function(newKeys)
						keybindField.Keys = newKeys
					end)

					keybind
						.new(config.keybinds.runStandardsTest, { sink = true })
						:Connect(function(inputComplete: boolean)
							if not inputComplete then
								return
							end

							coroutine.wrap(test)()
						end)
				end
			end

		end

		testingState = tab:TestingState({
			Visible = false,
			Passed = 0,
			Failed = 0,
			CurrentTest = "Initializing...",
			NextTest = "None",
		})

		testResults = tab:TestResults({
			Kind = "standards",
			Visible = false,
			Copied = function(text)
				if text == "" then
					app:Notification({
						App = "MYRIAD",
						Title = "There is no output.",
						Icon = cascade.Symbols.exclamationmarkTriangle,
					})
					return
				end

				if setclipboard or toclipboard then
					(setclipboard or toclipboard)(text)
					app:Notification({
						App = "MYRIAD",
						Title = "Copied results",
						Subtitle = "Results copied to clipboard.",
						Icon = cascade.Symbols.link,
					})
				else
					app:Notification({
						App = "MYRIAD",
						Title = "Failed to copy results",
						Icon = cascade.Symbols.exclamationmarkTriangle,
					})
				end
			end,
		})
	end

	do
		for viewName, viewSettings in views do
			local viewTab = tab:Tab({
				Title = viewName,
				Icon = viewSettings.Icon,
			})

			builtViews[viewName] = viewTab
			viewSettings.Init(name, viewTab, titledRow, app, testConfig)
		end
	end

	return results
end
