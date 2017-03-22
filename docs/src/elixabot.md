name: Title
class: font-title


How we write better programs with Elixir

---
name: Who are we
class: font-title

Who are we??

---
name: Ari + Anna
class: font-title
Ari + Anna

---
name: Ginger
class: font-title

Insert Ginger photo here

---
name: elixir helps us
class: font-title

How elixir helps us write better software

---
name: elixabot
class: font-title

# #Elixabot

---
name: quick prototyping
class: font-title

.font-title[Quick Prototyping]

Fun Fact - 1.5 working days to real-time system.
---
name: what we used  
class: font-title

 Twitter + Sockets + React

  ~~No framework~~

---
name: how did we accomplish that?
class: font-title

How did we accomplish that?

---
name: how did we accomplish that?
class: font-title

Elixir gave us that power

---
name: Elixir gives us power
class: font-title

Like any good app, we want to do design driven development

---
name: how did we accomplish that?
class: font-title

Umbrella apps force quality design

---
name: What does that get us
class: font-title

What does this way get us?

---
name: small modules
class: font-title

Small Modules

---
name: Dependency Management
class: font-title

Dependency Management

---
name: Dependency Management
class: font-title

TDD/BDD

---
name: Dependency Management
class: font-title

Isolated Functionality

---
name: Dependency Management
class: font-title

Features of a monolithic app

 +

Benefits of microservices
---
name: What do we need?
class: font-title
To build this app, what do we need?

---
name: Our 3 apps
class: font-title

A Twytter streamer

+

A web interface

+

A Database
---
name: So let's get started
class: font-title

So let's get started
---
name: Mix Build tool
class: font-title

We use the mix build tool

to create our app

---
name: Current App
class: font-title

Looking at our current app you see...

---

![](/Users/anna/Desktop/Screen%20Shot%202017-03-20%20at%206.20.16%20PM.png)

---
name: Set up DB
class: font-title

Let's set up our DB app
---
name: Save tweets and update votes
class: font-title

It will save tweets + update vote counts

---
name: Need dependencies
class: font-title

To start we need our dependencies.

---
name: Postgres + ecto
class: font-title

`postgres` + `ecto`

---
name: Show deps
class: background-blk 

Let's add these to our mix.exs file

```elixir

  defp deps(_) do
    [
      {:postgrex, "~> 0.13.2"},
      {:ecto, "~> 2.1"}
    ]
  end  

```
---

then run

---

```
mix deps.get

```

---

Mix makes it super easy to manage dependencies

---

Which means conflict is less likely

---

And resolution is easier

---

Smarter tools allow us to build smarter apps

---

# #smartertools

---

What comes with smarter apps

---

Tested Apps

---

Test Driven Development gives our apps stability

---

Just Ask Dave Thomas

---

And you probably can...cause he's here

---

In Elixir, testing is a core feature

---

It's not an afterthought

---

Let's take a look at Test Unit Integration

---

We want to DB app make sure our vote count is being set accurately

---

How can we ensure that?

---

We use ExUnit to Unit test

---

```
test "creates a new question when id is new" do
  Db.Tweet
  .first_or_create(%ExTwitter.Model.Tweet{
    id_str: "test",
    text: "What do you think about Brail?",
    favorite_count: 0
  })

  found_question = Db.Repo.one query_for_tweet(%{id_str: "test"})
  assert found_question != nil
end
```

---

![](/Users/anna/Desktop/Screen%20Shot%202017-03-20%20at%2011.06.42%20PM.png)

---

Now that we have a failing test

---

Then we implement the functionality to make it pass

---

```elixir
  def first_or_create(tweet) do
    query = from t in Db.Tweet,
            where: t.tweet_id == ^tweet.id_str,
            select: t

    new_tweet = %Db.Tweet{
      tweet_id: tweet.id_str,
      question: tweet.text,
      favorite_count: tweet.favorite_count
    }
    case Db.Repo.one(query) do
      nil ->
        {:ok, saved_tweet} = Db.Repo.insert(new_tweet) # Create tweet
        saved_tweet
      model -> model
    end
  end
```  

---


![](/Users/anna/Desktop/Screen%20Shot%202017-03-20%20at%2011.08.15%20PM.png)


---

This gives us the confidence that our code is working

---
Before we move on to our Twytter app
---
let's take a look at a powerful feature of elixir
---
Pattern matching
---
```elixir
case Db.Repo.one(query) do
  nil ->
    {:ok, saved_tweet} = Db.Repo.insert(new_tweet) # Create tweet
    saved_tweet
  model -> model
end
```
---
Why is this important?

---

Easily understandable as to what is going on

---

Declarative code

---

Prevents complicated conditionals

---

Compiler helps prevent data-type collisions

---

Pattern matching allows you to deal with data in small pieces.


---
Let's take a look at our Twytter app

---

Back to our high level diagram

---

![](/Users/anna/Desktop/high_level_overview.jpg)

