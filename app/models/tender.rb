class Tender < ActiveRecord::Base
  serialize :cpv_codes, Array
  after_initialize :set_defaults
  before_save :format_attributes
  validates_uniqueness_of :url
  scope :created_since, lambda { |ago|
    date = ( ( ago ? Date.parse(ago) : Date.today ).to_time - 2.hours ).to_date # correction according to UTC
    where("tenders.created_at >= ?",  date)
  }

  self.per_page = 10
  STATUSES      = [ :new, :edited, :marked_for_export, :exported ]
  LOCK_INTERVAL = 5*60 #5 min
  
  MESSAGES = 
  {
    :locked           => 'You need to lock this tender for editing before edit it!',
    :locked_by_others => 'This tender is already locked for editing by another user!',
    :locked_for_user  => 'Tender successfully locked for editing! You may now update tender fields!',
    :saved            => 'Tender successfully saved!',
    :general_error    => 'System error, please, try again!',
    :could_not_save   => 'Your lock has been expired while you were editing tender! Lock this tender again before editing and saving!',
    :lock_released    => 'Lock successfully realeased!'
  }
  
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
    ["buyer-contact",  
      [
        [ "registration_number", "contact" ],
        [ "buyer_name", "phone_number" ],
        [ "address", "mobile_phone_number" ],
        [ "city", "fax_number"],
        [ "post_code", "email"],
        [ "country", "website"]
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
     "lock_status",
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
        created_since(params[:created_at]).where( clean_params(params) ).page(params["page"]).order('created_at DESC, id DESC')
      else
        created_since(params[:created_at]).where( clean_params(params) ).order('created_at DESC')
      end
    end
    
    def clean_params(params)
      params.reject {|key,value| !column_names.include?(key.to_s) || key == "created_at" }
    end
  end
  
  #form disabled a) if it's locked for everyone (no one has intended to edit this tender)
  #b) if it's locked by another user for editing
  def locked?(session_id)
    lock_status == 'locked' || ( lock_status == 'locked_for_editing' && locked_by != session_id.to_s )
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
  
  def update_tender(params, session_id)
    default_params = { :lock_status => 'locked', :status => :edited }
    
    unless available_for_edit?(session_id)
      errors[:errors] << MESSAGES[:locked_by_others]
      return false
    end

    unless update_attributes(params.reject{|k,v| !Tender.editable_fields.include?(k.to_s)}.merge(default_params))
      errors[:errors] << MESSAGES[:general_error] if errors.empty?
      return false
    end
    true
  end
  
  def lock(session_id)
    if session_id.to_s == locked_by
      self.lock_status = 'locked'
    else
      return {:msg => MESSAGES[:locked_by_others], :status => 'error'}
    end
    
    return {:msg => MESSAGES[:lock_released], :status => 'info'} if self.save
    {:msg => MESSAGES[:general_error], :status => 'error'}
  end
  
  def unlock(session_id)
    result = {:status => 'error'}
    
    if available_for_unlock?
      if update_attributes(:lock_status => 'locked_for_editing', :locked_at => Time.now, :locked_by => session_id)
        result[:msg]    = MESSAGES[:locked_for_user]
        result[:status] = 'info'
        return result
      else
        result[:msg] = MESSAGES[:general_error]
      end
    else
      result[:msg]   = MESSAGES[:locked_by_others]
    end
    
    result
  end
  
  def to_xml
    Tender.exportable_fields.inject({}) do |memo, k| 
      if (k == "cpv_codes")
        memo[:cpv_codes] = (self.send k)
      else
        memo[k] = (self.send k).to_s
      end
      
      memo 
    end.to_xml(:skip_instruct => true, :skip_types => true)
  end
  
  private
  def set_defaults
    if self.id.nil?
      self.status         = :new
      self.exported_times = 0
      self.lock_status    = 'locked'
    end
  end
  
  def format_attributes
    self.cpv_codes = cpv_codes.split(/\s*,\s*/) unless cpv_codes.is_a?(Array)
  end
  
end
