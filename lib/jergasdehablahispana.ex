defmodule ContentAnalysis.Scraper do
  defmodule JergasDeHablaHispana do
    def parse(html) do
      html
      |> :unicode.characters_to_binary(:latin1)
      |> String.replace("&nbsp;"," ")
      |> Floki.find("#rightbar table table")
      |> Enum.map(fn(x)-> 
        x 
        |> Floki.text
        |> parse_definition
      end)
    end

    def parse_definition(text) do
      [term | definitions] = String.split(text, ~r/\d\)/)
      definitions = definitions |> Enum.map(fn(x)-> String.trim(x) end)
      {term,country} = parse_term!(term)
      {:ok, term, country, definitions}
    end

    defp parse_term!(raw_term) do
      [_all, term, country] = Regex.run(~r/([^\(]+)\(([^\)\(]+)\)/, raw_term)
      term = String.trim(term)
      country = country |> String.trim |> String.downcase
      {term,country}
    end
  end
end
