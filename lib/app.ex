defmodule ContentAnalysis.App do
  def main(args) do
    filename = List.first(args)
    IO.puts("Dumping to: #{filename}")
    ContentAnalysis.Jergozo.Scraper.run(filename)
  end
end
