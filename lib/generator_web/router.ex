defmodule GeneratorWeb.Router do
  use GeneratorWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {GeneratorWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", GeneratorWeb do
    pipe_through :browser

    get "/", PageController, :index

    live "/components", ComponentLive.Index, :index
    live "/components/new", ComponentLive.Index, :new
    live "/components/:id/edit", ComponentLive.Index, :edit

    live "/components/:id", ComponentLive.Show, :show
    live "/components/:id/show/edit", ComponentLive.Show, :edit

    live "/sites", SiteLive.Index, :index
    live "/sites/new", SiteLive.Index, :new
    live "/sites/:id/edit", SiteLive.Index, :edit

    live "/sites/:site_id/pages", PageLive.Index, :index
    live "/sites/:site_id/pages/new", PageLive.Index, :new
    live "/sites/:site_id/pages/:id/edit", PageLive.Index, :edit
    live "/sites/:site_id/pages/:id/show/edit", PageLive.Show, :edit
    live "/sites/:site_id/pages/:id/show", PageLive.Show, :show
  end

  # Other scopes may use custom stacks.
  # scope "/api", GeneratorWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: GeneratorWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
