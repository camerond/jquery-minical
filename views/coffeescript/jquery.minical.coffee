date_tools =
  getMonthName: (date) ->
    months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    months[date.getMonth()]
  getDays: ->
    days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    $tr = $("<tr />")
    $("<th />").text(day).appendTo($tr) for day in days
    $tr
  getStartOfCalendarBlock: (date) ->
    firstOfMonth = new Date(date)
    firstOfMonth.setDate(1)
    new Date(firstOfMonth.setDate(1 - firstOfMonth.getDay()))

minical =
  offset:
    x: 0
    y: 5
  trigger: null
  align_to_trigger: true
  dropdowns:
    month: null
    day: null
    year: null
  date_format: (date) ->
    [date.getMonth()+1, date.getDate(), date.getFullYear()].join("/")
  from: null
  to: null
  date_changed: $.noop
  month_drawn: $.noop
  getDayClass: (date) ->
    return "minical_day_" + [date.getMonth() + 1, date.getDate(), date.getFullYear()].join("_")
  render: (date) ->
    date ?= @selected_day
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
    days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    $tr = $li.find("tr")
    $("<th />", { text: day }).appendTo($tr) for day in days
    $tbody = $li.find("tbody")
    current_date = date_tools.getStartOfCalendarBlock(date)
    $li.find(".minical_prev").hide() if @from && @from > current_date
    for w in [1..6]
      $tr = $("<tr />")
      for d in [1..7]
        $tr.append(@renderDay(current_date, date))
        current_date.setDate(current_date.getDate() + 1)
      $tr.appendTo($tbody) if $tr.find(".minical_day").length
    $li.find(".#{@getDayClass(new Date())}").addClass("minical_today")
    $li.find(".#{@getDayClass(@selected_day)}").addClass("minical_selected").addClass("minical_highlighted") if @selected_day
    $li.find("td").not(".minical_disabled, .minical_past_month").eq(0).addClass("minical_highlighted") if !$li.find(".minical_highlighted").length
    $li.find(".minical_next").hide() if @to && @to < new Date($li.find("td").last().data("minical_date"))
    @month_drawn.apply(@$el)
    @$cal.empty().append($li)
  renderDay: (d, base_date) ->
    $td = $("<td />")
      .data("minical_date", new Date(d))
      .addClass(@getDayClass(d))
      .append($("<a />", {"href": "#"}).text(d.getDate()))
    current_month = d.getMonth()
    month = base_date.getMonth()
    $td.addClass("minical_disabled") if (@from && d < @from) || (@to && d > @to)
    if current_month < month
      $td.addClass("minical_past_month")
    else if current_month > month
      $td.addClass("minical_future_month")
    else
      $td.addClass("minical_day")
  selectDay: (e) ->
    $td = $(e.target).closest("td")
    return false if $td.hasClass("minical_disabled")
    mc = $td.closest("ul").data("minical")
    mc.selected_day = new Date($td.data("minical_date"))
    if (mc.$el.is(":text"))
      mc.$el.val(mc.date_format(mc.selected_day))
      mc.date_changed.apply(mc.$input)
    else
      mc.dropdowns.$month.val(mc.selected_day.getMonth() + 1)
      mc.dropdowns.$day.val(mc.selected_day.getDate())
      mc.dropdowns.$year.val(mc.selected_day.getFullYear())
      mc.date_changed.apply(mc.dropdowns)
    mc.hideCalendar()
  highlightDay: (e) ->
    $td = $(e.target).closest("td")
    klass = "minical_highlighted"
    $td.closest("tbody").find(".#{klass}").removeClass(klass)
    $td.addClass(klass)
  moveToDay: (x, y) ->
    $selected = if @$cal.find(".minical_highlighted").length then @$cal.find(".minical_highlighted") else @$cal.find("tbody td").eq(0)
    $tr = $selected.closest("tr")
    move_from = $selected.data("minical_date")
    if $tr.is(":first-of-type")
      if ($selected.is(":first-of-type") && x == -1) || y == -1 then @prevMonth()
    if $tr.is(":last-of-type")
      if ($selected.is(":last-of-type") && x == 1) || y == 1 then @nextMonth()
    move_to = new Date(move_from)
    move_to.setDate(move_from.getDate() + x + y * 7)
    @$cal.find(".#{@getDayClass(move_to)} a").trigger("mouseover")
    false
  nextMonth: (e) ->
    mc = if e then $(e.target).closest(".minical").data("minical") else @
    mc.selected_day.setMonth(mc.selected_day.getMonth() + 1)
    mc.render()
    false
  prevMonth: (e) ->
    mc = if e then $(e.target).closest(".minical").data("minical") else @
    mc.selected_day.setMonth(mc.selected_day.getMonth() - 1)
    mc.render()
    false
  showCalendar: (e) ->
    mc = if e then $(e.target).data("minical") else @
    mc.$el.prop("disabled", true) if mc.$el.is(":text")
    offset = if mc.align_to_trigger then mc.$trigger.offset() else mc.$el.offset()
    height = if mc.align_to_trigger then mc.$trigger.outerHeight() else mc.$el.outerHeight()
    position =
      left: "#{offset.left + mc.offset.x}px",
      top: "#{offset.top + height + mc.offset.y}px"
    mc.render().css(position).fadeIn(200)
  hideCalendar: (e) ->
    mc = if e then $(e.target).data("minical") else @
    return true if !mc.$cal || mc.$cal.is(":animated")
    mc.$cal.fadeOut(200)
    mc.$el.prop("disabled", false) if mc.$el.is(":text")
  input_keydown: (e) ->
    mc = $(e.target).data("minical")
    if e.keyCode == 13 && !mc.$cal.is(":visible")
      mc.showCalendar()
      false
  body_keydown: (e) ->
    key = e.keyCode
    mc = @
    keys =
      13: ->                       # enter
        mc.$cal.find(".minical_highlighted a").click()
        false
      27: -> mc.hideCalendar()     # esc
      37: -> mc.moveToDay(-1, 0)   # left
      38: -> mc.moveToDay(0, -1)   # up
      39: -> mc.moveToDay(1, 0)    # right
      40: -> mc.moveToDay(0, 1)    # down
    if keys[key] and @$cal.is(":visible") then keys[key]()
  outsideClick: (e) ->
    $t = $(e.target)
    return true if ($t.is(@$el) and @$el.is(":text")) or $t.is(@$trigger) or $t.is(@$el) or $t.closest(".minical").length
    @hideCalendar()
  init: ->
    @$cal = $("<ul />", { id: "minical_#{$('.minical').length}", class: "minical" }).data("minical", @).appendTo($("body")).hide()
    if @trigger
      @$trigger = @$el.find(@trigger)
      @$trigger = @$el.parent().find(@trigger) if !@$trigger.length
      @$trigger.bind("click.minical", @showCalendar).data("minical", @)
      @$trigger.on("keydown.minical", @input_keydown)
    else
      @align_to_trigger = false
    if @$el.is("input")
      @$el.addClass("minical_input").click(@showCalendar)
      @selected_day = new Date(@$el.val())
      @$el.on("keydown.minical", @input_keydown)
    else
      dr = @dropdowns
      dr.$year = @$el.find(dr.year) if dr.year
      dr.$month = @$el.find(dr.month) if dr.month
      dr.$day = @$el.find(dr.day) if dr.day
      @selected_day = new Date(dr.$year.val(), dr.$month.val() - 1, dr.$day.val())
      @from = new Date(dr.$year.find("option").eq(-1).val(), dr.$month.find("option:eq(0)").val() - 1, dr.$day.find("option:eq(0)").val()) if !@from
      @to = new Date(dr.$year.find("option:eq(0)").val(), dr.$month.find("option").eq(-1).val() - 1, dr.$day.find("option").eq(-1).val()) if !@to
      @align_to_trigger = true
    $(document).bind("click.minical", (e) => @outsideClick.call(@, e))
    @$cal.delegate("td a", "click.minical", @selectDay)
    @$cal.delegate("td a", "hover.minical", @highlightDay)
    @$cal.delegate("a.minical_next", "click.minical", @nextMonth)
    @$cal.delegate("a.minical_prev", "click.minical", @prevMonth)
    $("body").on("keydown.minical", (e) => @body_keydown.call(@, e))

do (minical) ->
  $.fn.minical = (opts) ->
    @.each ->
      $e = $(@)
      data = $.extend(true, { $el: $e }, minical, opts)
      data.data = data
      $e.data("minical", data)
      data.init()
