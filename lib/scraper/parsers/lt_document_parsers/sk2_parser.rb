module Sk2Parser
  def additional_elem_xpaths 
    {
      "closing_date"          => "//td/b[contains( text(), 'Projektų pateikimo terminas')]/../../following-sibling::tr[1]/td/text()",
      "closing_time"          => "//td/b[contains( text(), 'Projektų pateikimo terminas')]/../../following-sibling::tr[1]/td/text()"
    }
  end
  
  def procurement_procedure
    "Projektų konkursas"
  end
end