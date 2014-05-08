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
  url='http://railscasts.com/episodes/190-screen-scraping-with-nokogiri'
  @test=ImageCollector::ImageScraper.new.pullpage(url)
  erb :out
end
