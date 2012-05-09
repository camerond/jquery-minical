$ = jQuery

$.fx.off = true

tester =
  keydown: (k, msg) ->
    if msg then ok true, "I press #{msg}"
    $e = $.Event('keydown')
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
  cal: (selector) ->
    $cal = @$el.data("minical").$cal
    if selector then $cal.find(selector) else $cal
  init: (opts, date) ->
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

test "it is chainable", ->
  ok tester.init().hide().show().is(":visible"), "minical is invoked and visibility is toggled"

test "minical triggers on click", ->
  $input = tester.init().click()
  tester.cal().shouldBe(":visible")
  $input.shouldBe(":disabled")

test "minical hides on outside click", ->
  $input = tester.init().click()
  $("#qunit").click()
  tester.cal().shouldNotBe(":visible")
  $input.shouldNotBe(":disabled")

test "minical hides on esc", ->
  tester.init().click()
  tester.keydown(27, "esc")
  tester.cal().shouldNotBe(":visible")

module "Rendering a month"

test "minical displays the correct month heading", ->
  $input = tester.init().click()
  tester.cal("h1").shouldSay("Dec 2012")

test "minical displays the correct day table", ->
  $input = tester.init().click()
  deepEqual(tester.cal("th").getTextArray(), ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], "Days of week are displayed properly")
  days = ((day + "") for day in [].concat([25..30],[1..31],[1..5]))
  deepEqual(tester.cal("td").getTextArray(), days, "days of month are displayed properly")

test "clicking a day sets input to that value", ->
  $input = tester.init().click()
  tester.cal("td.minical_day_12_21_2012 a").click()
  tester.cal().shouldNotBe(":visible")
  $input.shouldHaveValue("12/21/2012")

test "minical fades out displayed days not of current month", ->
  $input = tester.init().click()
  tester.cal("td:lt(7)").shouldBe(".minical_past_month")

test "minical highlights the current day", ->
  today = new Date()
  today_array = [today.getMonth() + 1, today.getDate(), today.getFullYear()]
  $input = tester.init({}, today_array.join("/")).click()
  tester.cal("td.minical_day_#{today_array.join('_')}").shouldBe(".minical_today")

test "minical triggers from a separate trigger element", ->
  opts =
    trigger: ".trigger"
  $el = tester.init(opts)
  $el.data("minical").$trigger.click()
  tester.cal().shouldBe(":visible")

module "Navigating between months"

test "click to view next month", ->
  tester.init().click()
  tester.cal(".minical_next").click()
  tester.cal("h1").shouldSay("Jan 2013")
  tester.cal().shouldBe(":visible")

test "click to view previous month", ->
  tester.init().click()
  tester.cal(".minical_prev").click()
  tester.cal("h1").shouldSay("Nov 2012")
  tester.cal().shouldBe(":visible")

test "Minimum date specified", ->
  opts =
    from: new Date("October 4, 2012")
  $input = tester.init(opts).click()
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
  $input = tester.init(opts).click()
  tester.cal(".minical_next").click()
  tester.cal(".minical_next").click()
  tester.cal(".minical_next").shouldNotBe(":visible")
  tester.cal("h1").shouldSay("Feb 2013")
  tester.cal("td.minical_day_2_26_2013").shouldNotBe(".minical_disabled")
  tester.cal("td.minical_day_2_27_2013").shouldBe(".minical_disabled").find("a").click()
  tester.cal().shouldBe(":visible")
  $input.shouldHaveValue("12/1/2012")

module "Firing using dropdowns"

test "displays when trigger clicked and dropdowns specified", ->
  tester.initDropdowns().find(".trigger").click()
  tester.cal("h1").shouldSay("Dec 2012")

test "clicking a day sets dropdowns to that value", ->
  $el = tester.initDropdowns()
  $el.data("minical").$trigger.click()
  tester.cal("td.minical_12_21_2012").click()
  $el.find(".months").shouldHaveValue(12)
  $el.find(".days").shouldHaveValue(21)
  $el.find(".years").shouldHaveValue(2012)

test "Minimum date is autodetected from dropdown content", ->
  $el = tester.initDropdowns({}, 1, 1, 2000).data("minical").$trigger.click()
  tester.cal("td.minical_day_12_31_1999").shouldBe(".minical_disabled")
  tester.cal("td.minical_day_1_1_2000").shouldNotBe(".minical_disabled")
  tester.cal(".minical_prev").shouldNotBe(":visible")

test "Maximum date is autodetected from dropdown content", ->
  $el = tester.initDropdowns({}, 12, 25, 2020).data("minical").$trigger.click()
  tester.cal(".minical_next").shouldNotBe(":visible")

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

