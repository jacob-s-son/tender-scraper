require 'base64'

module TenderParser
  
  #return hash with keys correpsonding to tender columns
  def tender_fields
    unneeded_columns = [ "id", "created_at", "updated_at", "exported_times", "exported_at", "last_time_exported_by", "last_edited_by" ]
    
    # 1) get all tender columns, 2) delete nonefield columns, 3) create hash , where each key is Tender column with initial value of nil
    Tender.column_names.reject {|cn| unneeded_columns.include?(cn) }.inject({}) {|memo, v| memo[v] = nil; memo }
  end
  
  def extract_data_node(hash_key)
    @doc.xpath full_xpath_list[hash_key]
  end
  
  def extract_multiple_data_nodes(hash_key)
    @doc.xpath full_xpath_list[hash_key]
  end

  def extract_data(hash_key)
    extract_data_node(hash_key).to_a.map {|e| e.to_s.mb_chars.strip.to_s }.reject(&:empty?).join(" ")
  end
  
  def extract_clean_data(hash_key)
    #extract_data("buyer_name").match(/^(.+?)\(\d/u).to_a[1].to_s.strip
    match_data = extract_data(hash_key).match( full_regex_list[hash_key] ).to_a
    ( match_data.size > 1 ?  match_data[1] : match_data ).to_s.strip
  end

  def method_missing(name, *args, &block) 
    name = name.to_s
    
    if full_regex_list.has_key? name
      extract_clean_data name
    elsif full_xpath_list.has_key? name
      extract_data(name)
    end
  end
  
  def this_method
    caller[0]=~/`(.*?)'/
    $1
  end
  
  #default methods for all tenders - cleanups etc.
  
  # merges elem_xpaths with additional_elem_xpaths
  # elem_xpaths - defined in tender country module
  # additional_elem_xpaths - defined in tender document module, for exampl form Sk-1 in LT tenders
  def full_xpath_list
    #TODO: maybe it's wise to add some attr accessible, 
    xpath_list ||= elem_xpaths.merge additional_elem_xpaths 
  end
  
  def full_regex_list
    regex_list ||= elem_regexes.merge additional_elem_regexes
  end
  
  def phone_default(phone)
    phone.gsub /[()+\s\-]/, ""
  end
  
  def document
    Base64.encode64(@doc.to_s)
  end
  
  def country
    CODES_TO_COUNTRIES[@country_code]
  end 
end