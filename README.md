[![Build Status](https://travis-ci.org/fewlinesco/bamboo_smtp.svg?branch=master)](https://travis-ci.org/fewlinesco/bamboo_smtp)
[![Inline docs](http://inch-ci.org/github/fewlinesco/bamboo_smtp.svg)](http://inch-ci.org/github/fewlinesco/bamboo_smtp)

# Bamboo.SMTPAdapter

An Adapter for the [Bamboo](https://github.com/thoughtbot/bamboo) email app.

## Installation

The package can be installed as:

1. Add `bamboo_smtp` to your list of dependencies in `mix.exs`:

  ```elixir
  def deps do
    [{:bamboo_smtp, "~> 1.4.0"}]
  end
  ```

2. Add `bamboo` and `bamboo_smtp` to your list of applications in `mix.exs`:

  ```elixir
  def application do
    [applications: [:bamboo, :bamboo_smtp]]
  end
  ```

3. Setup your SMTP configuration:

  ```elixir
  # In your config/config.exs file
  config :my_app, MyApp.Mailer,
    adapter: Bamboo.SMTPAdapter,
    server: "smtp.domain",
    port: 1025,
    username: "your.name@your.domain", # or {:system, "SMTP_USERNAME"}
    password: "pa55word", # or {:system, "SMTP_PASSWORD"}
    tls: :if_available, # can be `:always` or `:never`
    allowed_tls_versions: [:"tlsv1", :"tlsv1.1", :"tlsv1.2"], # or {":system", ALLOWED_TLS_VERSIONS"} w/ comma seprated values (e.g. "tlsv1.1,tlsv1.2")
    ssl: false, # can be `true`
    retries: 1
  ```

*Sensitive credentials should not be committed to source control and are best kept in environment variables.
Using `{:system, "ENV_NAME"}` configuration is read from the named environment variable at runtime.*

4. Follow Bamboo [Getting Started Guide](https://github.com/thoughtbot/bamboo#getting-started)

## Usage

You can find more information about advanced features in the [Wiki](https://github.com/fewlinesco/bamboo_smtp/wiki).

## Contributing

Before opening a pull request you can open an issue if you have any question or need some guidance.

Here's how to setup the project:

```
$ git clone https://github.com/fewlinesco/bamboo_smtp.git
$ cd bamboo_smtp
$ mix deps.get
$ mix test
```

Once you've made your additions and `mix test` passes, go ahead and open a Pull Request.

## License

Bamboo SMTPAdapter is released under [The MIT License (MIT)](https://opensource.org/licenses/MIT).
