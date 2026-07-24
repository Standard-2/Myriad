local result = require("@vulnerabilities/result")

local function requestCall(func, url)
	return func({ Url = url })
end

local function urlCall(func, url)
	return func(url)
end

local function gameHttpPost(_, url)
	return game:HttpPost(url, "myriad")
end

local function gameHttpPostAsync(_, url)
	return game:HttpPostAsync(url, "myriad")
end

local function test(id, name, getFunc, call)
	return {
		id = id,
		name = name,
		category = "Executor Protocols",
		run = function()
			local func = getFunc()
			if type(func) ~= "function" then
				return result.secured("API is not exposed")
			end

			local success = pcall(call, func, "file:///C:/")
			if success then
				return result.vulnerable("Accepted a file:// URL")
			end

			return result.secured("Rejected file:// URL")
		end,
	}
end

return function()
	local env = getgenv and getgenv() or _G

	return {
		test("executor.request.fileProtocol", "request blocks file://", function()
			return env.request
		end, requestCall),

		test("executor.http_request.fileProtocol", "http_request blocks file://", function()
			return env.http_request
		end, requestCall),

		test("executor.http.request.fileProtocol", "http.request blocks file://", function()
			return type(env.http) == "table" and env.http.request or nil
		end, requestCall),

		test("executor.HttpGet.fileProtocol", "HttpGet blocks file://", function()
			return env.HttpGet
		end, urlCall),

		test("executor.HttpGetAsync.fileProtocol", "HttpGetAsync blocks file://", function()
			return env.HttpGetAsync
		end, urlCall),

		test("executor.game.HttpGet.fileProtocol", "game:HttpGet blocks file://", function()
			return game.HttpGet
		end, function(_, url)
			return game:HttpGet(url)
		end),

		test("executor.game.HttpGetAsync.fileProtocol", "game:HttpGetAsync blocks file://", function()
			return game.HttpGetAsync
		end, function(_, url)
			return game:HttpGetAsync(url)
		end),

		test("executor.game.HttpPost.fileProtocol", "game:HttpPost blocks file://", function()
			return game.HttpPost
		end, gameHttpPost),

		test("executor.game.HttpPostAsync.fileProtocol", "game:HttpPostAsync blocks file://", function()
			return game.HttpPostAsync
		end, gameHttpPostAsync),
	}
end
