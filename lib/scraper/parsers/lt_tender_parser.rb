require 'tender_parser.rb'

module LtTenderParser
  include TenderParser
  include CountryCommonMethods::Lt
  
  #extend does not work with constants
  def elem_xpaths 
    {
      "registration_number"   => "//td/b[contains(text(), 'Organizacijos pavadinimas ir kodas')]/../text()",
      "buyer_name"            => "//td/b[contains(text(), 'Organizacijos pavadinimas ir kodas')]/../text()",
      "address"               => "//td/b[contains(text(), 'Adresas')]/../text()",
      "city"                  => "//td/b[contains(text(), 'Adresas')]/../text()",
      "post_code"             => "//td[contains(text(), 'Pašto indeksas')]/text()",
      "contact"               => "//td/b[contains(text(), 'Kontaktiniai duomenys')]/../text()",
      "phone_number"          => "//td[contains(text(), 'Telefonas')]/text()",
      # "mobile_phone_number"   => "", FIXME:need an example to understand how to fetch it
      "fax_number"            => "//td[contains(text(), 'Faksas')]/text()",
      "email"                 => "//td[contains(text(), 'El. paštas')]/text()",
      "website"               => "//td/b[contains(text(), 'Interneto adresas')]/../text()",
      "heading"               => "//td/b[contains(text(), 'Pirkimo pavadinimas')]/../../../tr[2]/td/text()",
      "cpv_codes"             => "//td/b[contains(text(), 'Pagrindinis žodynas')]/../../../tr/td/text()",
      "form_number"           => "//td[contains( text(), 'Sk-') and contains( text(), 'tipinė forma')]/text()"
    }
  end
  
  #will be overwrited by document module
  def additional_elem_xpaths
    {}
  end
  
  def elem_regexes
    {
      "registration_number"   => /^[^(]+\(([0-9]+)\)/,
      "buyer_name"            => /^(.+?)\(\d/u,
      "post_code"             => /LT\s*-\s*[0-9]+/,
      "phone_number"          => /^[^\d(]+([0-9()\-+\s]+)/,
      # "mobile_phone_number"   => "", FIXME:need an example to understand how to fetch it
      "fax_number"            => /^[^\d(]+([0-9()\-+\s]+)/,
      "email"                 => /^.*?([\S\w\d\-_\.]+@[\S\w\d\-_\.]+\.[\S\w\d\-_\.]+)$/
    }
  end
  
  def additional_elem_regexes
    {}
  end
   
   # These fields may change in different forms
   # ADDITIONAL_ELEM_XPATHS = {
   #   "procurement_procedure" => "",
   #   "case_number"           => "",
   #   "closing_date"          => "",
   #   "closing_time"          => "",
   #   "opening_time"          => "",
   #   "opening_date"          => "",
   #   "material_closing_date" => "",
   #   "material_closing_time" => "",
   #   "assignment"            => "",
   #   "attachment"            => "//td/b[contains( text(), 'PAPILDOMA INFORMACIJA')]/../../../tr/td/b[contains(text(), 'Arba')]/../a/@href",
   #   "tender_type"           => "",
   #   "value"                 => ""
   # }
   
   
  # values defined without parsing, may be ovverriden by document module methods
  def sector
   "Public"
  end
  
  def nuts_code
    "Lietuva"
  end
  
  def value
    "National"
  end
  
  def tender_type
    "Tender (Pirkimas)"
  end
  
  
  #tender fiels methods, common to all LT tender documents
  def address
    #divide in portions
    splitted_address = extract_data("address").split(",")
    # assuming that last element is city/town we are removing it
    splitted_address.delete_at(splitted_address.size-1)
    #joining array back to string
    splitted_address.join("").strip
  end
  
  def city
    #divide in portions, last portion is city
    splitted_address = extract_data("address").split(",").last.strip
  end
  
  def post_code
    extract_clean_data("post_code").gsub /\s/, ""
  end
  
  def contact
    extract_data("contact").sub(/Kam/, "").strip
  end
  
  def phone_number
    phone_default( extract_clean_data("phone_number") )
  end
  
  def fax_number
    phone_default( extract_clean_data("fax_number") )
  end
    
  def cpv_codes
    extract_multiple_data_nodes("cpv_codes").inject([]) do |memo, c|
      cpv_code = c.content.match(/([0-9]+-[0-9]+)/).to_a[1]
      memo << cpv_code.to_s if cpv_code
      memo
    end
  end
  
  def closing_date
    default_date extract_data "closing_date"
  end
  
  def closing_time
    default_time extract_data "closing_time"
  end
  
  def publication_date
    default_date url
  end
  
  #LT helper methods
  
  # def default_date date_str
  #   ClassMethods::default_date default_date
  # end
  
  def default_time time_str
    time_str.match(/[0-9]+:[0-6][0-9]/).to_s
  end
  
  #method for extending Parser class with document specific methods
  def document_module_name
    form_name = extract_data("form_number").match(/(Sk-[0-9])\s+tipinė\s+forma/iu).to_a[1].to_s.sub /-/, ""
    form_name = "Sk6" if form_name.empty? #ensuring that some default module is loaded
    "#{form_name}Parser"
  end
end
