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
    
#FIXME: this piece cries for refactor - too much code repeated
class TenderUpdater
  contructor: ->
  
  attach_events: =>
    @attach_event_to_edit_buttons()
    # @attach_event_to_submit_buttons
    @attach_event_to_cancel_buttons()
  
  attach_event_to_edit_buttons: =>
    for elem in $('button.form-unlocker:not(.unlock-event-attached)')
      $(elem).addClass('unlock-event-attached')
      $(elem).click(@unlock_form)
  
  attach_event_to_cancel_buttons: =>
    for elem in $('button.cancel:not(.cancel-event-attached)')
      $(elem).addClass('cancel-event-attached')
      $(elem).click(@lock_form)
  
  lock_form: (event) =>
    elem = $(event.currentTarget)
    console.log elem
    id = elem.attr('id').match(/-([0-9]+)-/)[1]
    form_id = "edit_tender_" + id
    console.log id
    msg_container = $("#tender-#{id}-message")
    msg_container.hide()
    $.getJSON elem.data('url'), (result) =>
      paragraph = $(msg_container.children().first())
      paragraph.text(result.msg)
      msg_container.addClass(result.status)
    
      unless result.status == 'error'
        $("#unlock-tender-form-#{id}").attr('disabled', false)
        $("##{form_id}").find("input, select, button").each ->
          $(this).attr('disabled', true)
          
      msg_container.show()
      paragraph.show()
      setTimeout ( =>
        msg_container.fadeOut(1400)
      ), 500
  
  unlock_form: (event) =>
    elem = $(event.currentTarget)
    id = elem.attr('id').match /[0-9]+$/
    form_id = "edit_tender_" + id
    msg_container = $("#tender-#{id}-message")
    msg_container.hide()
    $.getJSON elem.data('url'), (result) =>
      paragraph = $(msg_container.children().first())
      paragraph.text(result.msg)
      msg_container.addClass(result.status)
    
      unless result.status == 'error'
        elem.attr('disabled', true)
        $("##{form_id}").find("input, select, button").each ->
          child = $(this)
          child.attr('disabled', false)
      
      msg_container.show()
      paragraph.show()
      setTimeout ( =>
        msg_container.fadeOut(1400)
      ), 500