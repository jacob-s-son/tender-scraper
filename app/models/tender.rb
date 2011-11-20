class Tender < ActiveRecord::Base
  serialize :cpv_codes, Array
  after_initialize :set_defaults
  scope :created_since, lambda { |ago|
      where("tenders.created_at >= ?", ( ago ? Date.parse(ago) : Date.today ) )
    }
  self.per_page = 10
  STATUSES = [ :new, :marked_for_export, :exported]
  
  TENDER_FIELD_ORDER = [ 
    ["general", 
      [
        "case_number",
        "heading",
        "cpv_codes",
        "nuts_code",
        "material_closing_date",
        "material_closing_time",
        "closing_date",
        "closing_time",
        "opening_date",
        "opening_time"
      ]
    ],
    ["buyer",  
      [
        "registration_number",
        "buyer_name",
        "address",
        "city",
        "post_code",
        "country"
      ]
    ],
    ["contact",
      [
        "contact",
        "phone_number",
        "mobile_phone_number",
        "fax_number",
        "email",
        "website"
      ]
    ] 
  ]
  
  NONE_EXPORTABLE_FIELDS = 
    [
     "id",
     "exported_times",
     "exported_at",
     "last_time_exported_by",
     "created_at",
     "updated_at",
     "last_time_edited_by",
     "marked_for_export",
     "locked",
     "status"
    ]
  
  NONE_EDITABLE_FIELDS = NONE_EXPORTABLE_FIELDS + 
    [
     "document",
     "url"
     ]
  
  #class methods
  class << self
    def editable_fields
      column_names - NONE_EDITABLE_FIELDS
    end
    
    def misc_fields
      editable_fields - TENDER_FIELD_ORDER.flatten
    end
    
    def exportable_fields
      column_names - NONE_EXPORTABLE_FIELDS
    end
    
    def search(params = {}, without_pagination=false)
      params = {"page" => 1}.merge(params)

      unless without_pagination
        created_since(params[:created_at]).where( clean_params(params) ).page(params["page"]).order('created_at DESC')
      else
        created_since(params[:created_at]).where( clean_params(params) ).order('created_at DESC')
      end
    end
    
    def clean_params(params)
      params.reject {|key,value| !column_names.include?(key) || key == "created_at" }
    end
  end
  
  def locked?
    locked
  end
  
  private
  def set_defaults
    self.status = :new
    self.exported_times = 0
    self.locked = true
  end
  
end
