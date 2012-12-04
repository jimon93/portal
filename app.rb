require "rubygems"
require "sinatra"
require "coffee-script"
require "haml"

get "/js/jimon.portal.js" do
  #coffee :jimon_portal
end

get "/" do
  haml :home
end
