jQuery ->
  if $('#tender-container').length
    new TendersPager()
    
class TendersPager
  constructor: ->
    $(window).scroll(@check)
  
  check: =>
    if @nearBottom()
      $(window).unbind('scroll', @check)
      $.getJSON($('#tender-container').data('json-url'), @render)
      
  nearBottom: =>
    $(window).scrollTop() > $(document).height() - $(window).height() - 50
    
  render: (tenders) =>
    alert tenders