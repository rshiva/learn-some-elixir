defmodule ParserTest do
  use ExUnit.Case
  doctest Servy.Parser

  alias Servy.Parser

  test "parse a list of header to map" do

    header_list = ["A: 1", "B: 2"]

    headers = Parser.parse_headers(header_list,%{})

    assert headers == %{"A" => "1", "B" => "2"}
    
  end
end
