--!nocheck
--!nolint

return {
	global = "firetouchinterest",
	cases = {
		{
			id = "touch part",
			run = function(self)
				--// Functionality test
				local touchPart = game.Players.LocalPlayer.Character.Head
				local originalPart = Instance.new("Part")
				self._touchPart = touchPart
				self._part = originalPart

				originalPart.Anchored = true
				originalPart.Transparency = 1
				originalPart.CanCollide = false
				originalPart.Position = Vector3.new(0, -100, 0)
				originalPart.Parent = workspace

				originalPart.Touched:Connect(function(part: BasePart)
					if part ~= touchPart then
						originalPart:Destroy()
						self._touchWrong = true
						return
					end

					self._touched = true
				end)

				originalPart.TouchEnded:Connect(function(part: BasePart)
					if part ~= touchPart then
						originalPart:Destroy()
						self._touchEndWrong = true
						return
					end

					self._touchEnded = true
				end)

				firetouchinterest(touchPart, originalPart, false)
				game:GetService("RunService").PostSimulation:Wait()
				self._began = true

				if self._touchWrong then
					self._part = nil
					return {
						status = 500,
						message = "Touch part given wasn't the passed touch part",
					}
				end

				return { status = 200, message = `Passed` }
			end,
		},
		{
			id = "touched",
			run = function(self)
				if not self._began or self._touchWrong then
					return { status = 200, message = `Passed` }
				end

				if not self._touched then
					return {
						status = 500,
						message = "Touched event wasn't fired",
					}
				end

				return { status = 200, message = `Passed` }
			end,
		},
		{
			id = "touch end part",
			run = function(self)
				if not self._began or self._touchWrong or not self._touched or not self._part then
					return { status = 200, message = `Passed` }
				end

				firetouchinterest(self._touchPart, self._part, true)
				game:GetService("RunService").PostSimulation:Wait()
				self._ended = true

				if self._touchEndWrong then
					self._part = nil
					return {
						status = 500,
						message = "Touch part given wasn't the passed touch part",
					}
				end

				return { status = 200, message = `Passed` }
			end,
		},
		{
			id = "touch ended",
			run = function(self)
				if not self._ended or self._touchEndWrong then
					return { status = 200, message = `Passed` }
				end

				if not self._touchEnded then
					return {
						status = 500,
						message = "Touched event wasn't fired",
					}
				end

				if self._part then
					self._part:Destroy()
					self._part = nil
				end

				return { status = 200, message = `Passed` }
			end,
		},
	},
}
