$ = jQuery

$.fx.off = true

tester =
  keydown: (k, msg, $el) ->
    $el ?= @$el
    if msg then ok true, "I press #{msg}"
    $e = $.Event('keydown')
    $e.keyCode = $e.which = k
    $el.trigger($e)
  cal: (selector) ->
    $cal = @$el.data("minical").$cal
    if selector then $cal.find(selector) else $cal
  init: (opts, date) ->
    $(document).off("keydown")
    date ?= "12/1/2012"
    @$el = $(".calendar :text").val(date).minical(opts)

$.fn.getTextArray = ->
  ($(@).map -> $(@).text()).get()

$.fn.shouldHaveValue = (val) ->
  equal @.val(), val, "#{@.selector} should have a value of #{val}"
  @

$.fn.shouldBe = (attr) ->
  ok @.is(attr), "#{@.selector} should be #{attr}"
  @

$.fn.shouldNotBe = (attr) ->
  ok !@.is(attr), "#{@.selector} should not be #{attr}"
  @

$.fn.shouldSay = (text) ->
  equal @.text(), text, "#{text} is displayed within #{@.selector}"
  @

QUnit.testDone -> $('.minical').each -> $(@).minical('destroy')

test "it is chainable", ->
  ok tester.init().hide().show().is(":visible"), "minical is invoked and visibility is toggled"

test "minical triggers on focus", ->
  $input = tester.init().focus()
  tester.cal().shouldBe(":visible")

asyncTest "minical hides on blur", ->
  $input = tester.init().focus()
  tester.keydown(9, "tab")
  $input.blur()
  setTimeout(->
    tester.cal().shouldNotBe(":visible")
    QUnit.start()
  , 100)

test "minical hides on outside click", ->
  $input = tester.init().focus()
  tester.cal("h1").click()
  tester.cal().shouldBe(":visible")
  $("#qunit").click()
  tester.cal().shouldNotBe(":visible")

module "Rendering a month"

test "minical displays the correct month heading", ->
  $input = tester.init().focus()
  tester.cal("h1").shouldSay("Dec 2012")

test "minical displays the correct day table", ->
  $input = tester.init().focus()
  deepEqual(tester.cal("th").getTextArray(), ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], "Days of week are displayed properly")
  days = ((day + "") for day in [].concat([25..30],[1..31],[1..5]))
  deepEqual(tester.cal("td").getTextArray(), days, "days of month are displayed properly")

test "clicking a day sets input to that value", ->
  $input = tester.init().focus()
  tester.cal("td.minical_day_12_21_2012 a").click()
  tester.cal().shouldNotBe(":visible")
  $input.shouldHaveValue("12/21/2012")

test "minical fades out displayed days not of current month", ->
  $input = tester.init().focus()
  tester.cal("td:lt(7)").shouldBe(".minical_past_month")
  tester.cal("td:last").shouldBe(".minical_future_month")

test "minical highlights the current day", ->
  today = new Date()
  today_array = [today.getMonth() + 1, today.getDate(), today.getFullYear()]
  $input = tester.init({}, today_array.join("/")).focus()
  tester.cal("td.minical_day_#{today_array.join('_')}").shouldBe(".minical_today")

test "minical writes initial value of today if field is empty", ->
  $input = tester.init({}, "").focus()
  today = new Date()
  today_array = [today.getMonth() + 1, today.getDate(), today.getFullYear()]
  $input.shouldHaveValue(today_array.join("/"))

test "minical triggers from a separate trigger element", ->
  opts =
    trigger: ".trigger"
  $el = tester.init(opts)
  $el.data("minical").$trigger.click()
  tester.cal().shouldBe(":visible")

test "minical triggers from a trigger element defined through a function", ->
  $('.calendar').after($("<a />", class: "other_trigger"))
  opts =
    trigger: ->
      $(@).closest('.calendar').siblings().filter(".other_trigger")
  $el = tester.init(opts)
  equal($el.data("minical").$trigger.length, 1, "trigger exists")
  $el.data("minical").$trigger.click()
  tester.cal().shouldBe(":visible")

test "minical does not show from trigger if input is disabled", ->
  opts =
    trigger: ".trigger"
  $el = tester.init(opts)
  $el.prop("disabled", true)
  $el.data("minical").$trigger.click()
  tester.cal().shouldNotBe(":visible")

module "Navigating between months"

test "click to view next month", ->
  tester.init().focus()
  tester.cal(".minical_next").click()
  tester.cal("h1").shouldSay("Jan 2013")
  tester.cal().shouldBe(":visible")

test "click to view previous month", ->
  tester.init().focus()
  tester.cal(".minical_prev").click()
  tester.cal("h1").shouldSay("Nov 2012")
  tester.cal().shouldBe(":visible")

