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

class TenderForm
  constructor: (@form_id) ->
    @tender_id = form_id.match /[0-9]+$/ #"edit_tender_123"
    @init()
  
  init: =>
    @form = $("##{@form_id}")
    @cancel_button = $("#tender-#{@tender_id}-cancel-btn")
    @unlock_button= $("#unlock-tender-form-#{@tender_id}")
    @msg_box = $("#tender-#{@tender_id}-message")
    @msg_paragraph = @msg_box.find('p:first')
    @load_indicator = $("#load-indicator-container-#{@tender_id}")
    @attach_events()

  attach_events: =>
    @cancel_button.click(@lock_form)
    @unlock_button.click(@unlock_form)
    @form.bind("ajax:beforeSend",  @toggle_loading)
    @form.bind "ajax:complete", (event, data, status, xhr) =>
      @toggle_loading()
      @form.parent().html(data.responseText)
      @init() # rebind events to form elements
      @msg_box.show()
      @msg_paragraph.show()
    
    @form.addClass('with-events')
    
  # enabling form
  lock_form: (event) =>
    @msg_box.hide()
    $.getJSON @cancel_button.data('url'), (result) =>
      @toggle_form_state(result)
        
  #disabling form
  unlock_form: (event) =>
    @msg_box.hide()
    $.getJSON @unlock_button.data('url'), (result) =>
      @toggle_form_state(result)
  
  toggle_form_state: (result)=>
    @msg_paragraph.text(result.msg)
    @msg_box.addClass(result.status)

    unless result.status == 'error'
      form_lock = @is_form_disabled()
      if form_lock then @unlock_button.attr('disabled', form_lock) else @unlock_button.removeAttr('disabled')
      @form.find("input, select, button").each (index, value) =>
        $(value).attr('disabled', !form_lock)
    
    @show_message()
  
  show_message: =>
    @msg_box.show()
    @msg_paragraph.show()
    setTimeout ( =>
      @msg_box.fadeOut(2500)
    ), 500
  
  toggle_loading: =>
    @load_indicator.toggle()
    @form.parent().toggle()
  
  is_form_disabled: =>
    @cancel_button.attr('disabled')

  
#FIXME: this piece cries for refactor - too much code repeated
class TenderUpdater
  contructor: ->
  
  attach_events: =>
    for elem in $('form:not(.with-events)')
      t = new TenderForm($(elem).attr('id'))