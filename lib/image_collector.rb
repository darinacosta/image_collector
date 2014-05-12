module ImageCollector

  class Collector

    def initialize(url,spreadsheet,selectors)
      @url=url
      scraper=ImageScraper.new
      page_elements=scraper.pullimages(url,selectors)
      image_writer=ImageWriter.new(spreadsheet,url)
      image_writer.image_loop(page_elements)
    end

  end


  class ImageScraper

    def initialize
      @agent = Mechanize.new { |agent| agent.user_agent_alias = "Mac Safari" }
    end 

    def pullimages(page_url,selectors)
        html = @agent.get(page_url).body
        page = Nokogiri::HTML(html)
        page_images=[]
        page.css("#{selectors} img").each do |image|
          relative_image_path=image['src']
          absolute_image_url = compile_image_url(page_url, relative_image_path)
          page_images.push(absolute_image_url)
        end
        return page_images
      rescue Mechanize::ResponseCodeError => e  
        page_images="error"
        return page
      end

    def compile_image_url(page_url, relative_image_path)
      split_url=page_url.split('/')
      root_url=split_url[0]+'//'+split_url[1]+split_url[2]
      absolute_image_url=URI.join(root_url, relative_image_path).to_s
      return absolute_image_url
    end


      def worksheet
        @worksheet
      end

    end



  class ImageWriter 

    def initialize(spreadsheet,url)
      @url=url
      @worksheet = Session.spreadsheet_by_url(spreadsheet).worksheets[0]
      @rows=@worksheet.rows.count
    end

    def image_loop(images)
      count=0
      row=@rows+1
      images.each do |img|
        count+=1
        row+=1
        @worksheet.reload
        if count==1
          @worksheet[row,1]=@url
        end
        @worksheet[row, 2] = img
        @worksheet.synchronize
      end
    end

  end

end