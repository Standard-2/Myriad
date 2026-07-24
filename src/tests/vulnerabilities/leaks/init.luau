local result = require("@vulnerabilities/result")

local TEST_URL = "https://economy.roblox.com/v1/user/currency"

local function requestCall(func, url)
	return func({ Url = url })
end

local function urlCall(func, url)
	return func(url)
end

local function getResponseBody(response)
	if type(response) == "table" and response.Body ~= nil then
		return tostring(response.Body)
	end

	return tostring(response)
end

local function containsAuthenticatedCurrencyResponse(body)
	return body:find('"robux"', 1, true) ~= nil or body:find('"isPremium"', 1, true) ~= nil
end

local function test(id, name, getFunc, call)
	return {
		id = id,
		name = name,
		category = "Roblox Auth Leaks",
		run = function()
			local func = getFunc()
			if type(func) ~= "function" then
				return result.secured("API is not exposed")
			end

			local success, response = pcall(call, func, TEST_URL)
			if not success then
				return result.secured("Roblox API request was rejected")
			end

			local body = getResponseBody(response)
			if containsAuthenticatedCurrencyResponse(body) then
				return result.vulnerable("Roblox API response included authenticated currency data")
			end

			return result.secured("Roblox API response did not include authenticated account data")
		end,
	}
end

return function()
	local env = getgenv and getgenv() or _G

	return {
		test("leaks.request.auth", "request strips Roblox auth", function()
			return env.request
		end, requestCall),

		test("leaks.http_request.auth", "http_request strips Roblox auth", function()
			return env.http_request
		end, requestCall),

		test("leaks.http.request.auth", "http.request strips Roblox auth", function()
			return type(env.http) == "table" and env.http.request or nil
		end, requestCall),

		test("leaks.HttpGet.auth", "HttpGet strips Roblox auth", function()
			return env.HttpGet
		end, urlCall),

		test("leaks.HttpGetAsync.auth", "HttpGetAsync strips Roblox auth", function()
			return env.HttpGetAsync
		end, urlCall),

		test("leaks.game.HttpGet.auth", "game:HttpGet strips Roblox auth", function()
			return game.HttpGet
		end, function(_, url)
			return game:HttpGet(url)
		end),

		test("leaks.game.HttpGetAsync.auth", "game:HttpGetAsync strips Roblox auth", function()
			return game.HttpGetAsync
		end, function(_, url)
			return game:HttpGetAsync(url)
		end),
	}
end
