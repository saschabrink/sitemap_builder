# Changelog

## [0.1.3] - 2026-06-12

### Changed
- Repository moved to https://github.com/saschabrink/sitemap_builder — package
  metadata, docs links, and license now reflect the maintainer's real name.
- CI tests against Elixir 1.19 and 1.20 via the Nix flake dev shells.
- README badges for Hex version, docs, CI status, and license.

## [0.1.2] - 2026-04-18

### Added
- `usage-rules.md` — ships with the hex package so tools like `usage_rules`
  and memex `deps` sources can surface it to AI agents.

## [0.1.1] - 2026-04-15

### Added
- `comment/2` — inserts an XML comment into the sitemap output for grouping sections

## [0.1.0] - 2026-04-14

### Added
- `SitemapBuilder` struct with `:url` and `:lastmod` fields
- `new/1` — creates a builder for a given host URL
- `add/2` — adds a pre-built entry
- `add/3` — maps a single item or a list to entries via a function
- `generate/1` — renders to XML string
- `lastmod` accepts `Date`, `DateTime`, and Ecto datetime tuples
