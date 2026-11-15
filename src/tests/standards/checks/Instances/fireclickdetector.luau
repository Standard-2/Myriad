--!nocheck
--!nolint

return {
	global = "fireclickdetector",
	cases = {
		{
			id = "player",
			run = function(self)
				--// Functionality test
				local originalPart = Instance.new("Part", workspace)
				local originalClickDetector = Instance.new("ClickDetector", originalPart)

				originalPart.Anchored = true
				originalPart.Transparency = 1
				originalPart.CanCollide = false
				originalPart.Position = Vector3.new(0, -100, 0)

				local failure = nil

				local function testEvent(event)
					originalClickDetector[event]:Connect(function(player)
						if player ~= game:GetService("Players").LocalPlayer then
							failure = {
								status = 500,
								message = "Player passed wasn't the LocalPlayer",
							}
						end
					end)

					local success, returned = pcall(fireclickdetector, originalClickDetector, 0, event)

					if not success then
						failure = {
							status = 0,
							message = `Failed w/ error: {returned}`,
						}
						return false
					end

					return true
				end

				local mouseClick = testEvent("MouseClick")
				local rightMouseClick = testEvent("RightMouseClick")
				local mouseHoverEnter = testEvent("MouseHoverEnter")
				local mouseHoverLeave = testEvent("MouseHoverLeave")

				game:GetService("RunService").PostSimulation:Wait()

				self._mouseClick = mouseClick
				self._rightMouseClick = rightMouseClick
				self._mouseHoverEnter = mouseHoverEnter
				self._mouseHoverLeave = mouseHoverLeave
				self._ready = true

				if failure then
					self._failed = true
					return failure
				end

				return { status = 200, message = `Passed` }
			end,
		},
		{
			id = "mouse click",
			run = function(self)
				if not self._ready or self._failed then
					return { status = 200, message = `Passed` }
				end

				if not self._mouseClick then
					return {
						status = 500,
						message = "MouseClick event was not fired or errored.",
					}
				end

				return { status = 200, message = `Passed` }
			end,
		},
		{
			id = "right mouse click",
			run = function(self)
				if not self._ready or self._failed then
					return { status = 200, message = `Passed` }
				end

				if not self._rightMouseClick then
					return {
						status = 500,
						message = "RightMouseClick event was not fired.",
					}
				end

				return { status = 200, message = `Passed` }
			end,
		},
		{
			id = "hover enter",
			run = function(self)
				if not self._ready or self._failed then
					return { status = 200, message = `Passed` }
				end

				if not self._mouseHoverEnter then
					return {
						status = 500,
						message = "MouseHoverEnter event was not fired.",
					}
				end

				return { status = 200, message = `Passed` }
			end,
		},
		{
			id = "hover leave",
			run = function(self)
				if not self._ready or self._failed then
					return { status = 200, message = `Passed` }
				end

				if not self._mouseHoverLeave then
					return {
						status = 500,
						message = "MouseHoverLeave event was not fired.",
					}
				end

				return { status = 200, message = `Passed` }
			end,
		},
	},
}
