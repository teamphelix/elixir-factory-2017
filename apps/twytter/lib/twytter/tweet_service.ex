defmodule Twytter.TweetService do
  
  use GenServer

  def fetch_topic(pid, hashtag) do
    GenServer.call(pid, {:update, hashtag})
  end

  def track_topic(pid, hashtag) do
    GenServer.cast(pid, {:track, hashtag})
  end

  def track_user(pid, username) do
    GenServer.cast(pid, {:track_user, username})
  end

  def stop_tracking(pid, hashtag) do
    GenServer.cast(pid, {:untrack, hashtag})
  end

  def start_link() do
    start_link(%{})
  end

  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  def handle_call({:update, hashtag}, from, state) do
    for tweet <- ExTwitter.search(hashtag) do
      IO.inspect tweet.text
    end
    {:reply, from, state}
  end

  def handle_cast({:track, hashtag}, state) do
    pid = spawn(fn ->
      stream = ExTwitter.stream_filter(track: hashtag)
      for tweet <- stream do
        IO.puts tweet.text
      end
    end)
    new_state = Map.put(state, hashtag, pid)
    {:noreply, new_state}
  end

  def handle_cast({:track_user, username}, state) do
    pid = spawn(fn ->
      stream = ExTwitter.stream_user(track: username)
      for tweet <- stream do
        IO.puts tweet.text
      end
    end)
    new_state = Map.put(state, username, pid)
    {:noreply, new_state}
  end

  def handle_cast({:untrack, hashtag}, state) do
    case Map.fetch(state, String.to_atom(hashtag)) do
      pid when is_pid(pid) ->
        ExTwitter.stream_control(pid, :stop)
        new_state = Map.drop(state, hashtag)
        {:noreply, new_state}
      _ ->
        {:noreply, state}
    end
  end

  def handle_cast(_, state) do
    {:noreply, state}
  end

  def handle_info(msg, state) do
    IO.puts msg
    {:ok, state}
  end

end