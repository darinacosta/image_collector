module ImageCollector


  class Enabler

    def initialize(url)
      @agent = Mechanize.new { |agent| agent.user_agent_alias = "Mac Safari" }
      @url=url
      @worksheet = Session.spreadsheet_by_url("https://docs.google.com/a/searchinfluence.com/spreadsheets/d/1Xo98mtLrWfy4fpL3-60lOLKX7wmxRK92o14cE8hAEZQ/edit#gid=0").worksheets[0]
    end

    def self.parse(url)
      page = ImageScraper.new(url).pullpage(url)
      return page
    end 

  end


  class ImageScraper < Enabler

    def pullpage(url)
        html = @agent.get(url).body
        page = Nokogiri::HTML(html)
        page_images=[]
        root_url=@url.split('/')
        root_url=root_url[0]+'//'+root_url[1]+root_url[2]
        page.css('img').each do |image|
          path=image['src']
          absolute_uri = URI.join(root_url, path).to_s
          page_images.push(absolute_uri)
        end
        return ImageWriter.new(url).image_loop(page_images)
      rescue Mechanize::ResponseCodeError => e  
        page_images="error"
        return page
      end   

    end



  class ImageWriter < Enabler

    def next_index
      @worksheet.num_rows + 1
    end

    def save_img(img)
      @worksheet.reload
      @worksheet[next_index, 2] = img
      @worksheet.synchronize
    end

    def image_loop(images)
      images.each do |x|
        save_img(x)
      end 
    end

  end

end