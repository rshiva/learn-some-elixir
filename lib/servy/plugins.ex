defmodule Servy.Plugins do

  alias Servy.Conv

  def track(%Conv{status: 404, path: path} = conv) do
    IO.puts "Warning #{path} is not present"
    conv
  end

  def track(%Conv{} = conv), do: conv


  def rewrite_path(%Conv{path: "/wildlife"} = conv) do
    %{conv | path: "/wildthings"}
  end

  def rewrite_path(%Conv{} = conv), do: conv

  def log(%Conv{} = conv), do: IO.inspect conv
end