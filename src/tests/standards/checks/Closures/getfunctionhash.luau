--!nocheck
--!nolint

return {
	global = "getfunctionhash",
	cases = {
		{
			id = "hex",
			run = function(self)
				local function hexEncoded(hash)
					return #hash == 96 and hash:match("^[0-9a-fA-F]+$") ~= nil
				end

				local function1 = function() end
				local function2 = function(...) end
				local function3 = function() end
				local function4 = function()
					return 1
				end
				local function5 = function()
					return 2
				end
				local cHashSuccess = pcall(function()
					getfunctionhash(print)
				end)

				self._function1 = function1
				self._function2 = function2
				self._function3 = function3
				self._function4 = function4
				self._function5 = function5
				self._cHashSuccess = cHashSuccess

				if not hexEncoded(getfunctionhash(function1)) then
					return {
						status = 500,
						message = "Hash is not hex encoded",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "unequal",
			run = function(self)
				if self._function1 == nil or self._function2 == nil then
					return { status = 200, message = "Passed" }
				end

				if getfunctionhash(self._function1) == getfunctionhash(self._function2) then
					return {
						status = 500,
						message = "Unequal functions returned equal hashes",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "equal",
			run = function(self)
				if self._function1 == nil or self._function3 == nil then
					return { status = 200, message = "Passed" }
				end

				if getfunctionhash(self._function1) ~= getfunctionhash(self._function3) then
					return {
						status = 500,
						message = "Equal functions returned unequal hashes",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "returns",
			run = function(self)
				if self._function4 == nil or self._function5 == nil then
					return { status = 200, message = "Passed" }
				end

				if getfunctionhash(self._function4) == getfunctionhash(self._function5) then
					return {
						status = 500,
						message = "Unequal returns gave equal returns",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "c",
			run = function(self)
				if self._cHashSuccess == nil then
					return { status = 200, message = "Passed" }
				end

				if self._cHashSuccess then
					return {
						status = 500,
						message = "Passed when given a lua standard C closure",
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
