# Gazoline ![Made in Elixir](https://cdn.rawgit.com/tchoutri/botfuel-elixir-sdk/master/elixir.svg)

>Quite a clever bot.

Find it at https://t.me/GazolineBot

Gazoline is an incredible opportunity to work with several interesting technologies, namely the [Botfuel.io](https://botfuel.io) NLP platform, Foursquare
data, and PostgreSQL's *PostGIS* extension.

It helps you pick restaurants around Paris' neighbourhood *La Butte aux Cailles*, by type.

![Image 1](https://i.imgur.com/upXJkp6.png)
![Image 2](https://i.imgur.com/zTmPBDR.png)


## Prerequesites

minimum dependencies:

* Elixir 1.6
* Erlang OTP 20.2
* PostgreSQL 9.6
* PostGIS 2.3.3

## Configuration

You need to export the following environment variables:

```
TELEGRAM_TOKEN
FOURSQUARE_ID
FOURSQUARE_SECRET
BTFL_APPID
BTFL_APPKEY
```

## Installation

1. Install the dependencies with `mix deps.get`
2. Create and migrate the database models with `mix ecto.setup`
4. Launch the application with `iex -S mix`


## TODO

- [ ] Expand the search radius (despite 4square's API).
- [ ] Don't crash on message edition (not really an issue but hey)
- [ ] Don't be limited to one location.
- [ ] A way to easily (in-chat) add a restaurant.
