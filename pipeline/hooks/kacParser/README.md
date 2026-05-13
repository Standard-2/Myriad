# kacParser

A proper [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) v1.1.0-compliant Markdown parser for [Lune](https://lune-org.github.io/docs).

Supports metadata tags (`` `STABLE` ``, `` `HOTFIX` ``, etc.), blockquote notes in Unreleased blocks, reference links, and fine-grained output control.

---

## Library usage

```lua
local kacParser = require("path/to/kacParser")

local source = fs.readFile("CHANGELOG.md")

local changelog = kacParser.parse(source, {
    keepUnreleased    = true,   -- include ## [Unreleased] block (default: true)
    preserveLinks     = true,   -- parse [version]: url refs  (default: true)
    preserveNotes     = true,   -- keep > blockquotes in Unreleased (default: true)
    includePreReleases = true,  -- keep 1.0.0-beta.x releases (default: true)
    keepEmptyReleases  = true,  -- keep releases with no entries (default: true)
})

local json = kacParser.toJSON(changelog, {
    indent       = "  ",  -- indentation unit (default: two spaces)
    emitNulls    = false, -- emit null for absent fields (default: false)
    includeLinks = true,  -- include reference links (default: true)
})

fs.writeFile("changelog.json", json)
```

---

## CLI usage

```bash
lune run kacParser/init [INPUT] [OUTPUT] [OPTIONS...]
```

| Argument              | Default          | Description                                     |
| --------------------- | ---------------- | ----------------------------------------------- |
| `INPUT`               | `CHANGELOG.md`   | Path to the source Markdown file                |
| `OUTPUT`              | `changelog.json` | Path to write the JSON output                   |
| `--no-unreleased`     | —                | Omit the `[Unreleased]` block                   |
| `--no-links`          | —                | Omit reference links from output                |
| `--no-notes`          | —                | Omit blockquote notes from Unreleased           |
| `--no-pre-releases`   | —                | Omit pre-release versions (e.g. `1.0.0-beta.2`) |
| `--no-empty-releases` | —                | Omit releases with zero change entries          |
| `--emit-nulls`        | —                | Emit `null` for absent optional fields          |
| `--indent=<str>`      | `"  "`           | JSON indentation (`\t` for tabs)                |

### Examples

```bash
# Basic — parse and write JSON
lune run kacParser/init

# Custom paths
lune run kacParser/init docs/CHANGELOG.md build/changelog.json

# Strip pre-releases and unreleased block, use tab indentation
lune run kacParser/init CHANGELOG.md out.json --no-unreleased --no-pre-releases --indent=\t

# Emit nulls for all absent optional fields
lune run kacParser/init CHANGELOG.md out.json --emit-nulls
```

---

## JSON output shape

```jsonc
{
 "title": "Changelog",
 "description": "Optional preamble text", // omitted when absent (unless --emit-nulls)
 "unreleased": {
  // null when absent
  "notes": ["Current target: [1.6.3]"], // blockquote lines
  "changes": {
   "added": ["Some upcoming feature"],
  },
 },
 "releases": [
  {
   "version": "1.6.2",
   "date": "2024-03-01", // omitted when absent
   "tags": ["STABLE"], // backtick metadata tags
   "link": "https://github.com/…/compare/…", // from reference links
   "changes": {
    "added": ["Home section with a changelog tab"],
   },
  },
 ],
 "links": {
  "1.6.2": "https://github.com/…/compare/v1.6.1...v1.6.2",
 },
}
```
