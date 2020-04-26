defmodule Servy.Tracker do

  def get_location(wildthings) do
    
    :timer.sleep(500)

    locations = %{
      "roscoe" => %{lat: "44.87 N", long: "110.229 W"},
      "smokey" => %{lat: "48.77 N", long: "130.256 W"},
      "brutus" => %{lat: "22.77 N", long: "110.134 W"},
      "bigfoot" => %{lat: "28.17 N", long: "980.234 W"}
    }

    Map.get(locations, wildthings)
  end


end