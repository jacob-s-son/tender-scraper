require 'nokogiri'

class TenderXmlBuilder
  def self.xml(tenders_for_export)
    tenders_for_export.each do |t|
      Tender.exportable_fields.each { |k| t.send "#{k}=", (t.send k).to_s }
    end
    
    (<<-xml
      <?xml version="1.0"?>
        <tenders>
           #{ tenders_for_export.map { |t| t.to_xml(:skip_instruct => true, :except => Tender::NONE_EXPORTABLE_FIELDS, :skip_type => true) }.to_s }
        </tenders>
    xml
    ).strip
  end
end