module UrlScraper
  include Downloader
  
  def current_page
    download TENDER_URLS[@country]
  end
end