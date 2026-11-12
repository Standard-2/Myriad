--!nocheck
--!nolint

return {
	global = "lz4compress",
	aliases = {
		"crypt.lz4compress",
	},
	cases = {
		{
			id = "type",
			run = function(self)
				local referenceCrypt = require("@dependencies/crypt/crypt.luau")
				local plaintext = "MYRIAD"
				local referenceCompressed = referenceCrypt.base64decode("YE1ZUklBRA==")
				local compressed = lz4compress(plaintext)
				self._compressed = compressed
				self._reference = referenceCompressed
				self._ready = true

				if typeof(compressed) ~= "string" then
					return {
						status = 500,
						message = "Did not return the expected type",
					}
				end

				return { status = 200, message = "Passed" }
			end,
		},
		{
			id = "match",
			run = function(self)
				if not self._ready then
					return { status = 200, message = "Passed" }
				end

				if self._compressed ~= self._reference then
					return {
						status = 500,
						message = "Compressed data doesn't match reference data",
					}
				end

				return { status = 200, message = "Passed" }
			end,
		},
	},
}
