How we write better programs with Elixir

---

Who are we

---

Ari + Anna

---

Insert Ginger photo here

---

How elixir helps us write better software

---

INSERT A BUNCH OF SLIDES INTRODUCING THE IDEA

---

Introduce the app

---

### Quick prototyping

fun fact - 1.5 working days to real-time system with Twitter, sockets, and React without a framework

---

How did we accomplish that?

---

Elixir gave us that power

---

Like any good app, we want to do design driven development
___

Umbrella apps force quality design

---

So in building this app, what do we need?

---

We came up with

---

A Twytter streammer + Rate limiting

---

A web interface

---

A Database
___

So let's get started
___

We are going to use the mix build tool to create our app

---

```bash
mix new --umbrella elixabot
cd elixabot/apps
mix new db --sup
mix new db --sup
mix new db --web
```
___

Looking at our current app you see our umbrella + children

![](/Users/anna/Desktop/Screen%20Shot%202017-03-20%20at%206.20.16%20PM.png)

---

What does setting up our app this way get us?

---

Small modules

---

dependency management

---

TDD/BDD

---

Isolated Functionality

---

Let's set up our DB app and see how some of these concepts are applied

---

This app will save tweets and update vote counts

---

In order to get started we need our dependencies.

---

Here we need `postgres` and `ecto`

---

Let's add these to our mix.exs file

```

  defp deps(_) do
    [
      {:postgrex, "~> 0.13.2"},
      {:ecto, "~> 2.1"}
    ]
  end  

```
___

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

#smartertools

---

What comes with smarter apps

---

Tested Apps

---

Test Driven Development gives our apps stability

---

Just Ask Dave Thomas

---

In Elixir, testing is a core feature

---

It's not an afterthought

---

Let's take a look at Test Unit Integration

___

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

TODO: Add functionality

---


![](/Users/anna/Desktop/Screen%20Shot%202017-03-20%20at%2011.08.15%20PM.png)


---

This gives us the confidence that our code is working

---

Let's take a look at our Twytter app

---

Bake to our high level diagram

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

Fetching tweets with Elixir is easy (Thanks ExTwitter)

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

1. Fetch tweets
2. Check DB and persist questions
3. Send to web

---

This looks like a flow diagram

---

