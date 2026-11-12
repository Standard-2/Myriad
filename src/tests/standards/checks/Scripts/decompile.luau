--!nocheck
--!nolint

return {
	cases = {
		{
			id = "decomp target",
			run = function(self)
				local gameRefs = require("@gameRefs")
				local indexedDcmpScript, dcmp = pcall(function()
					return gameRefs.decompTarget
				end)

				if not indexedDcmpScript then
					return {
						status = 401,
						message = "Testing dependency 'ReplicatedFirst.decompTarget' not found.",
					}
				end

				self._scriptOk = true
				self._script = dcmp
				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "global",
			run = function(self)
				if not decompile then
					return {
						status = 400,
						message = "Global not found",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "string",
			run = function(self)
				if not self._scriptOk or not decompile then
					return {
						status = 200,
						message = "Passed",
					}
				end

				local dcmpDecompiled = decompile(self._script)
				if typeof(dcmpDecompiled) ~= "string" then
					return {
						status = 500,
						message = "Decompiled script isn't a string",
					}
				end

				self._source = dcmpDecompiled
				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "empty",
			run = function(self)
				if typeof(self._source) ~= "string" then
					return {
						status = 200,
						message = "Passed",
					}
				end

				if #self._source <= 0 then
					return {
						status = 500,
						message = "Decompiled script didn't return anything",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "patterns",
			run = function(self)
				if typeof(self._source) ~= "string" or #self._source <= 0 then
					return {
						status = 200,
						message = "Passed",
					}
				end

				--// Functionality test
				local function checkPatterns(source, patterns)
					local missing = {}
					for _, pattern in ipairs(patterns) do
						if not source:find(pattern, 1, true) then
							table.insert(missing, pattern)
						end
					end

					if #missing > 0 then
						return false, missing
					end

					return true
				end

				local passed, missing = checkPatterns(self._source, {
					"truthy",
					"falsey",
					"123",
					"456",
					"TableWeirdness",
					"func",
					"inline-fn",
					"loopFn",
					"nil-check",
					"true-check",
					"fallback",
					"setmetatable",
					"__index",
					"secret",
					"found",
					"MethodStyle",
				})

				if not passed then
					return {
						status = 500,
						message = "Decompiled script missing expected strings: " .. table.concat(missing, ", "),
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
