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
  authorize: "https://github.com/login/oauth/authorize",
  token: "https://github.com/login/oauth/access_token",
  user: "https://api.github.com/user"
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
  if session[:state] != params[:state]
    [403, {}, []]
  else
    query_params = {
      client_id: GITHUB_ID,
      client_secret: GITHUB_SECRET,
      code: params[:code]
    }

    token_response = RestClient.get("#{GITHUB_API[:token]}?#{query_params.to_query}", {accept: "json"})
    token_params = JSON.parse(token_response.body)

    query_params = { access_token: token_params['access_token'] }
    user_response = RestClient.get("#{GITHUB_API[:user]}?#{query_params.to_query}", {accept: "json"})
    user_params = JSON.parse(user_response.body)

    session[:user_id] = user_params['id']
    session[:logged_in] = true
    [302, {"Location" => "/"}, []]
  end
end

get "/logout" do
  session[:logged_in] = false
  [302, {"Location" => "/"}, []]
end
