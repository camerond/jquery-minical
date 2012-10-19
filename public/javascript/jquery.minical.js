// jQuery Minical Plugin
// http://github.com/camerond/jquery-minical
// version 0.5.4
//
// Copyright (c) 2012 Cameron Daigle, http://camerondaigle.com
//
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
// LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

(function() {
  var date_tools, minical;

  date_tools = {
    getMonthName: function(date) {
      var months;
      months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
      return months[date.getMonth()];
    },
    getDays: function() {
      var $tr, day, days, _i, _len;
      days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
      $tr = $("<tr />");
      for (_i = 0, _len = days.length; _i < _len; _i++) {
        day = days[_i];
        $("<th />").text(day).appendTo($tr);
      }
      return $tr;
    },
    getStartOfCalendarBlock: function(date) {
      var firstOfMonth;
      firstOfMonth = new Date(date);
      firstOfMonth.setDate(1);
      return new Date(firstOfMonth.setDate(1 - firstOfMonth.getDay()));
    }
  };

  minical = {
    offset: {
      x: 0,
      y: 5
    },
    trigger: null,
    align_to_trigger: true,
    read_only: false,
    dropdowns: {
      month: null,
      day: null,
      year: null
    },
    date_format: function(date) {
      return [date.getMonth() + 1, date.getDate(), date.getFullYear()].join("/");
    },
    from: null,
    to: null,
    date_changed: $.noop,
    month_drawn: $.noop,
    getDayClass: function(date) {
      return "minical_day_" + [date.getMonth() + 1, date.getDate(), date.getFullYear()].join("_");
    },
    render: function(date) {
      var $li, $tbody, $tr, current_date, d, day, days, w, _i, _j, _k, _len;
      if (date == null) {
        date = this.selected_day;
      }
      $li = $("<li />", {
        "class": "minical_" + (date_tools.getMonthName(date).toLowerCase())
      });
      $li.html("      <article>        <header>          <h1>" + (date_tools.getMonthName(date)) + " " + (date.getFullYear()) + "</h1>          <a href='#' class='minical_prev'></a>          <a href='#' class='minical_next'></a>        </header>        <section>          <table>            <thead>              <tr>              </tr>            </thead>            <tbody>            </tbody>          </table>        </section>      </article>    ");
      days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
      $tr = $li.find("tr");
      for (_i = 0, _len = days.length; _i < _len; _i++) {
        day = days[_i];
        $("<th />", {
          text: day
        }).appendTo($tr);
      }
      $tbody = $li.find("tbody");
      current_date = date_tools.getStartOfCalendarBlock(date);
      if (this.from && this.from > current_date) {
        $li.find(".minical_prev").hide();
      }
      for (w = _j = 1; _j <= 6; w = ++_j) {
        $tr = $("<tr />");
        for (d = _k = 1; _k <= 7; d = ++_k) {
          $tr.append(this.renderDay(current_date, date));
          current_date.setDate(current_date.getDate() + 1);
        }
        if ($tr.find(".minical_day").length) {
          $tr.appendTo($tbody);
        }
      }
      $li.find("." + (this.getDayClass(new Date()))).addClass("minical_today");
      if (this.selected_day) {
        $li.find("." + (this.getDayClass(this.selected_day))).addClass("minical_selected").addClass("minical_highlighted");
      }
      if (!$li.find(".minical_highlighted").length) {
        $li.find("td").not(".minical_disabled, .minical_past_month").eq(0).addClass("minical_highlighted");
      }
      if (this.to && this.to < new Date($li.find("td").last().data("minical_date"))) {
        $li.find(".minical_next").hide();
      }
      this.month_drawn.apply(this.$el);
      return this.$cal.empty().append($li);
    },
    renderDay: function(d, base_date) {
      var $td, current_month, month;
      $td = $("<td />").data("minical_date", new Date(d)).addClass(this.getDayClass(d)).append($("<a />", {
        "href": "#"
      }).text(d.getDate()));
      current_month = d.getMonth();
      month = base_date.getMonth();
      if ((this.from && d < this.from) || (this.to && d > this.to)) {
        $td.addClass("minical_disabled");
      }
      if (current_month > month || current_month === 0 && month === 11) {
        return $td.addClass("minical_future_month");
      } else if (current_month < month) {
        return $td.addClass("minical_past_month");
      } else {
        return $td.addClass("minical_day");
      }
    },
    selectDay: function(e) {
      var $td, mc;
      $td = $(e.target).closest("td");
      if ($td.hasClass("minical_disabled")) {
        return false;
      }
      mc = $td.closest("ul").data("minical");
      mc.selected_day = new Date($td.data("minical_date"));
      if (mc.$el.is(":text")) {
        mc.$el.val(mc.date_format(mc.selected_day));
        mc.date_changed.apply(mc.$input);
      } else {
        mc.dropdowns.$month.val(mc.selected_day.getMonth() + 1);
        mc.dropdowns.$day.val(mc.selected_day.getDate());
        mc.dropdowns.$year.val(mc.selected_day.getFullYear());
        mc.date_changed.apply(mc.dropdowns);
      }
      mc.hideCalendar();
      return false;
    },
    highlightDay: function(e) {
      var $td, klass;
      $td = $(e.target).closest("td");
      klass = "minical_highlighted";
      $td.closest("tbody").find("." + klass).removeClass(klass);
      return $td.addClass(klass);
    },
    moveToDay: function(x, y) {
      var $selected, $tr, move_from, move_to;
      if (!this.$cal.is(":visible")) {
        return true;
      }
      $selected = this.$cal.find(".minical_highlighted").length ? this.$cal.find(".minical_highlighted") : this.$cal.find("tbody td").eq(0);
      $tr = $selected.closest("tr");
      move_from = $selected.data("minical_date");
      if ($tr.parent().children().eq(0).is($tr)) {
        if (($selected.parent().children().eq(0).is($selected) && x === -1) || y === -1) {
          this.prevMonth();
        }
      } else if ($tr.parent().children().eq(-1).is($tr)) {
        if (($selected.parent().children().eq(-1).is($selected) && x === 1) || y === 1) {
          this.nextMonth();
        }
      }
      move_to = new Date(move_from);
      move_to.setDate(move_from.getDate() + x + y * 7);
      this.$cal.find("." + (this.getDayClass(move_to)) + " a").trigger("mouseover");
      return false;
    },
    nextMonth: function(e) {
      var mc, next;
      mc = e ? $(e.target).closest(".minical").data("minical") : this;
      if (!mc.$cal.find(".minical_next").is(":visible")) {
        return false;
      }
      next = new Date(mc.$cal.find("td").eq(8).data("minical_date"));
      next.setMonth(next.getMonth() + 1);
      mc.render(next);
      return false;
    },
    prevMonth: function(e) {
      var mc, prev;
      mc = e ? $(e.target).closest(".minical").data("minical") : this;
      if (!mc.$cal.find(".minical_prev").is(":visible")) {
        return false;
      }
      prev = new Date(mc.$cal.find("td").eq(8).data("minical_date"));
      prev.setMonth(prev.getMonth() - 1);
      mc.render(prev);
      return false;
    },
    showCalendar: function(e) {
      var $other_cals, height, mc, offset, overlap, position;
      mc = e ? $(e.target).data("minical") : this;
      $other_cals = $("[id^='minical_calendar']").not(mc.$cal);
      if ($other_cals.length) {
        $other_cals.data("minical").hideCalendar();
      }
      if (mc.$cal.is(":visible")) {
        return true;
      }
      offset = mc.align_to_trigger ? mc.$trigger.offset() : mc.$el.offset();
      height = mc.align_to_trigger ? mc.$trigger.outerHeight() : mc.$el.outerHeight();
      position = {
        left: "" + (offset.left + mc.offset.x) + "px",
        top: "" + (offset.top + height + mc.offset.y) + "px"
      };
      mc.render().css(position).show();
      overlap = mc.$cal.width() + mc.$cal.offset().left - $(window).width();
      if (overlap > 0) {
        mc.$cal.css("left", offset.left - overlap - 10);
      }
      return mc.attachCalendarKeyEvents();
    },
    hideCalendar: function(e) {
      var mc;
      mc = this;
      if (e && (e.type === "focusout" || e.type === "blur")) {
        mc = $(e.target).data("minical");
        return setTimeout(function() {
          var $e;
          $e = $(document.activeElement);
          if (!$e.is("body") && !$e.is(mc.$trigger) && !$e.is(mc.$el)) {
            mc.$cal.hide();
            return mc.detachCalendarKeyEvents();
          }
        }, 1);
      } else {
        mc.$cal.hide();
        return mc.detachCalendarKeyEvents();
      }
    },
    attachCalendarKeyEvents: function() {
      var mc;
      mc = this;
      $(document).off("keydown.minical_" + mc.id);
      return $(document).on("keydown.minical_" + mc.id, function(e) {
        return mc.keydown.call(mc, e);
      });
    },
    detachCalendarKeyEvents: function() {
      return $(document).off("keydown.minical_" + this.id);
    },
    keydown: function(e) {
      var key, keys, mc;
      key = e.which;
      mc = this;
      keys = {
        9: function() {
          return true;
        },
        13: function() {
          mc.$cal.find(".minical_highlighted a").click();
          return false;
        },
        37: function() {
          return mc.moveToDay(-1, 0);
        },
        38: function() {
          return mc.moveToDay(0, -1);
        },
        39: function() {
          return mc.moveToDay(1, 0);
        },
        40: function() {
          return mc.moveToDay(0, 1);
        }
      };
      if (keys[key]) {
        return keys[key]();
      } else if (!e.metaKey && !e.ctrlKey) {
        return false;
      }
    },
    preventKeystroke: function(e) {
      var key, keys, mc;
      mc = this;
      if (mc.$cal.is(":visible")) {
        return true;
      }
      key = e.which;
      keys = {
        9: function() {
          return true;
        },
        13: function() {
          mc.showCalendar();
          return false;
        }
      };
      if (keys[key]) {
        return keys[key]();
      } else {
        return !mc.read_only;
      }
    },
    dropdownChange: function(e) {
      var dr, mc;
      mc = $(e.target).data("minical");
      dr = mc.dropdowns;
      if (dr.$year.val() && dr.$month.val() && dr.$day.val()) {
        mc.selected_day = new Date(dr.$year.val(), dr.$month.val() - 1, dr.$day.val());
      } else {
        mc.selected_day = new Date();
      }
      if (mc.$cal.is(":visible")) {
        return mc.render();
      }
    },
    outsideClick: function(e) {
      var $t;
      $t = $(e.target);
      if ($t.is(this.$el) || $t.is(this.$trigger) || $t.closest(".minical").length) {
        return true;
      }
      return this.hideCalendar();
    },
    init: function() {
      var dr, initial_date, max_year, mc, min_day, min_month, min_year,
        _this = this;
      this.id = $(".minical").length;
      mc = this;
      this.$cal = $("<ul />", {
        id: "minical_calendar_" + this.id,
        "class": "minical"
      }).data("minical", this).appendTo($("body"));
      if (this.trigger) {
        this.$trigger = this.$el.find(this.trigger);
        if (!this.$trigger.length) {
          this.$trigger = this.$el.parent().find(this.trigger);
        }
        this.$trigger.data("minical", this).on("blur.minical", this.hideCalendar).on("focus.minical", this.showCalendar).on("click.minical", function() {
          mc.$trigger.focus();
          return false;
        });
      } else {
        this.align_to_trigger = false;
      }
      if (this.$el.is("input")) {
        this.$el.addClass("minical_input").on("focus.minical click.minical", this.showCalendar).on("blur.minical", this.hideCalendar).on("keydown.minical", function(e) {
          return mc.preventKeystroke.call(mc, e);
        });
        initial_date = this.$el.attr("data-minical-initial") || this.$el.val();
        this.selected_day = initial_date ? new Date(initial_date) : new Date();
      } else {
        dr = this.dropdowns;
        if (dr.year) {
          dr.$year = this.$el.find(dr.year).data("minical", this).change(this.dropdownChange);
        }
        if (dr.month) {
          dr.$month = this.$el.find(dr.month).data("minical", this).change(this.dropdownChange);
        }
        if (dr.day) {
          dr.$day = this.$el.find(dr.day).data("minical", this).change(this.dropdownChange);
        }
        if (!this.from) {
          min_year = Math.min.apply(Math, dr.$year.children().map(function() {
            if ($(this).val()) {
              return $(this).val();
            }
          }).get());
          min_month = Math.min.apply(Math, dr.$month.children().map(function() {
            if ($(this).val()) {
              return $(this).val();
            }
          }).get());
          min_day = Math.min.apply(Math, dr.$day.children().map(function() {
            if ($(this).val()) {
              return $(this).val();
            }
          }).get());
          this.from = new Date(min_year, min_month - 1, min_day);
        }
        if (!this.to) {
          max_year = Math.max.apply(Math, dr.$year.children().map(function() {
            return $(this).val();
          }).get());
          this.to = new Date(max_year, dr.$month.find("option").eq(-1).val() - 1, dr.$day.find("option").eq(-1).val());
        }
        this.align_to_trigger = true;
        dr.$year.change();
      }
      this.$cal.on("click.minical", "td a", this.selectDay).on("hover.minical", "td a", this.highlightDay).on("click.minical", "a.minical_next", this.nextMonth).on("click.minical", "a.minical_prev", this.prevMonth);
      return $("body").on("click.minical touchend.minical", function(e) {
        return _this.outsideClick.call(_this, e);
      });
    }
  };

  (function(minical) {
    return $.fn.minical = function(opts) {
      return this.each(function() {
        var $e, data;
        $e = $(this);
        data = $.extend(true, {
          $el: $e
        }, minical, opts);
        data.data = data;
        $e.data("minical", data);
        return data.init();
      });
    };
  })(minical);

}).call(this);