# SitemapBuilder

Minimal, pipeline-friendly XML sitemap generator.

## Why

The existing sitemap packages for Elixir are built for writing to files or S3. If you just want to return XML from a Phoenix controller, they are significant overkill. SitemapBuilder renders to a string and stays out of the way.

## Status

Used in production. Updates only for Elixir version compatibility.

## Installation

```elixir
def deps do
  [{:sitemap_builder, "~> 0.1"}]
end
```

## Usage

```elixir
sitemap_xml =
  SitemapBuilder.new(MyAppWeb.Endpoint.url())
  |> SitemapBuilder.add(%SitemapBuilder{url: "/en", lastmod: ~D[2026-01-01]})
  |> SitemapBuilder.add(posts, &%SitemapBuilder{url: "/posts/#{&1.slug}", lastmod: &1.updated_at})
  |> SitemapBuilder.generate()

conn
|> put_resp_content_type("text/xml")
|> text(sitemap_xml)
```

### Entry struct

Each entry is a `%SitemapBuilder{}` with two required fields:

- `:url` — path relative to the host (e.g. `"/en/about"`)
- `:lastmod` — accepts `Date`, `DateTime`, or an Ecto datetime tuple

## License

MIT
