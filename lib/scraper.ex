defmodule Scraper do
  defmodule Jergozo do
    def parse(html) do
      definitions = 
        prepare_html(html)
        |> Floki.find(".word-container")
        |> Enum.map(fn(container_node) ->
          term =
            container_node
            |> Floki.find(".word-word a")
            |> Floki.text

          definition =
            container_node
            |> Floki.find(".word-definition")
            |> Floki.text

          examples =
            container_node
            |> Floki.find(".word-example-container")
            |> Enum.map(fn(example_container_node) ->
              example_container_node
              |> Floki.find(".word-example")
              |> Floki.text
            end)

          countries =
            container_node
            |> Floki.find(".word-countries a")
            |> Enum.map(&Floki.text/1)

        %{
          term: term,
          definition: definition,
          examples: examples,
          countries: countries,
        }
      end)

      {:ok, definitions}
    end

    def prepare_html(html) do
      html
      #|> :unicode.characters_to_binary(:latin1)
      |> String.replace("&nbsp;"," ")
    end
  end

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
