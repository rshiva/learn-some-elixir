defmodule Servy.GenericServer do

  #__MODULE__  = name of the current module
  def start(callback_module,initial_state, process_name) do
    pid = spawn(__MODULE__, :listen_loop, [initial_state, callback_module])
    Process.register(pid, process_name)
    pid
  end

  def call(pid, message) do
    send pid, {:call, self(), message}
    receive do {:response, response} -> response end
  end

  def cast(pid, message) do
    send pid, {:cast, message}
  end

  def listen_loop(state,callback_module) do
    # IO.puts "Waiting for message ...."
    receive do
      {:call, sender_pid, message} when is_pid(sender_pid) ->
        {response, new_state} = callback_module.handle_call(message, state)
        send sender_pid, {:response, response}
        listen_loop(new_state,callback_module)
      {:cast, message} ->
        new_state = Servy.PledgeServer.handle_cast(message, state)
        listen_loop(new_state,callback_module)
      unexpected ->
        IO.puts "Unexpected message #{inspect unexpected}"
        listen_loop(state,callback_module)
    end
  end

end

defmodule Servy.PledgeServer do

  alias Servy.GenericServer

  @process_name :pledge_server

  def start do
    GenericServer.start(__MODULE__, [], @process_name)
  end

  def create_pledge(name, amount) do
    GenericServer.call @process_name, {self(), :create_pledge, name, amount}
  end

  def recent_pledges do
    GenericServer.call @process_name, :recent_pledges
  end

  def total_pledges do
    GenericServer.call @process_name, :total_pledges
  end

  def clear do
    GenericServer.cast @process_name, :clear
  end
  

  def handle_cast(:clear, _state) do
    []
  end

  def handle_call(:total_pledges, state) do
    total = Enum.map(state, &elem(&1,1)) |> Enum.sum
    {total, state}
  end

  def handle_call(:recent_pledges, state) do
    {state, state}
  end

  def handle_call({:create_pledge, name, amount }, state) do
    {:ok, id} = send_pledge_to_service(name, amount)
    most_recent_pledges = Enum.take(state,2)
    new_state = [ {name, amount} | most_recent_pledges]
    {id, new_state}
  end

  defp send_pledge_to_service(_name,_amount) do
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end
end


alias Servy.PledgeServer

pid = PledgeServer.start()

send pid, {:stop, "hammertime"}

IO.inspect PledgeServer.create_pledge("Shiva", 20 )
IO.inspect PledgeServer.create_pledge("Larry", 10 )
IO.inspect PledgeServer.create_pledge("Sam", 50 )

PledgeServer.clear()
IO.inspect PledgeServer.create_pledge("Grace", 30 )
IO.inspect PledgeServer.create_pledge("curly", 20 )

IO.inspect PledgeServer.recent_pledges
