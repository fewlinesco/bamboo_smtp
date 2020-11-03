defmodule BambooSMTP.TestAdapter do
  @moduledoc """
  Based on `Bamboo.TestAdapter`, this module can be used for testing email delivery.

  The `deliver/2` function will provide a response that follow the format of a SMTP server raw response.

  No emails are sent, instead it sends back `{%Bamboo.Email{...}, {:ok,"<raw_smtp_response>"}}` 
  for success and raise an exception on error.

  ## Example config

      # Typically done in config/test.exs
      config :my_app, MyApp.Mailer,
        adapter: BambooSMTP.TestAdapter

      # Define a Mailer. Typically in lib/my_app/mailer.ex
      defmodule MyApp.Mailer do
        use Bamboo.Mailer, otp_app: :my_app
      end
  """

  @behaviour Bamboo.Adapter

  @doc false
  def deliver(_email, _config) do
    send(test_process(), {:ok, "Ok #{Enum.random(100_000_000..999_999_999)}"})
  end

  defp test_process do
    Application.get_env(:bamboo, :shared_test_process) || self()
  end

  def handle_config(config) do
    case config[:deliver_later_strategy] do
      nil ->
        Map.put(config, :deliver_later_strategy, Bamboo.ImmediateDeliveryStrategy)

      Bamboo.ImmediateDeliveryStrategy ->
        config

      _ ->
        raise ArgumentError, """
        BambooSMTP.TestAdapter requires that the deliver_later_strategy is
        Bamboo.ImmediateDeliveryStrategy

        Instead it got: #{inspect(config[:deliver_later_strategy])}

        Please remove the deliver_later_strategy from your config options, or
        set it to Bamboo.ImmediateDeliveryStrategy.
        """
    end
  end

  @doc false
  def supports_attachments?, do: true
end
