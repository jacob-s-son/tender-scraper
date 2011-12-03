class TendersController < ApplicationController
  before_filter :find_tender, :only => [ :update, :lock, :unlock ]
  
  def index
    #FIXME:looks ugly
    @tenders = request.accept.match(/xml/) ? Tender.search(params, false) : Tender.search(params)
    
    respond_to do |format|
      format.html { render :partial => "tender_list" if params["ajax"] }
      format.xml  { render :xml => TenderXmlBuilder.xml(@tenders) }
    end
  end
  
  def update
    flash[:notice] = Tender::MESSAGES[:saved] if @tender.update_tender(params[:tender], @session_id)
    render :partial => 'tender', :locals => { :tender => @tender }
  end
  
  def lock
    respond_to do |format|
      format.json { render :json => @tender.lock(@session_id) }
    end
  end
  
  def unlock
    respond_to do |format|
      format.json { render :json => @tender.unlock(@session_id) }
    end
  end
  
  def get_statuses
    sleep(5)
    respond_to do |format|
      format.json { render :json => Tender.get_statuses(params[:tender_statuses]) }
    end
  end
  
  private
  def find_tender
    @tender = Tender.find(params[:id])
  end
end