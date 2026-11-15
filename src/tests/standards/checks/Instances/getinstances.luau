--!nocheck
--!nolint

return {
	global = "getinstances",
	cases = {
		{
			id = "instance",
			run = function(self)
				--// Functionality test
				local originalPart1, found1 = Instance.new("Part"), false
				local originalPart2, found2 = Instance.new("Part", workspace), false

				originalPart2.Anchored = true
				originalPart2.Transparency = 1
				originalPart2.CanCollide = false
				originalPart2.Position = Vector3.new(0, -100, 0)

				for _, v in pairs(getinstances()) do
					if v == originalPart1 then
						found1 = true
					elseif v == originalPart2 then
						found2 = true
					elseif typeof(v) ~= "Instance" then
						self._found1 = found1
						self._found2 = found2
						self._nonInstance = true
						self._ready = true
						return {
							status = 500,
							message = "Found a part that isn't an instance",
						}
					end
				end

				self._found1 = found1
				self._found2 = found2
				self._ready = true
				return { status = 200, message = `Passed` }
			end,
		},
		{
			id = "nil parent",
			run = function(self)
				if not self._ready or self._nonInstance then
					return { status = 200, message = `Passed` }
				end

				if not self._found1 then
					return {
						status = 500,
						message = "Didn't find a part w/ a nil parent",
					}
				end

				return { status = 200, message = `Passed` }
			end,
		},
		{
			id = "parent",
			run = function(self)
				if not self._ready or self._nonInstance then
					return { status = 200, message = `Passed` }
				end

				if not self._found2 then
					return {
						status = 500,
						message = "Didn't find a part w/ a parent",
					}
				end

				return { status = 200, message = `Passed` }
			end,
		},
	},
}
