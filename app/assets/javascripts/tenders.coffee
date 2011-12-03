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

class TenderMarker
  constructor: (cb_id)->
    @checkbox = $("##{cb_id}")
    @tender_id = cb_id.match /[0-9]+$/
    @container = @checkbox.parent()
    @load_indicator = $("#marker-load-indicator-#{@tender_id}")
    @checkbox.change @mark_for_export
    
    @checkbox.addClass('with-events')
    
  mark_for_export: =>
    alert 'Works !'

class TenderLabel
  constructor: (label_id)->
    @label = $("##{label_id}")
    @tender_id = label_id.match /[0-9]+$/
    @load_indicator = $("#label-load-indicator-#{@tender_id}").parent()
    # @load_indicator_container = @load_indicator.parent()
    
    @label.addClass "with-events"
  
  current_status: =>
    @label.text().toLowerCase()
  
  toggle_loading: =>
    @load_indicator.width(@label.parent().width()) if @label.is(':visible')
    @label.toggle()
    @load_indicator.toggle()
    
  update: (status)=>
    label_type = switch status.toLowerCase()
      when "new"
        "success"
      when "edited", "marked for export"
        "warning"
      when "exported"
        "important"
    
    @label.removeAttr 'class'
    @label.attr 'class', "label #{label_type}"
    @label.text(status)

class TenderStatusUpdater
  constructor: ->
    @existing_labels = {}
    @interval = 10000
    setTimeout ( => @update_statuses() ), @interval
  
  labels: =>
    for elem in $('span.label:not(.with-events)')
      label_id = $(elem).attr('id')
      unless @existing_labels[label_id]
        @existing_labels[label_id] = new TenderLabel label_id
    
    @existing_labels
      
  update_statuses: =>
    @start = new Date().getTime()
    json_str = {}
    for label_id, label of @labels()
      label.toggle_loading()
      json_str[label.tender_id] = label.current_status()
    
    $.getJSON $('#tender-container').data('status-url'), {tender_statuses: json_str}, (result) =>
      @update_labels(result)
    
  update_labels: (statuses) =>
    for label_id, label of @existing_labels
      label.update statuses[label.tender_id] if statuses[label.tender_id]
      label.toggle_loading()
    
    @finish = new Date().getTime()
    
    setTimeout ( 
      => @update_statuses() 
    ), @interval

class TenderUpdater
  contructor: ->
  
  attach_events: =>
    @attach_form_events()
    @attach_marker_events()
    @attach_status_updater() unless @status_updater
    
  attach_form_events: =>
    for elem in $('form:not(.with-events)')
      new TenderForm($(elem).attr('id'))
  
  attach_marker_events: =>
    for elem in $('.marker-cb:not(.with-events)')
      new TenderMarker($(elem).attr('id'))
      
  attach_status_updater: =>
    @status_updater = new TenderStatusUpdater()
    
class @Tester
  constructor: ->
    @img = $("#label-load-indicator-167")
    @img_container = $("#label-load-indicator-167").parent()
    @label = $("#status-label-167")
    @label_container = @label.parent()
  
  show_img: =>
    w = @label_container.width()
    @img_container.width(w)
    @label.hide()
    @img_container.show()
  
  hide_img: =>
    @img_container.hide()
    @label.show()
  
    
  toggle: =>
    if @label.is(':visible') then @show_img() else @hide_img()