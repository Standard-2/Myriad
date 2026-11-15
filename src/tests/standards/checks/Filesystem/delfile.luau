--!nocheck
--!nolint

return {
	global = "delfile",
	dependencies = {
		globals = {
			{ name = "writefile", message = "Dependency 'writefile' not found" },
			{ name = "isfile", message = "Dependency 'isfile' not found" },
		},
	},
	cases = {
		{
			id = "write test1",
			run = function(self)
				self._test1 = "test1.txt"
				local legal1Suc, legal1Msg = pcall(writefile, self._test1, "Content")
				if not legal1Suc then
					return {
						status = 0,
						message = "Failed to write @ test1.txt: " .. legal1Msg,
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
			id = "write test2",
			run = function(self)
				self._test2 = "./test2.txt"
				local legal2Suc, legal2Msg = pcall(writefile, self._test2, "Content")
				if not legal2Suc then
					return {
						status = 0,
						message = "Failed to write @ ./test2.txt: " .. legal2Msg,
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
			id = "illegal C",
			run = function(self)
				local illegal1Suc = pcall(writefile, "C:/test3.txt", "Content")
				if illegal1Suc then
					return {
						status = 500,
						message = "Didn't fail to write in illegal location: @ C:/test3.txt",
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
				local illegal2Suc = pcall(writefile, "../test4.txt", "Content")
				if illegal2Suc then
					return {
						status = 500,
						message = "Didn't fail to write in illegal location: @ ../test4.txt",
					}
				end
				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "find test1",
			run = function(self)
				if not self._test1Ok then
					return {
						status = 200,
						message = `Passed`,
					}
				end
				if not isfile(self._test1) then
					return {
						status = 500,
						message = "Didn't find: test1.txt",
					}
				end
				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "find test2",
			run = function(self)
				if not self._test2Ok then
					return {
						status = 200,
						message = `Passed`,
					}
				end
				if not isfile(self._test2) then
					return {
						status = 500,
						message = "Didn't find: ./test2.txt",
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
				if not self._test1Ok and not self._test2Ok then
					return {
						status = 200,
						message = `Passed`,
					}
				end
				if self._test1Ok then
					delfile(self._test1)
				end
				if self._test2Ok then
					delfile(self._test2)
				end
				self._deleted = true
				task.wait(0.2)
				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "missing test1",
			run = function(self)
				if not self._test1Ok or not self._deleted then
					return {
						status = 200,
						message = `Passed`,
					}
				end
				if isfile(self._test1) then
					return {
						status = 500,
						message = "Found: test1.txt",
					}
				end
				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "missing test2",
			run = function(self)
				if not self._test2Ok or not self._deleted then
					return {
						status = 200,
						message = `Passed`,
					}
				end
				if isfile(self._test2) then
					return {
						status = 500,
						message = "Found: ./test2.txt",
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
