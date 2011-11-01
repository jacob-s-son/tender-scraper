require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Proxy::ProxyListMailReceiver do
  include Proxy::ProxyListMailReceiver
    before do
      #TODO: Jāpārdomā visa stubošana , iespējams daudz izdevīgāk vienkārši sūtīt meilu uz testa pastkasti
      @imap = mock(Net::IMAP)
      @imap.stub(
        :login => true, :select => true, :close => true, 
        :logout => true, :disconnect => true, :disconnected? => true, 
        :uid_copy => true, :uid_store => true)
      Net::IMAP.stub!(:new).and_return(@imap)
    end
    
    describe :poll_mail do
      subject { poll_mail }
      context "when email not found" do
        before { @imap.stub!(:uid_search).and_return(nil) }
        it { should be_blank }
      end
      
      context "when email found" do
        before do
          @imap.stub!(:uid_search).and_return([123])
          @fetch_data = Net::IMAP::FetchData.new
          @fetch_data.stub!(:attr).and_return({ "BODY[2]" => "MTQ2LjU3LjI0OS45OTozMTI0Cjc5LjExOS4zMS44Nzo4MDgw"})
          @imap.stub!(:uid_fetch).and_return([@fetch_data])
          Net::IMAP.stub!(:new).and_return(@imap)
        end
        
        it { should == "146.57.249.99:3124\n79.119.31.87:8080" }
      end
    end
end  