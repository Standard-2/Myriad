--!nocheck

return function(name, tab, titledRow, app, testConfig)
	local cascade = require("@packages/cascade")
	local config = require("@config")
	local writefileTest = require("@checks/Filesystem/writefile")

	local pageSection = tab:PageSection({ Title = "Settings", Subtitle = "Configure the vulnerabilities test" })

	-- Filters
	do
		local form = pageSection:Form()

		titledRow(
			form,
			"Included Tests",
			"Only run these modules, categories, check names, or check IDs (comma-delimited). Leave blank to run all."
		)
			:Right()
			:TextField({
				Placeholder = "Escapes, request blocks file://",
				Value = testConfig.includedTests,
				ValueChanged = function(self, value)
					testConfig.includedTests = value
				end,
			})

		titledRow(
			form,
			"Excluded Tests",
			"Exclude modules, categories, check names, or check IDs (comma-delimited)."
		)
			:Right()
			:TextField({
				Placeholder = "Services, BrowserService.OpenBrowserWindow",
				Value = testConfig.excludedTests,
				ValueChanged = function(self, value)
					testConfig.excludedTests = value
				end,
			})
	end

	-- Delays
	do
		local form = pageSection:Form()

		titledRow(form, "Checkpoint Delay", "Adds delay per test. Useful to check for crashes."):Right():Stepper({
			Fielded = true,
			Value = 0,
			Minimum = 0,
			Maximum = 0.5,
			Step = 0.01,
			ValueChanged = function(self, value)
				testConfig.checkpointDelay = value
			end,
		})

		titledRow(form, "Test Timeout", "Maximum seconds a single vulnerability check may run before being cancelled.")
			:Right()
			:Stepper({
				Fielded = true,
				Value = testConfig.testTimeout,
				Minimum = 1,
				Maximum = 30,
				Step = 1,
				ValueChanged = function(self, value)
					testConfig.testTimeout = value
				end,
			})
	end

	-- Display options
	do
		local form = pageSection:Form()

		titledRow(form, "Debug Logs", "Writes detailed vulnerability test lifecycle logs to .myriad/logs.")
			:Right()
			:Toggle({
				Value = config.logging.debugLogs.Value,
				ValueChanged = function(self, value)
					if value and not writefile then
						self.Value = false
						config.logging.debugLogs.Value = false
						testConfig.writeDebugLogs = false

						app:Notification({
							App = "MYRIAD",
							Title = "Debug logging unavailable",
							Subtitle = "Debug Logs: `writefile` is not available. Logging will not occur",
							Icon = cascade.Symbols.exclamationmarkTriangle,
						})

						return
					end

					if value then
						local success, result = pcall(writefileTest)
						if not success or result.status ~= 200 then
							app:Notification({
								App = "MYRIAD",
								Title = "Debug logging may fail",
								Subtitle = "Debug Logs: `writefile` test did not pass. Logging may not occur.",
								Icon = cascade.Symbols.exclamationmarkTriangle,
							})
						end
					end

					config.logging.debugLogs.Value = value
					testConfig.writeDebugLogs = value
				end,
			})

		titledRow(form, "Show Safe Results", "Shows functions that are safe. Disable to only show vulnerabilities.")
			:Right()
			:Toggle({
				Value = true,
				ValueChanged = function(self, value)
					testConfig.showSafe = value
				end,
			})

		titledRow(form, "Include Metadata", "Shows executor metadata at the end."):Right():Toggle({
			Value = false,
			ValueChanged = function(self, value)
				testConfig.includeMetadata = value
			end,
		})
	end
end
