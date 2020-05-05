defmodule Servy.PledgeServer do

  @process_name :pledge_server

  use GenServer

  defmodule State do
    defstruct cache_size: 3, pledges: []
  end

  def start do
    GenServer.start(__MODULE__, %State{}, name: @process_name)
  end

  def create_pledge(name, amount) do
    GenServer.call @process_name, {self(), :create_pledge, name, amount}
  end

  def recent_pledges do
    GenServer.call @process_name, :recent_pledges
  end

  def total_pledges do
    GenServer.call @process_name, :total_pledges
  end

  def clear do
    GenServer.cast @process_name, :clear
  end
  

  def handle_cast(:clear, state) do
    {:noreply, %{state | pledges: []}}
  end

  def handle_call(:total_pledges, _from, state) do
    total = Enum.map(state.pledges, &elem(&1,1)) |> Enum.sum
    {:reply, total, state}
  end

  def handle_call(:recent_pledges, _from, state) do
    {:reply, state.pledges, state}
  end

  def handle_call({:create_pledge, name, amount }, _from, state) do
    {:ok, id} = send_pledge_to_service(name, amount)
    most_recent_pledges = Enum.take(state.pledges,state.cache_size-1)
    cached_pledges = [ {name, amount} | most_recent_pledges]
    new_state = %{state | pledges: cached_pledges }
    {:reply, id, new_state}
  end

  defp send_pledge_to_service(_name,_amount) do
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end
end


alias Servy.PledgeServer

{:ok, pid} = PledgeServer.start()

# send pid, {:stop, "hammertime"}

IO.inspect PledgeServer.create_pledge("Shiva", 20 )
IO.inspect PledgeServer.create_pledge("Larry", 10 )
IO.inspect PledgeServer.create_pledge("Sam", 50 )

PledgeServer.clear()
IO.inspect PledgeServer.create_pledge("Grace", 30 )
IO.inspect PledgeServer.create_pledge("curly", 20 )

IO.inspect PledgeServer.recent_pledges
