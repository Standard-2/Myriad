--!nocheck
--!nolint

return {
	cases = {
		{
			id = "global",
			run = function(self)
				if type(Signal) ~= "table" then
					return {
						status = 400,
						message = "Global not found",
					}
				end

				self._table = true

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		-- Signal.new
		{
			id = "new",
			run = function(self)
				if not self._table then
					return {
						status = 200,
						message = "Passed",
					}
				end

				if type(Signal.new) ~= "function" then
					return {
						status = 400,
						message = "Signal.new is not a function",
					}
				end

				self._new = true

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "construct",
			run = function(self)
				if not self._new then
					return {
						status = 200,
						message = "Passed",
					}
				end

				local success, sig = pcall(function()
					return Signal.new()
				end)

				if not success or (type(sig) ~= "table" and type(sig) ~= "userdata") then
					return {
						status = 500,
						message = "No valid Signal object was created by Signal.new()",
					}
				end

				self._sig = sig

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		-- Signal properties
		{
			id = "method-connect",
			run = function(self)
				if not self._sig then
					return {
						status = 200,
						message = "Passed",
					}
				end

				local method = "Connect"
				local sig = self._sig
				local ok, val = pcall(function()
					return sig[method]
				end)
				if not ok or type(val) ~= "function" then
					return {
						status = 500,
						message = `Signal object is missing method: {method}`,
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "method-once",
			run = function(self)
				if not self._sig then
					return {
						status = 200,
						message = "Passed",
					}
				end

				local method = "Once"
				local sig = self._sig
				local ok, val = pcall(function()
					return sig[method]
				end)
				if not ok or type(val) ~= "function" then
					return {
						status = 500,
						message = `Signal object is missing method: {method}`,
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "method-wait",
			run = function(self)
				if not self._sig then
					return {
						status = 200,
						message = "Passed",
					}
				end

				local method = "Wait"
				local sig = self._sig
				local ok, val = pcall(function()
					return sig[method]
				end)
				if not ok or type(val) ~= "function" then
					return {
						status = 500,
						message = `Signal object is missing method: {method}`,
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "method-fire",
			run = function(self)
				if not self._sig then
					return {
						status = 200,
						message = "Passed",
					}
				end

				local method = "Fire"
				local sig = self._sig
				local ok, val = pcall(function()
					return sig[method]
				end)
				if not ok or type(val) ~= "function" then
					return {
						status = 500,
						message = `Signal object is missing method: {method}`,
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		-- Connect and Fire
		{
			id = "connect-fire",
			run = function(self)
				if not self._sig then
					return {
						status = 200,
						message = "Passed",
					}
				end

				local sig = self._sig
				self._fired = false
				self._firedArgs = nil
				local conn
				local ok, err = pcall(function()
					conn = sig:Connect(function(...)
						self._fired = true
						self._firedArgs = { ... }
					end)
					sig:Fire("test1", 123)
				end)
				self._conn = conn

				if not ok then
					return {
						status = 500,
						message = `Error while testing Connect/Fire: {err}`,
					}
				end

				self._connectRan = true

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "fired",
			run = function(self)
				if not self._connectRan then
					return {
						status = 200,
						message = "Passed",
					}
				end

				if not self._fired then
					return {
						status = 500,
						message = "Signal:Connect handler was not called when Signal:Fire was executed",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "arguments",
			run = function(self)
				if not self._connectRan or not self._fired then
					return {
						status = 200,
						message = "Passed",
					}
				end

				local firedArgs = self._firedArgs
				if not firedArgs or type(firedArgs) ~= "table" or firedArgs[1] ~= "test1" or firedArgs[2] ~= 123 then
					return {
						status = 500,
						message = "Signal:Fire did not pass correct arguments to Signal:Connect handler",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		-- Connection
		{
			id = "connection",
			run = function(self)
				if not self._connectRan then
					return {
						status = 200,
						message = "Passed",
					}
				end

				local conn = self._conn
				if type(conn) ~= "table" and type(conn) ~= "userdata" then
					return {
						status = 500,
						message = "Signal:Connect did not return a Connection object",
					}
				end

				self._connection = true

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "disconnect-method",
			run = function(self)
				if not self._connection then
					return {
						status = 200,
						message = "Passed",
					}
				end

				local conn = self._conn
				local okDisc, valDisc = pcall(function()
					return conn.Disconnect
				end)

				if not okDisc or type(valDisc) ~= "function" then
					return {
						status = 500,
						message = "Connection object is missing method: Disconnect",
					}
				end

				self._canDisconnect = true

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		-- Disconnect
		{
			id = "disconnect",
			run = function(self)
				if not self._canDisconnect then
					return {
						status = 200,
						message = "Passed",
					}
				end

				local conn = self._conn
				local disconnectOk, disconnectErr = pcall(function()
					conn:Disconnect()
				end)

				if not disconnectOk then
					return {
						status = 500,
						message = `Error while calling Connection:Disconnect - {disconnectErr}`,
					}
				end

				self._disconnected = true

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "disconnected",
			run = function(self)
				if not self._disconnected then
					return {
						status = 200,
						message = "Passed",
					}
				end

				self._fired = false
				self._sig:Fire("test2")
				if self._fired then
					return {
						status = 500,
						message = "Signal handler was called after Connection:Disconnect",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		-- Once
		{
			id = "once",
			run = function(self)
				if not self._sig then
					return {
						status = 200,
						message = "Passed",
					}
				end

				local sig = self._sig
				self._onceFiredCount = 0
				local onceConn
				local okOnce, errOnce = pcall(function()
					onceConn = sig:Once(function()
						self._onceFiredCount += 1
					end)
					sig:Fire()
					sig:Fire()
				end)
				self._onceConn = onceConn

				if not okOnce then
					return {
						status = 500,
						message = `Error while testing Signal:Once - {errOnce}`,
					}
				end

				self._onceRan = true

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "once-count",
			run = function(self)
				if not self._onceRan then
					return {
						status = 200,
						message = "Passed",
					}
				end

				local onceFiredCount = self._onceFiredCount
				if onceFiredCount ~= 1 then
					return {
						status = 500,
						message = `Signal:Once handler fired {onceFiredCount} times, expected 1`,
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "once-connection",
			run = function(self)
				if not self._onceRan then
					return {
						status = 200,
						message = "Passed",
					}
				end

				local onceConn = self._onceConn
				if type(onceConn) ~= "table" and type(onceConn) ~= "userdata" then
					return {
						status = 500,
						message = "Signal:Once did not return a Connection object",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "wait",
			run = function(self)
				if not self._sig then
					return {
						status = 200,
						message = "Passed",
					}
				end

				local sig = self._sig
				local waitWorked = false
				local waitArgs = nil
				local waitErr

				task.spawn(function()
					task.wait(0.05)
					sig:Fire("wait1", "wait2")
				end)

				local successWait, a, b = pcall(function()
					return sig:Wait()
				end)

				if successWait then
					waitWorked = true
					waitArgs = { a, b }
				else
					waitErr = a
				end

				self._waitWorked = waitWorked
				self._waitArgs = waitArgs
				self._waitErr = waitErr
				self._waitDone = true

				if waitErr then
					return {
						status = 500,
						message = `Error calling Signal:Wait - {waitErr}`,
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "wait-resume",
			run = function(self)
				if not self._waitDone or self._waitErr then
					return {
						status = 200,
						message = "Passed",
					}
				end

				if not self._waitWorked then
					return {
						status = 500,
						message = "Signal:Wait did not resume after Signal:Fire",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "wait-arguments",
			run = function(self)
				if not self._waitWorked then
					return {
						status = 200,
						message = "Passed",
					}
				end

				local waitArgs = self._waitArgs
				if not waitArgs or waitArgs[1] ~= "wait1" or waitArgs[2] ~= "wait2" then
					return {
						status = 500,
						message = "Signal:Wait did not return the correct arguments from Signal:Fire",
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
