--!nocheck
--!nolint

return {
	global = "restorefunction",
	dependencies = {
		globals = {
			"hookfunction"
		},
	},
	aliases = {
		"restorefunc",
	},
	cases = {
		{
			id = "baseline",
			run = function(self)
				local function originalFunc1()
					return 1
				end

				local function1 = originalFunc1

				local function function2()
					return 2
				end

				if function1() ~= 1 then
					return {
						status = 500,
						message = "This should never evaluate. Did a cosmic ray hit your computer and flip a bit?",
					}
				end

				self._function1 = function1
				self._function2 = function2
				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "hook",
			run = function(self)
				if self._function1 == nil or self._function2 == nil then
					return { status = 200, message = "Passed" }
				end

				local original = hookfunction(self._function1, self._function2)
				self._original = original

				if self._function1() ~= 2 then
					return {
						status = 500,
						message = "Hooked function did not return the expected value",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "old",
			run = function(self)
				if self._original == nil then
					return { status = 200, message = "Passed" }
				end

				if self._original() ~= 1 then
					return {
						status = 500,
						message = "Old function did not return the expected value",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "restore",
			run = function(self)
				if self._function1 == nil or self._original == nil then
					return { status = 200, message = "Passed" }
				end

				restorefunction(self._function1)

				if self._function1() ~= 1 then
					hookfunction(self._function1, self._original)
					return {
						status = 500,
						message = "Restored function did not return the expected value",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "upvalues",
			run = function(self)
				local up1, up2 = {}, {}
				local function upvals()
					return up1
				end

				local function extraUpvals()
					return up1, up2
				end

				hookfunction(upvals, extraUpvals)
				restorefunction(upvals)

				if upvals() ~= up1 then
					return {
						status = 500,
						message = "Restored function did not restore upvalues",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "[L>C]",
			run = function()
				if type(clonefunction) ~= "function" then
					return {
						status = 401,
						message = "Dependant global 'clonefunction' not found",
					}
				end

				local function lane()
					return "lane"
				end

				local byteOf = clonefunction(string.byte)
				if byteOf("Z") ~= 90 then
					return {
						status = 500,
						message = "Cloned function did not return the expected value",
					}
				end

				local hooked, original = pcall(hookfunction, lane, byteOf)
				if not hooked then
					return {
						status = 500,
						message = `Failed to hook: {original}`,
					}
				elseif lane("Z") ~= 90 then
					hookfunction(lane, original)
					return {
						status = 500,
						message = "Hooked function did not return the expected value",
					}
				elseif original() ~= "lane" then
					hookfunction(lane, original)
					return {
						status = 500,
						message = "Old function did not return the expected value",
					}
				end

				local restored, restoreError = pcall(restorefunction, lane)
				if not restored then
					pcall(hookfunction, lane, original)
					return {
						status = 0,
						message = tostring(restoreError),
					}
				elseif lane() ~= "lane" then
					hookfunction(lane, original)
					return {
						status = 500,
						message = "Restored function did not return the expected value",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "[L>NC]",
			run = function()
				if type(newcclosure) ~= "function" then
					return {
						status = 401,
						message = "Dependant global 'newcclosure' not found",
					}
				end

				local function pebble()
					return "pebble"
				end

				local quartz = newcclosure(function()
					return "quartz"
				end)
				if type(quartz) ~= "function" or quartz() ~= "quartz" then
					return {
						status = 500,
						message = "newcclosure did not return the expected value",
					}
				end

				local hooked, original = pcall(hookfunction, pebble, quartz)
				if not hooked then
					return {
						status = 500,
						message = `Failed to hook: {original}`,
					}
				elseif pebble() ~= "quartz" then
					hookfunction(pebble, original)
					return {
						status = 500,
						message = "Hooked function did not return the expected value",
					}
				elseif original() ~= "pebble" then
					hookfunction(pebble, original)
					return {
						status = 500,
						message = "Old function did not return the expected value",
					}
				end

				local restored, restoreError = pcall(restorefunction, pebble)
				if not restored then
					pcall(hookfunction, pebble, original)
					return {
						status = 0,
						message = tostring(restoreError),
					}
				elseif pebble() ~= "pebble" then
					hookfunction(pebble, original)
					return {
						status = 500,
						message = "Restored function did not return the expected value",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "[C>L]",
			run = function()
				if type(clonefunction) ~= "function" then
					return {
						status = 401,
						message = "Dependant global 'clonefunction' not found",
					}
				end

				local absolute = clonefunction(math.abs)
				if absolute(-8) ~= 8 then
					return {
						status = 500,
						message = "Cloned function did not return the expected value",
					}
				end

				local function fixed()
					return -4
				end

				local hooked, original = pcall(hookfunction, absolute, fixed)
				if not hooked then
					return {
						status = 500,
						message = `Failed to hook: {original}`,
					}
				elseif absolute(-8) ~= -4 then
					hookfunction(absolute, original)
					return {
						status = 500,
						message = "Hooked function did not return the expected value",
					}
				elseif original(-8) ~= 8 then
					hookfunction(absolute, original)
					return {
						status = 500,
						message = "Old function did not return the expected value",
					}
				end

				local restored, restoreError = pcall(restorefunction, absolute)
				if not restored then
					pcall(hookfunction, absolute, original)
					return {
						status = 0,
						message = tostring(restoreError),
					}
				elseif absolute(-8) ~= 8 then
					hookfunction(absolute, original)
					return {
						status = 500,
						message = "Restored function did not return the expected value",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "[C>C]",
			run = function()
				if type(clonefunction) ~= "function" then
					return {
						status = 401,
						message = "Dependant global 'clonefunction' not found",
					}
				end

				local upper = clonefunction(string.upper)
				local lower = clonefunction(string.lower)
				if upper("KeLp") ~= "KELP" or lower("KeLp") ~= "kelp" then
					return {
						status = 500,
						message = "Cloned function did not return the expected value",
					}
				end

				local hooked, original = pcall(hookfunction, upper, lower)
				if not hooked then
					return {
						status = 500,
						message = `Failed to hook: {original}`,
					}
				elseif upper("KeLp") ~= "kelp" then
					hookfunction(upper, original)
					return {
						status = 500,
						message = "Hooked function did not return the expected value",
					}
				elseif original("KeLp") ~= "KELP" then
					hookfunction(upper, original)
					return {
						status = 500,
						message = "Old function did not return the expected value",
					}
				end

				local restored, restoreError = pcall(restorefunction, upper)
				if not restored then
					pcall(hookfunction, upper, original)
					return {
						status = 0,
						message = tostring(restoreError),
					}
				elseif upper("KeLp") ~= "KELP" then
					hookfunction(upper, original)
					return {
						status = 500,
						message = "Restored function did not return the expected value",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "[NC>NC]",
			run = function()
				if type(newcclosure) ~= "function" then
					return {
						status = 401,
						message = "Dependant global 'newcclosure' not found",
					}
				end

				local mica = newcclosure(function()
					return "mica"
				end)
				local brine = newcclosure(function()
					return "brine"
				end)
				if type(mica) ~= "function" or mica() ~= "mica" or type(brine) ~= "function" or brine() ~= "brine" then
					return {
						status = 500,
						message = "newcclosure did not return the expected value",
					}
				end

				local hooked, original = pcall(hookfunction, mica, brine)
				if not hooked then
					return {
						status = 500,
						message = `Failed to hook: {original}`,
					}
				elseif mica() ~= "brine" then
					hookfunction(mica, original)
					return {
						status = 500,
						message = "Hooked function did not return the expected value",
					}
				elseif original() ~= "mica" then
					hookfunction(mica, original)
					return {
						status = 500,
						message = "Old function did not return the expected value",
					}
				end

				local restored, restoreError = pcall(restorefunction, mica)
				if not restored then
					pcall(hookfunction, mica, original)
					return {
						status = 0,
						message = tostring(restoreError),
					}
				elseif mica() ~= "mica" then
					hookfunction(mica, original)
					return {
						status = 500,
						message = "Restored function did not return the expected value",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "layered",
			run = function()
				local function root()
					return "root"
				end

				local function mid()
					return "mid"
				end

				local function tip()
					return "tip"
				end

				local firstHook, firstOriginal = pcall(hookfunction, root, mid)
				if not firstHook then
					return {
						status = 500,
						message = `Failed to hook: {firstOriginal}`,
					}
				end

				local secondHook, secondOriginal = pcall(hookfunction, root, tip)
				if not secondHook then
					pcall(hookfunction, root, firstOriginal)
					return {
						status = 500,
						message = `Failed to hook: {secondOriginal}`,
					}
				elseif root() ~= "tip" then
					pcall(hookfunction, root, firstOriginal)
					return {
						status = 500,
						message = "Hooked function did not return the expected value",
					}
				end

				local restored, restoreError = pcall(restorefunction, root)
				if not restored then
					pcall(hookfunction, root, firstOriginal)
					return {
						status = 0,
						message = tostring(restoreError),
					}
				elseif root() ~= "root" then
					pcall(hookfunction, root, firstOriginal)
					return {
						status = 500,
						message = "Restored function did not return the first original",
					}
				elseif mid() ~= "mid" or tip() ~= "tip" then
					return {
						status = 500,
						message = "Restore changed a hook function",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "unhooked",
			run = function()
				local function fresh()
					return "fresh"
				end

				if pcall(restorefunction, fresh) then
					return {
						status = 500,
						message = "restorefunction did not error on a function that was never hooked",
					}
				elseif fresh() ~= "fresh" then
					return {
						status = 500,
						message = "Unhooked function changed after restorefunction errored",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
	},
}
