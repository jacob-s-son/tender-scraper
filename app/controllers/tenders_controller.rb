class TendersController < ApplicationController
  before_filter :find_tender, :only => [ :update, :toggle_lock ]
  
  def index
    #FIXME:looks ugly
    @tenders = request.accept.match(/xml/) ? Tender.search(params, false) : Tender.search(params)
    
    respond_to do |format|
      format.html { render :partial => "tender_list" if params["ajax"] }
      format.xml  { render :xml => TenderXmlBuilder.xml(@tenders) }
    end
  end
  
  def update
    if @tender.update(params)
      flash[:notice] = "Tender updated"
    else
      flash[:error] = "Could not update tender. Please try again."
    end
  end
  
  def toggle_lock
    respond_to do |format|
      format.json { render :json => { :msg => @session_id }  }#@tender.toggle_lock(@session_id)
    end
  end
  
  private
  def find_tender
    @tender = Tender.find(params[:id])
  end
end