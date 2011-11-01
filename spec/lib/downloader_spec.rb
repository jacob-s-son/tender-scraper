require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Downloader do
  include Downloader
  before(:all) do
    @url = "http://www.google.lv"
  end
  
  it "should download HTML content" do
    self.stub!(:find_working_proxy).and_return(true)
    self.stub!(:populate_list).and_return(true)
    download(@url).should =~ /<title>Google<\/title>/
  end
end