---

Let's implement the Twitter streamer

---

... and try not to get banned

---

1. Fetch tweets
2. Check DB and persist questions
3. Send to web

---

Pulling from Twitter

---

Fetching tweets with Elixir is easy (Thanks @parroty/ExTwitter)

---

```elixir
tweets = ExTwitter.search(hashtag)
```

---

## With limits

```elixir
opts = [count: demand]
tweets = ExTwitter.search(hashtag, opts)
```

---

2. Persist in DB

```elixir
db_tweet = Db.Tweet.first_or_create(tweet)
db_tweet = Db.Tweet.update_votes(db_tweet, tweet.favorite_count)
```

---

3. Send to web

---

```elixir
jsonable_tweets = tweets |> Enum.map(&to_jsonable/1)
Web.WsServer.broadcast(jsonable_tweets)
```

---

```elixir
def flow(hash_tag) do
  opts = [count: demand]
  tweets = ExTwitter.search(hashtag, opts)
  db_tweet = Db.Tweet.first_or_create(tweet)
  db_tweet = Db.Tweet.update_votes(db_tweet, tweet.favorite_count)
  jsonable_tweets = tweets |> Enum.map(&to_jsonable/1)
  Web.WsServer.broadcast(jsonable_tweets)
end
```

---

## Lots of problems

* Mixing of concerns
* Difficult to test
* Pulls in a lot of disparate pieces into a monolithic method

---

## Better way?

---

## GenStage

---

Looking at the design

---

![](/Users/anna/Desktop/high_level_overview.jpg)

---

1. Fetch tweets
2. Check DB and persist questions
3. Send to web

---

This looks like a flow diagram

---

