defmodule ScraperTest do
  use ExUnit.Case
  doctest Scraper

  #  test "parses term and definition" do
  #    html = File.read!("test/data/jergasdehablahispana_definition.html")
  #    {:ok, {term, definitions}} = Scraper.JergasDeHablaHispana.parse(html)
  #    assert(term == "pelotudo")
  #    assert definitions == [
  #      {"Argentina", ["individuo torpe,  inútil, indolente. \"Sos pelotudo, tenías que armar esa lámpara al revés\", le dijo Ramón a su amigo. / La vieja estaba tirada en la calle, y todos alrededor seguían caminando, haciéndose los pelotudos.","estúpido. Si será pelotuda ésa: dejó las llaves colgadas en la puerta de su casa."]},
  #    ]
  #  end

  test "parses definition" do
    raw = "pelotudo(Argentina) (sust./adj.) 1) individuo torpe,  inútil, indolente. \"Sos pelotudo, tenías que armar esa lámpara al revés\", le dijo Ramón a su amigo. / La vieja estaba tirada en la calle, y todos alrededor seguían caminando, haciéndose los pelotudos.  2) estúpido. Si será pelotuda ésa: dejó las llaves colgadas en la puerta de su casa." 
    {:ok, term, country, definitions} = Scraper.JergasDeHablaHispana.parse_definition(raw)
    assert term == "pelotudo"
    assert country == "argentina"
    assert definitions == [
      "individuo torpe,  inútil, indolente. \"Sos pelotudo, tenías que armar esa lámpara al revés\", le dijo Ramón a su amigo. / La vieja estaba tirada en la calle, y todos alrededor seguían caminando, haciéndose los pelotudos.",
      "estúpido. Si será pelotuda ésa: dejó las llaves colgadas en la puerta de su casa."
    ]
  end
end
