defmodule FactHttpServer do
  require Logger
  require Fact
  @moduledoc """
  Documentation for `FactHttpServer`.
  """

  @doc """
  HTTP Fact Server

  ## Examples

      iex> FactHttpServer.hello()
      :world

  """
  def start_link(port: port) do
    case :gen_tcp.listen(
      port,
      active: false,  # blocks on :gen_tcp.recv/2 until data avail.
      packet: :http_bin, # think packets represented as raw binary?
      reuseaddr: true # allows to resuse addr if listener crashes
    ) do
      {:ok, socket} ->
        Logger.info("Listening for connections on port #{port}")
        {:ok, spawn_link(FactHttpServer, :accept, [socket])}

      {:error, reason} -> Logger.info("Unable to listen on port #{port}: #{reason}")
    end

    # w/o case statement
    # {:ok, socket} = :gen_tcp.listen(port, active: false, packet: :http_bin, reuseaddr: true)
    # Logger.info("Accepting connections on port #{port}")

    # {:ok, spawn_link(FactHttpServer, :accept, [socket])}
  end

  def accept(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    # require IEx; IEx.pry

    # { socket_info } = :socket.info(request)

    # Logger.info("Handling request:\n #{socket_info}")

    Logger.info("Handling request.")

    spawn(fn ->
      {_status, result } = JSON.encode([fact: Fact.get_facts])

      response =
      """
      HTTP/1.1 200\r
      Content-Type: application/json\r
      Content-Length: #{byte_size(result)}\r
      \r
      #{result}
      """

      send_response(client, response)
    end)

    accept(socket)
  end

  def send_response(socket, response) do
    Logger.info("Sending response\n #{response}")
    :gen_tcp.send(socket, response)
    :gen_tcp.close(socket)
  end

  def child_spec(opts) do
    %{id: FactHttpServer, start: {FactHttpServer, :start_link, [opts]}}
  end

end
