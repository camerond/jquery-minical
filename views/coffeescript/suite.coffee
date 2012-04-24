$ = jQuery

$.fx.off = true

tester =
  typeKeycode: (k, msg) ->
    if msg then ok true, "I press #{msg}"
    $e = $.Event('keyup')
    $e.keyCode = k
    @$el.trigger($e)
  initDropdowns: (opts, month, day, year, months, days, years) ->
    month ?= 12
    day ?= 21
    year ?= 2012
    months ?= ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    days ?= [1..31]
    years ?= [2000..2020].reverse()
    $div = $(".calendar")
    $div.find(":text").remove()
    $m = $("<select />", { class: "months"} ).appendTo($div)
    $d = $("<select />", { class: "days"} ).appendTo($div)
    $y = $("<select />", { class: "years"} ).appendTo($div)
    $m.append($("<option />", { text: m, value: i+1 })) for m, i in months
    $d.append($("<option />", { text: d, value: d })) for d in days
    $y.append($("<option />", { text: y, value: y })) for y in years
    $m.find("option:eq(#{month-1})").attr("selected", true)
    $d.find("option:eq(#{day-1})").attr("selected", true)
    $y.find("option:eq(#{2020-year})").attr("selected", true)
    dropdown_opts =
      trigger: ".trigger",
      dropdowns:
        month: ".months"
        day: ".days"
        year: ".years"
    @$el = $(".calendar").minical($.extend(opts, dropdown_opts))
  init: (opts, date) ->
    date ?= "12/1/2012"
    @$el = $(".calendar :text").val(date).minical(opts)

cal = (selector) ->
  if selector then $("ul#minical").find(selector) else $("ul#minical")

$.fn.getTextArray = ->
  ($(@).map -> $(@).text()).get()

$.fn.shouldHaveValue = (val) ->
  return equal @.val(), val, "#{@.selector} should have a value of #{val}"

$.fn.shouldBe = (attr) ->
  return ok @.is(attr), "#{@.selector} should be #{attr}"

$.fn.shouldNotBe = (attr) ->
  return ok !@.is(attr), "#{@.selector} should not be #{attr}"

$.fn.shouldSay = (text) ->
  return equal @.text(), text, "#{text} is displayed within #{@.selector}"

test "it is chainable", ->
  ok tester.init().hide().show().is(":visible"), "minical is invoked and visibility is toggled"

test "minical triggers on click", ->
  $input = tester.init().click()
  cal().shouldBe(":visible")
  $input.shouldBe(":disabled")

test "minical hides on outside click", ->
  $input = tester.init().click()
  $("#qunit").click()
  cal().shouldNotBe(":visible")
  $input.shouldNotBe(":disabled")

test "minical hides on esc", ->
  tester.init().click()
  tester.typeKeycode(27, "esc")

module "Rendering a month"

test "minical displays the correct month heading", ->
  $input = tester.init().click()
  cal("h1").shouldSay("Dec 2012")

test "minical displays the correct day table", ->
  $input = tester.init().click()
  deepEqual cal("th").getTextArray(), ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], "Days of week are displayed properly"
  days = ((day + "") for day in [].concat([25..30],[1..31],[1..5]))
  deepEqual(cal("td").getTextArray(), days, "days of month are displayed properly")

test "clicking a day sets input to that value", ->
  $input = tester.init().click()
  cal("td.minical_day_12_21_2012 a").click()
  cal().shouldNotBe(":visible")
  $input.shouldHaveValue("12/21/2012")

test "minical fades out displayed days not of current month", ->
  $input = tester.init().click()
  cal("td:lt(7)").shouldBe(".minical_past_month")

test "minical highlights the current day", ->
  today = new Date
  today_array = [today.getMonth() + 1, today.getDate(), today.getFullYear()]
  $input = tester.init({}, today_array.join("/")).click()
  cal("td.minical_day_#{today_array.join('_')}").shouldBe(".minical_today")

