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
  date_changed: $.noop
  month_drawn: $.noop
  getDayClass: (date) ->
    return "minical_day_" + [date.getMonth() + 1, date.getDate(), date.getFullYear()].join("_");
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
    ")
    days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    $tr = $li.find("tr")
    $("<th />", { text: day }).appendTo($tr) for day in days
    $tbody = $li.find("tbody")
    current_date = date_tools.getStartOfCalendarBlock(date)
    for w in [1..6]
      $tr = $("<tr />")
      for d in [1..7]
        $tr.append(@renderDay(current_date, date))
        current_date.setTime(current_date.getTime() + 86400000)
      $tr.appendTo($tbody) if $tr.find(".minical_day").length
    $li.find(".#{@getDayClass(new Date())}").addClass("minical_today")
    @$cal.empty().append($li)
  renderDay: (d, base_date) ->
    $td = $("<td />")
      .data("minical_date", new Date(d))
      .addClass(@getDayClass(d))
      .append($("<a />", {"href": "#"}).text(d.getDate()))
    current_month = d.getMonth()
    month = base_date.getMonth()
    if current_month < month
      $td.addClass("minical_past_month")
    else if current_month > month
      $td.addClass("minical_future_month")
    else
      $td.addClass("minical_day")
  selectDay: (e) ->
    $td = $(e.target).closest("td")
    mc = $td.closest("ul").data("minical")
    mc.selected_day = new Date($td.data("minical_date"));
    console.log($td.data("minical_date"))
    if (mc.$el.is(":text"))
      mc.$el.val(mc.date_format(mc.selected_day))
      mc.date_changed.apply(mc.$input)
    else
      mc.dropdowns.$month.val(mc.selected_day.getMonth() + 1)
      mc.dropdowns.$day.val(mc.selected_day.getDate())
      mc.dropdowns.$year.val(mc.selected_day.getFullYear())
      mc.date_changed.apply(mc.dropdowns)
    mc.hideCalendar()
  nextMonth: (e) ->
    console.log(e)
    mc = $(e.target).closest(".minical").data("minical")
    mc.selected_day.setMonth(mc.selected_day.getMonth() + 1)
    mc.render()
  prevMonth: (e) ->
    mc = $(e.target).closest(".minical").data("minical")
    mc.selected_day.setMonth(mc.selected_day.getMonth() - 1)
    mc.render()
  showCalendar: (e) ->
    mc = if e then $(e.target).data("minical") else @
    mc.$el.prop("disabled", true) if mc.$el.is(":text")
    mc.render().fadeIn(200)
  hideCalendar: (e) ->
    mc = if e then $(e.target).data("minical") else @
    return true if !mc.$cal || mc.$cal.is(":animated")
    mc.$cal.fadeOut(200)
    mc.$el.prop("disabled", false) if mc.$el.is(":text")
  outsideClick: (e) ->
    $t = $(e.target)
    return true if ($t.is(@$el) and @$el.is(":text")) or @$el.closest(".minical").length
    @hideCalendar()
  init: ->
    @$cal = $("<ul />", { id: "minical_#{$('.minical').length}", class: "minical" }).data("minical", @).appendTo($("body"))
    if @trigger
      @$trigger = @$el.find(@trigger)
      @$trigger.bind("click.minical", @showCalendar).data("minical", @)
    if @$el.is(":text")
      @$el.addClass("minical_input").click(@showCalendar)
      @selected_day = new Date(@$el.val())
    else
      @dropdowns.$year = @$el.find(@dropdowns.year) if @dropdowns.year
      @dropdowns.$month = @$el.find(@dropdowns.month) if @dropdowns.month
      @dropdowns.$day = @$el.find(@dropdowns.day) if @dropdowns.day
      @selected_day = new Date(@dropdowns.$year.val(), @dropdowns.$month.val() - 1, @dropdowns.$day.val())
    $(document).bind("click.minical", (e) => @outsideClick.call(@, e))
    @$cal.delegate("td a", "click.minical", @selectDay)
    @$cal.delegate("a.minical_next", "click.minical", @nextMonth)
    @$cal.delegate("a.minical_prev", "click.minical", @prevMonth)

do (minical) ->
  $.fn.minical = (opts) ->
    @.each ->
      $e = $(@)
      data = $.extend(true, { $el: $e }, minical, opts)
      data.data = data
      $e.data("minical", data)
      data.init()
