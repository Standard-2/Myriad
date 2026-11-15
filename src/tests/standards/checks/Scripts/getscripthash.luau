--!nocheck
--!nolint

return {
	cases = {
		{
			id = "Animate",
			run = function(self)
				local indexed1, script1 = pcall(function()
					return game.Players.LocalPlayer.Character.Animate
				end)
				if not indexed1 then
					return {
						status = 401,
						message = "Testing dependency 'Character.Animate' not found.",
					}
				end

				self._animateOk = true
				self._animate = script1
				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "whysodtc",
			run = function(self)
				local indexed2, script2 = pcall(function()
					return game.Players.LocalPlayer.Character.Character.whysodtc
				end)
				if not indexed2 then
					return {
						status = 401,
						message = "Testing dependency 'Character.whysodtc' not found.",
					}
				end

				self._whysodtcOk = true
				self._whysodtc = script2
				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "global",
			run = function(self)
				if not getscripthash then
					return {
						status = 400,
						message = "Global not found",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "animate hash",
			run = function(self)
				if not self._animateOk or not getscripthash then
					return {
						status = 200,
						message = `Passed`,
					}
				end

				local script1 = self._animate
				local script1Success, script1Returned = pcall(function()
					return getscripthash(script1)
				end)
				self._hash1Ok = script1Success
				self._hash1 = script1Returned

				if not script1Success then
					return {
						status = 500,
						message = "Failed to get bytecode of 'Character.Animate': " .. tostring(script1Returned),
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "no bytecode",
			run = function(self)
				if not getscripthash then
					return {
						status = 200,
						message = `Passed`,
					}
				end

				local noBytecodeScript = Instance.new("LocalScript")
				local noBytecodeSuccess, noBytecodeReturned = pcall(function()
					return getscripthash(noBytecodeScript)
				end)
				self._noBytecodeOk = noBytecodeSuccess
				self._noBytecode = noBytecodeReturned

				if not noBytecodeSuccess then
					return {
						status = 500,
						message = "Failed to get script w/ no bytecode. Errored instead of returning nothing/nil.",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "whysodtc hash",
			run = function(self)
				if not self._whysodtcOk or not getscripthash then
					return {
						status = 200,
						message = `Passed`,
					}
				end

				local script2 = self._whysodtc
				local script2Success, script2Returned = pcall(function()
					return getscripthash(script2)
				end)
				self._hash2Ok = script2Success
				self._hash2 = script2Returned

				if not script2Success then
					return {
						status = 500,
						message = "Failed to get bytecode of 'Character.whysodtc': " .. tostring(script2Returned),
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "hash string",
			run = function(self)
				if not self._hash1Ok then
					return {
						status = 200,
						message = `Passed`,
					}
				end

				local script1Returned = self._hash1
				if typeof(script1Returned) ~= "string" then
					return {
						status = 500,
						message = "Did not return a hash string",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "empty bytecode",
			run = function(self)
				if not self._noBytecodeOk then
					return {
						status = 200,
						message = `Passed`,
					}
				end

				local noBytecodeReturned = self._noBytecode
				if noBytecodeReturned ~= nil then
					return {
						status = 500,
						message = "A script with no bytecode returned non-nil data",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "different hashes",
			run = function(self)
				if not self._hash1Ok or not self._hash2Ok or typeof(self._hash1) ~= "string" then
					return {
						status = 200,
						message = `Passed`,
					}
				end

				local script1Returned = self._hash1
				local script2Returned = self._hash2
				if script1Returned == script2Returned then
					return {
						status = 500,
						message = "Different scripts returned the same hash string",
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
