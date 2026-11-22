--!nocheck
--!nolint

return {
	global = "cache.replace",
	cases = {
		{
			id = "distinct",
			run = function(self)
				local inst1 = game:GetService("BadgeService")
				local inst2 = game:GetService("Stats")

				if inst1 == inst2 then
					return {
						status = 500,
						message = "Did a cosmic ray just hit your computer? This should never evaluate",
					}
				end

				self._inst1 = inst1
				self._inst2 = inst2
				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "replaced",
			run = function(self)
				if self._inst1 == nil or self._inst2 == nil then
					return { status = 200, message = "Passed" }
				end

				cache.replace(self._inst1, self._inst2)

				if self._inst1 == self._inst2 then
					return {
						status = 500,
						message = "Reference is old reference",
					}
				end

				self._replaced = true
				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "target",
			run = function(self)
				if not self._replaced then
					return { status = 200, message = "Passed" }
				end

				if self._inst1 == game:GetService("Stats") then
					return {
						status = 500,
						message = "Reference is old references object",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "lookup",
			run = function(self)
				local holder = Instance.new("Folder")
				holder.Name = "n" .. string.gsub(tostring({}), "[^%w]", "")
				local host = Instance.new("Configuration")
				host.Name = "lane"
				local guest = Instance.new("StringValue")
				guest.Name = "cargo"
				guest.Value = "kelp"
				holder.Parent = game:GetService("ReplicatedStorage")
				host.Parent = holder
				guest.Parent = holder

				local function finish(result)
					holder:Destroy()
					return result
				end

				local indexedHost = holder.lane
				local indexedGuest = holder.cargo
				if indexedHost == nil or indexedGuest == nil then
					return finish({
						status = 500,
						message = "Name lookup did not return an instance",
					})
				end

				task.wait()
				local replaced, replaceErr = pcall(cache.replace, host, guest)
				if not replaced then
					return finish({
						status = 0,
						message = tostring(replaceErr),
					})
				end

				if holder.lane ~= guest then
					return finish({
						status = 500,
						message = "Name lookup did not return the replacement",
					})
				end

				if holder.lane.Value ~= "kelp" then
					return finish({
						status = 500,
						message = "Property read did not follow the replacement",
					})
				end

				if host == guest then
					return finish({
						status = 500,
						message = "Original reference was replaced",
					})
				end

				return finish({
					status = 200,
					message = `Passed`,
				})
			end,
		},
	},
}
