--!nocheck
--!nolint

return function()
	if not hookfunction then
		return {
			status = 400,
			message = "Global not found",
		}
	elseif require("@checks/Closures/newcclosure.luau")().status ~= 200 then
		return {
			status = 401,
			message = "Dependency 'newcclosure' didn't pass",
		}
	elseif require("@checks/Closures/clonefunction.luau")().status ~= 200 then
		return {
			status = 401,
			message = "Dependency 'clonefunction' didn't pass",
		}
	elseif not getfenv or not setfenv then
		return {
			status = 401,
			message = "Dependant global 'getfenv' not found",
		}
	end

	local function originalFunc1()
		return 1
	end

	local function1 = originalFunc1

	local function function2()
		return 2
	end

	if function1() ~= 1 then
		return {
			status = 500,
			message = "[L>L] This should never evaluate. Did a cosmic ray hit your computer and flip a bit?",
		}
	end

	local nameBefore, sourceBefore, lineBefore = debug.info(function1, "nsl")
	local original = hookfunction(function1, function2)

	if function1() ~= 2 then
		return {
			status = 500,
			message = "[L>L] Hooked function did not return the expected value",
		}
	elseif original() ~= 1 then
		return {
			status = 500,
			message = "[L>L] Old function did not return the expected value",
		}
	end

	local nameAfter, sourceAfter, lineAfter = debug.info(function1, "nsl")
	if nameAfter ~= nameBefore or sourceAfter ~= sourceBefore or lineAfter ~= lineBefore then
		return {
			status = 500,
			message = "[L>L] Hook changed the function's debug info",
		}
	end

	hookfunction(function1, original)

	if function1() ~= 1 then
		return {
			status = 500,
			message = "[L>L] Restored function did not return the expected value",
		}
	end

	local kept = { id = "kept" }
	local swapped = { id = "swapped" }

	local function readsKept()
		return kept
	end

	local function readsSwapped()
		return swapped
	end

	local keptOriginal = hookfunction(readsKept, readsSwapped)

	if readsKept() ~= swapped then
		return {
			status = 500,
			message = "[L>L] Hooked function did not use the hook's upvalue",
		}
	elseif keptOriginal() ~= kept then
		return {
			status = 500,
			message = "[L>L] Old function lost its upvalue",
		}
	end

	local function relay(...)
		return select("#", ...)
	end

	local function capture(...)
		return select("#", ...), ...
	end

	local capturedHook, capturedErr = pcall(hookfunction, relay, capture)
	if not capturedHook then
		return {
			status = 500,
			message = `[L>L] Failed to hook: {capturedErr}`,
		}
	end

	local captured = table.pack(relay("a", nil, "b"))
	if captured.n ~= 4 or captured[1] ~= 3 or captured[2] ~= "a" or captured[4] ~= "b" then
		return {
			status = 500,
			message = "[L>L] Hook did not pass nil arguments through",
		}
	end

	local calls = 0
	local function counted()
		calls += 1
		return "once"
	end

	local countedOriginal
	countedOriginal = hookfunction(counted, function()
		return "hooked-" .. countedOriginal()
	end)

	local chained = counted()
	if chained ~= "hooked-once" or calls ~= 1 then
		return {
			status = 500,
			message = "[L>L] Calling the old function re-entered the hook",
		}
	end

	local function base()
		return "base"
	end

	local function middle()
		return "middle"
	end

	local function top()
		return "top"
	end

	local first = hookfunction(base, middle)
	local second = hookfunction(base, top)
	local displacedOk, displaced = pcall(second)

	if base() ~= "top" then
		return {
			status = 500,
			message = "[L>L] A second hook did not replace the first",
		}
	elseif first() ~= "base" then
		return {
			status = 500,
			message = "[L>L] The first returned function no longer runs the original",
		}
	elseif not displacedOk or displaced == "top" then
		return {
			status = 500,
			message = "[L>L] The function returned by the second hook re-entered the active hook",
		}
	end

	local function plain()
		return "plain"
	end

	local function yielder()
		return coroutine.yield("paused")
	end

	hookfunction(plain, yielder)

	local thread = coroutine.create(function()
		return plain()
	end)

	local resumed, yielded = coroutine.resume(thread)
	if not resumed or coroutine.status(thread) ~= "suspended" or yielded ~= "paused" then
		return {
			status = 500,
			message = `[L>L] Hook did not yield the caller: {yielded}`,
		}
	end

	local resumedAgain, continued = coroutine.resume(thread, "continued")
	if not resumedAgain or continued ~= "continued" or coroutine.status(thread) ~= "dead" then
		return {
			status = 500,
			message = "[L>L] Resuming a hooked yield did not continue the hook",
		}
	end

	local function calm()
		return "calm"
	end

	local function boom()
		error("hook-body")
	end

	hookfunction(calm, boom)

	local calmOk, calmErr = pcall(calm)
	if calmOk or string.find(tostring(calmErr), "hook-body", 1, true) == nil then
		return {
			status = 500,
			message = "[L>L] Hook error did not reach the caller",
		}
	end

	local function luaSide()
		return "lua-side"
	end

	local wrapped = newcclosure(function()
		return "wrapped"
	end)

	local luaHooked, luaOriginal = pcall(hookfunction, luaSide, wrapped)
	if not luaHooked then
		return {
			status = 500,
			message = `[L>NC] Failed to hook: {luaOriginal}`,
		}
	elseif luaSide() ~= "wrapped" then
		return {
			status = 500,
			message = "[L>NC] Hooked function did not return the expected value",
		}
	elseif luaOriginal() ~= "lua-side" then
		return {
			status = 500,
			message = "[L>NC] Old function did not return the expected value",
		}
	end

	hookfunction(luaSide, luaOriginal)

	if luaSide() ~= "lua-side" then
		return {
			status = 500,
			message = "[L>NC] Restored function did not return the expected value",
		}
	end

	local function letter()
		return "letter"
	end

	local letterName, letterSource, letterLine = debug.info(letter, "nsl")
	local asChar = clonefunction(utf8.char)
	local letterHooked, letterOriginal = pcall(hookfunction, letter, asChar)
	if not letterHooked then
		return {
			status = 500,
			message = `[L>C] Failed to hook: {letterOriginal}`,
		}
	elseif letter(65) ~= "A" then
		return {
			status = 500,
			message = "[L>C] Hooked function did not return the expected value",
		}
	elseif letterOriginal() ~= "letter" then
		return {
			status = 500,
			message = "[L>C] Old function did not return the expected value",
		}
	end

	local letterNameNow, letterSourceNow, letterLineNow = debug.info(letter, "nsl")
	if letterNameNow ~= letterName or letterSourceNow ~= letterSource or letterLineNow ~= letterLine then
		return {
			status = 500,
			message = "[L>C] Hook changed the function's debug info",
		}
	end

	hookfunction(letter, letterOriginal)

	if letter() ~= "letter" then
		return {
			status = 500,
			message = "[L>C] Restored function did not return the expected value",
		}
	end

	local wrappedBody = newcclosure(function()
		return "wrapped-body"
	end)

	local function fromLua()
		return "from-lua"
	end

	local wrappedHooked, wrappedOriginal = pcall(hookfunction, wrappedBody, fromLua)
	if not wrappedHooked then
		return {
			status = 500,
			message = `[NC>L] Failed to hook: {wrappedOriginal}`,
		}
	elseif wrappedBody() ~= "from-lua" then
		return {
			status = 500,
			message = "[NC>L] Hooked function did not return the expected value",
		}
	elseif wrappedOriginal() ~= "wrapped-body" then
		return {
			status = 500,
			message = "[NC>L] Old function did not return the expected value",
		}
	end

	hookfunction(wrappedBody, wrappedOriginal)

	if wrappedBody() ~= "wrapped-body" then
		return {
			status = 500,
			message = "[NC>L] Restored function did not return the expected value",
		}
	end

	local firstNc = newcclosure(function()
		return "first"
	end)

	local secondNc = newcclosure(function()
		return "second"
	end)

	local ncHooked, ncOriginal = pcall(hookfunction, firstNc, secondNc)
	if not ncHooked then
		return {
			status = 500,
			message = `[NC>NC] Failed to hook: {ncOriginal}`,
		}
	elseif firstNc() ~= "second" then
		return {
			status = 500,
			message = "[NC>NC] Hooked function did not return the expected value",
		}
	elseif ncOriginal() ~= "first" then
		return {
			status = 500,
			message = "[NC>NC] Old function did not return the expected value",
		}
	end

	hookfunction(firstNc, ncOriginal)

	if firstNc() ~= "first" then
		return {
			status = 500,
			message = "[NC>NC] Restored function did not return the expected value",
		}
	end

	local ncForC = newcclosure(function()
		return "nc"
	end)

	local charHook = clonefunction(utf8.char)
	local ncForCHooked, ncForCOriginal = pcall(hookfunction, ncForC, charHook)
	if not ncForCHooked then
		return {
			status = 500,
			message = `[NC>C] Failed to hook: {ncForCOriginal}`,
		}
	elseif ncForC(66) ~= "B" then
		return {
			status = 500,
			message = "[NC>C] Hooked function did not return the expected value",
		}
	elseif ncForCOriginal() ~= "nc" then
		return {
			status = 500,
			message = "[NC>C] Old function did not return the expected value",
		}
	end

	hookfunction(ncForC, ncForCOriginal)

	if ncForC() ~= "nc" then
		return {
			status = 500,
			message = "[NC>C] Restored function did not return the expected value",
		}
	end

	local measure = clonefunction(utf8.len)

	local function substitute()
		return 11
	end

	local measureHooked, measureOriginal = pcall(hookfunction, measure, substitute)
	if not measureHooked then
		return {
			status = 500,
			message = `[C>L] Failed to hook: {measureOriginal}`,
		}
	elseif measure("ab") ~= 11 then
		return {
			status = 500,
			message = "[C>L] Hooked function did not return the expected value",
		}
	elseif measureOriginal("ab") ~= 2 then
		return {
			status = 500,
			message = "[C>L] Old function did not return the expected value",
		}
	end

	hookfunction(measure, measureOriginal)

	if measure("abcd") ~= 4 then
		return {
			status = 500,
			message = "[C>L] Restored function did not return the expected value",
		}
	end

	local countedLength = clonefunction(utf8.len)
	local fixedLength = newcclosure(function()
		return 9
	end)

	local countedHooked, countedLengthOriginal = pcall(hookfunction, countedLength, fixedLength)
	if not countedHooked then
		return {
			status = 500,
			message = `[C>NC] Failed to hook: {countedLengthOriginal}`,
		}
	elseif countedLength("ab") ~= 9 then
		return {
			status = 500,
			message = "[C>NC] Hooked function did not return the expected value",
		}
	elseif countedLengthOriginal("ab") ~= 2 then
		return {
			status = 500,
			message = "[C>NC] Old function did not return the expected value",
		}
	end

	hookfunction(countedLength, countedLengthOriginal)

	if countedLength("a") ~= 1 then
		return {
			status = 500,
			message = "[C>NC] Restored function did not return the expected value",
		}
	end

	local codepoint = clonefunction(utf8.codepoint)
	local length = clonefunction(utf8.len)
	local lengthHooked, lengthOriginal = pcall(hookfunction, length, codepoint)
	if not lengthHooked then
		return {
			status = 500,
			message = `[C>C] Failed to hook: {lengthOriginal}`,
		}
	elseif length("A") ~= 65 then
		return {
			status = 500,
			message = "[C>C] Hooked function did not return the expected value",
		}
	elseif lengthOriginal("A") ~= 1 then
		return {
			status = 500,
			message = "[C>C] Old function did not return the expected value",
		}
	end

	hookfunction(length, lengthOriginal)

	if length("AB") ~= 2 then
		return {
			status = 500,
			message = "[C>C] Restored function did not return the expected value",
		}
	end

	local bindable = Instance.new("BindableFunction")
	local function onInvoke(value)
		return "invoke-" .. tostring(value)
	end

	bindable.OnInvoke = onInvoke

	local invokeOriginal = hookfunction(onInvoke, function(value)
		return "hooked-" .. tostring(value)
	end)

	local invoked = bindable:Invoke("z")
	bindable:Destroy()

	if invoked ~= "hooked-z" then
		return {
			status = 500,
			message = "[L>L] Engine callback did not call the hook",
		}
	elseif invokeOriginal("z") ~= "invoke-z" then
		return {
			status = 500,
			message = "[L>L] Old callback did not keep its behavior",
		}
	end

	local oneOk = pcall(hookfunction, function() end)
	if oneOk then
		return {
			status = 500,
			message = "hookfunction accepted one argument",
		}
	end

	local typeOk = pcall(hookfunction, "nope", function() end)
	if typeOk then
		return {
			status = 500,
			message = "hookfunction accepted a non-function",
		}
	end

	local env = { flag = "reader" }
	local hookEnv = { flag = "writer" }

	local function reader()
		return flag
	end

	local function writer()
		return flag
	end

	setfenv(reader, env)
	setfenv(writer, hookEnv)

	if reader() ~= "reader" then
		return {
			status = 500,
			message = "[L>L] setfenv did not apply to the function under test",
		}
	end

	local readerOriginal = hookfunction(reader, writer)

	if reader() ~= "writer" then
		return {
			status = 500,
			message = "[L>L] Hook ran in the target environment",
		}
	elseif readerOriginal() ~= "reader" then
		return {
			status = 500,
			message = "[L>L] Old function lost its environment",
		}
	end

	local oldEnvOk, oldEnv = pcall(getfenv, readerOriginal)
	if not oldEnvOk or oldEnv ~= env then
		return {
			status = 500,
			message = "[L>L] Old function lost its environment",
		}
	end

	hookfunction(reader, readerOriginal)

	if reader() ~= "reader" then
		return {
			status = 500,
			message = "[L>L] Restored function did not return the expected value",
		}
	end

	--// Alias test
	local envIndex, failedIndex = require("@dependencies/aliasTest.luau")({
		"hookfunc",
		"replaceclosure",
	})

	if not envIndex then
		return {
			status = 501,
			message = `Alias not found: {failedIndex}`,
		}
	end

	return {
		status = 200,
		message = "Passed",
	}
end
