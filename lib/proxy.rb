require 'mechanize'
require 'net/imap'
require 'net/http'
require 'base64'

module Proxy
  module ProxyListMailReceiver
    def poll_mail
      result = ""
      begin
        # make a connection to imap account
        imap = Net::IMAP.new(PROXY_LIST_EMAIL_HOST, PROXY_LIST_EMAIL_PORT, true)
        imap.login(PROXY_LIST_EMAIL, PROXY_LIST_EMAIL_PASSWORD)
        # select inbox as our mailbox to process
        imap.select('Inbox')
        
        #FIXME:Jāpievieno kritērijs meklēšanai pēc sūtītāja un subjecta, lai kāds spams pēkšņi neatnāk
        uid = imap.uid_search(["NOT", "DELETED", "SUBJECT", "proxy list", "FROM", "jekabsons.edgars@gmail.com"]).first
        return result unless uid #atgriežam tukšumu, ja nekas nenotiek
        
        # fetches first attachment
        attachment = imap.uid_fetch(uid, "BODY[2]")[0].attr["BODY[2]"]
        
        # Unpack message, BASE64 decoded 
        result = attachment.unpack('m')[0]
        
        # there isn't move in imap so we copy to new mailbox and then delete from inbox
        imap.uid_copy(uid, "[Gmail]/All Mail")
        imap.uid_store(uid, "+FLAGS", [:Deleted])

        # expunge removes the deleted emails
        imap.close
        imap.logout
        imap.disconnect unless imap.disconnected?
        result
      # NoResponseError and ByResponseError happen often when imap'ing
      rescue => e
        Rails.logger.error("Unexpected error while polling from gmail : #{e.inspect}")
        result
      end
    end

    def extract_attachment_contents

    end
  end
  
  module ProxyListManager
    include ProxyListMailReceiver
    def truncate_proxy_servers
      #TODO: Pēc migrēšanas uz MySql vajadzēs nomainīt , lai izpildāts truncate table
      #ActiveRecord::Base.connection.execute("TRUNCATE TABLE proxy_servers") 
      ProxyServer.delete_all
    end
    
    def populate_list
      poll_mail.scan(/^([0-9\.]+):([0-9]{2,4})$/).each do |ip|
        ProxyServer.create(:ip => ip[0], :port => ip[1], :black_listed_flag => false)
      end
      ProxyServer.all.size
    end
    
    def list_empty?
      ProxyServer.first.nil?
    end
    
    def all_blacklisted?
      ProxyServer.where(:black_listed_flag => false).limit(1).empty?
    end
  end
  
  module ProxySetter
    
    def find_working_proxy
      ProxyServer.available.order("id asc").each do |ps|
        @agent.set_proxy(ps.server,ps.port)
        if proxy_valid?
          break
        else
          ps.black_listed_flag = true
          ps.save
        end
      end
    end
    
    def proxy_valid?
      @agent.get("http://www.iub.gov.lv").page.body =~ /<p>.+?Iepirkumu uzraudzības birojs.+?<\/p>/msui
    end
    
  end
end