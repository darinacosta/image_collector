require 'sinatra'
require "google_drive"
require "mechanize"
require "uri"

configure :development do
  require 'pp'
  require 'dotenv'

  Dotenv.load
end

require_relative "lib/image_collector.rb"

Session = GoogleDrive.login(ENV['GOOGLE_USER'], ENV['GOOGLE_PASS'])


#global methods
def get_page(page_url)
  @agent = Mechanize.new { |agent| agent.user_agent_alias = "Mac Safari" }
  #set the user agent to a variable
  @page_url=page_url
  html = agent.get(page_url).body
  page = Nokogiri::HTML(html)
  return page
end


#paths
get '/' do
  erb :form
end


post '/output' do
  input = params[:urls]
  urls = input.split(" ")
  selectors = params[:selectors]
  spreadsheet = params[:spreadsheet]
  urls.each do |url|
    puts "Checking #{url} for image(s)."
    ImageCollector.collect(url,spreadsheet,selectors)
  end
  "Image sources for the requested URLs are available in <a href='#{spreadsheet}' target='_blank'>this Google spreadsheet</a>."
end


