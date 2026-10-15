--!nocheck
--!nolint

return function()
	local network = game:GetService("ReplicatedStorage"):FindFirstChild("Network")
	local module = network and network:FindFirstChild("emptyModule")

	if not getloadedmodules then
		return {
			status = 400,
			message = "Global not found",
		}
	elseif not module then
		return {
			status = 401,
			message = "Testing dependency 'Network.emptyModule' not found.",
		}
	end

	--// Functionality test
	local requireOk, requireResult = pcall(require, module)
	if not requireOk then
		return {
			status = 500,
			message = `Failed to require 'Network.emptyModule': {requireResult}`,
		}
	end

	local unloadedModule = Instance.new("ModuleScript")

	local loadedModules = getloadedmodules()
	if not table.find(loadedModules, module) then
		return {
			status = 500,
			message = "Loaded module not found in returned table",
		}
	elseif table.find(loadedModules, unloadedModule) then
		return {
			status = 500,
			message = "Unloaded module found in returned table",
		}
	end

	--// Alias test
	local envIndex, failedIndex = require("@dependencies/aliasTest.luau")({})

	if not envIndex then
		return {
			status = 501,
			message = `Alias not found: {failedIndex}`,
		}
	end

	return {
		status = 200,
		message = `Passed`,
	}
end
