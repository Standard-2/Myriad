--!nocheck
--!nolint

return {
	global = "crypt.decrypt",
	cases = {
		{
			id = "call",
			run = function(self)
				local referenceCrypt = require("@dependencies/crypt/crypt.luau")
				local data = "jxF03fu7V3WKm7b2oRMo9HYz+KVDymqKU29qmsiTP4E="
				local key = referenceCrypt.base64encode("GMVIsgHnxm0YDYwUGkBhtRWSrSsfRMjY")
				local iv = referenceCrypt.base64encode("1234567890abcdef")
				local mode = "CBC"

				local decryptSuccess, cryptDecrypted = pcall(function()
					return crypt.decrypt(data, key, iv, mode)
				end)

				if decryptSuccess then
					self._called = true
					self._decrypted = cryptDecrypted
				end

				if not decryptSuccess then
					return {
						status = 0,
						message = "Decrypt failed: " .. tostring(cryptDecrypted),
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "result",
			run = function(self)
				if not self._called then
					return { status = 200, message = "Passed" }
				end

				local cryptDecrypted = self._decrypted
				if not cryptDecrypted then
					return {
						status = 500,
						message = "Decrypt returned nothing",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "match",
			run = function(self)
				if not self._called or not self._decrypted then
					return { status = 200, message = "Passed" }
				end

				local cryptDecrypted = self._decrypted
				if cryptDecrypted ~= "1234567890abcdef" then
					return {
						status = 500,
						message = "Decrypted data doesn't match reference data",
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
