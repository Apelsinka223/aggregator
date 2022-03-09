import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :aggregator, AggregatorWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "HXDNcje62XQ/MgrNdwXZkSMXVb5kWh+gWBcAInDxPXL8BNKVlgEREsVDPPQuK8jF",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :tesla, adapter: Tesla.Mock

config :aggregator, :ndc_apis, %{
  "BA" => %{
    code: "BA",
    url: "https://example.com/ba",
    auth_token: "ba_token",
    module: Aggregator.NDC.BA
  },
  "AFKLM" => %{
    code: "AFKLM",
    url: "https://example.com/afklm",
    auth_token: "afklm_token",
    module: Aggregator.NDC.AFKLM
  }
}
