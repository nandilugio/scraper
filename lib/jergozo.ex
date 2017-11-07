defmodule Jergozo do
  defmodule Scraper do
    alias Jergozo.Parser

    def run do
      letter_index_first_page_urls()
      |> Enum.take(2) #TODO
      |> Enum.flat_map(&scrap_word_urls/1)
      |> Enum.take(2) #TODO
      |> Enum.flat_map(fn(word_url) ->
        word_url
        |> get_body
        |> Parser.definitions_from_definition_page
      end)
    end

    def scrap_word_urls(:nomore), do: []
    def scrap_word_urls(letter_page_url) do
      letter_page_url
      |> get_body
      |> Parser.word_urls_from_letter_index_page
      |> (fn({word_urls, next_page_url}) ->
        word_urls # ++ scrap_word_urls(next_page_url) #TODO
      end).()
    end


    defp get_body(path) do
      "http://jergozo.com" <> path
      |> HTTPotion.get!
      |> Map.get(:body)
    end

    defp letter_index_first_page_urls do
      ?a..?z
        |> Enum.map(fn(char) ->
            "/letra/#{List.to_string([char])}"
        end)
    end
  end

  #####################################################################################################################

  defmodule Parser do
    def word_urls_from_letter_index_page(html) do
      prepared_html = prepare_html(html)
      urls =
        prepared_html
        |> Floki.find(".results-list li > a")
        |> Enum.map(fn(anchor_node) ->
          anchor_node
          |> Floki.attribute("href")
          |> List.first
        end)

      next_page_url =
        prepared_html
        |> Floki.find(".pagination-container .pagination-link a:fl-contains('Siguiente')")
        |> List.first
        |> case do
          nil -> :nomore
          a_element ->
            a_element
            |> Floki.attribute("href")
            |> List.first
        end

        {urls, next_page_url}
    end

    def definitions_from_definition_page(html) do
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
    end

    defp prepare_html(html) do
      html
      #|> :unicode.characters_to_binary(:latin1)
      |> String.replace("&nbsp;"," ")
    end
  end
end
