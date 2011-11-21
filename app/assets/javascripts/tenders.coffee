jQuery ->
  $('.tabs').tabs()
  if $('#tender-container').length
    window.tender_updater = new TenderUpdater()
    window.tender_updater.attach_events()
    window.tender_pager = new TendersPager()
    
class TendersPager
  constructor: ->
    $(window).scroll(@check)
    @next_page = 2
    @request_finished = true
  
  check: =>
    if @nearBottom() && @request_finished
      @request_finished = false
      $('#load-indicator-container').show()
      $.get($('#tender-container').data('url'), { ajax: "1", page: @next_page }, @render)
      
  nearBottom: =>
    $(window).scrollTop() > $(document).height() - $(window).height() - 50
    
  render: (tenders) =>
    $('#load-indicator-container').hide()
    $('#tender-container').append(tenders)
    unless tenders.match /No new tenders/
      window.tender_updater.attach_events()
      @next_page++
      @request_finished = true
    else
      $(window).unbind('scroll', @check)
    

class TenderUpdater
  contructor: ->
  
  attach_events: =>
    for elem in $('button.form-unlocker:not(.unlock-event-attached)')
      $(elem).addClass('unlock-event-attached')
      $(elem).click(@toggle_form_lock)
  
  toggle_form_lock: (event) =>
    elem = $(event.currentTarget)
    form_id = "edit_tender_" + elem.attr('id').match /[0-9]+$/, ''
    result = $.getJSON elem.data('url')
    console.log form_id
    $("##{form_id}").find("input, select, button").each ->
      child = $(this)
      console.log child
      child.attr('disabled', false)
      