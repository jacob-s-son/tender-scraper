namespace :scraper do
  namespace :tenders do    
    desc "scrapes tenders with params passed - country, date_from, to_page"
    task :scrape, [ :country, :date_from, :to_page ] => [ :environment ] do |t, args|
      args.with_defaults(:date_from => Date.today, :country => :lt, :to_page => nil)
      p "Scraping tenders, params passed from command line: #{args.inspect}"
      p "Time : #{Time.now}"
      scrape_tenders args
    end
    
    task :scrape_all_countries do 
    end
    
    def scrape_tenders(args)
      params             = {}
      params[:country]   = args.country.to_sym
      params[:date_from] = Date.strptime(args.date_from, '%d.%m.%Y')
      params[:to_page]   = args.to_page.to_i if args.to_page
      p "Parameter types after conversion:"
      p "Country  : #{params[:country].class}"
      p "Date from: #{params[:date_from].class}"
      p "Page to  : #{params[:to_page].class}"
      
      ts             = Scraper::TenderScraper.new params[:country]
      result         = ts.scrape(params)
      
      p "Tenders scraped  : #{result[:tenders_scraped]}"
      p "Last url scraped : #{result[:last_url_scraped]}"
      p "First url scraped: #{result[:first_url_scraped]}"
    end
  end
  
  namespace :tender_results do    
    desc "scrapes tender results wit params passed = date_from, page_to, country"
    task :scrape => :environment do
      puts "Scraping tenders, params = #{}"
      scrape_tender_results args
    end
    
    def scrape_tender_results
    end
  end
end