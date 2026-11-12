--!nocheck
--!nolint

return {
	global = "writefile",
	dependencies = {
		globals = {
			{ name = "delfile", message = "Dependency 'delfile' not found" },
			{ name = "readfile", message = "Dependency 'readfile' not found" },
			{ name = "isfolder", message = "Dependency 'isfolder' not found" },
			{ name = "delfolder", message = "Dependency 'delfolder' not found" },
		},
	},
	cases = {
		{
			id = "write test1",
			run = function(self)
				self._test1 = "test1.txt"
				self._content = "Content"
				local legal1Suc, legal1Msg = pcall(writefile, self._test1, self._content)
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
				self._test2Read = "test2.txt"
				self._content = "Content"
				local legal2Suc, legal2Msg = pcall(writefile, self._test2, self._content)
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
			id = "write nested",
			run = function(self)
				self._nested = "bub/lik.txt"
				self._folder = "bub"
				local nestedSuc, nestedMsg = pcall(writefile, self._nested, "")
				if not nestedSuc then
					return {
						status = 0,
						message = "Failed to write @ bub/lik.txt: " .. nestedMsg,
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
			id = "read test1",
			run = function(self)
				if not self._test1Ok then
					return {
						status = 200,
						message = `Passed`,
					}
				end
				if readfile(self._test1) ~= self._content then
					return {
						status = 500,
						message = "File didn't give expected contnet",
					}
				end
				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "read test2",
			run = function(self)
				if not self._test2Ok then
					return {
						status = 200,
						message = `Passed`,
					}
				end
				if readfile(self._test2Read) ~= self._content then
					return {
						status = 500,
						message = "File didn't give expected contnet",
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
					delfile(self._test1)
				end
				if self._test2Ok then
					delfile(self._test2)
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
