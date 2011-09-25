require 'open-uri'

module Scraper
  
  def download(url)
    open(url) {|f| f.read }
  end
  
  # class Parser
  #   def initialize(url)
  #     doc_content = Scraper::download(url)
  #     
  #     case true
  #       when url =~ /\.lt/
  #         if lt_tender?
  #       end
  #       when url =~ /\.ee/
  #       end
  #       when url =~ /\.lv/
  #       end
  #     end
  #   end
  # end
end