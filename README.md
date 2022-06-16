# Bamboo.SMTPAdapter

[![Build Status](https://github.com/fewlinesco/bamboo_smtp/workflows/Bamboo%20SMTP/badge.svg)](https://github.com/fewlinesco/bamboo_smtp/actions)
[![Inline docs](http://inch-ci.org/github/fewlinesco/bamboo_smtp.svg)](http://inch-ci.org/github/fewlinesco/bamboo_smtp)
[![Module Version](https://img.shields.io/hexpm/v/bamboo_smtp.svg)](https://hex.pm/packages/bamboo_smtp)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/bamboo_smtp/)
[![Total Download](https://img.shields.io/hexpm/dt/bamboo_smtp.svg)](https://hex.pm/packages/bamboo_smtp)
[![License](https://img.shields.io/hexpm/l/bamboo_smtp.svg)](https://github.com/fewlinesco/bamboo_smtp/blob/main/LICENSE)
[![Last Updated](https://img.shields.io/github/last-commit/fewlinesco/bamboo_smtp.svg)](https://github.com/fewlinesco/bamboo_smtp/commits/main)

An adapter for the [Bamboo](https://github.com/thoughtbot/bamboo) email app.

## Installation

The package can be installed as:

1. Add `bamboo_smtp` to your list of dependencies in `mix.exs`:

   ```elixir
   def deps do
     [{:bamboo_smtp, "~> 4.1.0"}]
   end
   ```

2. Add `:bamboo` and `:bamboo_smtp` to your list of applications in `mix.exs`:

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
     hostname: "your.domain",
     port: 1025,
     username: "your.name@your.domain", # or {:system, "SMTP_USERNAME"}
     password: "pa55word", # or {:system, "SMTP_PASSWORD"}
     tls: :if_available, # can be `:always` or `:never`
     allowed_tls_versions: [:"tlsv1", :"tlsv1.1", :"tlsv1.2"], # or {:system, "ALLOWED_TLS_VERSIONS"} w/ comma separated values (e.g. "tlsv1.1,tlsv1.2")
     tls_log_level: :error,
     tls_verify: :verify_peer, # optional, can be `:verify_peer` or `:verify_none`
     tls_cacertfile: "/somewhere/on/disk", # optional, path to the ca truststore
     tls_cacerts: "…", # optional, DER-encoded trusted certificates
     tls_depth: 3, # optional, tls certificate chain depth
     tls_verify_fun: {&:ssl_verify_hostname.verify_fun/3, check_hostname: "example.com"}, # optional, tls verification function
     ssl: false, # can be `true`
     retries: 1,
     no_mx_lookups: false, # can be `true`
     auth: :if_available # can be `:always`. If your smtp relay requires authentication set it to `:always`.
   ```

   *Sensitive credentials should not be committed to source control and are best kept in environment variables.
   Using `{:system, "ENV_NAME"}` configuration is read from the named environment variable at runtime.*

   The *hostname* option sets the FQDN to the header of your emails, its optional, but if you don't set it, the underlying `gen_smtp` module will use the hostname of your machine, like `localhost`.

4. Follow Bamboo [Getting Started Guide](https://github.com/thoughtbot/bamboo#getting-started)

5. **Optional** Set `BambooSMTP.TestAdapter` as your test adapter:

   ```elixir
   # In your config/config.exs file
   if Mix.env() == :test do
     config :my_app, MyApp.Mailer, adapter: MyApp.SMTPTestAdapter
   end
   ```

## Usage

You can find more information about advanced features in the [Wiki](https://github.com/fewlinesco/bamboo_smtp/wiki).

## Code of Conduct

By participating in this project, you agree to abide by its [CODE OF CONDUCT](CODE_OF_CONDUCT.md)

## Contributing

You can see the specific [CONTRIBUTING](CONTRIBUTING.md) guide.

## License

Bamboo SMTPAdapter is released under [The MIT License (MIT)](https://opensource.org/licenses/MIT).
