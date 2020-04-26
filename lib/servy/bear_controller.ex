defmodule Servy.BearController do

  alias Servy.Wildthings
  alias Servy.Bear

  @templates_path Path.expand("../../templates", __DIR__)

  # \\ is default parameters
  defp render_template(conv, template, bindings \\ []) do
    content = 
        @templates_path
        |> Path.join(template)
        |> EEx.eval_file(bindings)

    %{conv | status: 200, resp_body: content}
  end


  # & == fn() -> , u can also pass arity/1 instead of &1
  def index(conv) do
    bears = 
      Wildthings.list_bears()
      # |> Enum.filter(&Bear.is_grizzly/1)
      |> Enum.sort(&Bear.order_asc_name/2)

      render_template(conv, "index.eex", bears: bears)
      # content = 
      #   @templates_path
      #   |> Path.join("index.eex")
      #   |> EEx.eval_file(bears: bears)
  end

  def show(conv, %{"id" => id}) do
    bear = Wildthings.get_bear(id)
    render_template(conv, "show.eex", bear: bear)

    # %{conv | status: 200, resp_body: content}
  end

  def create(conv, params) do
    %{conv | status: 201,
             resp_body: "Created a #{params['type']} bear name #{params['name']}" }
  end
end