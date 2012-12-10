require "rubygems"
require "execjs"
require "sinatra"
require "coffee-script"
require "haml"

get "/js/jimon.portal.js" do
  COFFEE = [
    'utl',
    'iframe',
    'sort_reload',
    'model',
    'view',
    "routes",
    'jimon_portal'
  ]
  PATH = File.dirname(__FILE__) + "/coffee/"
  source = ''
  COFFEE.each do |cf|
    open(PATH+cf+'.coffee'){|f| source += f.read }
  end
  coffee source
end

get "/" do
  haml :home, :layout=>false
end
