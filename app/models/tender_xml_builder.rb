require 'nokogiri'

class TenderXmlBuilder
  def self.xml(tenders_for_export)
    (<<-xml
      <?xml version="1.0"?>
        <tenders>
           #{ tenders_for_export.map { |t| t.to_xml }.to_s.gsub(/hash>/, 'tender>') }
        </tenders>
    xml
    ).strip
  end
end