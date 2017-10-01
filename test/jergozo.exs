defmodule ScraperTest do
  use ExUnit.Case
  doctest Scraper

  test "parses term and definition" do
    html = File.read!("test/data/jergozo_definition.html")
    {:ok, definitions} = Scraper.Jergozo.parse(html)

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
