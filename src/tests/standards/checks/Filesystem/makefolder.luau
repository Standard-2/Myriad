--!nocheck
--!nolint

return {
	global = "makefolder",
	dependencies = {
		globals = {
			{ name = "delfolder", message = "Dependency 'delfolder' not found" },
			{ name = "isfolder", message = "Dependency 'isfolder' not found" },
		},
	},
	cases = {
		{
			id = "make test1",
			run = function(self)
				self._test1 = "test1"
				local legal1Suc, legal1Msg = pcall(makefolder, self._test1)
				if not legal1Suc then
					return {
						status = 0,
						message = "Failed to make @ test1: " .. legal1Msg,
					}
				end
				self._test1Ok = true
				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "make test2",
			run = function(self)
				self._test2 = "./test2"
				local legal2Suc, legal2Msg = pcall(makefolder, self._test2)
				if not legal2Suc then
					return {
						status = 0,
						message = "Failed to make @ ./test2: " .. legal2Msg,
					}
				end
				self._test2Ok = true
				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "make nested",
			run = function(self)
				self._nested = "bub/lik"
				self._folder = "bub"
				local nestedSuc, nestedMsg = pcall(makefolder, self._nested)
				if not nestedSuc then
					return {
						status = 0,
						message = "Failed to make @ bub/lik: " .. nestedMsg,
					}
				end
				self._nestedOk = true
				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "illegal C",
			run = function(self)
				local illegal1Suc = pcall(makefolder, "C:/test3")
				if illegal1Suc then
					return {
						status = 500,
						message = "Didn't fail to make in illegal location: @ C:/test3",
					}
				end
				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "illegal parent",
			run = function(self)
				local illegal2Suc = pcall(makefolder, "../test4")
				if illegal2Suc then
					return {
						status = 500,
						message = "Didn't fail to make in illegal location: @ ../test4",
					}
				end
				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "nested folder",
			run = function(self)
				if not self._nestedOk then
					return {
						status = 200,
						message = `Passed`,
					}
				end
				if not isfolder(self._folder) then
					return {
						status = 500,
						message = "Nested folder was not created",
					}
				end
				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "delete",
			run = function(self)
				if self._test1Ok then
					delfolder(self._test1)
				end
				if self._test2Ok then
					delfolder(self._test2)
				end
				if self._nestedOk then
					delfolder(self._folder)
				end
				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
	},
}
