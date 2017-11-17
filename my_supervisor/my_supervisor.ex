defmodule MySupervisor do
  use GenServer

  ##API

  # call init with child_spec_list 
  # specs describe how to restart the child if crashes
  
  def start_link(child_spec_list) do
    GenServer.start_link(__MODULE__, child_spec_list)
  end

  def list_processes(pid) do
    GenServer.call(pid, :list)
  end

  ## OTP Callbacks
  # trap exits to handle dying child processes without crashing

  def init(child_spec_list)  do
    Process.flag(:trap_exit, true)
    state = child_spec_list
    |>Enum.map(&start_child/1)
    |>Enum.into(%{})
    {:ok, state}
  end

  def handle_call(:list, _from, state) do
    {:reply, state, state}
  end

  def handle_info({:EXIT, dead_pid, _reason}, state) do

    # Start new process based on dead_pid spec
    {new_pid, child_spec} = state
    |>Map.get(dead_pid)
    |>start_child()

    # Remove the dead_pid and insert the new_pid with its spec
    new_state = state
    |> Map.delete(dead_pid)
    |>Map.put(new_pid, child_spec)
    {:noreply, new_state}    
  end
  
  defp start_child({module, function, args} = spec) do
    {:ok, pid} = apply(module, function, args)
    Process.link(pid)
    {pid, spec}
  end
end
