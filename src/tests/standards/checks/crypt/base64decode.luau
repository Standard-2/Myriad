--!nocheck
--!nolint

return {
	global = "crypt.base64decode",
	aliases = {
		"base64decode",
		"base64_decode",
		"crypt.base64.decode",
		"base64.decode",
		"crypt.base64_decode",
	},
	cases = {
		{
			id = "reference",
			run = function(self)
				local referenceCrypt = require("@dependencies/crypt/crypt.luau")
				self._plaintext = "MYRIAD"
				local reference = referenceCrypt.base64encode(self._plaintext)
				if not reference or typeof(reference) ~= "string" then
					return {
						status = 500,
						message = "Reference crypt failed",
					}
				end

				self._reference = reference
				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "type",
			run = function(self)
				if typeof(self._reference) ~= "string" then
					return { status = 200, message = "Passed" }
				end

				local decoded = crypt.base64decode(self._reference)
				if not decoded or typeof(decoded) ~= "string" then
					return {
						status = 500,
						message = "Did not return the expected type",
					}
				end

				self._decoded = decoded
				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "match",
			run = function(self)
				if typeof(self._decoded) ~= "string" then
					return { status = 200, message = "Passed" }
				end

				if self._decoded ~= self._plaintext then
					return {
						status = 500,
						message = "Decoded data doesn't match reference data",
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
				local emptyDecoded = crypt.base64decode("")
				if not emptyDecoded or typeof(emptyDecoded) ~= "string" then
					return {
						status = 500,
						message = "Empty string decode failed to return string",
					}
				end

				self._empty = emptyDecoded
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
						message = "Empty string decode mismatch",
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
