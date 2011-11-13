module LtUrlScraper
  include UrlScraper
  include CountryCommonMethods::Lt
  
  def next_page
    @current_page_nr += 1
    @current_page = agent.post TENDER_URLS[@country_code], { "page_no" => @current_page_nr, "B" => "PPO" }
  end
  
  def links_on_current_page
    @current_page.links_with(:text => /Lithuanian National Form [\d]/)
  end
  
  def get_page
    @downloader = Downloader.new
    page = agent.get url
  end
  
  def get_url_from_link(link)
    #javascript:viewNotice('','2011-11-11/b4e1ef5e-23ff-4fdf-8ff9-dbf40233742f.html','PPO','notice'); =>
    #https://pirkimai.eviesiejipirkimai.lt/app/notice/noticeform.asp?OJEC=&File=2011-11-11/b4e1ef5e-23ff-4fdf-8ff9-dbf40233742f.html&B=PPO
    match_data = link.href.match /javascript[^\(]+?\('[^']*?','(.+?)','(.+?)','notice'.*?$/msui
    "https://pirkimai.eviesiejipirkimai.lt/app/notice/noticeform.asp?OJEC=&File=#{match_data[1]}&B=#{match_data[2]}"
  end
end