![](http://www.ctgclean.com/sites/www.ctgclean.com/files/tech-blog/wp-content/uploads/Backpressure-Limiting-Valve.jpg)

---

1. Consume from Twitter
2. Persist in DB
3. Send to web

---

## GenStage goes backwards

---

TODO: Why go backwards?
Backpressure / control

---

1. Demand from web app
2. Pull from Twitter

---


We'll _pull_ demand from Twitter into our Web interface

---


## Web (tweet consumer)

---

Since we want to play nice to Twitter, we need to control our desires... aka manage demand pressure

---

![](http://www.onlymyhealth.com/imported/images/2013/January/10_Jan_2013/Control-Your-Desire-for-Food-for-Weight-Loss.jpg)

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
2. Db producter/consumer
3. Web consumer

---

How does this all fit together?

---

```elixir
{:ok, producer} = GenStage.start_link(TweetService, "#elixabot")
{:ok, prod_con} = GenStage.start_link(TweetProdConsumer, :ok)
{:ok, consumer} = GenStage.start_link(TweetConsumer, :ok)

GenStage.sync_subscribe(prod_con, to: producer, max_demand: 10)
GenStage.sync_subscribe(consumer, to: prod_con, max_demand: 5)
```

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

Precomputing our template (need for speed)

```elixir
@index_template Application.app_dir(:web, "priv/views/index.html.eex")
EEx.function_from_file :defp, :template_index, @index_template, [:env]
```

---


## React


---

We all know code bases can get large quickly

*some funny image of codebases
---

The mix build tool allows us to split our code into multiple apps

---

why?

----

Testability

---

Manageability

---

Development efficiency

---

How do we do this?

---

start a new mix project and pass in the umbrella flag

---

```
mix new --umbrella elixabot
```
---
This creates the following -


![](/Users/anna/Desktop/Screen%20Shot%202017-03-20%20at%206.08.52%20PM.png)

---

```
apps/ - where our sub (child) projects will reside
config/ - where our umbrella projects configuration will live
```
---

If we cd into our `apps` directory we can then create new apps using


`mix new app_name`

---
Looking at our current app you can see

![](/Users/anna/Desktop/Screen%20Shot%202017-03-20%20at%206.20.16%20PM.png)

---
How do  you interact with all the child applications ?

Each mix application works as you would expect a standalone mix app would

---

If we cd into  our root directory

![](/Users/anna/Desktop/Screen%20Shot%202017-03-20%20at%206.08.52%20PM.png)

We can interact with all 3 apps

---

running `iex -S mix` from the root directory of the umbrella app will allow you to interact with all  the child applications

---

Why do this?

*Umbrella apps allow for a very elegant separation of concerns


![](/Users/anna/Desktop/Screen%20Shot%202017-03-20%20at%206.20.16%20PM.png)

----
So this is cool but why else is this important?

----

We could isolate behavior

![](/Users/anna/Desktop/Screen%20Shot%202017-03-20%20at%206.20.16%20PM.png)

---
One app is speaking to twytter,

---
one is saving and retreving from the db


---
and one is handling the web socket connection.

---

![](/Users/anna/Desktop/Screen%20Shot%202017-03-20%20at%206.20.16%20PM.png)

Even at first glance, it is very clear what is going on here

---

Umbrella app == smaller child apps == easier testing!

----

We were able to test drive development pretty easily with ExUnit.

---

Write tests in tiny pieces

---
```  
test "a new record contains a favorite_count of 0" do
    new_question = %Db.Tweet{favorite_count: 0}
    saved = Db.Repo.insert!(new_question)
    assert saved.favorite_count == 0
  end
```



We only needed to be concerned with what was happening in the database

---

This lead to Isolated functionality

making it easier for us to think about where to put what code

---

Elixir allows/forces us to be really specfic
---

*Transition from umbrella apps to pattern matching - from a high level we separate concerns by separating apps

Yet we see this intentional focus on isolation throughout the language. Let's take another look at how this kidn of intentional isolation is a plus in message passing

---

Twytter (yes, the name could be better)

---

### #elixabot (any interesting questions yet?)
___


The job of this app is to retreive tweets from twitter


---
How do we do this?

---

# Genstage

---
New behaviour for exchanging events using back pressure between elixir processes

---

BackPressure?

![](http://www.ctgclean.com/sites/www.ctgclean.com/files/tech-blog/wp-content/uploads/Backpressure-Limiting-Valve.jpg)


no more can go into the system then the system can handle

----

Why is this important?

___


I love lucy...

---

![](https://engineering.spreedly.com/images/how-do-i-genstage/lucy1-31af5325.gif)
![](https://engineering.spreedly.com/images/how-do-i-genstage/lucy2-71f114af.gif)
![](
https://engineering.spreedly.com/images/how-do-i-genstage/lucy3-48d13a32.gif)

---

```
defmodule Twytter do

alias Twytter.TweetService
alias Twytter.TweetConsumer
alias Twytter.TweetProdConsumer

  def start do
    {:ok, producer} = GenStage.start_link(TweetService, "#elixabot")
    {:ok, prod_con} = GenStage.start_link(TweetProdConsumer, :ok)
    {:ok, consumer} = GenStage.start_link(TweetConsumer, :ok)

    GenStage.sync_subscribe(prod_con, to: producer, max_demand: 10)
    GenStage.sync_subscribe(consumer, to: prod_con, max_demand: 5)
  end
end
```
----

3 separate processes

---

Producer

 retreives tweets from twitter passes them to prodcon

```
 {:ok, producer} =
 GenStage.start_link(TweetService, "#elixabot")
 ```
---

```
defmodule Twytter.TweetService do
  use GenStage

  def init(hashtag) do
    {:producer, %{hashtag: hashtag, last_tweet: nil}}
  end
```  
---

Callback

That first argument demand, is actually set by the consumer

```
def handle_demand(demand, %{hashtag: hashtag, last_tweet: last_tweet}) do
  opts = [count: demand]
  opts = case last_tweet do
  %ExTwitter.Model.Tweet{id_str: id} -> Keyword.put(opts, :since_id, id)
  _ -> opts
  end

  tweets = ExTwitter.search(hashtag, opts)
  last_tweet = List.last(tweets)
  {:noreply, tweets, %{last_tweet: last_tweet, hashtag: hashtag}}
end    
```

explain demaind and return value of function

----

Producer Consumer

  Saves tweets to database and passes saved and updated tweets to consumer

```
  {:ok, prod_con} = GenStage.start_link(TweetProdConsumer, :ok)

```

---
```
defmodule Twytter.TweetProdConsumer do
  require Db.Tweet
  use GenStage

  def init(arg) do
    {:producer_consumer, :ok}
  end
end
```
---

```
  def handle_events(tweets, _from,  _state) do
  processed_tweets = tweets |> Enum.map(&get_record/1)

  {:noreply, processed_tweets, :ok}
  end
```   

passes processed tweets over to consumer


---

Consumer

```
 {:ok, consumer} = GenStage.start_link(TweetConsumer, :ok)

```

----

what is happenign in handle subscribe and handle info)
```
defmodule Twytter.TweetConsumer do
  require Web.WsServer

  use GenStage
  def init(_arg) do
    {:consumer, %{}}
  end

  def handle_subscribe(:producer, opts, from, producers) do
    pending = opts[:max_demand] || 5
    interval = opts[:interval] || 90000

    producers = Map.put(producers, from, {pending, interval})

    producers = ask_and_schedule(producers, from)

    {:manual, producers}
  end

    defp ask_and_schedule(producers, from) do
    case producers do
      %{^from => {pending, interval}} ->
        GenStage.ask(from, pending)
        Process.send_after(self(), {:ask, from}, interval)
        Map.put(producers, from, {0, interval})
      %{} ->
        producers
    end

```  
---

```  
def handle_info({:ask, from}, producers) do
  {:noreply, [], ask_and_schedule(producers, from)}
end
```
---

```
GenStage.sync_subscribe(prod_con, to: producer, max_demand: 10)
GenStage.sync_subscribe(consumer, to: prod_con, max_demand: 5)
```


Our consumer sits at the end of the message queue. It subscribes to our producer consumer, which subscribes to our producer

You see the `max_demand: 5` argument -

The consumer  set the demaning for the systesm
There will never be more than 5 messages pulled from twitter at a time, because the consumer has set that it cannot receive more than 5.

---

this type of message passing not only allows is to really isolate which part of the process is doing what, but it also allows us to carefully control the flow of messages.

---

We've talked abotu Elixir allowing apps at a high-level, and then processes, let's step a bit lower and talk about Pattern matching and how its realted to this theme of isolation

---

Looking back at our Twytter app

---
