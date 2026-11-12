--!nocheck
--!nolint

return {
	global = "crypt.base64encode",
	aliases = {
		"base64encode",
		"base64_encode",
		"crypt.base64.encode",
		"base64.encode",
		"crypt.base64_encode",
	},
	cases = {
		{
			id = "type",
			run = function(self)
				local referenceCrypt = require("@dependencies/crypt/crypt.luau")
				self._referenceCrypt = referenceCrypt
				self._plaintext = "MYRIAD"
				local encoded = crypt.base64encode(self._plaintext)
				if not encoded or typeof(encoded) ~= "string" then
					return {
						status = 500,
						message = "Did not return the expected type",
					}
				end

				self._encoded = encoded
				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "reference",
			run = function(self)
				if typeof(self._encoded) ~= "string" or self._referenceCrypt == nil then
					return { status = 200, message = "Passed" }
				end

				if self._encoded ~= self._referenceCrypt.base64encode(self._plaintext) then
					return {
						status = 500,
						message = "Encoded data doesn't match reference data",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "empty-type",
			run = function(self)
				local emptyEncoded = crypt.base64encode("")
				if not emptyEncoded or typeof(emptyEncoded) ~= "string" then
					return {
						status = 500,
						message = "Empty string encoding failed to return string",
					}
				end

				self._empty = emptyEncoded
				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "empty",
			run = function(self)
				if typeof(self._empty) ~= "string" then
					return { status = 200, message = "Passed" }
				end

				if self._empty ~= "" then
					return {
						status = 500,
						message = "Empty string encoding mismatch",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "padding",
			run = function(self)
				if typeof(self._encoded) ~= "string" then
					return { status = 200, message = "Passed" }
				end

				local encoded = self._encoded
				if #encoded % 4 ~= 0 then
					return {
						status = 500,
						message = "Encoded data length not multiple of 4, padding issue",
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
