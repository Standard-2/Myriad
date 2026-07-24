local parentVectors = require("@self/vectors")
local result = require("@vulnerabilities/result")

local function hasFunction(name)
	return type(getgenv and getgenv()[name] or _G[name]) == "function"
end

local function test()
	return {
		id = "escapes.identity.indexHook",
		name = "Identity escalation via __index hook",
		category = "Executor Environment Escapes",
		run = function()
			if
				not hasFunction("loadstring")
				or not hasFunction("getgenv")
				or type(getrenv) ~= "function"
				or type(clonefunction) ~= "function"
				or type(setthreadidentity) ~= "function"
				or type(hookmetamethod) ~= "function"
			then
				return result.ambiguous("Required executor primitives are unavailable")
			end

			local success, escalated = pcall(function()
				local env = getgenv()
				local robloxEnv = getrenv()
				local load = env.loadstring

				robloxEnv.loadstring = load
				robloxEnv.getgenv = env.getgenv
				robloxEnv._set = clonefunction(setthreadidentity)

				local escaped = false
				local old
				old = hookmetamethod(game, "__index", function(instance, key)
					task.spawn(function()
						robloxEnv._set(7)
						task.wait(0.1)
						local ran = pcall(function()
							load("return true")()
						end)
						escaped = ran
					end)

					hookmetamethod(game, "__index", old)
					return old(instance, key)
				end)

				task.wait(0.3)
				return escaped
			end)

			if not success then
				return result.ambiguous("Identity escalation probe errored", tostring(escalated))
			end

			if escalated then
				return result.vulnerable("Executor context escaped through a metamethod hook")
			end

			return result.secured("Metamethod hook did not escape executor context")
		end,
	}
end

local function parentTraversalCheck(vector)
	return {
		id = `escapes.parent.{vector.id}`,
		name = vector.name,
		category = "Parent Traversal Escapes",
		run = function()
			local success, root = pcall(vector.getter)
			if not success then
				return result.secured("Getter was rejected")
			end

			if root == nil then
				return result.secured("Getter returned nil")
			end

			local opened = pcall(function()
				return root:OpenScreenshotsFolder()
			end)

			if opened then
				return result.vulnerable("Vector reached the DataModel and executed a blocked method")
			end

			return result.secured("Vector did not execute a blocked DataModel method")
		end,
	}
end

return function()
	local checks = {
		test(),
	}

	for _, vector in ipairs(parentVectors) do
		table.insert(checks, parentTraversalCheck(vector))
	end

	return checks
end
