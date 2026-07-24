local valueState = require("@modules/valueState")

return {
	logging = {
		debugLogs = valueState.new(true),
		rootDirectory = ".myriad",
		logDirectory = ".myriad/logs",
		logExtension = "log",
	},

	keybinds = {
		toggleMenu = valueState.new({ Enum.KeyCode.RightControl }),
		runStandardsTest = valueState.new({ "Control", "Shift", "S" }),
		runVulnerabilityTest = valueState.new({ "Control", "Shift", "V" }),
		runStressTest = valueState.new({ "Control", "Shift", "T" }),
	},
}
