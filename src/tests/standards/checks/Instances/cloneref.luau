--!nocheck
--!nolint
return {
	global = "cloneref",
	dependencies = {
		checks = {
			{ id = "Metatable.setrawmetatable", message = "Dependency 'setrawmetatable' dosen't work properly." },
		},
	},
	aliases = {
		"clonereference",
	},
	cases = {
		{
			id = "service identity",
			run = function(self)
				local originalPart = Instance.new("Part")
				self._part = originalPart
				local originalService = game:GetService("CoreGui")

				if cloneref(originalService) == originalService then
					originalPart:Destroy()
					self._part = nil
					return {
						status = 500,
						message = "Cloned service cannot be equal to original reference",
					}
				end

				return { status = 200, message = `Passed` }
			end,
		},
		{
			id = "part identity",
			run = function(self)
				local originalPart = self._part
				if not originalPart then
					return { status = 200, message = `Passed` }
				end

				-- We do this so that getnilinstances doesn't find it.
				originalPart.Parent = workspace

				local marker = "Myriad" .. tostring(math.random(100000, 999999))
				originalPart.Name = marker
				self._marker = marker

				-- An "error" is only possible if setrawmetatable exists and was previously modified
				if setrawmetatable then
					local sameTable = {}
					self._canary = sameTable
					setrawmetatable(originalPart, {
						__type = "Instance",
						__index = function()
							return sameTable
						end,
					})
				end

				local originalPartNewRef = cloneref(originalPart)
				local collectGarbageDetecor = setmetatable({ {}, originalPart }, { __mode = "v" })
				self._newRef = originalPartNewRef
				self._detector = collectGarbageDetecor

				if originalPart == originalPartNewRef then
					pcall(function()
						originalPart:Destroy()
					end)
					self._part = nil
					self._newRef = nil
					self._detector = nil
					return {
						status = 500,
						message = "Cloned part cannot be equal to original reference",
					}
				end

				return { status = 200, message = `Passed` }
			end,
		},
		{
			id = "metadata match",
			run = function(self)
				local originalPart = self._part
				local originalPartNewRef = self._newRef
				local marker = self._marker
				local canary = self._canary
				if not originalPart or not originalPartNewRef or not marker then
					return { status = 200, message = `Passed` }
				end

				local renamed = marker .. "b"
				local writeOk = pcall(function()
					originalPartNewRef.Name = renamed
				end)
				local seen
				local readOk = pcall(function()
					seen = originalPartNewRef.Name
				end)
				local thirdSeen
				local thirdOk = pcall(function()
					thirdSeen = cloneref(originalPart).Name
				end)
				local spoofed = canary ~= nil and (seen == canary or thirdSeen == canary)

				if not writeOk or not readOk or not thirdOk or spoofed or seen ~= renamed or thirdSeen ~= renamed then
					pcall(function()
						originalPart:Destroy()
					end)
					self._part = nil
					self._newRef = nil
					self._detector = nil
					return {
						status = 500,
						message = "The new xref does not contain the same metadata as the original",
					}
				end

				return { status = 200, message = `Passed` }
			end,
		},
		{
			id = "timeout",
			run = function(self)
				local originalPart = self._part
				local collectGarbageDetecor = self._detector
				if not originalPart or not collectGarbageDetecor then
					return { status = 200, message = `Passed` }
				end

				pcall(function()
					originalPart:Destroy()
				end)

				originalPart = nil
				self._part = nil

				local timeout = false
				local cancelThread = task.delay(5, function()
					timeout = true
					collectGarbageDetecor[1] = nil
				end)

				while true do
					local sentinel = collectGarbageDetecor[1]
					if not sentinel then
						break
					end
					sentinel = nil
					local pressure = table.create(1024)
					pressure = nil
					task.wait()
				end

				if not timeout then
					task.cancel(cancelThread)
					self._collected = true
				else
					return {
						status = 500,
						message = "The garbage collector is not working properly. It should have cleaned up in 2 seconds, but it took more",
					}
				end

				return { status = 200, message = `Passed` }
			end,
		},
		{
			id = "xref",
			run = function(self)
				local collectGarbageDetecor = self._detector
				if not collectGarbageDetecor or not self._collected then
					return { status = 200, message = `Passed` }
				end

				if collectGarbageDetecor[2] then
					return {
						status = 500,
						message = "Cloned part still holds the original xref",
					}
				end

				return { status = 200, message = `Passed` }
			end,
		},
	},
}
