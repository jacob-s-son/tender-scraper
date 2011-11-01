require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Proxy::ProxyListManager do
  include Proxy::ProxyListManager
    before(:all) do
      @agent = Mechanize.new
    end
    
    it "list_empty? method should return true if list empty" do
      list_empty?.should be_true
    end
    
    it "list_empty? method should return false if list is not empty" do
      proxy_server1 = Factory(:valid_proxy_server)
      list_empty?.should be_false
    end
    
    it "should truncate table content" do
      proxy_server1 = Factory(:valid_proxy_server)
      proxy_server2 = Factory(:invalid_proxy_server)
      truncate_proxy_servers
      ProxyServer.all.should be_empty
    end
    
    it "should create ProxyServer objects from raw proxy list and return hwo many proxy servers added" do
      self.stub!(:poll_mail).and_return("146.57.249.99:3124\n79.119.31.87:8080")
      self.populate_list.should == 2
      ProxyServer.first.ip.should == "146.57.249.99"
      ProxyServer.first.port.should == "3124"
      ProxyServer.last.ip.should == "79.119.31.87"
      ProxyServer.last.port.should == "8080"
    end
    
    it "all_blacklisted? should return false if at least one not black listed proxy exists" do
      proxy_server1 = Factory(:valid_proxy_server)
      proxy_server2 = Factory(:invalid_proxy_server)
      all_blacklisted?.should be_false
    end
    
    it "all_blacklisted? should return true if all proxies are blacklisted" do
      proxy_server1 = Factory(:black_listed_proxy_server)
      proxy_server2 = Factory(:black_listed_proxy_server)
      all_blacklisted?.should be_true
    end
end