defmodule SuperIssuerWeb.Router do
  use SuperIssuerWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {SuperIssuerWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api_allow_cross do
    plug CORSPlug, origin: [~r/.*/]
    plug :accepts, ["json"]
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SuperIssuerWeb do
    pipe_through :browser
    get "/", IndexController, :index
    post "/", IndexController, :index

    get "/test", TestController, :index

    resources "/user/registrations", UserController, only: [:create, :new]
    get "/user/sign-in", SessionController, :new
    post "/user/sign-in", SessionController, :create
    get "/user", UserController, :index

    get "/credential/show", CredentialController, :index

    live "/live/clock", ClockLive
    live "/live/credential", CredentialLive
    live "/live/credential/new", CredentialLive.New
    live "/live/contract", ContractLive
    live "/live/contract/source_code", ContractSourceCodeLive
    live "/live/evidence", EvidencerLive

    live "/live/nft", NftLive.Index

    live "/live/tx", TxLive.Index

    live "/live/event", EventLive

    live "/live/app", AppLive

  end

  # Other scopes may use custom stacks.
  scope "/welight/api/v1", SuperIssuerWeb do
    pipe_through :api

    # weidentity group
    post "/weid/create", AppController, :create_weid

    # contract group
    get "/contracts", AppController, :get_contracts
    post "/contract/func", AppController, :interact_with_contract

    # token group
    get "/ft/get_balance", AppController, :get_ft_balance
    post "/ft/transfer", AppController, :transfer_ft

    post "/nft/mint", AppController, :mint_nft
  end

  scope "/welight/api/v1", SuperIssuerWeb do
    pipe_through :api_allow_cross
    get "/nft/get_balance", AppController, :get_nft_balance
    get "/nft/test", AppController, :test
  end

end
