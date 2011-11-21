class Tender < ActiveRecord::Base
  serialize :cpv_codes, Array
  after_initialize :set_defaults
  scope :created_since, lambda { |ago| where("tenders.created_at >= ?", ( ago ? Date.parse(ago) : Date.today ) ) }

  self.per_page = 10
  STATUSES      = [ :new, :marked_for_export, :exported]
  LOCK_INTERVAL = 5*60 #5 min
  
  MESSAGES = 
  [
    :locked           => 'You need to lock this tender for editing before edit it!',
    :locked_by_others => 'This tender is already locked for editing by another user!',
    :locked_for_user  => 'Tender successfully locked for editing! You may now update tender fields!',
    :saved            => 'Tender successfully saved!',
    :general_error    => 'System error, please, try again!',
    :could_not_save   => 'Your lock has been expired while you were editing tender! Lock this tender again before editing and saving!'
  ]
  
  TENDER_FIELD_ORDER = [ 
    ["general", 
      [
        "case_number",
        "heading",
        "cpv_codes",
        "nuts_code"
      ]
    ],
    ["dates", 
      [
        [ "material_closing_date", "material_closing_time" ],
        [ "closing_date", "closing_time" ],
        [ "opening_date", "opening_time" ]
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
     "locked_status",
     "locked_by",
     "locked_at",
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
  
  #form disabled a) if it's locked for everyone (no one has intended to edit this tender)
  #b) if it's locked by another user for editing
  def locked?(session_id)
    lock_status == 'locked' || ( lock_status == 'locked_for_editing' && locked_by != session_id )
  end
  
  def lock_expired?
    locked_at + LOCK_INTERVAL < Time.now
  end
  
  # available if status not locked
  # and ( if status is locked_for_editing, then lock must been made by current_user
  # or if locked for editing by another user and lock has expired
  def available_for_edit?(session_id)
    !locked?(session_id) || ( lock_status = 'locked_for_editing' && lock_expired? )
  end
  
  # tender can be unlocked for editing if it's generally locked (for everyone)
  # or user lock has been expired
  def available_for_unlock?
    lock_status == 'locked' || lock_expired?
  end
  
  def toggle_lock(session_id)
    result = {}
    
    if available_for_unlock?
      self.lock_status  = 'locked_for_editing'
      self.locked_at    = Time.now
      self.locked_by    = session_id
      
      if self.save
        result[:msg] = MESSAGES[:locked_for_user]
      else
        result[:msg] = MESSAGES[:general_error]
      end
    else
      result[:msg]   = MESSAGES[:locked_by_others]
    end
  end
  
  def update
    
  end
  
  def to_xml
    Tender.exportable_fields.inject({}) { |memo, k| memo[k] = (self.send k).to_s; memo }.to_xml(:skip_instruct => true, :skip_types => true)
  end
  
  private
  def set_defaults
    if self.id.nil?
      self.status         = :new
      self.exported_times = 0
      self.lock_status    = 'locked'
    end
  end
  
end
