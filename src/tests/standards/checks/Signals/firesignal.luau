--!nocheck
--!nolint

local function passed()
	return {
		status = 200,
		message = "Passed",
	}
end

local function actorFailure(self, prefix, code, message)
	if type(self._actorResponse) ~= "string" then
		return passed()
	end

	local Prefix = prefix
	local Function = if prefix == "O" then ":Once" else ":Wait"
	if self._actorResponse == `ERROR_{Prefix}{code}` then
		return {
			status = 500,
			message = message(Function),
		}
	end

	return passed()
end

return {
	cases = {
		{
			id = "global",
			run = function(self)
				if type(firesignal) ~= "function" then
					return {
						status = 400,
						message = "Global not found",
					}
				end

				self._fn = true

				return passed()
			end,
		},
		{
			id = "fire",
			run = function(self)
				if not self._fn then
					return passed()
				end

				local NoChildsService = game:GetService("SocialService")
				local BindableEv = Instance.new("BindableEvent")
				BindableEv.Name = "MYRIAD_FIRESIGNAL"

				--[[
	
		> As you can see, we believe that firesignal should also influence Actors. THE REASON? 
		Traditional RBXScriptSignals affect the entire game, so executing them only in the 
		normal State could cause the game to not perform the action or, worse still, BE DETECTED 
		by a comparison within the Actors.
		
		ERROR_O3 EXPLANATION:
			> Unlike run_on_actor, this is not directed towards an exploit function, so 
			it is mandatory that all tables are cloned and that the instances 
			provide their usable xrefs in the different state.
		
			> Only in this case should you use SendMessage and BindToMessage (Or create 
			something that does the same thing).
			
	]]

				local detectedOnceStacks = false

				local randomObject = Instance.new("TrussPart", BindableEv)
				local randomString = ""

				for _ = 1, 8 do
					randomString ..= string.char(math.random(1, 255))
				end

				randomObject.Name = randomString

				local onceReceivedArgs, waitReceivedArgs

				task.spawn(function()
					waitReceivedArgs = table.pack(BindableEv.Event:Wait())
				end)

				BindableEv.Event:Once(function(...)
					for StackLevel = 2, 20 do
						if debug.info(StackLevel, "f") then
							detectedOnceStacks = true
						end
					end

					local entersCount = debug.traceback():split("\n")
					if not entersCount or #entersCount > 2 then
						detectedOnceStacks = true
					end

					onceReceivedArgs = table.pack(...)
				end)

				BindableEv.Parent = NoChildsService

				task.wait(0.1)

				local s, e = pcall(function()
					firesignal(BindableEv.Event, randomString, randomObject, nil)
				end)

				local destroyEvent = function()
					if BindableEv.Parent then
						BindableEv:Destroy()
					end
				end

				self._destroyEvent = destroyEvent
				self._randomString = randomString
				self._randomObject = randomObject

				task.delay(1, destroyEvent)

				task.wait()

				self._onceReceivedArgs = onceReceivedArgs
				self._waitReceivedArgs = waitReceivedArgs
				self._detectedOnceStacks = detectedOnceStacks
				self._ran = true
				self._ok = s

				if not s then
					return {
						status = 0,
						message = `Ambiguous error: {e}`,
					}
				end

				return passed()
			end,
		},
		{
			id = "once",
			run = function(self)
				if not self._ok then
					return passed()
				end

				if type(self._onceReceivedArgs) ~= "table" then
					return {
						status = 500,
						message = "Signal handler did not run an :Once",
					}
				end

				return passed()
			end,
		},
		{
			id = "wait",
			run = function(self)
				if not self._ok then
					return passed()
				end

				if type(self._waitReceivedArgs) ~= "table" then
					return {
						status = 500,
						message = "Signal handler did not run an :Wait",
					}
				end

				return passed()
			end,
		},
		{
			id = "once-arguments",
			run = function(self)
				if not self._ok or type(self._onceReceivedArgs) ~= "table" then
					return passed()
				end

				local onceReceivedArgs = self._onceReceivedArgs
				local randomString = self._randomString
				local randomObject = self._randomObject
				if
					onceReceivedArgs[1] ~= randomString
					or onceReceivedArgs[2] ~= randomObject
					or onceReceivedArgs[3] ~= nil
					or onceReceivedArgs.n ~= 3
				then
					return {
						status = 500,
						message = "Arguments passed to firesignal with Once were not received by the handler",
					}
				end

				self._onceArgsOk = true

				return passed()
			end,
		},
		{
			id = "wait-arguments",
			run = function(self)
				if not self._ok or type(self._waitReceivedArgs) ~= "table" then
					return passed()
				end

				local waitReceivedArgs = self._waitReceivedArgs
				local randomString = self._randomString
				local randomObject = self._randomObject
				if
					waitReceivedArgs[1] ~= randomString
					or waitReceivedArgs[2] ~= randomObject
					or waitReceivedArgs[3] ~= nil
					or waitReceivedArgs.n ~= 3
				then
					return {
						status = 500,
						message = "Arguments passed to firesignal with Wait were not received by the handler",
					}
				end

				self._waitArgsOk = true

				return passed()
			end,
		},
		{
			id = "thread",
			run = function(self)
				if not self._onceArgsOk or not self._waitArgsOk then
					return passed()
				end

				if self._detectedOnceStacks then -- firesignal should obtain the function and execute it in a NEW Thread
					return {
						status = 500,
						message = "The function is being executed instead of creating a separate thread",
					}
				end

				self._threadOk = true

				return passed()
			end,
		},
		{
			id = "actor",
			run = function(self)
				if not self._threadOk then
					return passed()
				end

				local randomObject = self._randomObject
				local actorResponseTimeStart = tick()
				local actorResponse

				while not actorResponse and tick() - actorResponseTimeStart < 0.5 do
					actorResponse = randomObject:FindFirstChildWhichIsA("StringValue")
					if actorResponse then
						actorResponse = actorResponse.Value
						break
					end

					task.wait()
				end

				task.spawn(self._destroyEvent)

				if not actorResponse then
					return {
						status = 500,
						message = "Our actor took too long to respond",
					}
				end

				self._actorResponse = actorResponse

				return passed()
			end,
		},
		{
			id = "actor-once",
			run = function(self)
				return actorFailure(self, "O", 1, function(Function)
					return `Signal handler did not run a {Function} in an actor`
				end)
			end,
		},
		{
			id = "actor-once-args",
			run = function(self)
				return actorFailure(self, "O", 2, function(Function)
					return `Signal handler does not provide correct args in an {Function} of an Actor`
				end)
			end,
		},
		{
			id = "actor-once-xrefs",
			run = function(self)
				return actorFailure(self, "O", 3, function(Function)
					return `The Signal handler does not create new xrefs for the {Function} arguments of an Actor`
				end)
			end,
		},
		{
			id = "actor-once-count",
			run = function(self)
				return actorFailure(self, "O", 4, function(Function)
					return `Signal handler does not provide all args in an {Function} of an Actor`
				end)
			end,
		},
		{
			id = "actor-once-thread",
			run = function(self)
				if type(self._actorResponse) ~= "string" then
					return passed()
				end

				if self._actorResponse == "ERROR_O5" then -- Exclusive to :Once because its a function
					return {
						status = 500,
						message = `The function of an Actor is being executed instead of creating a separate thread`,
					}
				end

				return passed()
			end,
		},
		{
			id = "actor-wait",
			run = function(self)
				return actorFailure(self, "W", 1, function(Function)
					return `Signal handler did not run a {Function} in an actor`
				end)
			end,
		},
		{
			id = "actor-wait-args",
			run = function(self)
				return actorFailure(self, "W", 2, function(Function)
					return `Signal handler does not provide correct args in an {Function} of an Actor`
				end)
			end,
		},
		{
			id = "actor-wait-xrefs",
			run = function(self)
				return actorFailure(self, "W", 3, function(Function)
					return `The Signal handler does not create new xrefs for the {Function} arguments of an Actor`
				end)
			end,
		},
		{
			id = "actor-wait-count",
			run = function(self)
				return actorFailure(self, "W", 4, function(Function)
					return `Signal handler does not provide all args in an {Function} of an Actor`
				end)
			end,
		},
	},
}
