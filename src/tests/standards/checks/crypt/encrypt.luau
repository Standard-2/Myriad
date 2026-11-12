--!nocheck
--!nolint

return {
	global = "crypt.encrypt",
	cases = {
		{
			id = "call",
			run = function(self)
				local referenceCrypt = require("@dependencies/crypt/crypt.luau")
				local plaintext = "1234567890abcdef"
				local key = referenceCrypt.base64encode("GMVIsgHnxm0YDYwUGkBhtRWSrSsfRMjY")
				local iv = referenceCrypt.base64encode("1234567890abcdef")
				local mode = "CBC"

				local cryptSuccess, cryptEncrypted = pcall(function()
					return crypt.encrypt(plaintext, key, iv, mode)
				end)

				if cryptSuccess then
					self._called = true
					self._encrypted = cryptEncrypted
				end

				if not cryptSuccess then
					return {
						status = 0,
						message = "Encrypt failed: " .. tostring(cryptEncrypted),
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
				if not self._called then
					return { status = 200, message = "Passed" }
				end

				local assumed = self._encrypted
				local reference = "jxF03fu7V3WKm7b2oRMo9HYz+KVDymqKU29qmsiTP4E="
				if assumed ~= reference then
					return {
						status = 500,
						message = "Encrypted data doesn't match reference data",
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