test "Minimum date specified", ->
  opts =
    from: new Date("October 4, 2012")
  $input = tester.init(opts).focus()
  tester.cal(".minical_prev").click()
  tester.cal(".minical_prev").click()
  tester.cal(".minical_prev").shouldNotBe(":visible")
  tester.cal("h1").shouldSay("Oct 2012")
  tester.cal("td.minical_day_10_4_2012").shouldNotBe(".minical_disabled")
  tester.cal("td.minical_day_10_3_2012").shouldBe(".minical_disabled").find("a").click()
  tester.cal().shouldBe(":visible")
  $input.shouldHaveValue("12/1/2012")

test "Maximum date specified", ->
  opts =
    to: new Date("February 26, 2013")
  $input = tester.init(opts).focus()
  tester.cal(".minical_next").click()
  tester.cal(".minical_next").click()
  tester.cal(".minical_next").shouldNotBe(":visible")
  tester.cal("h1").shouldSay("Feb 2013")
  tester.cal("td.minical_day_2_26_2013").shouldNotBe(".minical_disabled")
  tester.cal("td.minical_day_2_27_2013").shouldBe(".minical_disabled").find("a").click()
  tester.cal().shouldBe(":visible")
  $input.shouldHaveValue("12/1/2012")

test "Min and max can be specified via data attributes", ->
  $input = $(".calendar :text")
  from = new Date("November 15, 2012")
  to = new Date("January 15, 2013")
  $input.attr('data-minical-from', +from)
  $input.attr('data-minical-to', +to)
  $input = tester.init()
  deepEqual from, $input.data('minical').from, "`from` value should assign from data attribute"
  deepEqual to, $input.data('minical').to, "`to` value should assign from data attribute"

module "Testing alignment"

test "Calendar aligns to trigger if one is specified", ->
  opts =
    trigger: ".trigger"
  $el = tester.init(opts)
  $trigger = $el.data("minical").$trigger.click()
  equal $trigger.offset().left, tester.cal().show().offset().left, "Calendar and trigger left offsets are identical"
  equal $trigger.offset().top + $trigger.outerHeight() + 5, tester.cal().show().offset().top, "Calendar is 5px below trigger by default"

test "Calendar offset can be specified", ->
  opts =
    trigger: ".trigger"
    offset:
      x: 20
      y: 20
  $el = tester.init(opts)
  $trigger = $el.data("minical").$trigger.click()
  equal $trigger.offset().left + 20, tester.cal().offset().left, "Calendar is 20px to the right of trigger"
  equal $trigger.offset().top + $trigger.outerHeight() + 20, tester.cal().offset().top, "Calendar is 20px below trigger"

test "Calendar aligns to text input if no trigger is specified", ->
  $el = tester.init().focus()
  equal $el.offset().left, tester.cal().offset().left, "Calendar and input left offsets are identical"
  equal $el.offset().top + $el.outerHeight() + 5, tester.cal().offset().top, "Calendar is 5px below input by default"

test "Calendar can be overridden to align to text input", ->
  opts =
    trigger: ".trigger"
    align_to_trigger: false
  $el = tester.init(opts).focus()
  equal $el.offset().left, tester.cal().offset().left, "Calendar and input left offsets are identical"
  equal $el.offset().top + $el.outerHeight() + 5, tester.cal().offset().top, "Calendar is 5px below input by default"

test "Calendar should be appended to the body by default", ->
  tester.init()
  ok tester.cal().parent().is("body"), "Calendar is appended to the body."

test "Calendar can be overridden to append to an arbitrary element", ->
  tester.init(
    appendCalendarTo: -> @parents(".calendar")
  )
  ok tester.cal().parent().is(".calendar"), "Calendar is appended to the .calendar element"

module "Selection feedback and keyboard support"

test "Select date in calendar on draw", ->
  tester.init().focus()
  equal tester.cal("td.minical_selected").length, 1, "Only one td with 'selected' class"
  tester.cal("td.minical_day_12_1_2012").shouldBe(".minical_selected")

test "Select date in calendar on redraw", ->
  $input = tester.init().focus()
  tester.cal("td.minical_day_12_1_2012").shouldBe(".minical_selected")
  tester.cal("td.minical_day_12_7_2012 a").click()
  $input.focus()
  equal tester.cal("td.minical_selected").length, 1, "Only one td with 'selected' class"
  tester.cal("td.minical_day_12_7_2012").shouldBe(".minical_selected")
  tester.cal("a.minical_next").click()
  equal tester.cal(".minical_selected").length, 0, "selected day was for previous month"
  tester.cal("a.minical_prev").click()
  tester.cal("td.minical_day_12_7_2012").shouldBe(".minical_selected")

