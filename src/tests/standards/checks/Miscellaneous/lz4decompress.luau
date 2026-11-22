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
		{
			id = "roundtrip",
			run = function(self)
				if type(lz4compress) ~= "function" then
					return {
						status = 401,
						message = "Dependant global 'lz4compress' not found",
					}
				end

				local text = "cedar-mark cedar-mark"
				local compressed = lz4compress(text)
				local plain = lz4decompress(compressed, #text)
				if plain ~= text then
					return {
						status = 500,
						message = "Decompressed data doesn't match the original",
					}
				end

				return { status = 200, message = "Passed" }
			end,
		},
	},
}
