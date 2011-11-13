require 'open-uri'
require 'downloader.rb'

module Scraper
  def determine_tender_country(url)
    domain = URI(url).host.match(/www\..+?\.(.+)$/)[1].downcase.to_sym
    #setting domain from URL if it's included in 
    TENDER_URLS.include?(domain) ? domain  : :lt
  end
  
  # receives list of URLs , intializes parser and save new tender
  class TenderScraper
    attr_accessor :url_scraper, :parser
    
    def initialize(country)
      @url_scrpaer = TenderUrlScraper.new country
      @parser = Parser.new country
    end
    
    def scrape
      @url_scraper.get_urls.each do |url|
        @parser.parse(url)
      end
    end
  end
  
  # class that collect URLs of the new tenders that haven't been scraped yet
  class TenderUrlScraper
    attr_accessor :country, :last_url
    
    def initialize(country, to_date = Date.today)
      @country = country
      extend_with_country_module    
      @last_url = Tender.where(:country => country, :publication_date => to_date).order("publication_date DESC").first.try(:url)
    end
    
    private
    def extend_with_country_module(country = @country)
      module_name = "#{country.to_s.capitalize}UrlScraper"
      path = "#{Rails.root}/lib/scraper/url_scrapers"
      file_name = "#{path}/#{module_name}.rb"
      
      require "#{path}/#{file_name}.rb"
      extend get_const(module_name)
    end
  end
  
  class Parser
    include Downloader
    attr_accessor :url, :doc, :country_code, :xpath_list
    
    def initialize(params = {})
      if params[:url]
        @url = params[:url]
        @doc = Nokogiri::HTML(download url)
      end
      
      if params[:country]
        @country_code = country
      elsif url
        @country_code = determine_tender_country
      end
      
      #FIXME: What happens if no country set ?
      extend_with_country_module
      extend_with_document_module
    end
    
    def determine_tender_country(url = @url)
      domain = URI(url).host.match(/(?:www)?\..+?\.(.+)$/)[1].downcase.to_sym
      #setting domain from URL if it's included in config
      TENDER_URLS.include?(domain) ? domain  : :lt
    end
    
    def self.parse(url)
      new( { :url => url } ).parse
    end
    
    def parse
      tender_fields.inject({}) do |memo, (key, value)|
        memo[key] = self.send key
        memo
      end
    end
    
    private
    def extend_with_country_module(country = @country_code)
      module_name = "#{country.to_s.capitalize}TenderParser"
      path        = "#{Rails.root}/lib/scraper/parsers"
      file_name   = "#{country.to_s}_tender_parser.rb"
      puts file_name
      
      require "#{path}/#{file_name}"
      extend Kernel.const_get(module_name)
    end
    
    def extend_with_document_module
      module_name = document_module_name
      path = "#{Rails.root}/lib/scraper/parsers/#{@country_code}_document_parsers/#{document_module_name.underscore}.rb"
      
      require path
      extend Kernel.const_get(module_name)
    end
  end
end