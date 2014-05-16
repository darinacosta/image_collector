require 'sinatra'
require "google_drive"
require "mechanize"
require "uri"


module ImageCollector
  def self.collect(page_url, spreadsheet, css_selector)
    image_scraper = ImageScraper.new(page_url, css_selector)
    image_urls = image_scraper.pull_image_urls
    image_writer = SpreadsheetWriter.new(spreadsheet, page_url)
    image_writer.write_to_spreadsheet(image_urls)
  end
      
   

  class ImageScraper
    attr_reader :page_url, :page, :css_selector

    def initialize(page_url, css_selector = "")
      @page_url = page_url
      @page = get_page(page_url)
      @css_selector = css_selector
    end

    def pull_image_urls
      image_urls = []
      css_selector = parse_css_selector(css_selector)
      page.css("#{css_selector}").each do |image|
        relative_image_path = image['src']
        absolute_image_url = compile_image_url(page_url, relative_image_path)
        image_urls.push(absolute_image_url)
      end
      puts image_urls.count.to_s + " images found."
      return image_urls
    end

    def parse_css_selector(css_selector)
      if css_selector == ""
        return "img"
      elsif css_selector =~ /,/
        return css_selector.split(',').map { |s| "#{s} img" }.join(',')
      else
        return "#{css_selector} img"
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



  class SpreadsheetWriter 
    attr_reader :url, :worksheet, :rows

    def initialize(spreadsheet,url="")
      @url = url
      @worksheet = Session.spreadsheet_by_url(spreadsheet).worksheets[0]
      @rows = @worksheet.rows.count
    end

    def write_to_spreadsheet(array)
      count = 0
      row = rows + 1
      array.each do |item|
        count += 1
        row += 1
        worksheet.reload
        worksheet[row, 1] = url if count == 1
        worksheet[row, 2] = item
        worksheet.synchronize
      end
    end
  end

end

