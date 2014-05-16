require 'sinatra'
require "google_drive"
require "mechanize"
require "uri"


module ImageCollector
  def self.collect(page_url, spreadsheet, image_selector)
    image_scraper = ImageScraper.new(page_url, image_selector)
    image_urls = image_scraper.pull_image_urls
    image_writer = SpreadsheetWriter.new(spreadsheet, page_url)
    image_writer.write_to_spreadsheet(image_urls)
  end
      
      
  class ImageScraper
    attr_reader :page_url, :page, :image_selector

    def initialize(page_url, image_selector = "")
      @page_url = page_url
      @page = Page.new(page_url).return_page
      @image_selector = image_selector
    end

    def pull_image_urls
      image_urls = []
      image_selector = parse_image_selector(image_selector)
      page.css("#{image_selector}").each do |image|
        relative_image_path = image['src']
        absolute_image_url = compile_image_url(page_url, relative_image_path)
        image_urls.push(absolute_image_url)
      end
      puts image_urls.count.to_s + " images found."
      return image_urls
    end

    def parse_image_selector(image_selector)
      if image_selector == ""
        return "img"
      elsif image_selector =~ /,/
        return image_selector.split(',').map { |s| "#{s} img" }.join(',')
      else
        return "#{image_selector} img"
      end
    end

    def compile_image_url(page_url, relative_image_path)
      split_url = page_url.split('/')
      root_url = "#{split_url[0]}//#{split_url[1] + split_url[2]}"
      relative_image_path.gsub!(" ","%20")
      absolute_image_url = URI.join(root_url, relative_image_path).to_s
      return absolute_image_url
    end

    def worksheet
      @worksheet
    end
  end


  class Page #move this out of the Image class, global level helper method (some new module)? Also, handle all the 404s etc
    attr_reader :agent, :page_url

    def initialize(page_url)
      @agent = Mechanize.new { |agent| agent.user_agent_alias = "Mac Safari" }
      #set the user agent to a variable
      @page_url=page_url
    end 

    def return_page
      html = agent.get(page_url).body
      page = Nokogiri::HTML(html)
      return page
    end
  end


  class SpreadsheetWriter 
    def initialize(spreadsheet,url="")
      @url = url
      @worksheet = Session.spreadsheet_by_url(spreadsheet).worksheets[0]
      @rows = @worksheet.rows.count
    end

    def write_to_spreadsheet(array)
      count = 0
      row = @rows + 1
      array.each do |item|
        count += 1
        row += 1
        @worksheet.reload
        @worksheet[row, 1] = @url if count == 1
        @worksheet[row, 2] = item
        @worksheet.synchronize
      end
    end
  end

end

