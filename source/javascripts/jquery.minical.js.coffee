# jQuery Minical Plugin
# http://github.com/camerond/jquery-minical
# version 0.6.1
#
# Copyright (c) 2012 Cameron Daigle, http://camerondaigle.com
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

date_tools =
  getMonthName: (date) ->
    months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    months[date.getMonth()]
  getDayClass: (date) ->
    return if !date
    return "minical_day_" + [date.getMonth() + 1, date.getDate(), date.getFullYear()].join("_")
  getStartOfCalendarBlock: (date) ->
    firstOfMonth = new Date(date)
    firstOfMonth.setDate(1)
    new Date(firstOfMonth.setDate(1 - firstOfMonth.getDay()))

templates =
  day: (date) ->
    $("<td />")
      .data("minical_date", new Date(date))
      .addClass(date_tools.getDayClass(date))
      .append($("<a />", {"href": "#"}).text(date.getDate()))
  dayHeader: ->
    days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    $tr = $("<tr />")
    $("<th />").text(day).appendTo($tr) for day in days
    $tr
  month: (date) ->
    $li = $("<li />", class: "minical_#{date_tools.getMonthName(date).toLowerCase()}")
    $li.html("
      <article>
        <header>
          <h1>#{date_tools.getMonthName(date)} #{date.getFullYear()}</h1>
          <a href='#' class='minical_prev'></a>
          <a href='#' class='minical_next'></a>
        </header>
        <section>
          <table>
            <thead>
              <tr>
              </tr>
            </thead>
            <tbody>
            </tbody>
          </table>
        </section>
      </article>
    ")
    $li.find('thead').append(@dayHeader())
    $li

minical =
  offset:
    x: 0
    y: 5
  trigger: null
  align_to_trigger: true
  move_on_resize: true
  read_only: true
  appendCalendarTo: -> $('body')
  date_format: (date) ->
    [date.getMonth()+1, date.getDate(), date.getFullYear()].join("/")
  from: null
  to: null
  date_changed: $.noop
  month_drawn: $.noop
  fireCallback: (name) ->
    @[name] && @[name].apply(@$el)
  buildCalendarContainer: ->
    $("<ul />", { id: "minical_calendar_#{@id}", class: "minical" })
      .data("minical", @)
      .appendTo(@appendCalendarTo.apply(@$el))
  render: (date) ->
    date ?= @selected_day
    $li = templates.month(date)
    current_date = date_tools.getStartOfCalendarBlock(date)
    $li.find(".minical_prev").detach() if @from and @from > current_date
    for w in [1..6]
      $tr = $("<tr />")
      for d in [1..7]
        $tr.append(@renderDay(current_date, date))
        current_date.setDate(current_date.getDate() + 1)
      $tr.appendTo($li.find('tbody')) if $tr.find('.minical_day').length
    $li.find(".#{date_tools.getDayClass(new Date())}").addClass("minical_today")
    $li.find(".minical_next").detach() if @to and @to <= new Date($li.find("td").last().data("minical_date"))
    @fireCallback('month_drawn')
    @$cal.empty().append($li)
    @$cal
  renderDay: (d, base_date) ->
    $td = templates.day(d)
    current_month = d.getMonth()
    month = base_date.getMonth()
    $td.addClass("minical_disabled") if (@from and d < @from) or (@to and d > @to)
    if current_month > month || current_month == 0 and month == 11
      $td.addClass("minical_future_month")
    else if current_month < month
      $td.addClass("minical_past_month")
    else
      $td.addClass("minical_day")
  highlightDay: (date) ->
    $td = @$cal.find(".#{date_tools.getDayClass(date)}")
    return if $td.hasClass("minical_disabled")
    return if @to and date > @to
    return if @from and date < @from
    if !$td.length
      @render(date)
      @highlightDay(date)
      return
    klass = "minical_highlighted"
    @$cal.find(".#{klass}").removeClass(klass)
    $td.addClass(klass)
  selectDay: (date) ->
    @selected_day = date
    @$el.val(@date_format(@selected_day))
    @fireCallback('date_changed')
  markSelectedDay: ->
    klass = 'minical_selected'
    @$cal.find('td').removeClass(klass)
    @$cal.find(".#{date_tools.getDayClass(@selected_day)}").addClass(klass)
  moveToDay: (x, y) ->
    $selected = @$cal.find(".minical_highlighted")
    if !$selected.length then $selected = @$cal.find(".minical_day").eq(0)
    move_from = $selected.data("minical_date")
    move_to = new Date(move_from)
    move_to.setDate(move_from.getDate() + x + y * 7)
    @highlightDay(move_to)
    false
  positionCalendar: ->
    offset = if @align_to_trigger then @$trigger[@offset_method]() else @$el[@offset_method]()
    height = if @align_to_trigger then @$trigger.outerHeight() else @$el.outerHeight()
    position =
      left: "#{offset.left + @offset.x}px",
      top: "#{height + offset.top + @offset.y}px"
    @$cal.css(position)
    overlap = @$cal.width() + @$cal[@offset_method]().left - $(window).width()
    if overlap > 0
      @$cal.css("left", offset.left - overlap - 10)
    @$cal
  clickDay: (e) ->
    $td = $(e.target).closest('td')
    return false if $td.hasClass("minical_disabled")
    @selectDay($td.data('minical_date'))
    @$cal.trigger('hide.minical')
    false
  hoverDay: (e) ->
    @highlightDay($(e.target).closest("td").data('minical_date'))
  nextMonth: (e) ->
    next = new Date(@$cal.find(".minical_day").eq(0).data("minical_date"))
    next.setMonth(next.getMonth() + 1)
    @render(next)
    false
  prevMonth: (e) ->
    prev = new Date(@$cal.find(".minical_day").eq(0).data("minical_date"))
    prev.setMonth(prev.getMonth() - 1)
    @render(prev)
    false
  showCalendar: (e) ->
    $(".minical").not(@$cal).trigger('hide.minical')
    return if @$cal.is(":visible") or @$el.is(":disabled")
    @markSelectedDay()
    @highlightDay(@selected_day)
    @positionCalendar().show()
    @attachCalendarEvents()
    e.preventDefault()
  hideCalendar: (e) ->
    if e and (e.type == "focusout" or e.type == "blur")
      mc = $(e.target).data("minical")
      $lc = mc.$last_clicked
      if $lc and !$lc.is(mc.$trigger) and !$lc.is(mc.$el) and !$lc.closest(".minical").length
        mc.$cal.hide()
        mc.detachCalendarEvents()
    else
      @$cal.hide()
      @detachCalendarEvents()
    false
  attachCalendarEvents: ->
    @detachCalendarEvents()
    $(document)
      .on("keydown.minical_#{@id}", $.proxy(@keydown, @))
      .on("click.minical touchend.minical", $.proxy(@outsideClick, @))
    if @move_on_resize
      $(window).on('resize.minical', $.proxy(@positionCalendar, @))
  detachCalendarEvents: ->
    $(document)
      .off("keydown.minical_#{@id}")
      .off("click.minical touchend.minical")
    $(window).off('resize.minical')
  keydown: (e) ->
    key = e.which
    mc = @
    keys =
      9:  -> true                  # tab
      13: ->                       # enter
        mc.$cal.find(".minical_highlighted a").click()
        false
      37: -> mc.moveToDay(-1, 0)   # left
      38: -> mc.moveToDay(0, -1)   # up
      39: -> mc.moveToDay(1, 0)    # right
      40: -> mc.moveToDay(0, 1)    # down
    if keys[key]
      keys[key]()
    else if !e.metaKey and !e.ctrlKey
      !mc.read_only
  preventKeystroke: (e) ->
    mc = @
    if mc.$cal.is(":visible") then return true
    key = e.which
    keys =
      9:  -> true                  # tab
      13: ->                       # enter
        mc.$cal.trigger('show.minical')
        false
    if keys[key] then return keys[key]() else return !mc.read_only
  outsideClick: (e) ->
    $t = $(e.target)
    @$last_clicked = $t
    return true if $t.is(@$el) or $t.is(@$trigger) or $t.closest(".minical").length
    @$cal.trigger('hide.minical')
  initTrigger: ->
    if $.isFunction(@trigger)
      @$trigger = $.proxy(@trigger, @$el)()
    else
      @$trigger = @$el.find(@trigger)
      @$trigger = @$el.parent().find(@trigger) if !@$trigger.length
    if @$trigger.length
      @$trigger
        .data("minical", @)
        .on("blur.minical", => @$cal.trigger('hide.minical'))
        .on("focus.minical click.minical", => @$cal.trigger('show.minical'))
    else
      @align_to_trigger = false
  detectDataAttributeOptions: ->
    for range in ['from', 'to']
      attr = @$el.attr("data-minical-#{range}")
      if attr and /^\d+$/.test(attr) then @[range] = new Date(+attr)
  detectInitialDate: ->
    initial_date = @$el.attr("data-minical-initial") || @$el.val()
    if /^\d+$/.test(initial_date)
      return new Date(+initial_date)
    else if initial_date
      return new Date(initial_date)
    new Date()
  external:
    destroy: ->
      mc = @data('minical')
      @trigger('hide.minical')
      mc.$cal.remove()
      mc.$el
        .removeClass('minical_input')
        .removeData('minical')
  init: ->
    @id = $(".minical").length
    mc = @
    @detectDataAttributeOptions()
    @$cal = @buildCalendarContainer()
    @selectDay(@detectInitialDate())
    @offset_method = if @$cal.parent().is("body") then "offset" else "position"
    @initTrigger()
    @$el
      .addClass("minical_input")
      .on("focus.minical click.minical", => @$cal.trigger('show.minical'))
      .on("blur.minical", $.proxy(@hideCalendar, @))
      .on("keydown.minical", (e) -> mc.preventKeystroke.call(mc, e))
    @$cal
      .on("click.minical", "td a", $.proxy(@clickDay, @))
      .on("mouseenter.minical", "td a", $.proxy(@hoverDay, @))
      .on("click.minical", "a.minical_next", $.proxy(@nextMonth, @))
      .on("click.minical", "a.minical_prev", $.proxy(@prevMonth, @))
      .on("hide.minical", $.proxy(@hideCalendar, @))
      .on("show.minical", $.proxy(@showCalendar, @))
    @render()

$.fn.minical = (opts) ->
  $els = @
  if opts and minical.external[opts]
    minical.external[opts].apply($els, Array.prototype.slice.call(arguments, 1))
  else
    $els.each ->
      $e = $(@)
      mc = $.extend(true, { $el: $e }, minical, opts)
      $e.data("minical", mc)
      mc.init()
