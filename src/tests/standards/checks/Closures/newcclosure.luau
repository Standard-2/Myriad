--!nocheck
--!nolint

return {
	global = "newcclosure",
	cases = {
		{
			id = "original-line",
			run = function(self)
				local originalFunction = function(...)
					local startTick = tick()
					local elapsedTick = task.wait(0.05)

					if tick() - startTick < 0.025 or elapsedTick < 0.025 then
						return "TICK_ERROR"
					end

					return select("#", ...), ...
				end

				local cFunction = newcclosure(originalFunction, "MYR1AD")
				self._originalFunction = originalFunction
				self._cFunction = cFunction

				if debug.info(originalFunction, "l") == -1 then
					return {
						status = 500,
						message = "The original function was also made C closure (line check)",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "c-line",
			run = function(self)
				if self._cFunction == nil then
					return { status = 200, message = "Passed" }
				end

				if debug.info(self._cFunction, "l") ~= -1 then
					return {
						status = 500,
						message = "The new C closure is not C (line check)",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "name",
			run = function(self)
				if self._cFunction == nil then
					return { status = 200, message = "Passed" }
				end

				if debug.info(self._cFunction, "n") ~= "MYR1AD" then
					return {
						status = 500,
						message = "C closure have a different name",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "error",
			run = function(self)
				local cFunction = self._cFunction
				if cFunction == nil then
					return { status = 200, message = "Passed" }
				end

				local failure = nil
				for i = 1, 5 do
					local startTick = tick()
					local nilsCount = math.random(3, 10)
					local result = table.pack(pcall(cFunction, i, unpack({}, 1, nilsCount)))

					if not result[1] then
						self._callsDone = true
						self._callFailure = {
							kind = "error",
						}
						return {
							status = 500,
							message = `C closure gave the error: {result[2]}`,
						}
					elseif tick() - startTick < 0.025 then
						failure = {
							kind = "yield",
						}
						break
					end

					table.move(result, 2, result.n, 1)
					result.n -= 1

					if result[1] == "TICK_ERROR" or result[1] == nil then
						failure = {
							kind = "omit",
						}
						break
					elseif result[1] ~= nilsCount + 1 then
						failure = {
							kind = "args",
						}
						break
					elseif result[2] ~= i then
						failure = {
							kind = "value",
						}
						break
					else
						local argsCount = nilsCount + 2
						local validNils = true

						for i = 3, nilsCount do
							if result[i] ~= nil then
								validNils = false
								break
							end
						end

						if result.n ~= argsCount or not validNils then
							print(result.n, nilsCount)

							failure = {
								kind = "returns",
							}
							break
						end
					end
				end

				self._callsDone = true
				self._callFailure = failure

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "yield",
			run = function(self)
				if not self._callsDone then
					return { status = 200, message = "Passed" }
				end

				if self._callFailure ~= nil and self._callFailure.kind == "yield" then
					return {
						status = 500,
						message = "C closure is not yielding",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "omit",
			run = function(self)
				if not self._callsDone then
					return { status = 200, message = "Passed" }
				end

				if self._callFailure ~= nil and self._callFailure.kind == "omit" then
					return {
						status = 500,
						message = "C closure omits the yields",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "args",
			run = function(self)
				if not self._callsDone then
					return { status = 200, message = "Passed" }
				end

				if self._callFailure ~= nil and self._callFailure.kind == "args" then
					return {
						status = 500,
						message = "C closure is cutting arguments",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "value",
			run = function(self)
				if not self._callsDone then
					return { status = 200, message = "Passed" }
				end

				if self._callFailure ~= nil and self._callFailure.kind == "value" then
					return {
						status = 500,
						message = "C closure did not return the expected value",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "returns",
			run = function(self)
				if not self._callsDone then
					return { status = 200, message = "Passed" }
				end

				if self._callFailure ~= nil and self._callFailure.kind == "returns" then
					return {
						status = 500,
						message = "C closure is cutting returns",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "overflow",
			run = function(self)
				if self._cFunction == nil or not self._callsDone or self._callFailure ~= nil then
					return { status = 200, message = "Passed" }
				end

				local wrapped = self._cFunction
				for i = 1, 198 do
					wrapped = coroutine.wrap(wrapped)
				end

				if not pcall(wrapped) then
					-- Many executors omit this protection. Native C functions can be wrapped 198 times without errors
					return {
						status = 500,
						message = "C closure stack overflow",
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
