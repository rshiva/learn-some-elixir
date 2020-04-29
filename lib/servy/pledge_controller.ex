defmodule Servy.PledgeController do

  def create(conv, params) do
    Servy.PledgeServer.create_pledge(params["name"], String.to_integer(params["amount"]))
    %{conv | status: 201, resp_body: "#{params["name"]} pledged #{params["amount"]} !" }
  end

  def index(conv) do
    pledges = Servy.PledgeServer.recent_pledges()

    %{conv | status: 200, resp_body: (inspect pledges) }
  end

end
