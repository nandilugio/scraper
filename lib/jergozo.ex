defmodule ContentAnalysis.Jergozo do
  
  defmodule Scraper do
    alias ContentAnalysis.Jergozo.Parser

    def run(filename) do
      {:ok, file} = File.open(filename, [:write])
      IO.binwrite(file, "\"Palabra\",\"Paises\",\"Definición\",\"Ejemplos\"\n")

      letter_index_first_page_paths()
      # |> Enum.take(2)
      |> Enum.flat_map(&scrap_word_paths/1)
      # |> Enum.take(2)
      |> Enum.each(fn(word_path) ->
        word_path
          |> get_page_body
          |> case do
            {:ok, body} ->
              body
                |> Parser.definitions_from_word_page
                |> Enum.map(&format_definition/1)
                |> Enum.each(&IO.binwrite(file, &1))
            {:err} ->
              IO.puts(" (!) Skipping word!")
          end
      end)

      File.close(file)
    end

    defp scrap_word_paths(:nomore), do: []
    defp scrap_word_paths(letter_page_path) do
      letter_page_path
      |> get_page_body
      |> case do
        {:ok, body} ->
          body
          |> Parser.word_paths_from_letter_index_page
          |> (fn({word_paths, next_page_path}) ->
            word_paths ++ scrap_word_paths(next_page_path)
          end).()
        {:err} ->
          IO.puts(" (!) Skipping the remainder of this letter!")
          []
      end
    end

    def get_page_body(path, opts \\ []) do
      retry = Keyword.get(opts, :retry, 3)
      "http://jergozo.com" <> path
      |> IO.inspect(label: "Retrieving")
      |> HTTPotion.get
      |> case do
        %HTTPotion.Response{body: body, status_code: 200} ->
          IO.puts("Retrieved!")
          {:ok, body}
        error_response ->
          if retry > 0 do
            IO.puts(" (!) Failed retrieving. Retrying...")
            get_page_body(path, retry: retry - 1)
          else
            IO.puts(" (!) Request failed after retries. Aborting!")
            IO.inspect(error_response)
            {:err}
          end
        end
    end

    defp format_definition(definition) do
      quoted_values = [
          definition.term,
          Enum.join(definition.countries, "/"),
          definition.definition,
          Enum.join(definition.examples, ". "),
        ]
        |> Enum.map(fn(value) ->
          escaped_value = value
            |> String.replace("\"", "\\\"")
            |> String.replace("\n", "\\n")
          "\"#{escaped_value}\""
        end)
      Enum.join(quoted_values, ",") <> "\n"
    end

    defp letter_index_first_page_paths do
      ?a..?z
        |> Enum.map(fn(char) ->
            "/letra/#{List.to_string([char])}"
        end)
    end
  end

  #####################################################################################################################

  defmodule Parser do
    def word_paths_from_letter_index_page(html) do
      prepared_html = prepare_html(html)
      urls =
        prepared_html
        |> Floki.find(".results-list li > a")
        |> Enum.map(fn(anchor_node) ->
          anchor_node
          |> Floki.attribute("href")
          |> List.first
        end)

      next_page_path =
        prepared_html
        |> Floki.find(".pagination-container .pagination-link a:fl-contains('Siguiente')")
        |> List.first
        |> case do
          nil -> :nomore
          element ->
            element
            |> Floki.attribute("href")
            |> List.first
        end

        {urls, next_page_path}
    end

    def definitions_from_word_page(html) do
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
