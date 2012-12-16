require "rubygems"
require "execjs"
require "sinatra"
require "coffee-script"
require "haml"

COFFEE = [
  'utl',
  'iframe',
  'extend_methods',
  'base_class',
  'core_model',
  'homeview',
  "routes",
  'jimon_portal'
]
get "/js/jimon.portal.js" do
  PATH = File.dirname(__FILE__) + "/coffee/"
  source = ''
  COFFEE.each do |cf|
    open(PATH+cf+'.coffee'){|f| source += f.read }
  end
  coffee source
end

get "/js/jimon.portal.coffee" do
  PATH = File.dirname(__FILE__) + "/coffee/"
  source = ''
  COFFEE.each do |cf|
    open(PATH+cf+'.coffee'){|f| source += f.read }
  end
  source
end

get "*" do
  haml :home, :layout=>false
end
