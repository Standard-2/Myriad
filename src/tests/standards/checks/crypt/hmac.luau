--!nocheck
--!nolint

return {
	global = "crypt.hmac",
	cases = {
		{
			id = "type",
			run = function(self)
				local referenceCrypt = require("@dependencies/crypt/crypt.luau")
				self._referenceCrypt = referenceCrypt

				local plaintext = "MYRIAD"
				local key = "secret_key"
				local algorithm = "sha256"
				local assumed = crypt.hmac(key, plaintext, algorithm)
				if assumed then
					self._assumed = assumed
				end

				if not assumed then
					return {
						status = 500,
						message = "Did not return the expected type",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "reference",
			run = function(self)
				if not self._assumed then
					return { status = 200, message = "Passed" }
				end

				local reference = "FaDPiTSLlbxRP5rKvomt0dzwl7zhszc46/QFPsZRGWY="
				local assumed = self._assumed
				if assumed ~= reference then
					return {
						status = 500,
						message = "Data doesn't match reference data",
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
