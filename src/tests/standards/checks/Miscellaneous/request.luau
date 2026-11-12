--!nocheck
--!nolint

return {
	global = "request",
	aliases = {
		"http.request",
		"http_request",
	},
	cases = {
		{
			id = "table",
			run = function(self)
				--// Functionality Test
				local response = request({
					Url = "https://any.httpbun.com/",
					Method = "GET",
				})
				self._response = response

				if typeof(response) ~= "table" then
					return {
						status = 500,
						message = "Reponse wasn't a table",
					}
				end

				return { status = 200, message = "Passed" }
			end,
		},
		{
			id = "status",
			run = function(self)
				local response = self._response
				if typeof(response) ~= "table" then
					return { status = 200, message = "Passed" }
				end

				if response.StatusCode ~= 200 then
					return {
						status = 500,
						message = "Didn't give status 200 (is any.httpbun.com down?)",
					}
				end

				return { status = 200, message = "Passed" }
			end,
		},
		{
			id = "user-agent",
			run = function(self)
				local response = self._response
				if typeof(response) ~= "table" or response.StatusCode ~= 200 then
					return { status = 200, message = "Passed" }
				end

				local data = game:GetService("HttpService"):JSONDecode(response.Body)
				if type(data) ~= "table" and type(data["user-agent"]) ~= "string" then
					return {
						status = 500,
						message = "Didn't give a table w/ user-agent string",
					}
				end

				return {
					status = 200,
					message = `Passed ({data["user-agent"]})`,
				}
			end,
		},
	},
}
