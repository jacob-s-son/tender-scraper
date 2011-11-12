require 'mechanize'
require 'proxy.rb'

module Downloader
  attr_accessor :downloader
  
  class Downloader
    # include Proxy::ProxyListManager
    # include Proxy::ProxySetter
    attr_accessor :agent
    
    def initialize
      @agent = Mechanize.new
      @agent.user_agent_alias = 'Linux Firefox'
      
      #FIXME: Uncomment when "hide my ass" proxy list is available
      # if list_empty? || all_blacklisted?
      #   truncate_proxy_servers
      #   populate_list
      # end
      # 
      # find_working_proxy
    end
    
    def download(url)
      @agent.get(url).body
    end
  end
  
  def download(url)
    @downloader = Downloader.new unless @downloader
    @downloader.download url
  end
end