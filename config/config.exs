# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

# Configures the endpoint
config :aggregator, AggregatorWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: AggregatorWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Aggregator.PubSub,
  live_view: [signing_salt: "cqzeMTa+"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :aggregator, :ndc_apis, %{
  "BA" => %{
    code: "BA",
    url: "https://api.ba.com/rest-v1/",
    auth_token: "",
    module: Aggregator.NDC.BA
  },
  "AFKLM" => %{code: "AFKLM", url: "", auth_token: "", module: Aggregator.NDC.AFKLM}
}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
