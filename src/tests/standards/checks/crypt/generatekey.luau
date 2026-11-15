--!nocheck
--!nolint

return {
	global = "crypt.generatekey",
	cases = {
		{
			id = "type",
			run = function(self)
				local referenceCrypt = require("@dependencies/crypt/crypt.luau")
				local key1 = referenceCrypt.base64decode(crypt.generatekey())
				local key2 = referenceCrypt.base64decode(crypt.generatekey())
				self._key2 = key2
				if type(key1) == "string" then
					self._key1 = key1
				end

				if type(key1) ~= "string" then
					return {
						status = 500,
						message = "Generated key doesn't form a string",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "length",
			run = function(self)
				if type(self._key1) ~= "string" then
					return { status = 200, message = "Passed" }
				end

				local key1 = self._key1
				if #key1 ~= 32 then
					return {
						status = 500,
						message = "Key dosen't match the expected length",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "unique",
			run = function(self)
				if type(self._key1) ~= "string" then
					return { status = 200, message = "Passed" }
				end

				local key1 = self._key1
				local key2 = self._key2
				if key1 == key2 then
					return {
						status = 500,
						message = "Keys aren't unique",
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
