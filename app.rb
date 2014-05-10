require 'sinatra'
require "google_drive"
require "mechanize"
require 'uri'

configure :development do
  require 'pp'
  require 'dotenv'

  Dotenv.load
end

Session = GoogleDrive.login(ENV['GOOGLE_USER'], ENV['GOOGLE_PASS'])

require_relative "lib/image_collector.rb"

#paths
get '/' do
  erb :form
end


post '/output' do
  input=params[:URL1]
  urls=input.split(" ")
  spreadsheet=params[:spreadsheet]
  urls.each do |url|
    ImageCollector::Collector.new(url,spreadsheet)
  end
  #{}"Image sources for the requested URLs are available in <a href='#{spreadsheet}' target='_blank'>this Google spreadsheet</a>."
end
