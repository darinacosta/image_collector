module ImageCollector


  class ImageScraper

    def initialize
      @agent = Mechanize.new { |agent| agent.user_agent_alias = "Mac Safari" }
    end 

    def pullimages(url)
        html = @agent.get(url).body
        page = Nokogiri::HTML(html)
        page_images=[]
        root_url=url.split('/')
        root_url=root_url[0]+'//'+root_url[1]+root_url[2]
        page.css('img').each do |image|
          path=image['src']
          absolute_uri = URI.join(root_url, path).to_s
          page_images.push(absolute_uri)
        end
        return page_images
      rescue Mechanize::ResponseCodeError => e  
        page_images="error"
        return page
      end   

      def worksheet
        @worksheet
      end

    end



  class ImageWriter 

    def initialize(spreadsheet)
      @worksheet = Session.spreadsheet_by_url(spreadsheet).worksheets[0]
    end

    def image_loop(images)
      images.each do |img|
        save_img(img)
      end 
    end

    def save_img(img)
      @worksheet.reload
      @worksheet[next_index, 2] = img
      @worksheet.synchronize
    end

    def next_index
      @worksheet.num_rows + 1
    end

  end

end