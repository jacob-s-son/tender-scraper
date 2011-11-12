require 'base64'

module TenderParser
  include Downloader
  
  #return hash with keys correpsonding to tender columns
  def tender_fields
    unneeded_columns = [ "id", "created_at", "updated_at", "exported_times", "exported_at", "last_time_exported_by", "publication_date", "last_edited_by" ]
    
    # 1) get all tender columns, 2) delete nonefield columns, 3) create hash , where each key is Tender column with initial value of nil
    Tender.column_names.reject {|cn| unneeded_columns.include?(cn) }.inject({}) {|memo, v| memo[v] = nil; memo }
  end
  
  # ELEM_XPATH - defined in tender country module
  # ADDITIONAL_ELEM_XPATHS - defined in tender document module, for exampl form Sk-1 in LT tenders 
  def extract_data_node(hash_key)
    @doc.xpath( self.elem_xpaths.merge( self.additional_elem_xpaths )[hash_key] )
  end
  
  def extract_multiple_data_nodes(hash_key)
    @doc.xpath( self.elem_xpaths.merge( self.additional_elem_xpaths )[hash_key] )
  end

  def extract_data(hash_key)
    #TODO: need to check, it's possible that .content is more suitable method
    p extract_data_node(hash_key).to_a
    extract_data_node(hash_key).to_a.map {|e| e.to_s.mb_chars.strip.to_s }.reject(&:empty?).join(" ")
  end

  def method_missing(name, *args, &block) 
    name = name.to_s
    return extract_data(name) if self.elem_xpaths.has_key?(name) || self.additional_elem_xpaths.has_key?(name)
  end
  
  def this_method
    caller[0]=~/`(.*?)'/
    $1
  end
  
  #default methods for all tenders - cleanups etc.
  def phone_default(phone)
    phone.gsub /[()+\s\-]/, ""
  end
  
  def document
    Base64.encode64(@doc.to_s)
  end
  
  def country
    case @country_code
      when :lt
        "Lietuva"
      when :lv
        "Latvia"
      when :ee
        "Estonia"
    end
  end 
end