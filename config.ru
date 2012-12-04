require 'app'

#require 'rubygems'
#require 'ruby-prof'
#Rack::RubyProf = RubyProf
#require 'rack/contrib/profiler'
#use Rack::Profiler, :printer => :graph_html

run Sinatra::Application

