module TendersHelper
  def tender_field_helper(f, attrib, options={})
    options = { :disabled => true, :label => attrib.humanize}.merge(options)
    options[:class] = options[:class].to_s + '.span5'
    
    field = if attrib.match /email/
      "email_field"
    # elsif Tender.columns_hash[attrib].type == :date
    #   ["date_select", default_class]
    else
      "text_field"
    end
    
    # if disabled
      f.send field, attrib.to_sym, options[:label], options#, label, :class => field[1], :disabled => true
    # else
      # f.send field[0], attrib.to_sym#, label, :class => field[1]
    # end
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
