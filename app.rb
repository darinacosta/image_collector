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
  url='http://www.wikipedia.org/'
  spreadsheet='https://docs.google.com/a/searchinfluence.com/spreadsheets/d/1lPhY_l5zo6Jg5Y0XQLjMvljnv1JumDbbEbmiKhtLt3M/edit#gid=0'
  scraper=ImageCollector::ImageScraper.new
  page_elements=scraper.pullimages(url)
  image_writer=ImageCollector::ImageWriter.new(spreadsheet)
  @test=image_writer.image_loop(page_elements)
  erb :out
end
