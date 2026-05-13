--!strict
--[[
	kacParser/lexer.luau

	Converts raw markdown source into a flat list of typed tokens.
	The lexer is intentionally simple — it classifies lines by their
	Keep-a-Changelog structural role so the parser never has to do
	raw pattern matching.

	Token kinds
	-----------
	"H1"          → # Title
	"H2_RELEASE"  → ## [version] - date `TAG` `TAG`
	"H2_UNRELEASED" → ## [Unreleased]
	"H3"          → ### Section (Added / Changed / …)
	"LIST_ITEM"   → - entry text
	"BLOCKQUOTE"  → > some note
	"REF_LINK"    → [label]: url
	"BLANK"       → empty line
	"OTHER"       → anything else (ignored during parse)
]]

export type TokenKind =
	"H1"
	| "H2_RELEASE"
	| "H2_UNRELEASED"
	| "H3"
	| "LIST_ITEM"
	| "BLOCKQUOTE"
	| "REF_LINK"
	| "BLANK"
	| "OTHER"

export type Token = {
	kind: TokenKind,
	--- The trimmed raw line (useful for debugging).
	raw: string,
	--- Extracted payload; contents depend on kind (see below).
	payload: { [string]: string | { string } },
}

-- ── helpers ────────────────────────────────────────────────────────────────

local function trim(s: string): string
	return (s:match("^%s*(.-)%s*$")) or s
end

local function split(s: string, sep: string): { string }
	local parts: { string } = {}
	for part in (s .. sep):gmatch("([^" .. sep .. "]*)" .. sep) do
		table.insert(parts, part)
	end
	return parts
end

--- Extract all backtick-delimited spans from a line, e.g. `` `STABLE` `HOTFIX` ``
local function parseTags(line: string): { string }
	local tags: { string } = {}
	for tag in line:gmatch("`([^`]+)`") do
		table.insert(tags, tag)
	end
	return tags
end

-- ── public ─────────────────────────────────────────────────────────────────

local Lexer = {}

--- Tokenise `source` and return an ordered array of tokens.
function Lexer.tokenise(source: string): { Token }
	local tokens: { Token } = {}

	for _, raw in split(source, "\n") do
		local line = trim(raw)
		local token: Token

		if line == "" then
			-- Blank line
			token = { kind = "BLANK", raw = line, payload = {} }

		elseif line:match("^#%s+(.+)") then
			-- H1: # Title
			local title = trim(line:match("^#%s+(.+)") or "")
			token = { kind = "H1", raw = line, payload = { title = title } }

		elseif line:match("^##%s+%[Unreleased%]") then
			-- H2 Unreleased (case-insensitive match)
			token = { kind = "H2_UNRELEASED", raw = line, payload = {} }

		elseif line:match("^##%s+") then
			-- H2 — only treat as a release if it contains a [version] bracket.
			-- Lines like `## Added` (malformed changelogs) are classified as OTHER
			-- so they never create phantom "unknown" releases.
			local bracketed = line:match("%[(.-)%]")
			if bracketed then
				local version = bracketed
				local date = line:match("%-%-?%s*(%d%d%d%d%-%d%d%-%d%d)")
					or line:match("%]%s*%-%s*(%d%d%d%d%-%d%d%-%d%d)")
				local tags = parseTags(line)
				token = {
					kind = "H2_RELEASE",
					raw = line,
					payload = {
						version = version,
						date = date or "",
						tags = tags,
					},
				}
			else
				token = { kind = "OTHER", raw = line, payload = {} }
			end

		elseif line:match("^###%s+") then
			-- H3: ### Section
			local section = trim(line:match("^###%s+(.+)") or ""):lower()
			token = { kind = "H3", raw = line, payload = { section = section } }

		elseif line:match("^%-%s+") then
			-- List item: - text
			local text = trim(line:match("^%-%s+(.+)") or "")
			token = { kind = "LIST_ITEM", raw = line, payload = { text = text } }

		elseif line:match("^>%s*") then
			-- Blockquote: > note
			local note = trim(line:match("^>%s*(.*)") or "")
			token = { kind = "BLOCKQUOTE", raw = line, payload = { note = note } }

		elseif line:match("^%[(.-)%]:%s*(.+)") then
			-- Reference link: [label]: url
			local label, url = line:match("^%[(.-)%]:%s*(.+)")
			if label and url then
				token = {
					kind = "REF_LINK",
					raw = line,
					payload = { label = label, url = trim(url) },
				}
			else
				token = { kind = "OTHER", raw = line, payload = {} }
			end

		else
			token = { kind = "OTHER", raw = line, payload = {} }
		end

		table.insert(tokens, token)
	end

	return tokens
end

return Lexer