test "Calendar aligns to trigger if dropdowns are used", ->
  $el = tester.initDropdowns()
  $trigger = $el.data("minical").$trigger.click()
  equal $trigger.offset().left, tester.cal().offset().left, "Calendar and trigger left offsets are identical"
  equal $trigger.offset().top + $trigger.outerHeight() + 5, tester.cal().offset().top, "Calendar is 5px below trigger by default"

test "Calendar aligns to text input if no trigger is specified", ->
  $el = tester.init().click()
  equal $el.offset().left, tester.cal().offset().left, "Calendar and input left offsets are identical"
  equal $el.offset().top + $el.outerHeight() + 5, tester.cal().offset().top, "Calendar is 5px below input by default"

test "Calendar can be overridden to align to text input", ->
  opts =
    trigger: ".trigger"
    align_to_trigger: false
  $el = tester.init(opts).click()
  equal $el.offset().left, tester.cal().offset().left, "Calendar and input left offsets are identical"
  equal $el.offset().top + $el.outerHeight() + 5, tester.cal().offset().top, "Calendar is 5px below input by default"

module "Selection feedback and keyboard support"

test "Select date in calendar on draw", ->
  tester.init().click()
  equal tester.cal("td.minical_selected").length, 1, "Only one td with 'selected' class"
  tester.cal("td.minical_day_12_1_2012").shouldBe(".minical_selected")

test "Select date in calendar on redraw", ->
  $input = tester.init().click()
  tester.cal("td.minical_day_12_1_2012").shouldBe(".minical_selected")
  tester.cal("td.minical_day_12_7_2012 a").click()
  $input.click()
  equal tester.cal("td.minical_selected").length, 1, "Only one td with 'selected' class"
  tester.cal("td.minical_day_12_7_2012").shouldBe(".minical_selected")

test "Highlight existing choice if available", ->
  tester.init({}, "12/5/2012").click()
  tester.cal("td.minical_day_12_5_2012").shouldBe(".minical_highlighted")

test "Highlight triggers on mouse hover", ->
  tester.init().click()
  tester.cal("td:eq(3) a").trigger("mouseover").parent().shouldBe(".minical_highlighted")
  equal tester.cal("td.minical_selected").length, 1, "Only one td with 'selected' class"

test "Enter selects highlighted day", ->
  $input = tester.init().click()
  tester.cal("td.minical_day_11_25_2012 a").trigger("mouseover")
  tester.keydown(13, "enter")
  tester.cal().shouldNotBe(":visible")
  $input.shouldHaveValue("11/25/2012")

test "Arrow keys move around current month", ->
  tester.init().click()
  tester.keydown(37, "left arrow")
  tester.cal("td.minical_day_11_30_2012").shouldBe(".minical_highlighted")
  tester.keydown(40, "down arrow")
  tester.cal("td.minical_day_12_7_2012").shouldBe(".minical_highlighted")
  tester.keydown(39, "right arrow")
  tester.cal("td.minical_day_12_8_2012").shouldBe(".minical_highlighted")
  tester.keydown(38, "up arrow")
  tester.cal("td.minical_day_12_1_2012").shouldBe(".minical_highlighted")

test "Arrow keys move around ends of week", ->
  tester.init().click()
  tester.keydown(39, "right arrow")
  tester.cal("td.minical_day_12_2_2012").shouldBe(".minical_highlighted")
  tester.keydown(37, "left arrow")
  tester.cal("td.minical_day_12_1_2012").shouldBe(".minical_highlighted")

test "Arrow keys move around ends of month", ->
  tester.init().click()
  tester.cal("td.minical_day_11_25_2012 a").trigger("mouseover")
  tester.keydown(37, "left arrow")
  tester.cal("h1").shouldSay("Nov 2012")
  tester.cal("td.minical_day_11_24_2012").shouldBe(".minical_highlighted")
  tester.keydown(40, "down arrow")
  tester.keydown(40, "down arrow")
  tester.cal("h1").shouldSay("Dec 2012")
  tester.cal("td.minical_day_12_8_2012").shouldBe(".minical_highlighted")


module "Other options"

test "Callback when date is changed", ->
  callback = false
  opts =
    date_changed: ->
      callback = true
  tester.init(opts).click()
  tester.cal("td.minical_day_12_21_2012 a").click()
  ok callback, "date_changed callback fires"

test "Callback when month is drawn", ->
  callback = 0
  opts =
    month_drawn: ->
      callback += 1
  tester.init(opts).click()
  tester.cal("a.minical_next").click()
  equal callback, 2, "month_drawn callback fires on show and month switch"

test "Allow custom date format output", ->
  opts =
    date_format: (date) ->
      return [date.getDate(), date.getMonth()+1, date.getFullYear()].join("-")
  $el = tester.init(opts).click()
  tester.cal("td.minical_day_12_21_2012 a").click()
  $el.shouldHaveValue("21-12-2012")

QUnit.done ->
  $(".minical").remove()