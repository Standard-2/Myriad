--!nocheck
--!nolint

--// Private Methods
local function compile(chunkName, source)
	if type(loadstring) ~= "function" then
		return nil
	end

	local compiled = loadstring(source, chunkName)
	if type(compiled) ~= "function" then
		return nil
	end

	return compiled()
end

--// Publish
return {
	global = "debug.getinfo",
	dependencies = {
		globals = {
			"loadstring"
		},
	},
	aliases = {
		"getinfo",
	},
	cases = {
		{
			id = "read",
			run = function(self)
				local sample = compile(
					"=lane-info",
					[[
					local function sample(left, right)
						return left .. "-" .. right
					end

					return sample
				]]
				)
				if type(sample) ~= "function" then
					return {
						status = 500,
						message = "Failed to compile test function with loadstring",
					}
				end

				local info = debug.getinfo(sample)
				if type(info) ~= "table" then
					return {
						status = 500,
						message = "debug.getinfo did not return a table",
					}
				end

				self._info = info
				if type(info.source) ~= "string" or string.find(info.source, "lane-info", 1, true) == nil then
					return {
						status = 500,
						message = "source did not name the compiled chunk",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "call",
			run = function(self)
				if type(self._info) ~= "table" then
					return { status = 200, message = `Passed` }
				end

				local fn = self._info.func
				if type(fn) ~= "function" then
					return {
						status = 500,
						message = "func was not a function",
					}
				end

				local ok, value = pcall(fn, "kel", "p")
				if not ok or value ~= "kel-p" then
					return {
						status = 500,
						message = "Returned function did not join its arguments",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "params",
			run = function(self)
				if type(self._info) ~= "table" then
					return { status = 200, message = `Passed` }
				end

				local empty = compile(
					"=lane-empty",
					[[
					local function sample()
						return true
					end

					return sample
				]]
				)
				if type(empty) ~= "function" then
					return {
						status = 500,
						message = "Failed to compile test function with loadstring",
					}
				end

				local emptyInfo = debug.getinfo(empty)
				if type(emptyInfo) ~= "table" then
					return {
						status = 500,
						message = "debug.getinfo did not return a table",
					}
				end

				local wide = self._info.numparams
				local narrow = emptyInfo.numparams
				if type(wide) ~= "number" or type(narrow) ~= "number" or wide <= narrow then
					return {
						status = 500,
						message = "Parameter count did not follow the function",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "upvalues",
			run = function(self)
				local closer, plain = compile(
					"=pebble-count",
					[[
					local tally = 4
					local function closer()
						tally += 3
						return tally
					end
					local function plain()
						return 11
					end
					return closer, plain
				]]
				)
				if type(closer) ~= "function" or type(plain) ~= "function" then
					return {
						status = 500,
						message = "Failed to compile test function with loadstring",
					}
				end

				local rich = debug.getinfo(closer)
				local bare = debug.getinfo(plain)
				if type(rich) ~= "table" or type(bare) ~= "table" then
					return {
						status = 500,
						message = "debug.getinfo did not return a table",
					}
				end

				if type(rich.nups) ~= "number" or type(bare.nups) ~= "number" or rich.nups <= bare.nups then
					return {
						status = 500,
						message = "Upvalue count did not follow the closure",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
	},
}