test "minical triggers from a separate trigger element", ->
  opts =
    trigger: ".trigger"
  $el = tester.init(opts)
  $el.data("minical").$trigger.click()
  cal().shouldBe(":visible")

module "Navigating between months"

test "click to view next month", ->
  tester.init().click()
  cal(".minical_next").click()
  cal("h1").shouldSay("Jan 2013")

test "click to view previous month", ->
  tester.init().click()
  cal(".minical_prev").click()
  cal("h1").shouldSay("Nov 2012")

module "Firing using dropdowns"

test "displays when trigger clicked and dropdowns specified", ->
  tester.initDropdowns().find(".trigger").click()
  cal("h1").shouldSay("Dec 2012")

test "clicking a day sets dropdowns to that value", ->
  $el = tester.initDropdowns()
  $el.data("minical").$trigger.click()
  cal("td.minical_12_21_2012").click()
  $el.find(".months").shouldHaveValue(12)
  $el.find(".days").shouldHaveValue(21)
  $el.find(".years").shouldHaveValue(2012)

module "Testing alignment"

test "Calendar aligns to trigger if one is specified", ->
  opts =
    trigger: ".trigger"
  $el = tester.init(opts)
  $trigger = $el.data("minical").$trigger.click()
  equal $trigger.offset().left, cal().offset().left, "Calendar and trigger left offsets are identical"
  equal $trigger.offset().top + $trigger.outerHeight() + 5, cal().offset().top, "Calendar is 5px below trigger by default"

test "Calendar offset can be specified", ->
  opts =
    trigger: ".trigger"
    offset:
      x: 20
      y: 20
  $el = tester.init(opts)
  $trigger = $el.data("minical").$trigger.click()
  equal $trigger.offset().left + 20, cal().offset().left, "Calendar is 20px to the right of trigger"
  equal $trigger.offset().top + $trigger.outerHeight() + 20, cal().offset().top, "Calendar is 20px below trigger"

test "Calendar aligns to trigger if dropdowns are used", ->
  $el = tester.initDropdowns()
  $trigger = $el.data("minical").$trigger.click()
  equal $trigger.offset().left, cal().offset().left, "Calendar and trigger left offsets are identical"
  equal $trigger.offset().top + $trigger.outerHeight() + 5, cal().offset().top, "Calendar is 5px below trigger by default"

test "Calendar aligns to text input if no trigger is specified", ->
  $el = tester.init().click()
  equal $el.offset().left, cal().offset().left, "Calendar and input left offsets are identical"
  equal $el.offset().top + $el.outerHeight() + 5, cal().offset().top, "Calendar is 5px below input by default"

test "Calendar can be overridden to align to text input", ->
  opts =
    trigger: ".trigger"
    align_to_trigger: false
  $el = tester.init(opts).click()
  equal $el.offset().left, cal().offset().left, "Calendar and input left offsets are identical"
  equal $el.offset().top + $el.outerHeight() + 5, cal().offset().top, "Calendar is 5px below input by default"

module "Other options"

test "Callback when date is changed", ->
  callback = false
  opts =
    date_changed: ->
      callback = true
  tester.init(opts).click()
  cal("td.minical_day_12_21_2012 a").click()
  ok callback, "date_changed callback fires"

test "Callback when month is drawn", ->
  callback = 0
  opts =
    month_drawn: ->
      callback += 1
  tester.init(opts).click()
  cal("a.minical_next").click()
  equal callback, 2, "month_drawn callback fires on show and month switch"

test "Allow custom date format output", ->
  opts =
    date_format: (date) ->
      return [date.getDate(), date.getMonth()+1, date.getFullYear()].join("-")
  $el = tester.init(opts).click()
  cal("td.minical_day_12_21_2012 a").click()
  $el.shouldHaveValue("21-12-2012")

QUnit.done ->
  cal().remove()