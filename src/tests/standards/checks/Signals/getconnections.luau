--!nocheck
--!nolint

local function cleanup(self)
	if self._conn then
		self._conn:Disconnect()
	end
	self._conn = nil
	self._connObj = nil
end

local function checkProperty(self, prop)
	if not self._conn or not self._connObj then
		return {
			status = 200,
			message = "Passed",
		}
	end

	local connObj = self._connObj
	local ps, val = pcall(function()
		return connObj[prop]
	end)
	if not ps or val == nil then
		cleanup(self)
		return {
			status = 500,
			message = `ConnectionProxy missing property: {prop}`,
		}
	end

	return {
		status = 200,
		message = "Passed",
	}
end

return {
	global = "getconnections",
	type = "function",
	cases = {
		{
			id = "fetch",
			run = function(self)
				local Event = Instance.new("BindableEvent")

				self._called = false
				local function handler()
					self._called = true
				end

				self._handler = handler
				local conn = Event.Event:Connect(handler)

				self._event = Event
				self._conn = conn

				local s, connections = pcall(function()
					return getconnections(Event.Event)
				end)

				if not s then
					cleanup(self)
					return {
						status = 0,
						message = `Ambiguous error: {connections}`,
					}
				end

				self._connections = connections

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "type",
			run = function(self)
				if not self._conn then
					return {
						status = 200,
						message = "Passed",
					}
				end

				if type(self._connections) ~= "table" then
					cleanup(self)
					return {
						status = 500,
						message = "Return type is not a table",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "count",
			run = function(self)
				if not self._conn or type(self._connections) ~= "table" then
					return {
						status = 200,
						message = "Passed",
					}
				end

				local connections = self._connections
				if #connections ~= 1 then
					cleanup(self)
					return {
						status = 500,
						message = `Expected 1 connection but found {#connections}`,
					}
				end

				self._connObj = connections[1]

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		-- Properties
		{
			id = "prop-enabled",
			run = function(self)
				return checkProperty(self, "Enabled")
			end,
		},
		{
			id = "prop-foreign-state",
			run = function(self)
				return checkProperty(self, "ForeignState")
			end,
		},
		{
			id = "prop-lua-connection",
			run = function(self)
				return checkProperty(self, "LuaConnection")
			end,
		},
		{
			id = "prop-function",
			run = function(self)
				return checkProperty(self, "Function")
			end,
		},
		{
			id = "prop-thread",
			run = function(self)
				return checkProperty(self, "Thread")
			end,
		},
		{
			id = "prop-fire",
			run = function(self)
				return checkProperty(self, "Fire")
			end,
		},
		{
			id = "prop-defer",
			run = function(self)
				return checkProperty(self, "Defer")
			end,
		},
		{
			id = "prop-disconnect",
			run = function(self)
				return checkProperty(self, "Disconnect")
			end,
		},
		{
			id = "prop-disable",
			run = function(self)
				return checkProperty(self, "Disable")
			end,
		},
		{
			id = "prop-enable",
			run = function(self)
				return checkProperty(self, "Enable")
			end,
		},
		{
			id = "starts-enabled",
			run = function(self)
				if not self._conn or not self._connObj then
					return {
						status = 200,
						message = "Passed",
					}
				end

				if self._connObj.Enabled ~= true then
					cleanup(self)
					return {
						status = 500,
						message = "Enabled was not true for a new connection",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "lua",
			run = function(self)
				if not self._conn or not self._connObj then
					return {
						status = 200,
						message = "Passed",
					}
				end

				if self._connObj.LuaConnection ~= true then
					cleanup(self)
					return {
						status = 500,
						message = "LuaConnection was not true for a Luau connection",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "foreign",
			run = function(self)
				if not self._conn or not self._connObj then
					return {
						status = 200,
						message = "Passed",
					}
				end

				if self._connObj.ForeignState ~= false then
					cleanup(self)
					return {
						status = 500,
						message = "ForeignState was true for a connection created here",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "function",
			run = function(self)
				if not self._conn or not self._connObj or not self._handler then
					return {
						status = 200,
						message = "Passed",
					}
				end

				if self._connObj.Function ~= self._handler then
					cleanup(self)
					return {
						status = 500,
						message = "Function was not the connected callback",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "thread",
			run = function(self)
				if not self._conn or not self._connObj then
					return {
						status = 200,
						message = "Passed",
					}
				end

				if type(self._connObj.Thread) ~= "thread" then
					cleanup(self)
					return {
						status = 500,
						message = "Thread was not a thread",
					}
				end

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		-- ConnectionProxy
		{
			id = "fire",
			run = function(self)
				if not self._conn or not self._connObj then
					return {
						status = 200,
						message = "Passed",
					}
				end

				local connObj = self._connObj
				local fs, fe = pcall(function()
					connObj:Fire()
				end)

				task.wait()

				if not fs then
					cleanup(self)
					return {
						status = 500,
						message = `Errored calling ConnectionProxy:Fire() - {fe}`,
					}
				end

				self._fireRan = true

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "fired",
			run = function(self)
				if not self._fireRan or not self._conn then
					return {
						status = 200,
						message = "Passed",
					}
				end

				if not self._called then
					cleanup(self)
					return {
						status = 500,
						message = "Handler was not called when invoking ConnectionProxy:Fire()",
					}
				end

				self._called = false
				self._handlerSeen = true

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		-- Disable
		{
			id = "disable",
			run = function(self)
				if not self._handlerSeen or not self._conn then
					return {
						status = 200,
						message = "Passed",
					}
				end

				local connObj = self._connObj
				local ds, de = pcall(function()
					connObj:Disable()
				end)

				if not ds then
					cleanup(self)
					return {
						status = 500,
						message = `Errored calling ConnectionProxy:Disable() - {de}`,
					}
				end

				self._disableRan = true

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "disabled",
			run = function(self)
				if not self._disableRan or not self._conn then
					return {
						status = 200,
						message = "Passed",
					}
				end

				if self._connObj.Enabled ~= false then
					cleanup(self)
					return {
						status = 500,
						message = "Enabled property not set to false after calling Disable()",
					}
				end

				self._disabled = true

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "disabled-signal",
			run = function(self)
				if not self._disabled or not self._conn then
					return {
						status = 200,
						message = "Passed",
					}
				end

				self._event:Fire()
				task.wait()
				if self._called then
					cleanup(self)
					return {
						status = 500,
						message = "Handler was called after being disabled",
					}
				end

				self._silenceChecked = true

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		-- Enable
		{
			id = "enable",
			run = function(self)
				if not self._silenceChecked or not self._conn then
					return {
						status = 200,
						message = "Passed",
					}
				end

				local connObj = self._connObj
				local es, ee = pcall(function()
					connObj:Enable()
				end)

				if not es then
					cleanup(self)
					return {
						status = 500,
						message = `Errored calling ConnectionProxy:Enable() - {ee}`,
					}
				end

				self._enableRan = true

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "enabled",
			run = function(self)
				if not self._enableRan or not self._conn then
					return {
						status = 200,
						message = "Passed",
					}
				end

				if self._connObj.Enabled ~= true then
					cleanup(self)
					return {
						status = 500,
						message = "Enabled property not set to true after calling Enable()",
					}
				end

				self._enabled = true

				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "reenabled",
			run = function(self)
				if not self._enabled or not self._conn then
					return {
						status = 200,
						message = "Passed",
					}
				end

				self._event:Fire()
				task.wait()
				if not self._called then
					cleanup(self)
					return {
						status = 500,
						message = "Handler was not called after being re-enabled",
					}
				end

				self._reenabled = true

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
				if not self._reenabled or not self._conn or not self._connObj then
					return {
						status = 200,
						message = "Passed",
					}
				end

				local connObj = self._connObj
				local discs, disce = pcall(function()
					connObj:Disconnect()
				end)

				if not discs then
					return {
						status = 500,
						message = `Errored calling ConnectionProxy:Disconnect() - {disce}`,
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
				if not self._disconnected or not self._conn or not self._connObj then
					return {
						status = 200,
						message = "Passed",
					}
				end

				local connObj = self._connObj
				local conn = self._conn
				if connObj.Enabled ~= false and conn.Connected ~= false then
					return {
						status = 500,
						message = "Connection did not successfully disconnect when invoking ConnectionProxy:Disconnect()",
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
