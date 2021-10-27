defmodule Fact do
  def get_facts do
    # MAybe this should be done elsewhere?
    Application.ensure_all_started(:inets)
    Application.ensure_all_started(:ssl)

    facts_uri = "https://www.mentalfloss.com/api/facts?page=1&limit=1&cb=0.24153849263177496"
    JSON.encode([fact: "The world wastes about 1 billion metric tons of food each year 😢."])
    # JSON.encode([facts: facts]


    {:ok, {{'HTTP/1.1', 200, 'OK'}, _headers, body}} = :httpc.request(:get, {facts_uri, []}, [], [])

    {_status, result} = JSON.decode(body)

    Enum.at(result, Enum.random(0..length(result)))["fact"]
  end
end
