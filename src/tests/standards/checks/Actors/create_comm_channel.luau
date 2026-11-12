--!nocheck
--!nolint

return {
	global = "create_comm_channel",
	dependencies = {
		globals = {
			{ name = "run_on_actor", message = "Dependency 'run_on_actor' not found" },
			{ name = "get_comm_channel", message = "Dependency 'get_comm_channel' not found" },
		},
	},
	cases = {
		{
			id = "actor",
			run = function(self)
				--// Functionality test
				local gameRefs = require("@gameRefs")
				local actor = gameRefs.PMOVON

				if not actor then
					return {
						status = 500,
						message = "Failed to find actor",
					}
				end

				self._actor = actor
				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "event",
			run = function(self)
				if self._actor == nil then
					return { status = 200, message = "Passed" }
				end

				local comm_id, eventObject = create_comm_channel()
				if not eventObject then
					return {
						status = 500,
						message = `EventObject dosen't exist`,
					}
				end

				self._commId = comm_id
				self._event = eventObject
				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "id",
			run = function(self)
				if self._event == nil then
					return { status = 200, message = "Passed" }
				end

				local comm_id = self._commId
				if type(comm_id) ~= "number" or math.floor(comm_id) ~= comm_id then
					return {
						status = 500,
						message = "Communication ID isn't a int number",
					}
				end

				self._idOk = true
				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "event-prop",
			run = function(self)
				if self._event == nil then
					return { status = 200, message = "Passed" }
				end

				if not self._event.Event then
					return {
						status = 500,
						message = "EventObject has no .Event property",
					}
				end

				self._hasEvent = true
				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "fire",
			run = function(self)
				if self._event == nil then
					return { status = 200, message = "Passed" }
				end

				if type(self._event.Fire) ~= "function" then
					return {
						status = 500,
						message = "EventObject has no .Fire Function",
					}
				end

				self._fireOk = true
				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "same",
			run = function(self)
				if self._event == nil or not self._idOk then
					return { status = 200, message = "Passed" }
				end

				if get_comm_channel(self._commId) ~= self._event then
					return {
						status = 500,
						message = "It was possible to create it, but get_comm_channel does not return the same EventObject",
					}
				end

				self._same = true
				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "methods",
			run = function(self)
				if not self._hasEvent then
					return { status = 200, message = "Passed" }
				end

				local signalMethods = { "Connect", "Once", "Wait" }

				for _, method in signalMethods do
					if not self._event.Event[method] then
						return {
							status = 500,
							message = `.Event does not contain the {method} method`,
						}
					end
				end

				self._methods = true
				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "once",
			run = function(self)
				if
					self._actor == nil
					or self._event == nil
					or not self._idOk
					or not self._fireOk
					or not self._same
					or not self._methods
				then
					return { status = 200, message = "Passed" }
				end

				local comm_id = self._commId
				local eventObject = self._event
				local randomString = ""
				for _ = 1, 8 do
					randomString ..= string.char(math.random(48, 90))
				end

				local onceReceivedArgs, waitReceivedArgs
				task.spawn(function()
					waitReceivedArgs = table.pack(eventObject.Event:Wait())
				end)

				eventObject.Event:Once(function(...)
					onceReceivedArgs = table.pack(...)
				end)

				run_on_actor(self._actor, [[
		local channel = get_comm_channel(]] .. comm_id .. [[)
		channel:Fire("]] .. randomString .. [[", game, nil)
	]])

				task.wait(0.1)

				self._onceArgs = onceReceivedArgs
				self._waitArgs = waitReceivedArgs
				self._token = randomString
				self._dispatched = true

				if type(onceReceivedArgs) ~= "table" then
					return {
						status = 500,
						message = "EventObject did not run an :Once",
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
				if not self._dispatched then
					return { status = 200, message = "Passed" }
				end

				if type(self._waitArgs) ~= "table" then
					return {
						status = 500,
						message = "EventObject did not run an :Wait",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "once-values",
			run = function(self)
				if type(self._onceArgs) ~= "table" then
					return { status = 200, message = "Passed" }
				end

				if self._onceArgs[1] ~= self._token or not self._onceArgs[2] then
					return {
						status = 500,
						message = "The :Once was executed but returned unexpected values",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "once-xref",
			run = function(self)
				if type(self._onceArgs) ~= "table" then
					return { status = 200, message = "Passed" }
				end
				if self._onceArgs[1] ~= self._token or not self._onceArgs[2] then
					return { status = 200, message = "Passed" }
				end

				if self._onceArgs[2] ~= game then
					return {
						status = 500,
						message = "The :Once was executed, but the xrefs wasn't transformed to their value in the Original State",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "once-args",
			run = function(self)
				if type(self._onceArgs) ~= "table" then
					return { status = 200, message = "Passed" }
				end
				if self._onceArgs[1] ~= self._token or not self._onceArgs[2] then
					return { status = 200, message = "Passed" }
				end
				if self._onceArgs[2] ~= game then
					return { status = 200, message = "Passed" }
				end

				if self._onceArgs[3] ~= nil or self._onceArgs.n ~= 3 then
					return {
						status = 500,
						message = `Does not provide all args in an :Once`,
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "wait-values",
			run = function(self)
				if type(self._waitArgs) ~= "table" then
					return { status = 200, message = "Passed" }
				end

				if self._waitArgs[1] ~= self._token or not self._waitArgs[2] then
					return {
						status = 500,
						message = "The :Wait was executed but returned unexpected values",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "wait-xref",
			run = function(self)
				if type(self._waitArgs) ~= "table" then
					return { status = 200, message = "Passed" }
				end
				if self._waitArgs[1] ~= self._token or not self._waitArgs[2] then
					return { status = 200, message = "Passed" }
				end

				if self._waitArgs[2] ~= game then
					return {
						status = 500,
						message = "The :Wait was executed, but the xrefs wasn't transformed to their value in the Original State",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "wait-args",
			run = function(self)
				if type(self._waitArgs) ~= "table" then
					return { status = 200, message = "Passed" }
				end
				if self._waitArgs[1] ~= self._token or not self._waitArgs[2] then
					return { status = 200, message = "Passed" }
				end
				if self._waitArgs[2] ~= game then
					return { status = 200, message = "Passed" }
				end

				if self._waitArgs[3] ~= nil or self._waitArgs.n ~= 3 then
					return {
						status = 500,
						message = `Does not provide all args in an :Wait`,
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
