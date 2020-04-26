defmodule Servy.Fetcher do

  alias Servy.VideoCam

  def async(fun) do
    parent = self() #request-handling process

    spawn(fn -> send(parent, {self(), :result, fun.()}) end)
  end

  def get_result(pid) do
    receive do {^pid, :result, value} -> value end
  end
end