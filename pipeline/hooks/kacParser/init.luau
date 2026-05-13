--!strict
--[[
	kacParser/init.luau

	Public API surface for the kacParser package.

	Usage (as a library)
	────────────────────
	  local kacParser = require("path/to/kacParser")

	  local changelog = kacParser.parse(source, {
	      keepUnreleased   = true,
	      preserveLinks    = true,
	      preserveNotes    = true,
	      includePreReleases = true,
	      keepEmptyReleases  = false,
	  })

	  local json = kacParser.toJSON(changelog, {
	      indent      = "  ",
	      emitNulls   = false,
	      includeLinks = true,
	  })

	Usage (as a CLI tool via Lune)
	──────────────────────────────
	  lune run kacParser/init [INPUT] [OUTPUT] [OPTIONS...]

	  Options:
	    --no-unreleased          Omit the [Unreleased] block
	    --no-links               Omit reference links
	    --no-notes               Omit blockquote notes from Unreleased
	    --no-pre-releases        Omit pre-release versions (e.g. 1.0.0-beta.2)
	    --no-empty-releases      Omit releases with no change entries
	    --emit-nulls             Emit null for absent optional fields
	    --indent=<string>        JSON indentation (default: two spaces)

	  Example:
	    lune run kacParser/init CHANGELOG.md out.json --no-unreleased --no-pre-releases
]]

local Parser = require("@self/parser")
local Serialiser = require("@self/serialiser")
local Types = require("@self/types")

-- Re-export types for consumers
export type Changelog = Types.Changelog
export type Release = Types.Release
export type ChangeSection = Types.ChangeSection
export type ChangeEntry = Types.ChangeEntry
export type ParseOptions = Types.ParseOptions
export type SerialiseOptions = Types.SerialiseOptions

local kacParser = {}

--- Parse a Keep a Changelog-formatted markdown string.
---
--- @param source      Raw markdown text.
--- @param options     Optional parse configuration (all fields default to `true`).
--- @return            A fully typed `Changelog` value.
function kacParser.parse(source: string, options: ParseOptions?): Changelog
	return Parser.parse(source, options)
end

--- Serialise a `Changelog` value to a pretty-printed JSON string.
---
--- @param changelog   The changelog to serialise.
--- @param options     Optional serialiser configuration.
--- @return            A JSON string.
function kacParser.toJSON(changelog: Changelog, options: SerialiseOptions?): string
	return Serialiser.toJSON(changelog, options)
end

-- ── CLI entry point (Lune only) ────────────────────────────────────────────

-- Guard: only run CLI code when `process` and `fs` are available (i.e. under Lune).
local ok_fs, fs = pcall(require, "@lune/fs")
local ok_proc, process = pcall(require, "@lune/process")

if ok_fs and ok_proc and fs and process then
	-- ── argument parsing ──────────────────────────────────────────────
	local args: { string } = process.args

	local inputPath = "CHANGELOG.md"
	local outputPath = "changelog.json"
	local positional = 0

	local parseOpts: ParseOptions = {}
	local serialOpts: SerialiseOptions = {}

	for _, arg in args do
		if arg:sub(1, 2) == "--" then
			-- Flag or key=value option
			local key, val = arg:match("^%-%-([^=]+)=?(.*)")
			if key == "no-unreleased" then
				parseOpts.keepUnreleased = false
			elseif key == "no-links" then
				parseOpts.preserveLinks = false
				serialOpts.includeLinks = false
			elseif key == "no-notes" then
				parseOpts.preserveNotes = false
			elseif key == "no-pre-releases" then
				parseOpts.includePreReleases = false
			elseif key == "no-empty-releases" then
				parseOpts.keepEmptyReleases = false
			elseif key == "emit-nulls" then
				serialOpts.emitNulls = true
			elseif key == "indent" and val and val ~= "" then
				-- --indent="\t" or --indent="    "
				-- Unescape common escape sequences entered on the command line
				local unescaped = val:gsub("\\t", "\t"):gsub("\\n", "\n")
				serialOpts.indent = unescaped
			else
				print("[warn] Unknown option: " .. arg)
			end
		else
			positional += 1
			if positional == 1 then
				inputPath = arg
			elseif positional == 2 then
				outputPath = arg
			end
		end
	end

	-- ── read input ────────────────────────────────────────────────────
	local readOk, source = pcall(fs.readFile, inputPath)
	if not readOk or type(source) ~= "string" then
		print("[error] Could not read: " .. inputPath)
		process.exit(1)
	end

	-- ── parse & serialise ─────────────────────────────────────────────
	local changelog = kacParser.parse(source :: string, parseOpts)
	local json = kacParser.toJSON(changelog, serialOpts)

	-- ── write output ──────────────────────────────────────────────────
	local writeOk, writeErr = pcall(fs.writeFile, outputPath, json)
	if not writeOk then
		print("[error] Could not write: " .. tostring(writeErr))
		process.exit(1)
	end

	local relCount = #changelog.releases
	local tagCount = 0
	for _ in changelog.links do
		tagCount += 1
	end

	print(string.format(
		"[ok] %d release(s), %d link(s) → %s",
		relCount,
		tagCount,
		outputPath
	))
end

return kacParser
