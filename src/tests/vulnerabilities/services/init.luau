local blocklist = require("@self/blocklist")
local result = require("@vulnerabilities/result")

local function getPseudoTarget(data)
	return data.Target
end

local function getServiceTarget(serviceName)
	local success, service = pcall(game.GetService, game, serviceName)
	if success then
		return service
	end

	return nil
end

local function test(id, category, targetName, methodName, getTarget)
	return {
		id = id,
		name = `{targetName}.{methodName}`,
		category = category,
		run = function()
			local target = getTarget()
			if target == nil then
				return result.ambiguous("Target is unavailable")
			end

			local exists, method = pcall(function()
				return target[methodName]
			end)

			if not exists or type(method) ~= "function" then
				return result.secured("Method is not exposed")
			end

			local success = pcall(method, target)
			if success then
				return result.vulnerable("Method executed without a permission block")
			end

			return result.secured("Method rejected direct invocation")
		end,
	}
end

return function()
	local checks = {}

	if blocklist._pseudo then
		for targetName, data in pairs(blocklist._pseudo) do
			for _, methodName in ipairs(data.Methods) do
				table.insert(
					checks,
					test(
						`services.pseudo.{targetName}.{methodName}`,
						"Pseudo Targets",
						targetName,
						methodName,
						function()
							return getPseudoTarget(data)
						end
					)
				)
			end
		end
	end

	if blocklist.Services then
		for serviceName, methods in pairs(blocklist.Services) do
			for _, methodName in ipairs(methods) do
				table.insert(
					checks,
					test(
						`services.{serviceName}.{methodName}`,
						"Standard Services",
						serviceName,
						methodName,
						function()
							return getServiceTarget(serviceName)
						end
					)
				)
			end
		end
	end

	return checks
end