![](http://www.ctgclean.com/sites/www.ctgclean.com/files/tech-blog/wp-content/uploads/Backpressure-Limiting-Valve.jpg)

---

Yet what if we flipped the direction of the flow?

---

## GenStage goes backwards

---

Why go backwards?
---

![](/Users/anna/Desktop/lucy1.gif)
![](/Users/anna/Desktop/lucy2.gif)
![](/Users/anna/Desktop/lucy3.gif)

---

Backpressure / control

---

1. Demand from web app
2. Pull from Twitter

---
30,000 ft view
---


---
How is this backwards system setup?
---

```elixir
{:ok, producer} = GenStage.start_link(TweetService, "#elixabot")
{:ok, prod_con} = GenStage.start_link(TweetProdConsumer, :ok)
{:ok, consumer} = GenStage.start_link(TweetConsumer, :ok)

GenStage.sync_subscribe(prod_con, to: producer, max_demand: 10)
GenStage.sync_subscribe(consumer, to: prod_con, max_demand: 5)
```


---

## Web (tweet consumer)

---

Since we want to play nice to Twitter, we need to control our desires... aka manage demand pressure

---

![](/Users/anna/Desktop/client-meme.jpg)

---

```elixir
def handle_subscribe(:producer, opts, from, producers) do
  pending = opts[:max_demand] || 5
  interval = opts[:interval] || 90000

  producers = Map.put(producers, from, {pending, interval})
  producers = ask_and_schedule(producers, from)

  {:manual, producers}
end
```

---

```elixir
defmodule Twytter.TweetConsumer do
  require Web.WsServer

  use GenStage

  def handle_events(events, from, producers) do
    producers = Map.update!(producers, from, fn {pending, interval} ->
      {pending + length(events), interval}
    end)

    jsonable_tweets = events |> Enum.map(&to_jsonable/1)
    Web.WsServer.broadcast(jsonable_tweets)

    {:noreply, [], producers}
  end
end
```

---

## DB Producer Consumer

---

```elixir
defmodule Twytter.TweetProdConsumer do
  require Db.Tweet
  use GenStage

  defp get_record(tweet) do
    db_tweet = Db.Tweet.first_or_create(tweet)
    Db.Tweet.update_votes(db_tweet, tweet.favorite_count)
  end

  def handle_events(tweets, _from,  _state) do
     processed_tweets = tweets |> Enum.map(&get_record/1)
    {:noreply, processed_tweets, :ok}
  end
end
```

---

Now, to get the tweets (Finally)

---

```elixir
defmodule Twytter.TweetService do
  use GenStage

  def handle_demand(demand, %{
  	hashtag: hashtag,
    last_tweet: last_tweet}) do

    opts = [count: demand]
    opts = case last_tweet do
      %ExTwitter.Model.Tweet{id_str: id} -> Keyword.put(opts, :since_id, id)
      _ -> opts
    end

    tweets = ExTwitter.search(hashtag, opts)
    last_tweet = List.last(tweets)

    {:noreply, tweets, %{last_tweet: last_tweet, hashtag: hashtag}}
  end
end
```

---

## Separation of concerns

1. Tweet producer
2. Db producer/consumer
3. Web consumer

---

Our _flow_ is missing one piece

---

## Web

---

We'll use the fantastic `Cowboy` connection pooling library

---

```elixir
defp deps(_) do
  [
    {:cowboy, "~> 1.1"},
    {:plug, "~> 1.3"},
    {:poison, "~> 2.0"}
  ]
end
```

---


```elixir
Plug.Adapters.Cowboy.child_spec(
  :http, Web.Router, [], [
    port: 4001,
    dispatch: dispatch()
])
```

```elixir
defp dispatch do
  [
    {:_, [
      {"/ws", Web.SocketHandler, []},
      {:_, Plug.Adapters.Cowboy.Handler, {Web.Router, []}}
    ]}
  ]
end
```

---

Web.Router

---

```elixir
defmodule Web.Router do
  require EEx

  plug Plug.Static,
    at: "/",
    from: {:web, "priv/static"},
    only: ~w(css js)

  @index_template Application.app_dir(:web, "priv/views/index.html.eex")
  EEx.function_from_file :defp, :template_index, @index_template, [:env]

  get "/" do
    page_contents = template_index(Mix.env)
    conn
    |> Plug.Conn.put_resp_content_type("text/html")
    |> Plug.Conn.send_resp(200, page_contents)
  end

  match _ do
    send_resp(conn, 404, "not found")
  end
end
```

---

Because all the cool kids are doing it...

---

```html
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>Elixabot</title>
</head>
<body>
    <div id="root"></div>
    <%= if env == :dev do %>
      <script src="http://localhost:8080/js/app.js"></script>
    <% else %>
      <script src="/js/app.js"></script>
    <% end %>
</body>
</html>
```

---


* React
* Webpack 2

---

```js
const publicPath = "http://localhost:8080/"
  const hot = "webpack-hot-middleware/client?path=" +
    publicPath + "__webpack_hmr"

  const entry = {
    app: [
      "js/app.js",
      "css/app.css"
    ]
  }
  if (!(env && env.prod)) {
    // HOT RELOADING!
    entry.app.unshift(hot)
  }
  // ...
}
```

---

## App loading

---

```javascript
ReactDOM.render(<App />, MOUNT)
```

---

## Redux

---

```javascript
export const socketConnect = () => dispatch => {
  dispatch({ type: types.SOCKET_CONNECT });

  const socket = new WebSocket(`ws://localhost:4001/ws`)
  socket.onopen = () => {
    dispatch({ type: types.SOCKET_CONNECTED });
  }

  socket.addEventListener("message", ({ data }) => {
    try {
      dispatch({
        type: types.RECEIVED_QUESTIONS,
        payload: JSON.parse(data)
      })
    } catch (e) {
    }
  })
}
```

---

## What are we connecting to?

---

## Cowboy websocket

---

```elixir
defmodule Web.SocketHandler do
  @behaviour :cowboy_websocket_handler

  def init(_, _req, _opts) do
    Web.WsServer.subscribe()
    {:upgrade, :protocol, :cowboy_websocket}
  end

  def websocket_handle({:text, "ping"}, req, state) do
    {:reply, {:text, "pong"}, req, state}
  end

  def websocket_handle({:message, message}, req, state) do
    {:reply, {:text, message}, req, state}
  end

  # ...
end
```

---

## Sending data from client to server

---

```javascript
socket.send(JSON.stringify({message: "c major"}))
```
```elixir
def websocket_handle(message, req, state) do
  {:text, msg} = message
  {:ok, data} = Poison.decode(msg)
  # Do something with the data
  {:reply, {:text, "OK"}, req, state}
end
```

## Sending server to client

---

## Broadcasting to our connected clients

---

Need to keep track of the connected clients

---

```elixir
supervisor(Registry, [:duplicate, :ws_registry]),
```

---

```elixir
def init(_, _req, _opts) do
  # on socket connect
  Web.WsServer.subscribe()
  {:upgrade, :protocol, :cowboy_websocket}
end
```

---

## Subscribing looks like...

---

```elixir
defmodule Web.WsServer do
  use GenServer

  def start_link(topic, opts \\ []) do
    GenServer.start_link(__MODULE__, topic, opts)
  end

  def subscribe(topic \\ "message") do
    Registry.register(:ws_registry, topic, :socket)
  end
end
```

---


```elixir
def broadcast(data, topic \\ "message") do
  {:ok, msg} = Poison.encode(data)
  Registry.dispatch(:ws_registry, topic, fn entries ->
    for {pid, _} <- entries, do: send(pid, msg)
  end)
end
```

---

Then handle the normal redux workflow. for instance...

---

```javascript
export const reducer = (state = initialState, action) => {
  switch (action.type) {
    case types.RECEIVED_QUESTIONS:
      return {
        ...state,
        list: action.payload,
      }
    default:
      return state
  }
}
```

---

## Topics covered

* GenServer
* GenStage
* Small modules
* Supervisors (TODO)
*
