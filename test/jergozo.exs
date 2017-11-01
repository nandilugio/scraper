defmodule JergozoScraperTest do
  use ExUnit.Case
  import Jergozo.Scraper

  # test "run gives us all word urls" do
  #   assert run == []
  # end
end

defmodule JergozoParserTest do
  use ExUnit.Case
  import Jergozo.Parser

  test "parses index pages and return all word URLs in it" do
    html = File.read!("test/data/jergozo_word_index.html")
    {:ok, urls, next_page_url} = word_urls_from_letter_index_page(html)

    assert Enum.count(urls) == 100
    assert next_page_url == "/letra/a/pagina/2"
  end

  test "parses term and definition" do
    html = File.read!("test/data/jergozo_definition.html")
    {:ok, definitions} = definitions_from_definition_page(html)

    assert definitions == [
      %{term: "macana", definition: "Coa, palo endurecido al fuego con que los indios labraban la tierra.", examples: [], countries: ["colombia", "costa rica", "méxico"]},
      %{term: "macana", definition: "cada una de las pinzas de la langosta o camarón", examples: [], countries: ["venezuela"]},
      %{term: "macana", definition: "porra , cachiporra (para pegar a los malosos)", examples: [], countries: ["méxico"]},
      %{term: "macana", definition: "Hueon manos de hacha (rompe todo)", examples: [], countries: ["chile"]},
      %{term: "macana", definition: "locura , mentira, estupidez", examples: [], countries: ["argentina"]},
      %{term: "macana", definition: "pene , falo", examples: [], countries: ["cuba"]},
      %{term: "macana", definition: "Expresión que se usa cuando algo está mal o da pena.", examples: ["Que macana que no puedas venir a la fiesta. \r\nEl partido de fútbol estaba una macana."], countries: ["bolivia"]},
    ]
  end
end
