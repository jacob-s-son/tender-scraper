module TendersHelper
  def tender_field_helper(f, attrib, disabled = true)
    default_class = '.span5'
    
    field = if attrib.match /email/
      [ "email_field", default_class ]
    # elsif Tender.columns_hash[attrib].type == :date
    #   ["date_select", default_class]
    else
      ["text_field", default_class]
    end
    
    if disabled
      f.send field[0], attrib.to_sym, :class => field[1], :disabled => true
    else
      f.send field[0], attrib.to_sym, :class => field[1]
    end
  end
  
  def tender_label(tender)
    label_type = case tender.status
      when :new 
        "success"
      when :marked_for_export
        "warning"
      when :exported
        "important"
      end
      
    "<span class='label #{label_type}'>#{tender.status.to_s.capitalize}</span>".html_safe
  end
end
