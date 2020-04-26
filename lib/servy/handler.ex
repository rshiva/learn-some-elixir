defmodule Servy.Handler do
  @moduledoc "Handles HTTP request"

  alias Servy.Conv
  alias Servy.BearController
  alias Servy.VideoCam
  alias Servy.Fetcher
  # alias Servy.Api.BearController, as: ApiBearController

  @pages_path Path.expand("../../pages", __DIR__) #like a constant , module attributes
  import Servy.Plugins
  import Servy.Parser, only: [parse: 1]
  @doc "Transform request to response"
  def handle(request) do
    request
    |> parse
    |> rewrite_path
    |> log
    |> route
    |> Servy.Plugins.track
    |> format_response
  end


  # def route(conv) do
  #   route(conv,conv.method, conv.path)
  # end

  #function arity(parameter) using pattern matching

  def route(%Conv{method: "GET", path: "/hibernate/" <> time} = conv ) do
    time |> String.to_integer |> :timer.sleep

    %{conv | status: 200, resp_body: "Awake!"}
  end


  def route(%Conv{method: "GET", path: "/snapshots"} = conv ) do

    #Task is same as Fetcher but inbuild in Elixir 
    pid1 = Fetcher.async(fn -> VideoCam.get_snapshot("cam-1") end )
    pid2 = Fetcher.async(fn -> VideoCam.get_snapshot("cam-2") end )
    pid3 = Fetcher.async(fn -> VideoCam.get_snapshot("cam-3") end )
    task = Task.async(fn -> Servy.Tracker.get_location("bigfoot") end )

    where_is_bigfoot = Task.await(task)
    snapshot1 = Fetcher.get_result(pid1)
    snapshot2 = Fetcher.get_result(pid2)
    snapshot3 = Fetcher.get_result(pid3)

    snapshot = [snapshot1,snapshot2,snapshot3]


    %{conv | status: 200, resp_body: inspect {snapshot,where_is_bigfoot}}
  end

  def route(%Conv{method: "GET", path: "/wildthings"} = conv ) do
    %{conv | status: 200, resp_body: "Bears, Lions, Tigers"}
  end

  def route(%Conv{method: "GET", path: "/api/bears"} = conv) do
    Servy.Api.BearController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/bears"} = conv) do
    BearController.index(conv)
  end

  # def route(conv, "GET", "/bears" <> id) do 
  def route(%Conv{method: "GET", path: "/bears/" <> id} = conv) do 
    params = Map.put(conv.params, "id", id)
    BearController.show(conv,params)
  end

  #Post request
  def route(%Conv{method: "POST", path: "/bears"} = conv) do 
    BearController.create(conv, conv.params)
  end



  def route(%Conv{method: "GET", path: "/about"} = conv ) do
    @pages_path
    |> Path.join("about.html")
    |> File.read
    |> handle_file(conv)
  end

  def route(%Conv{path: path} = conv) do
    %{conv | status: 404, resp_body: "No #{path} here!!" }
  end
  
  def handle_file({:ok, content}, conv) do
    %{conv | status: 200, resp_body: content}
  end

  def handle_file({:ok, :enoent}, conv) do
    %{conv | status: 404, resp_body: "File not found"}
  end


  def handle_file({:error, reason}, conv) do
    %{conv | status: 500, resp_body: "File error: #{reason}"}
  end


  # def route(%{method: "GET", path: "/about"} = conv ) do
  #   file =
  #     Path.expand("../..pages", __DIR__)
  #     |> Path.join("about.html")
  #   case File.read(file) do
  #     {:ok, content} -> 
  #       %{conv | status: 200, resp_body: content}
  #     {:ok, :enoent} ->
  #       %{conv | status: 404, resp_body: "File not found"}
  #     {:error, reason} ->
  #       %{conv | status: 500, resp_body: "File error: #{reason}"}
  #   end
  # end

  
  
  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}\r
    Content-Type: #{conv.resp_content_type}\r
    Content-Length: #{String.length(conv.resp_body)}\r
    \r
    #{conv.resp_body}
    """
  end
end

# request = """
# GET /wildthings HTTP/1.1
# Host: example.com
# User-Agent: ExampleBrowser/1.0
# Accept: */*
# Content-Type: text/html
# Content-Length: 21

# """

# response = Servy.Handler.handle(request)
# IO.puts response

# request = """
# GET /wildlife HTTP/1.1
# Host: example.com
# User-Agent: ExampleBrowser/1.0
# Accept: */*
# Content-Type: text/html
# Content-Length: 21

# """

# response = Servy.Handler.handle(request)
# IO.puts response


# request = """
# GET /bears HTTP/1.1
# Host: example.com
# User-Agent: ExampleBrowser/1.0
# Accept: */*
# Content-Type: text/html
# Content-Length: 21

# """
# response = Servy.Handler.handle(request)
# IO.puts response


# request = """
# GET /api/bears HTTP/1.1
# Host: example.com
# User-Agent: ExampleBrowser/1.0
# Accept: */*
# Content-Type: application/json
# Content-Length: 21

# """
# response = Servy.Handler.handle(request)
# IO.puts response

# request = """
# GET /bigfoot HTTP/1.1
# Host: example.com
# User-Agent: ExampleBrowser/1.0
# Accept: */*
# Content-Type: text/html
# Content-Length: 21

# """
# response = Servy.Handler.handle(request)
# IO.puts response


# request = """
# GET /bears/1 HTTP/1.1
# Host: example.com
# User-Agent: ExampleBrowser/1.0
# Accept: */*
# Content-Type: text/html
# Content-Length: 21

# """
# response = Servy.Handler.handle(request)
# IO.puts response

# request = """
# GET /about HTTP/1.1
# Host: example.com
# User-Agent: ExampleBrowser/1.0
# Accept: */*
# Content-Type: text/html
# Content-Length: 21

# """
# response = Servy.Handler.handle(request)
# IO.puts response


# request = """
# POST /bears HTTP/1.1
# HOST: example.com
# User-Agent: ExampleBrowser/1.0
# Accept: */*
# Content-Type: application/x-www-form-urlencoded
# Content-Length: 21

# name=Baloo&type=Brown
# """
# response = Servy.Handler.handle(request)
# IO.puts response


# expected_response= """
# HTTP/1.1 200 OK
# Content-Type: text/html
# Content-Length: 20

# Bears, Lions, Tigers
# """
