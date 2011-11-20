class TendersController < ApplicationController
  def index
    #FIXME:looks ugly
    @tenders = request.accept.match(/xml/) ? Tender.search(params, false) : Tender.search(params)
    
    respond_to do |format|
      format.html do
        if params["ajax"]
          render :layout => false
        end
      end
      format.xml { render :xml => TenderXmlBuilder.xml(@tenders) }
    end
  end
  
  def update
    @tender = Tender.find(params[:id])
    if @tender.update_attributes(params)
      flash[:notice] = "Tender updated"
    else
      flash[:error] = "Could not update tender. Please try again."
    end
  end
end