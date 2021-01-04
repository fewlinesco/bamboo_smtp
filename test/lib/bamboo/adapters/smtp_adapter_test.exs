defmodule Bamboo.SMTPAdapterTest do
  use ExUnit.Case

  alias Bamboo.Email
  alias Bamboo.SMTPAdapter

  defmodule FakeGenSMTP do
    use GenServer

    @impl true
    def init(args) do
      {:ok, args}
    end

    def start_link(_) do
      GenServer.start_link(__MODULE__, [], name: __MODULE__)
    end

    def send_blocking(email, config) do
      GenServer.call(__MODULE__, {:send_email, {email, config}})
    end

    def fetch_sent_emails do
      GenServer.call(__MODULE__, :fetch_emails)
    end

    @impl true
    def handle_call(:fetch_emails, _from, state) do
      {:reply, state, state}
    end

    @impl true
    def handle_call({:send_email, {email, config}}, _from, state) do
      case check_validity(email, config) do
        :ok ->
          {:reply, "200 Ok 1234567890", [{email, config} | state]}

        error ->
          {:reply, error, state}
      end
    end

    defp check_validity(email, config) do
      with :ok <- check_configuration(config),
           :ok <- check_credentials(config[:username], config[:password], config[:auth]),
           :ok <- check_email(email),
           do: :ok
    end

    defp check_credentials(username, password, :always = _auth)
         when is_nil(username) or is_nil(password) do
      {:error, :no_credentials}
    end

    defp check_credentials(_username, _password, _auth), do: :ok

    defp check_configuration(config) do
      case Keyword.fetch(config, :relay) do
        {:ok, wrong_domain = "wrong.smtp.domain"} ->
          {:error, :retries_exceeded, {:network_failure, wrong_domain, {:error, :nxdomain}}}

        _ ->
          :ok
      end
    end

    defp check_email({from, _to, _raw}) do
      case from do
        "wrong@user.com" ->
          {:error, :no_more_hosts,
           {:permanent_failure, "an-smtp-adddress",
            "554 Message rejected: Email address is not verified.\r\n"}}

        _ ->
          :ok
      end
    end
  end

  @configuration %{
    adapter: SMTPAdapter,
    server: "smtp.domain",
    port: 1025,
    hostname: "your.domain",
    username: "your.name@your.domain",
    password: "pa55word",
    transport: FakeGenSMTP,
    no_mx_lookups: false
  }

  @email [
    from: {"John Doe", "john@doe.com"},
    to: [{"Jane Doe", "jane@doe.com"}],
    cc: [{"Richard Roe", "richard@roe.com"}],
    bcc: [{"Mary Major", "mary@major.com"}, {"Joe Major", "joe@major.com"}],
    subject: "Hello from Bamboo",
    html_body: "<h1>Bamboo is awesome!</h1>",
    text_body: "*Bamboo is awesome!*",
    headers: %{
      "Reply-To" => "reply@doe.com"
    }
  ]

  @email_in_utf8 [
    from: {"John Doe", "john@doe.com"},
    to: [{"Jane Doe", "jane@doe.com"}],
    cc: [{"Richard Roe", "richard@roe.com"}],
    bcc: [{"Mary Major", "mary@major.com"}, {"Joe Major", "joe@major.com"}],
    subject: "日本語のｓｕｂｊｅｃｔ",
    html_body: "<h1>Bamboo is awesome!</h1>",
    text_body: "*Bamboo is awesome!*",
    headers: %{
      "Reply-To" => "reply@doe.com"
    }
  ]

  setup do
    start_supervised!(FakeGenSMTP)

    :ok
  end

  test "raises if the server is nil" do
    assert_raise ArgumentError, ~r/Key server is required/, fn ->
      SMTPAdapter.handle_config(configuration(%{server: nil}))
    end
  end

  test "raises if the port is nil" do
    assert_raise ArgumentError, ~r/Key port is required/, fn ->
      SMTPAdapter.handle_config(configuration(%{port: nil}))
    end
  end

  test "sets default tls key if not present" do
    %{tls: tls} = SMTPAdapter.handle_config(configuration())

    assert :if_available == tls
  end

  test "doesn't set a default tls key if present" do
    %{tls: tls} = SMTPAdapter.handle_config(configuration(%{tls: :always}))

    assert :always == tls
  end

  test "sets default ssl key if not present" do
    %{ssl: ssl} = SMTPAdapter.handle_config(configuration())

    refute ssl
  end

  test "doesn't set a default ssl key if present" do
    %{ssl: ssl} = SMTPAdapter.handle_config(configuration(%{ssl: true}))

    assert ssl
  end

  test "sets default retries key if not present" do
    %{retries: retries} = SMTPAdapter.handle_config(configuration())

    assert retries == 1
  end

  test "doesn't set a default retries key if present" do
    %{retries: retries} = SMTPAdapter.handle_config(configuration(%{retries: 42}))

    assert retries == 42
  end

  test "sets server and port from System when specified" do
    System.put_env("SERVER", "server")
    System.put_env("PORT", "123")

    config = %{
      server: {:system, "SERVER"},
      port: {:system, "PORT"}
    }

    bamboo_email = new_email()
    bamboo_config = SMTPAdapter.handle_config(configuration(config))
    {:ok, "200 Ok 1234567890"} = SMTPAdapter.deliver(bamboo_email, bamboo_config)
    [{{_from, _to, _raw_email}, gen_smtp_config}] = FakeGenSMTP.fetch_sent_emails()

    assert gen_smtp_config[:relay] == "server"
    assert gen_smtp_config[:port] == 123
  end

  test "sets tls if_available from System when specified" do
    System.put_env("TLS", "if_available")

    config = SMTPAdapter.handle_config(configuration(%{tls: {:system, "TLS"}}))
    {:ok, "200 Ok 1234567890"} = SMTPAdapter.deliver(new_email(), config)
    [{{_from, _to, _raw_email}, gen_smtp_config}] = FakeGenSMTP.fetch_sent_emails()

    assert gen_smtp_config[:tls] == :if_available
  end

  test "sets tls always from System when specified" do
    System.put_env("TLS", "always")

    config = SMTPAdapter.handle_config(configuration(%{tls: {:system, "TLS"}}))
    {:ok, "200 Ok 1234567890"} = SMTPAdapter.deliver(new_email(), config)
    [{{_from, _to, _raw_email}, gen_smtp_config}] = FakeGenSMTP.fetch_sent_emails()

    assert gen_smtp_config[:tls] == :always
  end

  test "sets tls never from System when specified" do
    System.put_env("TLS", "never")

    config = SMTPAdapter.handle_config(configuration(%{tls: {:system, "TLS"}}))
    {:ok, "200 Ok 1234567890"} = SMTPAdapter.deliver(new_email(), config)
    [{{_from, _to, _raw_email}, gen_smtp_config}] = FakeGenSMTP.fetch_sent_emails()

    assert gen_smtp_config[:tls] == :never
  end

  test "sets username and password from System when specified" do
    System.put_env("SMTP_USER", "joeblow")
    System.put_env("SMTP_PASS", "fromkokomo")

    bamboo_email = new_email()

    bamboo_config =
      configuration(%{username: {:system, "SMTP_USER"}, password: {:system, "SMTP_PASS"}})

    {:ok, "200 Ok 1234567890"} = SMTPAdapter.deliver(bamboo_email, bamboo_config)

    [{{_from, _to, _raw_email}, gen_smtp_config}] = FakeGenSMTP.fetch_sent_emails()

    assert gen_smtp_config[:username] == "joeblow"
    assert gen_smtp_config[:password] == "fromkokomo"
  end

  test "sets ssl true from System when specified" do
    System.put_env("SSL", "true")

    config = SMTPAdapter.handle_config(configuration(%{ssl: {:system, "SSL"}}))
    {:ok, "200 Ok 1234567890"} = SMTPAdapter.deliver(new_email(), config)
    [{{_from, _to, _raw_email}, gen_smtp_config}] = FakeGenSMTP.fetch_sent_emails()

    assert gen_smtp_config[:ssl]
  end

  test "sets ssl false from System when specified" do
    System.put_env("SSL", "false")
    config = SMTPAdapter.handle_config(configuration(%{ssl: {:system, "SSL"}}))
    {:ok, "200 Ok 1234567890"} = SMTPAdapter.deliver(new_email(), config)
    [{{_from, _to, _raw_email}, gen_smtp_config}] = FakeGenSMTP.fetch_sent_emails()

    refute gen_smtp_config[:ssl]
  end

  test "sets retries from System when specified" do
    bamboo_email = new_email()
    System.put_env("RETRIES", "123")

    config = SMTPAdapter.handle_config(configuration(%{retries: {:system, "RETRIES"}}))
    {:ok, "200 Ok 1234567890"} = SMTPAdapter.deliver(bamboo_email, config)
    [{{_from, _to, _raw_email}, gen_smtp_config}] = FakeGenSMTP.fetch_sent_emails()

    assert 123 == gen_smtp_config[:retries]
  end

  test "sets tls versions from System when specified" do
    System.put_env("ALLOWED_TLS_VERSIONS", "tlsv1,tlsv1.2")

    config =
      SMTPAdapter.handle_config(
        configuration(%{allowed_tls_versions: {:system, "ALLOWED_TLS_VERSIONS"}})
      )

    {:ok, "200 Ok 1234567890"} = SMTPAdapter.deliver(new_email(), config)
    [{{_from, _to, _raw_email}, gen_smtp_config}] = FakeGenSMTP.fetch_sent_emails()

    assert [:tlsv1, :"tlsv1.2"] == gen_smtp_config[:tls_options][:versions]
  end

  test "sets no_mx_lookups false from System when specified" do
    System.put_env("NO_MX_LOOKUPS", "false")

    config =
      SMTPAdapter.handle_config(configuration(%{no_mx_lookups: {:system, "NO_MX_LOOKUPS"}}))

    {:ok, "200 Ok 1234567890"} = SMTPAdapter.deliver(new_email(), config)
    [{{_from, _to, _raw_email}, gen_smtp_config}] = FakeGenSMTP.fetch_sent_emails()

    refute gen_smtp_config[:no_mx_lookups]
  end

  test "sets no_mx_lookups true from System when specified" do
    System.put_env("NO_MX_LOOKUPS", "true")

    config =
      SMTPAdapter.handle_config(configuration(%{no_mx_lookups: {:system, "NO_MX_LOOKUPS"}}))

    {:ok, "200 Ok 1234567890"} = SMTPAdapter.deliver(new_email(), config)
    [{{_from, _to, _raw_email}, gen_smtp_config}] = FakeGenSMTP.fetch_sent_emails()

    assert gen_smtp_config[:no_mx_lookups]
  end

  test "deliver raises an exception when username and password configuration are required" do
    bamboo_email = new_email()

    bamboo_config =
      configuration(%{
        username: nil,
        password: nil,
        auth: :always
      })

    assert_raise SMTPAdapter.SMTPError, ~r/no_credentials/, fn ->
      SMTPAdapter.deliver(bamboo_email, bamboo_config)
    end

    try do
      SMTPAdapter.deliver(bamboo_email, bamboo_config)
    rescue
      error in SMTPAdapter.SMTPError ->
        assert {:no_credentials, "Username and password were not provided for authentication."} =
                 error.raw
    end
  end

  test "deliver is successful when username and password are required and present" do
    bamboo_email = new_email()

    bamboo_config =
      configuration(%{
        username: "a",
        password: "b",
        auth: :always
      })

    assert {:ok, "200 Ok 1234567890"} = SMTPAdapter.deliver(bamboo_email, bamboo_config)
  end

  test "deliver is successful when username and password configuration are not required" do
    bamboo_email = new_email()

    bamboo_config =
      configuration(%{
        username: nil,
        password: nil,
        auth: :if_available
      })

    assert {:ok, "200 Ok 1234567890"} = SMTPAdapter.deliver(bamboo_email, bamboo_config)
  end

  test "deliver raises an exception when server configuration is wrong" do
    bamboo_email = new_email()
    bamboo_config = configuration(%{server: "wrong.smtp.domain"})

    assert_raise SMTPAdapter.SMTPError, ~r/network_failure/, fn ->
      SMTPAdapter.deliver(bamboo_email, bamboo_config)
    end

    try do
      SMTPAdapter.deliver(bamboo_email, bamboo_config)
    rescue
      error ->
        assert {:retries_exceeded, _detail} = error.raw
    end
  end

  test "sets default auth key if not present" do
    %{auth: auth} = SMTPAdapter.handle_config(configuration())

    assert :if_available == auth
  end

  test "doesn't set a default auth key if present" do
    %{auth: auth} = SMTPAdapter.handle_config(configuration(%{auth: :always}))

    assert :always == auth
  end

  test "sets auth if_available from System when specified" do
    System.put_env("AUTH", "if_available")

    config = SMTPAdapter.handle_config(configuration(%{auth: {:system, "AUTH"}}))
    {:ok, "200 Ok 1234567890"} = SMTPAdapter.deliver(new_email(), config)
    [{{_from, _to, _raw_email}, gen_smtp_config}] = FakeGenSMTP.fetch_sent_emails()

    assert gen_smtp_config[:auth] == :if_available
  end

  test "sets auth always from System when specified" do
    System.put_env("AUTH", "always")

    config = SMTPAdapter.handle_config(configuration(%{auth: {:system, "AUTH"}}))
    {:ok, "200 Ok 1234567890"} = SMTPAdapter.deliver(new_email(), config)
    [{{_from, _to, _raw_email}, gen_smtp_config}] = FakeGenSMTP.fetch_sent_emails()

    assert gen_smtp_config[:auth] == :always
  end

  test "emails raise an exception when email can't be sent" do
    bamboo_email = new_email(from: {"Wrong User", "wrong@user.com"})
    bamboo_config = configuration()

    assert_raise SMTPAdapter.SMTPError, ~r/554 Message rejected/, fn ->
      SMTPAdapter.deliver(bamboo_email, bamboo_config)
    end

    try do
      SMTPAdapter.deliver(bamboo_email, bamboo_config)
    rescue
      error ->
        assert {:no_more_hosts, _detail} = error.raw
    end
  end

  test "emails looks fine when only text body is set" do
    bamboo_email = new_email(text_body: nil)
    bamboo_config = configuration()

    {:ok, "200 Ok 1234567890"} = SMTPAdapter.deliver(bamboo_email, bamboo_config)

    assert 1 = length(FakeGenSMTP.fetch_sent_emails())

    [{{from, to, raw_email}, gen_smtp_config}] = FakeGenSMTP.fetch_sent_emails()

    [multipart_header] =
      Regex.run(
        ~r{Content-Type: multipart/alternative; boundary="([^"]+)"\r\n},
        raw_email,
        capture: :all_but_first
      )

    assert format_email_as_string(bamboo_email.from, false) == from
    assert format_email(bamboo_email.to ++ bamboo_email.cc ++ bamboo_email.bcc, false) == to

    assert String.contains?(raw_email, "Subject: #{rfc822_encode("Hello from Bamboo")}")

    assert String.contains?(raw_email, "From: #{format_email_as_string(bamboo_email.from)}\r\n")
    assert String.contains?(raw_email, "To: #{format_email_as_string(bamboo_email.to)}\r\n")
    assert String.contains?(raw_email, "Cc: #{format_email_as_string(bamboo_email.cc)}\r\n")
    assert String.contains?(raw_email, "Bcc: #{format_email_as_string(bamboo_email.bcc)}\r\n")
    assert String.contains?(raw_email, "Reply-To: reply@doe.com\r\n")
    assert String.contains?(raw_email, "MIME-Version: 1.0\r\n")

    assert String.contains?(
             raw_email,
             "--#{multipart_header}\r\n" <>
               "Content-Type: text/html;charset=UTF-8\r\n" <>
               "Content-Transfer-Encoding: base64\r\n" <>
               "\r\n" <>
               "#{SMTPAdapter.base64_and_split(bamboo_email.html_body)}\r\n"
           )

    refute String.contains?(
             raw_email,
             "--#{multipart_header}\r\n" <>
               "Content-Type: text/plain;charset=UTF-8\r\n" <>
               "\r\n"
           )

    assert_configuration(bamboo_config, gen_smtp_config)
  end

  test "email is sent when subject is not set" do
    bamboo_email = new_email(subject: nil)
    bamboo_config = configuration()

    {:ok, "200 Ok 1234567890"} = SMTPAdapter.deliver(bamboo_email, bamboo_config)

    assert 1 = length(FakeGenSMTP.fetch_sent_emails())

    [{{_from, _to, raw_email}, gen_smtp_config}] = FakeGenSMTP.fetch_sent_emails()

    plain_text = "Subject: \r\n"
    assert String.contains?(raw_email, plain_text)

    assert_configuration(bamboo_config, gen_smtp_config)
  end

  test "emails looks fine when only HTML body is set" do
    bamboo_email = new_email(html_body: nil)
    bamboo_config = configuration()

    {:ok, "200 Ok 1234567890"} = SMTPAdapter.deliver(bamboo_email, bamboo_config)

    assert 1 = length(FakeGenSMTP.fetch_sent_emails())

    [{{from, to, raw_email}, gen_smtp_config}] = FakeGenSMTP.fetch_sent_emails()

    [multipart_header] =
      Regex.run(
        ~r{Content-Type: multipart/alternative; boundary="([^"]+)"\r\n},
        raw_email,
        capture: :all_but_first
      )

    assert format_email_as_string(bamboo_email.from, false) == from
    assert format_email(bamboo_email.to ++ bamboo_email.cc ++ bamboo_email.bcc, false) == to

    assert String.contains?(raw_email, "Subject: #{rfc822_encode("Hello from Bamboo")}")
    assert String.contains?(raw_email, "From: #{format_email_as_string(bamboo_email.from)}\r\n")
    assert String.contains?(raw_email, "To: #{format_email_as_string(bamboo_email.to)}\r\n")
    assert String.contains?(raw_email, "Cc: #{format_email_as_string(bamboo_email.cc)}\r\n")
    assert String.contains?(raw_email, "Bcc: #{format_email_as_string(bamboo_email.bcc)}\r\n")
    assert String.contains?(raw_email, "Reply-To: reply@doe.com\r\n")
    assert String.contains?(raw_email, "MIME-Version: 1.0\r\n")

    refute String.contains?(
             raw_email,
             "--#{multipart_header}\r\n" <>
               "Content-Type: text/html;charset=UTF-8\r\n" <>
               "\r\n"
           )

    assert String.contains?(
             raw_email,
             "--#{multipart_header}\r\n" <>
               "Content-Type: text/plain;charset=UTF-8\r\n" <>
               "\r\n" <>
               "#{bamboo_email.text_body}\r\n"
           )

    assert_configuration(bamboo_config, gen_smtp_config)
  end

  test "emails looks fine when text and HTML bodys are sets" do
    bamboo_email = new_email()
    bamboo_config = configuration()

    {:ok, "200 Ok 1234567890"} = SMTPAdapter.deliver(bamboo_email, bamboo_config)

    assert 1 = length(FakeGenSMTP.fetch_sent_emails())

    [{{from, to, raw_email}, gen_smtp_config}] = FakeGenSMTP.fetch_sent_emails()

    [multipart_header] =
      Regex.run(
        ~r{Content-Type: multipart/alternative; boundary="([^"]+)"\r\n},
        raw_email,
        capture: :all_but_first
      )

    assert format_email_as_string(bamboo_email.from, false) == from
    assert format_email(bamboo_email.to ++ bamboo_email.cc ++ bamboo_email.bcc, false) == to

    assert String.contains?(raw_email, "Subject: #{rfc822_encode("Hello from Bamboo")}")
    assert String.contains?(raw_email, "From: #{format_email_as_string(bamboo_email.from)}\r\n")
    assert String.contains?(raw_email, "To: #{format_email_as_string(bamboo_email.to)}\r\n")
    assert String.contains?(raw_email, "Cc: #{format_email_as_string(bamboo_email.cc)}\r\n")
    assert String.contains?(raw_email, "Bcc: #{format_email_as_string(bamboo_email.bcc)}\r\n")
    assert String.contains?(raw_email, "Reply-To: reply@doe.com\r\n")
    assert String.contains?(raw_email, "MIME-Version: 1.0\r\n")

    assert String.contains?(
             raw_email,
             "--#{multipart_header}\r\n" <>
               "Content-Type: text/html;charset=UTF-8\r\n" <>
               "Content-Transfer-Encoding: base64\r\n" <>
               "\r\n" <>
               "#{SMTPAdapter.base64_and_split(bamboo_email.html_body)}\r\n"
           )

    assert String.contains?(
             raw_email,
             "--#{multipart_header}\r\n" <>
               "Content-Type: text/plain;charset=UTF-8\r\n" <>
               "\r\n" <>
               "#{bamboo_email.text_body}\r\n"
           )

    assert_configuration(bamboo_config, gen_smtp_config)
  end

  test "email looks fine when no bcc: is set" do
    bamboo_email = new_email(bcc: [])
    bamboo_config = configuration()

    {:ok, "200 Ok 1234567890"} = SMTPAdapter.deliver(bamboo_email, bamboo_config)

    assert 1 = length(FakeGenSMTP.fetch_sent_emails())

    [{{from, to, raw_email}, gen_smtp_config}] = FakeGenSMTP.fetch_sent_emails()

    [multipart_header] =
      Regex.run(
        ~r{Content-Type: multipart/alternative; boundary="([^"]+)"\r\n},
        raw_email,
        capture: :all_but_first
      )

    assert format_email_as_string(bamboo_email.from, false) == from
    assert format_email(bamboo_email.to ++ bamboo_email.cc ++ bamboo_email.bcc, false) == to

    assert String.contains?(raw_email, "Subject: #{rfc822_encode("Hello from Bamboo")}")
    assert String.contains?(raw_email, "From: #{format_email_as_string(bamboo_email.from)}\r\n")
    assert String.contains?(raw_email, "To: #{format_email_as_string(bamboo_email.to)}\r\n")
    assert String.contains?(raw_email, "Cc: #{format_email_as_string(bamboo_email.cc)}\r\n")
    refute String.contains?(raw_email, "Bcc: #{format_email_as_string(bamboo_email.bcc)}\r\n")
    assert String.contains?(raw_email, "Reply-To: reply@doe.com\r\n")
    assert String.contains?(raw_email, "MIME-Version: 1.0\r\n")

    assert String.contains?(
             raw_email,
             "--#{multipart_header}\r\n" <>
               "Content-Type: text/html;charset=UTF-8\r\n" <>
               "Content-Transfer-Encoding: base64\r\n" <>
               "\r\n" <>
               "#{SMTPAdapter.base64_and_split(bamboo_email.html_body)}\r\n"
           )

    assert String.contains?(
             raw_email,
             "--#{multipart_header}\r\n" <>
               "Content-Type: text/plain;charset=UTF-8\r\n" <>
               "\r\n"
           )

    assert_configuration(bamboo_config, gen_smtp_config)
  end

  test "email looks fine when no cc: is set" do
    bamboo_email = new_email(cc: [])
    bamboo_config = configuration()

    {:ok, "200 Ok 1234567890"} = SMTPAdapter.deliver(bamboo_email, bamboo_config)

    assert 1 = length(FakeGenSMTP.fetch_sent_emails())

    [{{from, to, raw_email}, gen_smtp_config}] = FakeGenSMTP.fetch_sent_emails()

    [multipart_header] =
      Regex.run(
        ~r{Content-Type: multipart/alternative; boundary="([^"]+)"\r\n},
        raw_email,
        capture: :all_but_first
      )

    assert format_email_as_string(bamboo_email.from, false) == from
    assert format_email(bamboo_email.to ++ bamboo_email.cc ++ bamboo_email.bcc, false) == to

    assert String.contains?(raw_email, "Subject: #{rfc822_encode("Hello from Bamboo")}")
    assert String.contains?(raw_email, "From: #{format_email_as_string(bamboo_email.from)}\r\n")
    assert String.contains?(raw_email, "To: #{format_email_as_string(bamboo_email.to)}\r\n")
    refute String.contains?(raw_email, "Cc: #{format_email_as_string(bamboo_email.cc)}\r\n")
    assert String.contains?(raw_email, "Bcc: #{format_email_as_string(bamboo_email.bcc)}\r\n")
    assert String.contains?(raw_email, "Reply-To: reply@doe.com\r\n")
    assert String.contains?(raw_email, "MIME-Version: 1.0\r\n")

    assert String.contains?(
             raw_email,
             "--#{multipart_header}\r\n" <>
               "Content-Type: text/html;charset=UTF-8\r\n" <>
               "Content-Transfer-Encoding: base64\r\n" <>
               "\r\n" <>
               "#{SMTPAdapter.base64_and_split(bamboo_email.html_body)}\r\n"
           )

    assert String.contains?(
             raw_email,
             "--#{multipart_header}\r\n" <>
               "Content-Type: text/plain;charset=UTF-8\r\n" <>
               "\r\n"
           )

    assert_configuration(bamboo_config, gen_smtp_config)
  end

  test "email looks fine when they have non-ASCII characters in subject, from and to" do
    bamboo_email =
      new_email(
        from: {"Awesome Person 😎", "awesome@person.local"},
        to: {"Person Awesome 🤩", "person@awesome.local"},
        subject: "Hello! 👋"
      )

    bamboo_config = configuration()

    {:ok, "200 Ok 1234567890"} = SMTPAdapter.deliver(bamboo_email, bamboo_config)

    assert 1 = length(FakeGenSMTP.fetch_sent_emails())

    [{{from, to, raw_email}, gen_smtp_config}] = FakeGenSMTP.fetch_sent_emails()

    [multipart_header] =
      Regex.run(
        ~r{Content-Type: multipart/alternative; boundary="([^"]+)"\r\n},
        raw_email,
        capture: :all_but_first
      )

    assert format_email_as_string(bamboo_email.from, false) == from
    assert format_email(bamboo_email.to ++ bamboo_email.cc ++ bamboo_email.bcc, false) == to

    rfc822_subject = "Subject: =?UTF-8?B?SGVsbG8hIPCfkYs=?=\r\n"
    assert String.contains?(raw_email, rfc822_subject)

    assert String.contains?(raw_email, "From: #{format_email_as_string(bamboo_email.from)}\r\n")
    assert String.contains?(raw_email, "To: #{format_email_as_string(bamboo_email.to)}\r\n")
    assert String.contains?(raw_email, "Cc: #{format_email_as_string(bamboo_email.cc)}\r\n")
    assert String.contains?(raw_email, "Bcc: #{format_email_as_string(bamboo_email.bcc)}\r\n")
    assert String.contains?(raw_email, "Reply-To: reply@doe.com\r\n")
    assert String.contains?(raw_email, "MIME-Version: 1.0\r\n")

    assert String.contains?(
             raw_email,
             "--#{multipart_header}\r\n" <>
               "Content-Type: text/html;charset=UTF-8\r\n" <>
               "Content-Transfer-Encoding: base64\r\n" <>
               "\r\n" <>
               "#{SMTPAdapter.base64_and_split(bamboo_email.html_body)}\r\n"
           )

    assert String.contains?(
             raw_email,
             "--#{multipart_header}\r\n" <>
               "Content-Type: text/plain;charset=UTF-8\r\n" <>
               "\r\n"
           )

    assert_configuration(bamboo_config, gen_smtp_config)
  end

  test "email have a Content-ID properly set when attaching files with content_id" do
    bamboo_email =
      new_email()
      |> Bamboo.Email.put_attachment(Path.absname("test/attachments/attachment_one.txt"),
        content_id: "12345"
      )
      |> Bamboo.Email.put_attachment(Path.absname("test/attachments/attachment_two.txt"),
        content_id: "54321"
      )

    bamboo_config = configuration()

    {:ok, "200 Ok 1234567890"} = SMTPAdapter.deliver(bamboo_email, bamboo_config)

    assert 1 = length(FakeGenSMTP.fetch_sent_emails())

    [{{_from, _to, raw_email}, _gen_smtp_config}] = FakeGenSMTP.fetch_sent_emails()

    assert Regex.run(~r{Content-ID: <12345>\r\n}, raw_email, capture: :all_but_first)
    assert Regex.run(~r{Content-ID: <54321>\r\n}, raw_email, capture: :all_but_first)
  end

  test "check rfc822 encoding for subject" do
    bamboo_email =
      @email_in_utf8
      |> Email.new_email()
      |> Bamboo.Mailer.normalize_addresses()

    bamboo_config = configuration()

    {:ok, "200 Ok 1234567890"} = SMTPAdapter.deliver(bamboo_email, bamboo_config)

    [{{_from, _to, raw_email}, _gen_smtp_config}] = FakeGenSMTP.fetch_sent_emails()

    rfc822_subject = "Subject: =?UTF-8?B?5pel5pys6Kqe44Gu772T772V772C772K772F772D772U?=\r\n"
    assert String.contains?(raw_email, rfc822_subject)
  end

  defp format_email(emails), do: format_email(emails, true)

  defp format_email({name, email}, true), do: "#{rfc822_encode(name)} <#{email}>"
  defp format_email({_name, email}, false), do: email

  defp format_email(emails, format) when is_list(emails) do
    emails |> Enum.map(&format_email_as_string(&1, format))
  end

  defp format_email_as_string(emails) when is_list(emails) do
    emails |> format_email |> Enum.join(", ")
  end

  defp format_email_as_string(email, format \\ true) do
    format_email(email, format)
  end

  defp rfc822_encode(content) do
    "=?UTF-8?B?#{Base.encode64(content)}?="
  end

  defp assert_configuration(bamboo_config, gen_smtp_config) do
    assert bamboo_config[:server] == gen_smtp_config[:relay]
    assert bamboo_config[:port] == gen_smtp_config[:port]
    assert bamboo_config[:hostname] == gen_smtp_config[:hostname]
    assert bamboo_config[:username] == gen_smtp_config[:username]
    assert bamboo_config[:password] == gen_smtp_config[:password]
    assert bamboo_config[:tls] == gen_smtp_config[:tls]
    assert bamboo_config[:ssl] == gen_smtp_config[:ssl]
    assert bamboo_config[:retries] == gen_smtp_config[:retries]
    assert bamboo_config[:no_mx_lookups] == gen_smtp_config[:no_mx_lookups]
  end

  defp configuration(override \\ %{}), do: Map.merge(@configuration, override)

  defp new_email(override \\ []) do
    @email
    |> Keyword.merge(override)
    |> Email.new_email()
    |> Bamboo.Mailer.normalize_addresses()
  end
end
