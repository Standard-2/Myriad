--!nocheck
--!nolint

return {
	global = "hookfunction",
	dependencies = {
		checks = {
			"Closures.newcclosure",
			"Closures.clonefunction",
		},
		globals = {
			"getfenv",
			"setfenv",
		},
	},
	aliases = {
		"hookfunc",
		"replaceclosure",
	},
	cases = {
		{
			id = "[L>L] 1",
			run = function()
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
						message = "This should never evaluate. Did a cosmic ray hit your computer and flip a bit?",
					}
				end

				local original = hookfunction(function1, function2)

				if function1() ~= 2 then
					return {
						status = 500,
						message = "Hooked function did not return the expected value",
					}
				elseif original() ~= 1 then
					return {
						status = 500,
						message = "Old function did not return the expected value",
					}
				end

				hookfunction(function1, original)

				if function1() ~= 1 then
					return {
						status = 500,
						message = "Restored function did not return the expected value",
					}
				end

				return { status = 200, message = "Passed" }
			end,
		},
		{
			id = "[L>L] 2",
			run = function()
				local function function1()
					return 1
				end

				local function function2()
					return 2
				end

				local nameBefore, sourceBefore, lineBefore = debug.info(function1, "nsl")
				local original = hookfunction(function1, function2)
				local nameAfter, sourceAfter, lineAfter = debug.info(function1, "nsl")

				hookfunction(function1, original)

				if nameAfter ~= nameBefore or sourceAfter ~= sourceBefore or lineAfter ~= lineBefore then
					return {
						status = 500,
						message = "Hook changed the function's debug info",
					}
				end

				return { status = 200, message = "Passed" }
			end,
		},
		{
			id = "[L>L] 3",
			run = function()
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
						message = "Hooked function did not use the hook's upvalue",
					}
				elseif keptOriginal() ~= kept then
					return {
						status = 500,
						message = "Old function lost its upvalue",
					}
				end

				hookfunction(readsKept, keptOriginal)

				return { status = 200, message = "Passed" }
			end,
		},
		{
			id = "[L>L] 4",
			run = function()
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
						message = `Failed to hook: {capturedErr}`,
					}
				end

				local captured = table.pack(relay("a", nil, "b"))
				if captured.n ~= 4 or captured[1] ~= 3 or captured[2] ~= "a" or captured[4] ~= "b" then
					hookfunction(relay, capturedErr)
					return {
						status = 500,
						message = "Hook did not pass nil arguments through",
					}
				end

				hookfunction(relay, capturedErr)

				return { status = 200, message = "Passed" }
			end,
		},
		{
			id = "[L>L] 5",
			run = function()
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
					hookfunction(counted, countedOriginal)
					return {
						status = 500,
						message = "Calling the old function re-entered the hook",
					}
				end

				hookfunction(counted, countedOriginal)

				return { status = 200, message = "Passed" }
			end,
		},
		{
			id = "[L>L] 6",
			run = function()
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
				local hookedResult = base()
				local originalResult = first()

				hookfunction(base, first)

				if hookedResult ~= "top" then
					return {
						status = 500,
						message = "A second hook did not replace the first",
					}
				elseif originalResult ~= "base" then
					return {
						status = 500,
						message = "The first returned function no longer runs the original",
					}
				elseif not displacedOk or displaced == "top" then
					return {
						status = 500,
						message = "The function returned by the second hook re-entered the active hook",
					}
				end

				return { status = 200, message = "Passed" }
			end,
		},
		{
			id = "[L>L] 7",
			run = function()
				local function plain()
					return "plain"
				end

				local function yielder()
					return coroutine.yield("paused")
				end

				local original = hookfunction(plain, yielder)

				local thread = coroutine.create(function()
					return plain()
				end)

				local resumed, yielded = coroutine.resume(thread)
				if not resumed or coroutine.status(thread) ~= "suspended" or yielded ~= "paused" then
					hookfunction(plain, original)
					return {
						status = 500,
						message = `Hook did not yield the caller: {yielded}`,
					}
				end

				local resumedAgain, continued = coroutine.resume(thread, "continued")
				hookfunction(plain, original)

				if not resumedAgain or continued ~= "continued" or coroutine.status(thread) ~= "dead" then
					return {
						status = 500,
						message = "Resuming a hooked yield did not continue the hook",
					}
				end

				return { status = 200, message = "Passed" }
			end,
		},
		{
			id = "[L>L] 8",
			run = function()
				local function calm()
					return "calm"
				end

				local function boom()
					error("hook-body")
				end

				local original = hookfunction(calm, boom)
				local calmOk, calmErr = pcall(calm)
				hookfunction(calm, original)

				if calmOk or string.find(tostring(calmErr), "hook-body", 1, true) == nil then
					return {
						status = 500,
						message = "Hook error did not reach the caller",
					}
				end

				return { status = 200, message = "Passed" }
			end,
		},
		{
			id = "[L>NC]",
			run = function()
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
						message = `Failed to hook: {luaOriginal}`,
					}
				elseif luaSide() ~= "wrapped" then
					hookfunction(luaSide, luaOriginal)
					return {
						status = 500,
						message = "Hooked function did not return the expected value",
					}
				elseif luaOriginal() ~= "lua-side" then
					hookfunction(luaSide, luaOriginal)
					return {
						status = 500,
						message = "Old function did not return the expected value",
					}
				end

				hookfunction(luaSide, luaOriginal)

				if luaSide() ~= "lua-side" then
					return {
						status = 500,
						message = "Restored function did not return the expected value",
					}
				end

				return { status = 200, message = "Passed" }
			end,
		},
		{
			id = "[L>C]",
			run = function()
				local function letter()
					return "letter"
				end

				local letterName, letterSource, letterLine = debug.info(letter, "nsl")
				local asChar = clonefunction(utf8.char)
				local letterHooked, letterOriginal = pcall(hookfunction, letter, asChar)
				if not letterHooked then
					return {
						status = 500,
						message = `Failed to hook: {letterOriginal}`,
					}
				elseif letter(65) ~= "A" then
					hookfunction(letter, letterOriginal)
					return {
						status = 500,
						message = "Hooked function did not return the expected value",
					}
				elseif letterOriginal() ~= "letter" then
					hookfunction(letter, letterOriginal)
					return {
						status = 500,
						message = "Old function did not return the expected value",
					}
				end

				local letterNameNow, letterSourceNow, letterLineNow = debug.info(letter, "nsl")
				hookfunction(letter, letterOriginal)

				if letterNameNow ~= letterName or letterSourceNow ~= letterSource or letterLineNow ~= letterLine then
					return {
						status = 500,
						message = "Hook changed the function's debug info",
					}
				elseif letter() ~= "letter" then
					return {
						status = 500,
						message = "Restored function did not return the expected value",
					}
				end

				return { status = 200, message = "Passed" }
			end,
		},
		{
			id = "[NC>L]",
			run = function()
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
						message = `Failed to hook: {wrappedOriginal}`,
					}
				elseif wrappedBody() ~= "from-lua" then
					hookfunction(wrappedBody, wrappedOriginal)
					return {
						status = 500,
						message = "Hooked function did not return the expected value",
					}
				elseif wrappedOriginal() ~= "wrapped-body" then
					hookfunction(wrappedBody, wrappedOriginal)
					return {
						status = 500,
						message = "Old function did not return the expected value",
					}
				end

				hookfunction(wrappedBody, wrappedOriginal)

				if wrappedBody() ~= "wrapped-body" then
					return {
						status = 500,
						message = "Restored function did not return the expected value",
					}
				end

				return { status = 200, message = "Passed" }
			end,
		},
		{
			id = "[NC>NC]",
			run = function()
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
						message = `Failed to hook: {ncOriginal}`,
					}
				elseif firstNc() ~= "second" then
					hookfunction(firstNc, ncOriginal)
					return {
						status = 500,
						message = "Hooked function did not return the expected value",
					}
				elseif ncOriginal() ~= "first" then
					hookfunction(firstNc, ncOriginal)
					return {
						status = 500,
						message = "Old function did not return the expected value",
					}
				end

				hookfunction(firstNc, ncOriginal)

				if firstNc() ~= "first" then
					return {
						status = 500,
						message = "Restored function did not return the expected value",
					}
				end

				return { status = 200, message = "Passed" }
			end,
		},
		{
			id = "[NC>C]",
			run = function()
				local ncForC = newcclosure(function()
					return "nc"
				end)

				local charHook = clonefunction(utf8.char)
				local ncForCHooked, ncForCOriginal = pcall(hookfunction, ncForC, charHook)
				if not ncForCHooked then
					return {
						status = 500,
						message = `Failed to hook: {ncForCOriginal}`,
					}
				elseif ncForC(66) ~= "B" then
					hookfunction(ncForC, ncForCOriginal)
					return {
						status = 500,
						message = "Hooked function did not return the expected value",
					}
				elseif ncForCOriginal() ~= "nc" then
					hookfunction(ncForC, ncForCOriginal)
					return {
						status = 500,
						message = "Old function did not return the expected value",
					}
				end

				hookfunction(ncForC, ncForCOriginal)

				if ncForC() ~= "nc" then
					return {
						status = 500,
						message = "Restored function did not return the expected value",
					}
				end

				return { status = 200, message = "Passed" }
			end,
		},
		{
			id = "[C>L]",
			run = function()
				local measure = clonefunction(utf8.len)

				local function substitute()
					return 11
				end

				local measureHooked, measureOriginal = pcall(hookfunction, measure, substitute)
				if not measureHooked then
					return {
						status = 500,
						message = `Failed to hook: {measureOriginal}`,
					}
				elseif measure("ab") ~= 11 then
					hookfunction(measure, measureOriginal)
					return {
						status = 500,
						message = "Hooked function did not return the expected value",
					}
				elseif measureOriginal("ab") ~= 2 then
					hookfunction(measure, measureOriginal)
					return {
						status = 500,
						message = "Old function did not return the expected value",
					}
				end

				hookfunction(measure, measureOriginal)

				if measure("abcd") ~= 4 then
					return {
						status = 500,
						message = "Restored function did not return the expected value",
					}
				end

				return { status = 200, message = "Passed" }
			end,
		},
		{
			id = "[C>NC]",
			run = function()
				local countedLength = clonefunction(utf8.len)
				local fixedLength = newcclosure(function()
					return 9
				end)

				local countedHooked, countedLengthOriginal = pcall(hookfunction, countedLength, fixedLength)
				if not countedHooked then
					return {
						status = 500,
						message = `Failed to hook: {countedLengthOriginal}`,
					}
				elseif countedLength("ab") ~= 9 then
					hookfunction(countedLength, countedLengthOriginal)
					return {
						status = 500,
						message = "Hooked function did not return the expected value",
					}
				elseif countedLengthOriginal("ab") ~= 2 then
					hookfunction(countedLength, countedLengthOriginal)
					return {
						status = 500,
						message = "Old function did not return the expected value",
					}
				end

				hookfunction(countedLength, countedLengthOriginal)

				if countedLength("a") ~= 1 then
					return {
						status = 500,
						message = "Restored function did not return the expected value",
					}
				end

				return { status = 200, message = "Passed" }
			end,
		},
		{
			id = "[C>C]",
			run = function()
				local codepoint = clonefunction(utf8.codepoint)
				local length = clonefunction(utf8.len)
				local lengthHooked, lengthOriginal = pcall(hookfunction, length, codepoint)
				if not lengthHooked then
					return {
						status = 500,
						message = `Failed to hook: {lengthOriginal}`,
					}
				elseif length("A") ~= 65 then
					hookfunction(length, lengthOriginal)
					return {
						status = 500,
						message = "Hooked function did not return the expected value",
					}
				elseif lengthOriginal("A") ~= 1 then
					hookfunction(length, lengthOriginal)
					return {
						status = 500,
						message = "Old function did not return the expected value",
					}
				end

				hookfunction(length, lengthOriginal)

				if length("AB") ~= 2 then
					return {
						status = 500,
						message = "Restored function did not return the expected value",
					}
				end

				return { status = 200, message = "Passed" }
			end,
		},
		{
			id = "[L>L] 9",
			run = function()
				local bindable = Instance.new("BindableFunction")
				local function onInvoke(value)
					return "invoke-" .. tostring(value)
				end

				bindable.OnInvoke = onInvoke

				local invokeOriginal = hookfunction(onInvoke, function(value)
					return "hooked-" .. tostring(value)
				end)

				local invokedOk, invoked = pcall(function()
					return bindable:Invoke("z")
				end)
				bindable:Destroy()
				hookfunction(onInvoke, invokeOriginal)

				if not invokedOk then
					return {
						status = 500,
						message = `Engine callback did not call the hook: {invoked}`,
					}
				elseif invoked ~= "hooked-z" then
					return {
						status = 500,
						message = "Engine callback did not call the hook",
					}
				elseif invokeOriginal("z") ~= "invoke-z" then
					return {
						status = 500,
						message = "Old callback did not keep its behavior",
					}
				end

				return { status = 200, message = "Passed" }
			end,
		},
		{
			id = "arguments",
			run = function()
				local oneOk = pcall(hookfunction, function() end)
				if oneOk then
					return {
						status = 500,
						message = "hookfunction accepted one argument",
					}
				end

				return { status = 200, message = "Passed" }
			end,
		},
		{
			id = "type",
			run = function()
				local typeOk = pcall(hookfunction, "nope", function() end)
				if typeOk then
					return {
						status = 500,
						message = "hookfunction accepted a non-function",
					}
				end

				return { status = 200, message = "Passed" }
			end,
		},
		{
			id = "[L>L] 10",
			run = function()
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
						message = "setfenv did not apply to the function under test",
					}
				end

				local readerOriginal = hookfunction(reader, writer)

				if reader() ~= "writer" then
					hookfunction(reader, readerOriginal)
					return {
						status = 500,
						message = "Hook ran in the target environment",
					}
				elseif readerOriginal() ~= "reader" then
					hookfunction(reader, readerOriginal)
					return {
						status = 500,
						message = "Old function lost its environment",
					}
				end

				local oldEnvOk, oldEnv = pcall(getfenv, readerOriginal)
				hookfunction(reader, readerOriginal)

				if not oldEnvOk or oldEnv ~= env then
					return {
						status = 500,
						message = "Old function lost its environment",
					}
				elseif reader() ~= "reader" then
					return {
						status = 500,
						message = "Restored function did not return the expected value",
					}
				end

				return { status = 200, message = "Passed" }
			end,
		},
	},
}
