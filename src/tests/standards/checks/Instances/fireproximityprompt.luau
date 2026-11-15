--!nocheck
--!nolint

return {
	global = "fireproximityprompt",
	cases = {
		{
			id = "hold began",
			run = function(self)
				--// Functionality test
				local fired = false
				local holdBegan = false
				local holdEnded = false
				local holdModified = false
				local badPlayer = false

				local localPlayer = game:GetService("Players").LocalPlayer
				local proximityPromptService = game:GetService("ProximityPromptService")
				local originalPart = Instance.new("Part", workspace)
				local originalProximityPrompt = Instance.new("ProximityPrompt", originalPart)

				originalPart.Anchored = true
				originalPart.Transparency = 1
				originalPart.CanCollide = false
				originalPart.Position = Vector3.new(0, -100, 0)
				originalProximityPrompt.HoldDuration = 1

				proximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
					holdBegan = true
				end)

				proximityPromptService.PromptButtonHoldEnded:Connect(function(prompt)
					holdEnded = true
				end)

				originalProximityPrompt:GetPropertyChangedSignal("HoldDuration"):Connect(function()
					holdModified = true
				end)

				originalProximityPrompt.Triggered:Connect(function(player)
					if player ~= localPlayer then
						badPlayer = true
						return
					end

					fired = true
				end)

				local success, returned = pcall(fireproximityprompt, originalProximityPrompt)

				game:GetService("RunService").PostSimulation:Wait()

				self._holdBegan = holdBegan
				self._holdEnded = holdEnded
				self._holdModified = holdModified
				self._badPlayer = badPlayer
				self._success = success
				self._returned = returned
				self._fired = fired
				self._ready = true

				if holdBegan then
					return {
						status = 500,
						message = "Proximity prompt was manually fired",
					}
				end

				return { status = 200, message = `Passed` }
			end,
		},
		{
			id = "hold ended",
			run = function(self)
				if not self._ready then
					return { status = 200, message = `Passed` }
				end

				if self._holdEnded then
					return {
						status = 500,
						message = "Proximity prompt was manually fired",
					}
				end

				return { status = 200, message = `Passed` }
			end,
		},
		{
			id = "hold duration",
			run = function(self)
				if not self._ready then
					return { status = 200, message = `Passed` }
				end

				if self._holdModified then
					return {
						status = 500,
						message = "Modified HoldDuration",
					}
				end

				return { status = 200, message = `Passed` }
			end,
		},
		{
			id = "player",
			run = function(self)
				if not self._ready then
					return { status = 200, message = `Passed` }
				end

				if self._badPlayer then
					return {
						status = 500,
						message = "Player passed wasn't the LocalPlayer",
					}
				end

				return { status = 200, message = `Passed` }
			end,
		},
		{
			id = "error",
			run = function(self)
				if not self._ready then
					return { status = 200, message = `Passed` }
				end

				if not self._success then
					local returned = self._returned
					return {
						status = 0,
						message = `Failed w/ error: {returned}`,
					}
				end

				return { status = 200, message = `Passed` }
			end,
		},
		{
			id = "triggered",
			run = function(self)
				if not self._ready or not self._success or self._badPlayer then
					return { status = 200, message = `Passed` }
				end

				if not self._fired then
					return {
						status = 500,
						message = `Prompt was not triggered`,
					}
				end

				return { status = 200, message = `Passed` }
			end,
		},
	},
}
