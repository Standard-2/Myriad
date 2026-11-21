--!nocheck
--!nolint

--// Private Methods
local function pass()
	return { status = 200, message = "Passed" }
end

local function restore(original)
	pcall(setthreadidentity, original)
end

local function checkType(ok, value)
	return ok and typeof(value) == "Instance"
end

--// Publish
return {
	global = "setthreadidentity",
	dependencies = {
		checks = {
			"Reflection.getthreadidentity",
		},
	},
	aliases = {
		"setidentity",
		"setthreadcontext",
	},
	cases = {
		{
			id = "[L:0]",
			run = function(self)
				local original = getthreadidentity()
				local ok, err = pcall(setthreadidentity, 0)
				if not ok then
					restore(original)
					return { status = 0, message = tostring(err) }
				end

				local current = getthreadidentity()
				restore(original)

				if current ~= 0 then
					return {
						status = 500,
						message = `Identity was {current} after setthreadidentity(0)`,
					}
				end

				return pass()
			end,
		},
		{
			id = "[L:2]",
			run = function(self)
				local original = getthreadidentity()
				local ok, err = pcall(setthreadidentity, 2)
				if not ok then
					restore(original)
					return { status = 0, message = tostring(err) }
				end

				local current = getthreadidentity()
				restore(original)

				if current ~= 2 then
					return {
						status = 500,
						message = `Identity was {current} after setthreadidentity(2)`,
					}
				end

				return pass()
			end,
		},
		{
			id = "[L:6]",
			run = function(self)
				local original = getthreadidentity()
				local ok, err = pcall(setthreadidentity, 6)
				if not ok then
					restore(original)
					return { status = 0, message = tostring(err) }
				end

				local current = getthreadidentity()
				restore(original)

				if current ~= 6 then
					return {
						status = 500,
						message = `Identity was {current} after setthreadidentity(6)`,
					}
				end

				return pass()
			end,
		},
		{
			id = "[L:8]",
			run = function(self)
				local original = getthreadidentity()
				local ok, err = pcall(setthreadidentity, 8)
				if not ok then
					restore(original)
					return { status = 0, message = tostring(err) }
				end

				local current = getthreadidentity()
				restore(original)

				if current ~= 8 then
					return {
						status = 500,
						message = `Identity was {current} after setthreadidentity(8)`,
					}
				end

				return pass()
			end,
		},
		{
			id = "[L:0] CoreGui",
			run = function(self)
				local original = getthreadidentity()

				local lowOk, lowErr = pcall(setthreadidentity, 0)
				if not lowOk then
					restore(original)
					return { status = 0, message = tostring(lowErr) }
				end
				local lowGuiOk, lowGui = pcall(function()
					return game:GetService("CoreGui")
				end)
				restore(original)

				if checkType(lowGuiOk, lowGui) then
					return {
						status = 500,
						message = "CoreGui was reachable at identity 0",
					}
				end

				return pass()
			end,
		},
		{
			id = "[L:2] CoreGui",
			run = function(self)
				local original = getthreadidentity()

				local lowOk, lowErr = pcall(setthreadidentity, 2)
				if not lowOk then
					restore(original)
					return { status = 0, message = tostring(lowErr) }
				end
				local lowGuiOk, lowGui = pcall(function()
					return game:GetService("CoreGui")
				end)
				restore(original)

				if checkType(lowGuiOk, lowGui) then
					return {
						status = 500,
						message = "CoreGui was reachable at identity 2",
					}
				end

				return pass()
			end,
		},
		{
			id = "[L:6] CoreGui",
			run = function(self)
				local original = getthreadidentity()

				local highOk, highErr = pcall(setthreadidentity, 6)
				if not highOk then
					restore(original)
					return { status = 0, message = tostring(highErr) }
				end
				local highGuiOk, highGui = pcall(function()
					return game:GetService("CoreGui")
				end)
				restore(original)

				if not checkType(highGuiOk, highGui) then
					return {
						status = 500,
						message = `CoreGui was not reachable at identity 6: {highGuiOk and tostring(highGui) or highGui}`,
					}
				end

				return pass()
			end,
		},
		{
			id = "[L:8] CoreGui",
			run = function(self)
				local original = getthreadidentity()

				local highOk, highErr = pcall(setthreadidentity, 8)
				if not highOk then
					restore(original)
					return { status = 0, message = tostring(highErr) }
				end
				local highGuiOk, highGui = pcall(function()
					return game:GetService("CoreGui")
				end)
				restore(original)

				if not checkType(highGuiOk, highGui) then
					return {
						status = 500,
						message = `CoreGui was not reachable at identity 8: {highGuiOk and tostring(highGui) or highGui}`,
					}
				end

				return pass()
			end,
		},
		{
			id = "[L:3] defer",
			run = function(self)
				local original = getthreadidentity()
				local child
				local childErr

				task.defer(function()
					local ok, err = pcall(function()
						setthreadidentity(2)
						child = getthreadidentity()
					end)
					pcall(setthreadidentity, original)
					if not ok then
						childErr = tostring(err)
					end
				end)

				local parentOk, parentErr = pcall(setthreadidentity, 3)
				if not parentOk then
					restore(original)
					return { status = 0, message = tostring(parentErr) }
				end

				local parent = getthreadidentity()
				for _ = 1, 20 do
					if child ~= nil or childErr ~= nil then
						break
					end
					task.wait()
				end
				restore(original)

				if childErr ~= nil then
					return { status = 0, message = childErr }
				end

				if parent ~= 3 then
					return {
						status = 500,
						message = `Identity was {parent} after setthreadidentity(3)`,
					}
				end

				if child ~= 2 then
					return {
						status = 500,
						message = `Deferred thread identity was {child} after setthreadidentity(2)`,
					}
				end

				return pass()
			end,
		},
		{
			id = "[L:2] yield",
			run = function(self)
				local original = getthreadidentity()
				local child
				local thread = coroutine.create(function()
					setthreadidentity(2)
					child = getthreadidentity()
					coroutine.yield()
					child = getthreadidentity()
					pcall(setthreadidentity, original)
				end)

				local resumed, resumeErr = coroutine.resume(thread)
				local parent = getthreadidentity()
				local during = child
				local resumedAgain, resumeErrAgain = true, nil
				if coroutine.status(thread) == "suspended" then
					resumedAgain, resumeErrAgain = coroutine.resume(thread)
				end
				local after = child
				restore(original)

				if not resumed then
					return { status = 0, message = tostring(resumeErr) }
				end

				if not resumedAgain then
					return { status = 0, message = tostring(resumeErrAgain) }
				end

				if parent ~= original then
					return {
						status = 500,
						message = `setthreadidentity(2) on another thread changed this thread to {parent}`,
					}
				end

				if during ~= 2 then
					return {
						status = 500,
						message = `Other thread identity was {during} after setthreadidentity(2)`,
					}
				end

				if after ~= 2 then
					return {
						status = 500,
						message = `Other thread identity was {after} after yielding`,
					}
				end

				return pass()
			end,
		},
	},
}
