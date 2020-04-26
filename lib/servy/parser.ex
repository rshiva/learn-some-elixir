defmodule Servy.Parser do

  alias Servy.Conv, as: Conv #as is optional ,default it will take Conv

  def parse(request) do
    [top, params_string] = String.split(request,"\r\n\r\n")

    [request_line | header_lines] = String.split(top,"\r\n")

    [method, path, _] = String.split(request_line," ")

    headers  = parse_headers(header_lines, %{})

    params = parse_params(headers["Content-Type"], params_string)

    

      # top
      # |> String.split("\n") 
      # |> List.first
      # |> String.split(" ")

      %Conv{
        method: method,
        path: path,
        params: params,
        headers: headers

        }
  end

  def parse_headers([head | tail], headers) do
    # IO.puts "-- #{headers}"
    [key, value] =  String.split(head,": ")
    headers = Map.put(headers, key, value)
    parse_headers(tail, headers)
  end

  def parse_headers([], headers), do: headers

  def parse_params("application/x-www-form-urlencoded",params_string) do
    params_string |> String.trim |> URI.decode_query
  end

  def parse_params(_, _), do: %{}

end