--!nocheck
--!nolint

return {
	global = "getscriptbytecode",
	aliases = {
		"dumpstring",
	},
	cases = {
		{
			id = "sigma",
			run = function(self)
				local cryptReference = require("@dependencies/crypt/crypt.luau")

				--// Functionality test
				local originalScript = game.Players.LocalPlayer.Character.Character:FindFirstChild("whysoud")
				local bytecode = getscriptbytecode(originalScript)
				self._bytecode = bytecode

				if not bytecode:find("sigma") then
					return {
						status = 500,
						message = "Didn't find an expected segment in the bytecode",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "task",
			run = function(self)
				if type(self._bytecode) ~= "string" then
					return {
						status = 200,
						message = `Passed`,
					}
				end

				if not self._bytecode:find("task") then
					return {
						status = 500,
						message = "Didn't find an expected segment in the bytecode",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "wait",
			run = function(self)
				if type(self._bytecode) ~= "string" then
					return {
						status = 200,
						message = `Passed`,
					}
				end

				if not self._bytecode:find("wait") then
					return {
						status = 500,
						message = "Didn't find an expected segment in the bytecode",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "drop",
			run = function(self)
				if type(self._bytecode) ~= "string" then
					return {
						status = 200,
						message = `Passed`,
					}
				end

				if
					not self._bytecode:find(
						"GOT A DROP ON THIS FLEXING FELLA<MYRIAD_UD_MAX_UD_NEVER_SPEAK_TO_ME_AGAIN_KING_VON_IS_A_SAINT"
					)
				then
					return {
						status = 500,
						message = "Didn't find an expected segment in the bytecode",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "tostring",
			run = function(self)
				if type(self._bytecode) ~= "string" then
					return {
						status = 200,
						message = `Passed`,
					}
				end

				if not self._bytecode:find("tostring") then
					return {
						status = 500,
						message = "Didn't find an expected segment in the bytecode",
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
