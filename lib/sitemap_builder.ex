defmodule SitemapBuilder do
  @moduledoc """
  Minimal, pipeline-friendly XML sitemap generator.

  Build a sitemap by starting with `new/1`, adding entries via `add/2` or
  `add/3`, and rendering to XML with `generate/1`.

  ## Usage

      SitemapBuilder.new("https://example.com")
      |> SitemapBuilder.comment("Homepage")
      |> SitemapBuilder.add(%SitemapBuilder{url: "/en", lastmod: ~D[2026-01-01]})
      |> SitemapBuilder.comment("Posts")
      |> SitemapBuilder.add(posts, &%SitemapBuilder{url: "/posts/\#{&1.slug}", lastmod: &1.updated_at})
      |> SitemapBuilder.generate()

  Each entry is a `%SitemapBuilder{}` struct with two required fields:

  - `:url` — path relative to the host (e.g. `"/en/about"`)
  - `:lastmod` — accepts `Date`, `DateTime`, or an Ecto datetime tuple
  """

  @enforce_keys [:url, :lastmod]
  defstruct [:url, :lastmod]

  @doc "Creates a new builder for the given host URL."
  def new(host) do
    {host, []}
  end

  @doc "Adds a list of items or a single item, mapping each to a `%SitemapBuilder{}` entry via `fun`."
  def add({host, sitemap_list}, list, fun) when is_list(list) and is_function(fun) do
    {host, sitemap_list ++ Enum.map(list, fn item -> fun.(item) end)}
  end

  def add({host, sitemap_list}, item, fun) when is_function(fun) do
    {host, sitemap_list ++ [fun.(item)]}
  end

  @doc "Adds a pre-built `%SitemapBuilder{}` entry directly."
  def add({host, sitemap_list}, %SitemapBuilder{} = sitemap) do
    {host, sitemap_list ++ [sitemap]}
  end

  @doc "Inserts an XML comment into the sitemap output. Useful for grouping sections."
  def comment({host, sitemap_list}, text) when is_binary(text) do
    {host, sitemap_list ++ [{:comment, text}]}
  end

  @doc "Renders the sitemap to an XML string."
  def generate({host, sitemap_list}) when is_list(sitemap_list) do
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
    #{Enum.map(sitemap_list, &generate_entry(host, &1))}</urlset>
    """
  end

  defp generate_entry(_host, {:comment, text}) do
    "<!-- #{text} -->\n"
  end

  defp generate_entry(host, %SitemapBuilder{url: url, lastmod: lastmod}) do
    """
    <url>
      <loc>#{host <> url}</loc>
      <lastmod>#{stringify_date(lastmod)}</lastmod>
    </url>
    """
  end

  defp stringify_date({{_, _, _} = date_tuple, {_, _, _}}),
    do: date_tuple |> Date.from_erl!() |> Date.to_iso8601()

  defp stringify_date(%DateTime{} = dt),
    do: dt |> DateTime.to_date() |> Date.to_iso8601()

  defp stringify_date(%Date{} = date),
    do: Date.to_iso8601(date)

  defp stringify_date(_), do: ""
end
