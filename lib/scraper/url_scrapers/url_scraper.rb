module UrlScraper
  def get_urls
    urls  = []
    url = 'nil can not be used, because @last_url may be nil'
    date = Date.today
    
    while ( @from_date <= date ) && ( url != @last_url )
      links_on_current_page.each do |l|
        url  = get_url_from_link l
        date = default_date url
        p url
        break if ( @from_date > date ) || ( url == @last_url )
        urls << url
      end
      next_page
    end
    
    urls
  end
  
end