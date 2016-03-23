require "sinatra"
require "rest-client"
require "date"
require "securerandom"
require "json"
require "active_support/all"

# global variables
GITHUB_ID = "d1f4907472e9c3886fa9"
GITHUB_SECRET = "b096810a75a2d80dda981de47a65156aea78172d"
GITHUB_SCOPE = "user:email,read:org"
GITHUB_API = {
  authorize: "https://github.com/login/oauth/authorize"
}

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
  session[:state] = SecureRandom.hex(8)

  query_params = {
    client_id: GITHUB_ID,
    scope: GITHUB_SCOPE,
    redirect_uri: "http://localhost:4567/oauth/github",
    state: session[:state]
  }

  authorize_url = "#{GITHUB_API[:authorize]}?#{query_params.to_query}"
  [302, {"Location" => authorize_url}, []]
end

get "/oauth/github" do
  puts params.inspect
  [302, {"Location" => "/"}, []]
end

get "/logout" do
  session[:logged_in] = false
  [302, {"Location" => "/"}, []]
end
