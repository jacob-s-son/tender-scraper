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
    attr_accessor :url_scraper
    
    def initialize(country_code, from_date = Date.today)
      @url_scraper = TenderUrlScraper.new country_code, from_date
    end
    
    def scrape( params = {} )
      @url_scraper.get_urls(params).each do |url|
        Tender.create( Scraper::Parser.parse(url) )
      end
    end
  end
  
  # class that collect URLs of the new tenders that haven't been scraped yet
  class TenderUrlScraper
    include Downloader
    attr_accessor :country_code, :last_url, :current_page, :current_page_nr, :from_date
    
    def initialize(country, from_date = Date.today)
      @country_code = country      
      @last_url = Tender.where(:country => CODES_TO_COUNTRIES[@country_code], :publication_date => from_date).order("publication_date DESC").first.try(:url)
      @current_page_nr = 1
      @current_page = agent.get TENDER_URLS[@country_code]
      @from_date = from_date
      
      extend_with_country_module
    end
    
    private
    def extend_with_country_module(country = @country_code)
      module_name = "#{country_code.to_s.capitalize}UrlScraper"
      path = "#{Rails.root}/lib/scraper/url_scrapers"
      
      require "#{path}/#{module_name.underscore}.rb"
      extend Kernel.const_get(module_name)
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
      
      require "#{path}/#{file_name}"
      extend Kernel.const_get(module_name)
    end
    
    def extend_with_document_module
      path        = "#{Rails.root}/lib/scraper/parsers/#{@country_code}_document_parsers/"
      module_name = document_module_name
      full_path   = "#{path}#{document_module_name.underscore}.rb"
      
      unless File.exist? full_path
        module_name = default_document_module
        full_path   = "#{path}#{module_name.underscore}.rb"
      end        
      
      require full_path
      extend Kernel.const_get(module_name)
    end
  end
end