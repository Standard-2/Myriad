--!nocheck
--!nolint

return {
	global = "getcallbackvalue",
	aliases = {
		"getcallbackmember",
	},
	cases = {
		{
			id = "bindable",
			run = function(self)
				--// Functionality test
				local r1, r2, r3 = math.random(1, 10), math.random(1, 10), math.random(1, 10)

				local ReplicatedStorage = game:GetService("ReplicatedStorage")
				local externalBindable = ReplicatedStorage:WaitForChild("BindableFunction")

				local originalRemote = Instance.new("RemoteFunction")

				local originalBindable1 = Instance.new("BindableFunction")
				local originalBindable2 = Instance.new("BindableFunction")

				originalBindable1.OnInvoke = function(a, b)
					return (a + b) ^ r3
				end
				originalRemote.OnServerInvoke = function()
					return r3
				end

				local bindableCb1 = getcallbackvalue(originalBindable1, "OnInvoke")
				local bindableCb2 = getcallbackvalue(originalBindable2, "OnInvoke")
				local remoteCb = getcallbackvalue(originalRemote, "OnServerInvoke")
				local externalBindableCb = getcallbackvalue(externalBindable, "OnInvoke")

				self._r1 = r1
				self._r2 = r2
				self._r3 = r3
				self._bindableCb1 = bindableCb1
				self._bindableCb2 = bindableCb2
				self._remoteCb = remoteCb
				self._externalBindableCb = externalBindableCb
				self._ready = true

				if not bindableCb1 then
					return {
						status = 500,
						message = "Didn't return a callback value for a bindable",
					}
				end

				return { status = 200, message = `Passed` }
			end,
		},
		{
			id = "empty bindable",
			run = function(self)
				if not self._ready then
					return { status = 200, message = `Passed` }
				end

				if self._bindableCb2 then
					return {
						status = 500,
						message = "Returned a callback value for a bindable with none",
					}
				end

				return { status = 200, message = `Passed` }
			end,
		},
		{
			id = "remote",
			run = function(self)
				if not self._ready then
					return { status = 200, message = `Passed` }
				end

				if not self._remoteCb then
					return {
						status = 500,
						message = "Returned a callback value for a remote with none",
					}
				end

				return { status = 200, message = `Passed` }
			end,
		},
		{
			id = "bindable result",
			run = function(self)
				local bindableCb1 = self._bindableCb1
				if not self._ready or not bindableCb1 then
					return { status = 200, message = `Passed` }
				end

				local r1, r2, r3 = self._r1, self._r2, self._r3
				if bindableCb1(r1, r2) ~= (r1 + r2) ^ r3 then
					return {
						status = 500,
						message = "Bindable's callback value didn't return the expected value",
					}
				end

				return { status = 200, message = `Passed` }
			end,
		},
		{
			id = "remote result",
			run = function(self)
				local remoteCb = self._remoteCb
				if not self._ready or not remoteCb then
					return { status = 200, message = `Passed` }
				end

				if remoteCb(game.Players.LocalPlayer) ~= self._r3 then
					return {
						status = 500,
						message = "Remote's callback value didn't return the expected value",
					}
				end

				return { status = 200, message = `Passed` }
			end,
		},
		{
			id = "external bindable",
			run = function(self)
				if not self._ready then
					return { status = 200, message = `Passed` }
				end

				if not self._externalBindableCb then
					return {
						status = 500,
						message = "Didn't return a callback value for a external bindable",
					}
				end

				return { status = 200, message = `Passed` }
			end,
		},
		{
			id = "external function",
			run = function(self)
				local externalBindableCb = self._externalBindableCb
				if not self._ready or not externalBindableCb then
					return { status = 200, message = `Passed` }
				end

				if
					externalBindableCb() ~= tostring(externalBindableCb)
					or debug.info(externalBindableCb, "n") ~= "Callback"
				then
					return {
						status = 500,
						message = "External bindable's callback value is not the expected function",
					}
				end

				return { status = 200, message = `Passed` }
			end,
		},
	},
}
