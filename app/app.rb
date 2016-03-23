require "sinatra"
require "rest-client"
require "date"
require "securerandom"
require "json"
require "active_support/all"

Tilt.register Tilt::ERBTemplate, 'html.erb'

# configure cookie sessions
set :sessions,
  key: "_app_session",
  path: "/",
  secret: "super secret",
  expire_after: 365.days

helpers do
  def logged_in?
    session[:logged_in]
  end
end

get "/" do
  erb :home
end

get "/login" do
  session[:logged_in] = true
  [302, {"Location" => "/"}, []]
end

get "/logout" do
  session[:logged_in] = false
  [302, {"Location" => "/"}, []]
end