test "Highlight existing choice if available", ->
  tester.init({}, "12/5/2012").focus()
  tester.cal("td.minical_day_12_5_2012").shouldBe(".minical_highlighted")

test "Highlight triggers on mouse hover", ->
  tester.init().focus()
  tester.cal("td:eq(3) a").trigger("mouseover").parent().shouldBe(".minical_highlighted")
  equal tester.cal("td.minical_selected").length, 1, "Only one td with 'selected' class"

test "Enter on trigger or input toggles calendar and selects highlighted day", ->
  opts =
    trigger: ".trigger"
  $input = tester.init(opts).focus()
  tester.cal("td.minical_day_11_25_2012 a").trigger("mouseover")
  tester.keydown(13, "enter")
  tester.cal().shouldNotBe(":visible")
  $input.shouldHaveValue("11/25/2012")
  $input.data('minical').$trigger.focus()
  tester.cal("td.minical_day_11_27_2012 a").trigger("mouseover")
  tester.keydown(13, "enter")
  tester.cal().shouldNotBe(":visible")
  $input.shouldHaveValue("11/27/2012")

test "Arrow keys move around current month", ->
  tester.init().focus()
  tester.keydown(37, "left arrow")
  tester.cal("td.minical_day_11_30_2012").shouldBe(".minical_highlighted")
  tester.keydown(40, "down arrow")
  tester.cal("td.minical_day_12_7_2012").shouldBe(".minical_highlighted")
  tester.keydown(39, "right arrow")
  tester.cal("td.minical_day_12_8_2012").shouldBe(".minical_highlighted")
  tester.keydown(38, "up arrow")
  tester.cal("td.minical_day_12_1_2012").shouldBe(".minical_highlighted")

test "Arrow keys move around ends of week", ->
  tester.init().focus()
  tester.keydown(39, "right arrow")
  tester.cal("td.minical_day_12_2_2012").shouldBe(".minical_highlighted")
  tester.keydown(37, "left arrow")
  tester.cal("td.minical_day_12_1_2012").shouldBe(".minical_highlighted")

test "Arrow keys move around ends of month", ->
  tester.init().focus()
  tester.cal("td.minical_day_11_25_2012 a").trigger("mouseover")
  tester.keydown(37, "left arrow")
  tester.cal("h1").shouldSay("Nov 2012")
  tester.cal("td.minical_day_11_24_2012").shouldBe(".minical_highlighted")
  tester.keydown(40, "down arrow")
  tester.keydown(40, "down arrow")
  tester.cal("h1").shouldSay("Dec 2012")
  tester.cal("td.minical_day_12_8_2012").shouldBe(".minical_highlighted")

test "Arrow keys should not go to inaccessible months", ->
  opts =
    to: new Date("January 5, 2013")
  tester.init(opts, "12/21/2012").focus()
  tester.cal(".minical_next").shouldNotBe(":visible")
  tester.keydown(40, "down arrow")
  tester.keydown(40, "down arrow")
  tester.cal("td.minical_day_1_4_2013").shouldBe(".minical_highlighted")
  tester.keydown(40, "down arrow")
  tester.cal("td.minical_day_1_4_2013").shouldBe(".minical_highlighted")

test "Arrow keys should not go to inaccessible days", ->
  opts =
    to: new Date("December 17, 2012")
  tester.init(opts).focus()
  tester.keydown(40, "down arrow")
  tester.keydown(40, "down arrow")
  tester.cal("td.minical_day_12_15_2012").shouldBe(".minical_highlighted")
  tester.keydown(40, "down arrow")
  tester.cal("td.minical_day_12_15_2012").shouldBe(".minical_highlighted")
  tester.keydown(39, "right arrow")
  tester.keydown(39, "right arrow")
  tester.keydown(39, "right arrow")
  tester.cal("td.minical_day_12_17_2012").shouldBe(".minical_highlighted")

test "Arrow keys fire anywhere on page as long as calendar is visible", ->
  tester.init().focus()
  tester.keydown(37, "left arrow", $("body"))
  tester.cal("td.minical_day_11_30_2012").shouldBe(".minical_highlighted")

module "Displaying Inline"

test "It appends the calendar inline if `inline` is true", ->
  tester.init(inline: true)
  ok tester.$el.next().is(tester.cal()), "calendar is appended directly after input"

test "Inline calendar doesn't hide on blur", ->
  tester.init(inline: true)
  tester.$el.focus().blur()
  tester.cal().shouldBe(':visible')

