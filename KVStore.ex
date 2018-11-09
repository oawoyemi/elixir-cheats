defmodule KVStore do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def write(key, value) do
    GenServer.cast(__MODULE__, {:write, key, value})
  end

  def read(key) do
    GenServer.call(__MODULE__, {:read, key})
  end

  def handle_cast({:write, key, value}, state) do
    {:noreply, Map.put(state, key, value)}
  end

  def handle_call({:read, key}, _, state) do
    {:reply, Map.get(state, key), state}
  end
end

defmodule Persist do
  def write_all(params) when is_map(params) do
    Enum.each(params, fn {k, v} -> KVStore.write(key, value) end)
  end

  def read_all(keys) when is_list(keys) do
    Enum.map(keys, &KVStore.read/1)
  end
end
