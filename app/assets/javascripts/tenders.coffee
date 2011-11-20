jQuery ->
  $('.tabs').tabs()
  if $('#tender-container').length
    window.tender_pager = new TendersPager()
    
class TendersPager
  constructor: ->
    $(window).scroll(@check)
    @next_page = 2
    @request_finished = true
  
  check: =>
    if @nearBottom() && @request_finished
      @request_finished = false
      $.get($('#tender-container').data('url'), { ajax: "1", page: @next_page }, @render)
      
  nearBottom: =>
    $(window).scrollTop() > $(document).height() - $(window).height() - 50
    
  render: (tenders) =>
    unless tenders.match /No new tenders/
      $('#tender-container').append($(tenders).find('#tender-container').contents())
      @next_page++
      @request_finished = true
    else
      $(window).unbind('scroll', @check)