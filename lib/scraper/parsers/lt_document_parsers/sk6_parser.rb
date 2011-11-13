module Sk6Parser
  def additional_elem_xpaths 
    {
      "closing_date"          => "//td/b[contains( text(), 'Pasiūlymų pateikimo terminas')]/../../following-sibling::tr[1]/td/text()",
      "closing_time"          => "//td/b[contains( text(), 'Pasiūlymų pateikimo terminas')]/../../following-sibling::tr[1]/td/text()",
      "attachment"            => "//td/b[contains( text(), 'PAPILDOMA INFORMACIJA')]/../../../tr/td/b[contains(text(), 'Arba')]/../a/@href"
    }
  end
  
  def value
    "BelownNational"
  end
end