defmodule SuperIssuer.MixProject do
  use Mix.Project

  def project do
    [
      app: :super_issuer,
      version: "0.1.0",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {SuperIssuer.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.5.6"},
      {:phoenix_ecto, "~> 4.1"},
      {:ecto_sql, "~> 3.4"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_live_view, "~> 0.14.6"},
      {:floki, ">= 0.27.0", only: :test},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_dashboard, "~> 0.3 or ~> 0.2.9"},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 0.4"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},

      # http
      {:httpoison, "~> 1.5"},
      {:poison, "~> 3.1"},
      # crypto
      {:binary, "~> 0.0.5"},
      # eth
      {:ex_rlp, "~> 0.5.3"},
      # {:ksha3, "~> 1.0.0", git: "https://github.com/onyxrev/ksha3.git", branch: "master"},
      # {:keccakf1600, "~> 3.0.0"},
      # ecto
      {:ecto_enum, "~> 1.2"},
      # for user
      {:comeonin, "~> 4.0"},
      {:bcrypt_elixir, "~> 1.0"},
      # live clock example
      {:nimble_strftime, ">= 0.0.0"},

      # cross domain
      {:cors_plug, "~> 2.0"},

      #ethereum
      {:ethereumex, "~> 0.9"},
      {:ex_abi, "~> 0.5.2"},
      # struct handler
      {:ex_struct_translator, "~> 0.1.1"},
      {:ecto, "~> 3.5.5", override: true},

      # markdown
      {:earmark, "~> 1.4"},
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "cmd npm install --prefix assets"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.dev.gen_data": ["run priv/repo/admin_seeds_dev.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end
end
