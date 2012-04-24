/*

jQuery minical Plugin
version 0.4.6

Copyright (c) 2011 Cameron Daigle, http://camerondaigle.com

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/

(function($) {

  $.fn.minical = function(options) {
    return this.each(function() {

      var defaults = {
            start_date: new Date(),
            selected_day: null,
            offset: {
              x: 0,
              y: 5
            },
            trigger: null,
            attach_to_trigger: false,
            dropdowns: {
              month: null,
              day: null,
              year: null
            },
            date_format: function(date) {
              return [date.getMonth()+1, date.getDate(), date.getFullYear()].join("/");
            },
            date_changed: $.noop,
            month_drawn: $.noop
      };

      var mc;

      if (typeof options === "string") {
        if (options === "refresh") {
          mc = $(this).data("minical");
          detectDate.call(mc);
        }
      } else {
        mc = {
          opts: $.extend(defaults, options),
          dates: []
        };

        mc.$el = $("<ul />").attr("id", "minical");
        mc.$called_on = $(this);
        mc.$called_on.data("minical", mc);

        if (mc.$called_on.is(":text")) {
          mc.$input = mc.$called_on.addClass("minical_input");
        } else {
          if (mc.$called_on.find(":text").length === 1) {
            mc.$input = mc.$called_on.find(":text").addClass("minical_input");
          } else {
            mc.dropdowns = {
              $month: mc.$called_on.find(mc.opts.dropdowns.month),
              $day: mc.$called_on.find(mc.opts.dropdowns.day),
              $year: mc.$called_on.find(mc.opts.dropdowns.year)
            };
          }
        }
        if (mc.opts.trigger) {
          mc.$trigger = mc.$called_on.find(mc.opts.trigger);
          if (!mc.$trigger.length) {
            mc.$trigger = mc.$called_on.parent().find(mc.opts.trigger);
          }
        }
        attachEvents.call(mc);
        detectDate.call(mc);
      }

    });
  };

  function attachEvents() {
    var mc = this;

    $(document).bind("click.minical", function(e) {
      var $target = $(e.target);
      if ($target.is(mc.$trigger) || $target.is(mc.$input)) { return; }
      var $associated_trigger = $target.closest("li").data("minical_trigger");
      if ($associated_trigger) {
        if($associated_trigger.is(mc.$trigger)) {
          return;
        }
      }
      hideCalendar();
    });

    $(document).bind("keyup.minical", function(e) {
      if (e.keyCode === 27) {
        hideCalendar();
      }
    });

    if (mc.$trigger) {
      mc.$trigger.bind("click.minical", showCalendar);
    }
    if (mc.$input) {
      mc.$input.bind("click.minical", showCalendar);
      mc.$input.keydown(handleKeypress);
    } else {
      mc.dropdowns.$year.bind("change.minical", changeCalendar);
      mc.dropdowns.$day.bind("change.minical", changeCalendar);
      mc.dropdowns.$month.bind("change.minical", changeCalendar);
    }

    mc.$el.delegate("header a.minical_prev", "click.minical", function() {
      var $a = $(this);
      var prevMonth = $a.closest("li").detach().data("minical_month");
      prevMonth.setMonth(prevMonth.getMonth() - 1);
      attachMonth(prevMonth);
      return false;
    });

    mc.$el.delegate("header a.minical_next", "click.minical", function() {
      var $a = $(this);
      var nextMonth = $a.closest("li").detach().data("minical_month");
      nextMonth.setMonth(nextMonth.getMonth() + 1);
      attachMonth(nextMonth);
      return false;
    });

    mc.$el.delegate("td a", "click.minical", function(e) {
      e.preventDefault();
      var $td = $(this).closest("td");
      mc.opts.selected_day = new Date($td.data("minical_date"));
      if (mc.$input) {
        mc.$input.val(mc.opts.date_format(mc.opts.selected_day));
        mc.opts.date_changed.apply(mc.$input);
      } else {
        mc.dropdowns.$month.val(mc.opts.selected_day.getMonth() + 1);
        mc.dropdowns.$day.val(mc.opts.selected_day.getDate());
        mc.dropdowns.$year.val(mc.opts.selected_day.getFullYear());
        mc.opts.date_changed.apply(mc.dropdowns);
      }
      hideCalendar();
    });

    function attachMonth(date) {
      mc.$el.find("li").detach();
      var $month = buildMonth.call(mc, date);
      if (mc.$trigger) {
        $month.data("minical_trigger", mc.$trigger);
      }
      mc.$el.append($month);
      date.setMonth(date.getMonth() - 1);
      mc.$el.find("a.minical_prev").toggle(dateExistsInDropdowns(date));
      date.setMonth(date.getMonth() + 2);
      mc.$el.find("a.minical_next").toggle(dateExistsInDropdowns(date));
      mc.opts.month_drawn.apply(mc.$el);
    }

    function changeCalendar() {
      if (mc.$el.is(":visible")) {
        showCalendar();
      }
    }

    function dateExistsInDropdowns(date) {
      if (mc.$input) { return true; }
      if (mc.dropdowns.$month.find("option[value='" + (date.getMonth() + 1) + "']").length &&
          mc.dropdowns.$year.find("option[value='" + date.getFullYear() + "']").length) {
            return true;
          }
      return false;
    }

    function showCalendar() {
      var offset = mc.dropdowns || mc.opts.attach_to_trigger ? mc.$trigger.offset() : mc.$input.offset();
      var height = mc.dropdowns || mc.opts.attach_to_trigger ? mc.$trigger.height() : mc.$input.outerHeight();
      if (mc.$input) {
        mc.opts.selected_day ? attachMonth(new Date(mc.opts.selected_day)) : attachMonth(new Date(mc.opts.start_date));
      } else {
        attachMonth(new Date(mc.dropdowns.$year.val(), mc.dropdowns.$month.val() - 1, mc.dropdowns.$day.val()));
      }

      if (!mc.$el.is(":visible")) {
        mc.$el.appendTo(document.body).hide();
      }
      mc.$el.css({
        left: offset.left + mc.opts.offset.x,
        top: offset.top + height + mc.opts.offset.y
      }).fadeIn(200);
      if (mc.$input) {
        mc.$input.prop("disabled", true);
      }
    }

    function hideCalendar() {
      if (!mc.$el.is(":animated")) {
        mc.$el.fadeOut(200, function() {
          mc.$el.detach();
        });
        if (mc.$input) {
          mc.$input.prop("disabled", false);
        }
      }
    }

    function handleKeypress(e) {
      var key = e.keyCode;
      if (key === 27 || key === 9) {
        hideCalendar();
      }
      return true;
    }

  }

  function buildMonth(date) {
    var mc = this,
        year = date.getFullYear(),
        month = date.getMonth();

    if (!mc.dates[year]) {
      mc.dates[year] = [];
    };

    if (!mc.dates[year][month]) {
      mc.dates[year][month] = buildMonthElement(date);
    }

    var $days = mc.dates[year][month].data("minical_month", new Date(date.setDate(1)));
    if (mc.$trigger) {
      $days.data("minical_trigger", mc.$trigger);
    }

    $days.find("td.minical_selected").removeClass("minical_selected");
    $days.find(getDayClass(new Date())).addClass("minical_today");
    if (mc.opts.selected_day) {
      $days.find(getDayClass(mc.opts.selected_day)).addClass("minical_selected");
    }

    return mc.dates[year][month];

  }

  function buildMonthElement(date) {
    var $li = $("<li />").addClass("minical_" + getMonthName(date).toLowerCase()),
        $article = $("<article />").appendTo($li),
        $header = $("<header />").appendTo($article),
        $section = $("<section />").appendTo($article),
        $table = $("<table />").appendTo($section),
        $thead = $("<thead />").append(getDays()).appendTo($table),
        $tbody = $("<tbody />").appendTo($table),
        current_day = getStartOfCalendarBlock(date),
        month = date.getMonth(),
        current_month;
    $("<h1 />").text(getMonthName(date) + " " + date.getFullYear()).appendTo($header);
    $("<a />", { "class": "minical_prev", "href": "#" }).appendTo($header);
    $("<a />", { "class": "minical_next", "href": "#" }).appendTo($header);
    for (var w = 0; w < 6; w++) {
      var $tr = $("<tr />");
      for (var d = 0; d < 7; d++) {
        current_month = current_day.getMonth();
        var $day = $("<td />").append($("<a />", {"href": "#"}).text(current_day.getDate())).appendTo($tr);
        if (current_month < month) {
          $day.addClass("minical_past_month");
        } else if (current_month > month) {
          $day.addClass("minical_future_month");
        } else {
          $day.addClass("minical_day");
        }
        $day.data("minical_date", new Date(current_day));
        $day.addClass("minical_day_" + [current_day.getMonth() + 1, current_day.getDate(), current_day.getFullYear()].join("_"));
        current_day.setTime(current_day.getTime() + 86400000);
      }
      $tr.find("td.minical_day").length ? $tr.appendTo($tbody) : false;
    }
    return $li;
  }

  function detectDate() {
    var mc = this;
    if (mc.$input && mc.$input.val()) {
      mc.opts.selected_day = new Date(mc.$input.val());
    } else if (mc.dropdowns) {
      mc.opts.selected_day = new Date(mc.dropdowns.$year.val(), mc.dropdowns.$month.val() - 1, mc.dropdowns.$day.val());
    }
  }

  function getStartOfCalendarBlock(date) {
    var firstOfMonth = new Date(date);
    firstOfMonth.setDate(1);
    return new Date(firstOfMonth.setDate(1 - firstOfMonth.getDay()));
  }

  function getDays() {
    var days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
    var $tr = $("<tr />");
    for (var i = 0, max = days.length; i < max; i++) {
      $("<th />").text(days[i]).appendTo($tr);
    }
    return $tr;
  }

  function getMonthName(date) {
    var months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return months[date.getMonth()];
  }

  function getDayClass(day) {
    return "td.minical_day_" + [day.getMonth() + 1, day.getDate(), day.getFullYear()].join("_");
  }

})(jQuery);