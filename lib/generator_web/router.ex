defmodule GeneratorWeb.Router do
  use GeneratorWeb, :router

  import GeneratorWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {GeneratorWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :signed_in_layout do
    plug :put_layout, {GeneratorWeb.LayoutView, :signed_in}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/webhooks", GeneratorWeb do
    pipe_through :api

    post "/subscriptions", SubscriptionController, :create
    post "/authenticate", SiteAuthenticationController, :create
  end

  scope "/admin", GeneratorWeb do
    pipe_through :browser

    live "/users", UserLive.Index, :index
    live "/users/:id/edit", UserLive.Index, :edit

    live "/users/:user_id/sites", SiteLive.Index, :index
    live "/users/:user_id/sites/new", SiteLive.Index, :new
    live "/users/:user_id/sites/:id/edit", SiteLive.Index, :edit

    live "/users/:user_id/sites/:site_id/pages", PageLive.Index, :index
    live "/users/:user_id/sites/:site_id/pages/new", PageLive.Index, :new
    live "/users/:user_id/sites/:site_id/pages/:id/edit", PageLive.Index, :edit
    live "/users/:user_id/sites/:site_id/pages/:id/show/edit", PageLive.Show, :edit
    live "/users/:user_id/sites/:site_id/pages/:id/show", PageLive.Show, :show

    live "/users/:user_id/plan", UserPlanLive.Index, :index
    live "/plans", PlanLive.Index, :index
    live "/plans/:id/edit", PlanLive.Index, :edit

    live "/admins", AdminLive.Index, :index
    live "/admins/new", AdminLive.Index, :new
    live "/admins/:id/edit", AdminLive.Index, :edit

    live "/threads", ThreadLive.Index, :index
    live "/threads/messages", MessageLive.Show, :show
  end

  ## Authentication routes

  scope "/", GeneratorWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/", PageController, :index

    get "/users/register", UserRegistrationController, :new
    post "/users/register", UserRegistrationController, :create
    get "/users/log_in", UserSessionController, :new
    post "/users/log_in", UserSessionController, :create
    get "/users/reset_password", UserResetPasswordController, :new
    post "/users/reset_password", UserResetPasswordController, :create
    get "/users/reset_password/:token", UserResetPasswordController, :edit
    put "/users/reset_password/:token", UserResetPasswordController, :update

    get "/plans", PlanController, :index
  end

  scope "/", GeneratorWeb do
    pipe_through [:browser, :require_authenticated_user, :signed_in_layout]

    get "/users/dashboard", DashboardController, :index

    get "/users/settings", UserSettingsController, :edit
    put "/users/settings", UserSettingsController, :update
    get "/users/settings/confirm_email/:token", UserSettingsController, :confirm_email

    get "/threads/:id/messages", MessageController, :index
    post "/threads/:id/messages/create", MessageController, :create

    get "/threads", ThreadController, :index
    post "/threads/create", ThreadController, :create

    get "/billing", BillingController, :index
    get "/billing/add-card", BillingController, :new
    post "/billing/add-card", BillingController, :create
    delete "/billing/delete-card/:id", BillingController, :delete
    post "/billing/make-default/:id", BillingController, :make_default

    get "/moderators", ModeratorController, :index
    get "/moderators/new", ModeratorController, :new
    post "/moderators/create", ModeratorController, :create
    get "/moderators/:id", ModeratorController, :show
    put "/moderators/:id/update", ModeratorController, :update
    delete "/moderators/delete/:id", ModeratorController, :delete
  end

  scope "/", GeneratorWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
    get "/users/confirm", UserConfirmationController, :new
    post "/users/confirm", UserConfirmationController, :create
    get "/users/confirm/:token", UserConfirmationController, :edit
    post "/users/confirm/:token", UserConfirmationController, :update
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
