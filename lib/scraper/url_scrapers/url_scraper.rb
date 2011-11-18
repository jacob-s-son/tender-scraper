module UrlScraper
  def get_urls(params = {})
    @from_date = params[:from_date] if params[:from_date]
 
    urls = []
    url  = 'nil can not be used, because @last_url may be nil'
    date = Date.today
    
    while not finished? date, params[:to_page], url
      links_on_current_page.each do |l|
        url  = get_url_from_link l
        date = default_date url
        break if finished? date, params[:to_page], url
        urls << url
      end
      next_page
    end
    
    urls.reverse #reversing so that latest tender on url , is latest added to DB
  end
  
  def finished?(date, to_page, url)
    return ( url == @last_url || to_page < @current_page_nr ) if to_page
    ( url == @last_url || @from_date > date )
  end
end