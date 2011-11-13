module Sk1Parser
  def additional_elem_xpaths 
    {
      "closing_date"  => "//td/b[contains( text(), 'Pasiūlymų (pirminių pasiūlymų) pateikimo terminas')]/../../following-sibling::tr[1]/td/text()",
      "closing_time"  => "//td/b[contains( text(), 'Pasiūlymų (pirminių pasiūlymų) pateikimo terminas')]/../../following-sibling::tr[1]/td/text()",
      "opening_date"  => "//td/b[contains( text(), 'Komisijos posėdžio, kuriame bus atplėšiami vokai su pasiūlymais data, laikas ir vieta')]/../../following-sibling::tr[1]/td/text()",
      "opening_time"  => "//td/b[contains( text(), 'Komisijos posėdžio, kuriame bus atplėšiami vokai su pasiūlymais data, laikas ir vieta')]/../../following-sibling::tr[1]/td/text()",
      "assignment"    => "//td/b[contains( text(), 'Pasiūlymu vertinimo kriterijai')]/../../following-sibling::tr[1]/td/input[@type='checkbox']"
    }
  end
    
  def opening_date
    default_date extract_data_node("opening_date").first.to_s
  end
  
  def opening_time
    default_time extract_data_node("closing_time").first.to_s
  end
  
  def assignment
    if extract_data_node("assignment").first.attr("checked") == "checked"
      "Lowest price (Mažiausios kainos)"
    else
      "The most economic tender (Ekonomiškai naudingiausio pasiūlymo)"
    end
  end
  
  def procurement_procedure
    "Open (Atviras konkursas)"
  end
end