--!nocheck
--!nolint

return {
	global = "lz4decompress",
	aliases = {
		"crypt.lz4decompress",
	},
	cases = {
		{
			id = "type",
			run = function(self)
				local referenceCrypt = require("@dependencies/crypt/crypt.luau")
				local plaintext = "MYRIAD"
				local referenceCompressed = referenceCrypt.base64decode("YE1ZUklBRA==")
				local decompressed = lz4decompress(referenceCompressed, #plaintext)
				self._decompressed = decompressed
				self._plaintext = plaintext
				self._ready = true

				if typeof(decompressed) ~= "string" then
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

				if self._decompressed ~= self._plaintext then
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