test "Inline calendar doesn't respond to keypresses", ->
  tester.init(inline: true)
  tester.cal("td.minical_day_12_1_2012").shouldBe(".minical_selected")
  tester.cal("td.minical_day_12_1_2012").shouldBe(".minical_highlighted")
  tester.keydown(39, "right arrow")
  tester.cal("td.minical_day_12_1_2012").shouldBe(".minical_highlighted")
  tester.cal("td.minical_day_12_2_2012").shouldNotBe(".minical_highlighted")
  tester.cal().shouldBe(':visible')

test "Inline calendar is only selectable via click", ->
  tester.init(inline: true)
  tester.cal("td.minical_day_12_2_2012 a").trigger("mouseover")
  tester.keydown(13, "enter")
  tester.$el.shouldHaveValue("12/1/2012")
  tester.cal("td.minical_day_12_2_2012 a").trigger("click")
  tester.$el.shouldHaveValue("12/2/2012")
  tester.cal().shouldBe(':visible')

module "Other options"

test "Initialize with data-minical-initial attribute if provided", ->
  $(".calendar :text")
    .attr("data-minical-initial", "Tue Aug 07 2012 00:00:00")
    .val("August seventh two thousand and twelvey!")
  tester.init({ write_initial_value: false }).focus()
  tester.cal("td.minical_day_8_7_2012").shouldBe(".minical_highlighted")

test "Support integer data-minical-initial attribute", ->
  $(".calendar :text")
    .attr("data-minical-initial", "1381937430000")
  tester.init().focus()
  tester.cal("td.minical_day_10_16_2013").shouldBe(".minical_highlighted")

test "Callback when date is changed", ->
  callback = false
  opts =
    date_changed: ->
      callback = true
  tester.init(opts).focus()
  tester.cal("td.minical_day_12_21_2012 a").click()
  ok callback, "date_changed callback fires"

test "Callback when month is drawn", ->
  callback = 0
  opts =
    month_drawn: ->
      callback += 1
  tester.init(opts).focus()
  tester.cal("a.minical_next").click()
  equal callback, 2, "month_drawn callback fires on show and month switch"

test "Allow custom date format output", ->
  opts =
    date_format: (date) ->
      return [date.getDate(), date.getMonth()+1, date.getFullYear()].join("-")
  $el = tester.init(opts).focus()
  tester.cal("td.minical_day_12_21_2012 a").click()
  $el.shouldHaveValue("21-12-2012")

test "Write initial date value by default via custom date format output if provided via data-minical-initial", ->
  opts =
    date_format: (date) ->
      return [date.getDate(), date.getMonth()+1, date.getFullYear()].join("-")
  $(".calendar :text")
    .attr("data-minical-initial", "Tue Aug 07 2012 00:00:00")
    .val("")
  $el = tester.init(opts).focus()
  tester.cal("td.minical_day_8_7_2012").shouldBe(".minical_highlighted")
  $el.shouldHaveValue("7-8-2012")

test "Initialize without writing to empty field automatically", ->
  opts =
    initialize_with_date: false
  $input = tester.init(opts, '')
  $input.shouldHaveValue('')
  $input.focus()
  today = new Date()
  today_array = [today.getMonth() + 1, today.getDate(), today.getFullYear()]
  $input = tester.init({}, today_array.join("/")).focus()
  tester.cal("td.minical_day_#{today_array.join('_')}")
    .shouldBe(".minical_today")
    .shouldBe(".minical_highlighted")

test "Clear input", ->
  $input = tester.init().focus()
  tester.cal().minical('clear')
  $input.shouldHaveValue('')
  ok !$input.data('minical').selected_date, 'selected date removed'
  $input.focus()
  today = new Date()
  today_array = [today.getMonth() + 1, today.getDate(), today.getFullYear()]
  $input = tester.init({}, today_array.join("/")).focus()
  tester.cal("td.minical_day_#{today_array.join('_')}")
    .shouldBe(".minical_today")
    .shouldBe(".minical_highlighted")

test "Initialize without writing to empty field provides link to clear input", ->
  today = new Date()
  today_val = [today.getMonth() + 1, today.getDate(), today.getFullYear()].join("/")
  opts =
    initialize_with_date: false
  $input = tester.init(opts, '').focus()
  tester.cal("td.minical_today a").click()
  $input.shouldHaveValue(today_val)
  $input.focus()
  $clear = tester.cal(".minical_clear a")
  equal $clear.length, 1, "Clear link appended to calendar"
  $clear.click()
  $input.shouldHaveValue("")
  tester.cal().shouldNotBe(":visible")

test "Destroy", ->
  $input = tester.init().focus()
  tester.cal().minical('destroy')
  equal $('.minical').length, 0, 'minical element destroyed'
  equal $input.attr('class'), '', 'class removed from input'
  ok !$input.data('minical'), 'data removed from input'
