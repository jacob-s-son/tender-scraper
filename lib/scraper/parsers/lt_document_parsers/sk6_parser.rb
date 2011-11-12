module Sk6Parser
  def additional_elem_xpaths 
    {
      "closing_date"          => "//td/b[contains( text(), 'Pasiūlymų pateikimo terminas')]/../../following-sibling::tr[1]/td/text()",
      "closing_time"          => "//td/b[contains( text(), 'Pasiūlymų pateikimo terminas')]/../../following-sibling::tr[1]/td/text()",
      "attachment"            => "//td/b[contains( text(), 'PAPILDOMA INFORMACIJA')]/../../../tr/td/b[contains(text(), 'Arba')]/../a/@href"
    }
  end
  
  def tender_type
    "Tender (Pirkimas)"
  end
  
  def value
    "BelownNational"
  end
  
  def closing_date
    if match_data = extract_data("closing_time").match(/(20[1-9][1-9])-([0-1]?[0-9])-([0-3][0-9])/)
      Date.civil(match_data[1].to_i, match_data[2].to_i, match_data[3].to_i)
    end
  end
  
  def closing_time
    extract_data("closing_time").match(/[0-9]+:[0-6][0-9]/).to_s
  end
end