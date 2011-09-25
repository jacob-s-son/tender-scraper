require 'mechanize'
require 'proxy.rb'

module Downloader
  mattr_accessor :agent
  
  class Downloader
    include Proxy::ProxyListManager
    include Proxy::ProxySetter
    
    def initialize
      @agent = Mechanize.new
      @agent.user_agent_alias = 'Linux Firefox'
      
      if list_empty? || all_blacklisted?
        truncate_proxy_servers
        download_raw_list
      end
      
      find_working_proxy
    end
    
    def download(url)
      @agent.get(url).page.body
    end
  end
end