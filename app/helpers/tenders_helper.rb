module TendersHelper
  def tender_field_label(attrib)
    attrib = attrib.humanize
    attrib.match(/phone|fax/i) ? attrib.sub(/number/,'').strip : attrib
  end
  
  def tender_field_value(f, attrib)
    (attrib == 'cpv_codes' ? f.object.send(attrib).join(' , ') : f.object.send(attrib) ).to_s
  end
  
  def tender_field_helper(f, attrib, options={})
    options = { :disabled => true, :label => tender_field_label(attrib), :value => tender_field_value(f, attrib) }.merge(options)
    options[:class] = options[:class].to_s + '.span5'
    
    field = if attrib.match /email/
      "email_field"
    else
      "text_field"
    end
    
    f.send field, attrib.to_sym, options[:label], options
  end
  
  def tender_label(tender)
    label_type = case tender.status.to_sym
      when :new
        "success"
      when :edited, :marked_for_export
        "warning"
      when :exported
        "important"
      end
      
    "<span class='label #{label_type}'>#{tender.status.to_s.capitalize}</span>".html_safe
  end
  
  def buyer_contact_legend
    "<span class='buyer-legend'>Buyer</span><span class='contact-legend'>Contact</span>".html_safe
  end
end
