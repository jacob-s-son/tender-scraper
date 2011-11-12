require 'tender_parser.rb'

module LtTenderParser
  include TenderParser
  
  #extend does not work with constants
  def elem_xpaths 
    {
      "url"                   => "",
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
      # "publication_date"      => "", FIXME: need to add this when parsing list
    }
  end
  
  #will be overwrited by document module
  def additional_elem_xpaths
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
   
  def sector
   "Public"
  end
  
  def nuts_code
    "Lietuva"
  end
  
  def buyer_name
    extract_data("buyer_name").match(/^(.+?)\(\d/u).to_a[1].to_s.strip
  end
  
  def registration_number
    extract_data("registration_number").match(/^[^(]+\(([0-9]+)\)/).to_a[1].to_s.strip
  end
  
  def address
    #divide in portions
    splitted_address = extract_data("address").split(",")
    # assuming that last element is city/town we are removing it
    splitted_address.delete_at(splitted_address.size-1)
    #joining array back to string
    p splitted_address
    splitted_address.join("").strip
  end
  
  def city
    #divide in portions, last portion is city
    splitted_address = extract_data("address").split(",").last.strip
  end
  
  def post_code
    p extract_data("post_code")
    extract_data("post_code").match(/LT\s*-\s*[0-9]+/).to_s.gsub /\s/, ""
  end
  
  def contact
    extract_data("contact").sub(/Kam/, "").strip
  end
  
  def phone_number
    p extract_data("phone_number")
    phone_default( extract_data("phone_number").match(/^[^\d(]+([0-9()\-+\s]+)/).to_a[1].to_s )
  end
  
  def fax_number
    p extract_data("fax_number")
    phone_default( extract_data("fax_number").match(/^[^\d(]+([0-9()\-+\s]+)/).to_a[1].to_s )
  end
  
  def email
    extract_data("email").match(/^.*?([\S\w\d\-_\.]+@[\S\w\d\-_\.]+\.[\S\w\d\-_\.]+)$/).to_a[1].to_s
  end
    
  def cpv_codes
    extract_multiple_data_nodes("cpv_codes").inject([]) do |memo, c|
      cpv_code = c.content.match(/([0-9]+-[0-9]+)/).to_a[1]
      memo << cpv_code.to_s if cpv_code
      memo
    end
  end
  
  #method for extending Parser class with document specific methods
  def document_module_name
    form_name = extract_data("form_number").match(/(Sk-[0-9])\s+tipinė\s+forma/iu).to_a[1].to_s.sub /-/, ""
    "#{form_name}Parser"
  end
end
