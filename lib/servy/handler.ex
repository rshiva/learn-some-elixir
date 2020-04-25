defmodule Servy.Handler do
  @moduledoc "Handles HTTP request"

  alias Servy.Conv
  alias Servy.BearController

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
  def route(%Conv{method: "GET", path: "/wildthings"} = conv ) do
    %{conv | status: 200, resp_body: "Bears, Lions, Tigers"}
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
    HTTP/1.1 #{Conv.full_status(conv)}
    Content-Type: text/html
    Content-Length: #{String.length(conv.resp_body)}

    #{conv.resp_body}
    """
  end
end

request = """
GET /wildthings HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*
Content-Type: text/html
Content-Length: 21

"""

response = Servy.Handler.handle(request)
IO.puts response

request = """
GET /wildlife HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*
Content-Type: text/html
Content-Length: 21

"""

response = Servy.Handler.handle(request)
IO.puts response


request = """
GET /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*
Content-Type: text/html
Content-Length: 21

"""
response = Servy.Handler.handle(request)
IO.puts response

request = """
GET /bigfoot HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*
Content-Type: text/html
Content-Length: 21

"""
response = Servy.Handler.handle(request)
IO.puts response


request = """
GET /bears/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*
Content-Type: text/html
Content-Length: 21

"""
response = Servy.Handler.handle(request)
IO.puts response

request = """
GET /about HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*
Content-Type: text/html
Content-Length: 21

"""
response = Servy.Handler.handle(request)
IO.puts response


request = """
POST /bears HTTP/1.1
HOST: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*
Content-Type: application/x-www-form-urlencoded
Content-Length: 21

name=Baloo&type=Brown
"""
response = Servy.Handler.handle(request)
IO.puts response


# expected_response= """
# HTTP/1.1 200 OK
# Content-Type: text/html
# Content-Length: 20

# Bears, Lions, Tigers
# """
