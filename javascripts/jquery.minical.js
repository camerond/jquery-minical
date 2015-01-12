(function() {
  var date_tools, minical, templates;

  date_tools = {
    getMonthName: function(date) {
      var months;
      months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
      return months[date.getMonth()];
    },
    getDayClass: function(date) {
      if (!date) {
        return;
      }
      return "minical_day_" + [date.getMonth() + 1, date.getDate(), date.getFullYear()].join("_");
    },
    getStartOfCalendarBlock: function(date) {
      var firstOfMonth;
      firstOfMonth = new Date(date);
      firstOfMonth.setDate(1);
      return new Date(firstOfMonth.setDate(1 - firstOfMonth.getDay()));
    }
  };

  templates = {
    clear_link: function() {
      return $("<p />", {
        "class": "minical_clear"
      }).append($("<a />", {
        href: "#",
        text: "clear date"
      }));
    },
    day: function(date) {
      return $("<td />").data("minical_date", new Date(date)).addClass(date_tools.getDayClass(date)).append($("<a />", {
        "href": "#"
      }).text(date.getDate()));
    },
    dayHeader: function() {
      var $tr, day, days, _i, _len;
      days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
      $tr = $("<tr />");
      for (_i = 0, _len = days.length; _i < _len; _i++) {
        day = days[_i];
        $("<th />").text(day).appendTo($tr);
      }
      return $tr;
    },
    month: function(date) {
      var $li;
      $li = $("<li />", {
        "class": "minical_" + (date_tools.getMonthName(date).toLowerCase())
      });
      $li.html("<article> <header> <h1>" + (date_tools.getMonthName(date)) + " " + (date.getFullYear()) + "</h1> <a href='#' class='minical_prev'></a> <a href='#' class='minical_next'></a> </header> <section> <table> <thead> <tr> </tr> </thead> <tbody> </tbody> </table> </section> </article>");
      $li.find('thead').append(this.dayHeader());
      return $li;
    }
  };

  minical = {
    offset: {
      x: 0,
      y: 5
    },
    inline: false,
    trigger: null,
    align_to_trigger: true,
    initialize_with_date: true,
    move_on_resize: true,
    read_only: true,
    show_clear_link: false,
    add_timezone_offset: false,
    appendCalendarTo: function() {
      return $('body');
    },
    date_format: function(date) {
      return [date.getMonth() + 1, date.getDate(), date.getFullYear()].join("/");
    },
    from: null,
    to: null,
    date_changed: $.noop,
    month_drawn: $.noop,
    fireCallback: function(name) {
      return this[name] && this[name].apply(this.$el);
    },
    buildCalendarContainer: function() {
      var $cal;
      $cal = $("<ul />", {
        id: "minical_calendar_" + this.id,
        "class": "minical"
      }).data("minical", this);
      if (this.inline) {
        return $cal.addClass('minical-inline').insertAfter(this.$el);
      } else {
        return $cal.appendTo(this.appendCalendarTo.apply(this.$el));
      }
    },
    render: function(date) {
      var $li, $tr, current_date, d, w, _i, _j;
      if (date == null) {
        date = this.selected_day;
      }
      $li = templates.month(date);
      if (this.show_clear_link || !this.initialize_with_date) {
        templates.clear_link().insertAfter($li.find("table"));
      }
      current_date = date_tools.getStartOfCalendarBlock(date);
      if (this.from && this.from > current_date) {
        $li.find(".minical_prev").detach();
      }
      for (w = _i = 1; _i <= 6; w = ++_i) {
        $tr = $("<tr />");
        for (d = _j = 1; _j <= 7; d = ++_j) {
          $tr.append(this.renderDay(current_date, date));
          current_date.setDate(current_date.getDate() + 1);
        }
        if ($tr.find('.minical_day').length) {
          $tr.appendTo($li.find('tbody'));
        }
      }
      $li.find("." + (date_tools.getDayClass(new Date()))).addClass("minical_today");
      if (this.to && this.to <= new Date($li.find("td").last().data("minical_date"))) {
        $li.find(".minical_next").detach();
      }
      this.$cal.empty().append($li);
      this.markSelectedDay();
      this.fireCallback('month_drawn');
      return this.$cal;
    },
    renderDay: function(d, base_date) {
      var $td, current_month, month;
      $td = templates.day(d);
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
    highlightDay: function(date) {
      var $td, klass;
      $td = this.$cal.find("." + (date_tools.getDayClass(date)));
      if ($td.hasClass("minical_disabled")) {
        return;
      }
      if (this.to && date > this.to) {
        return;
      }
      if (this.from && date < this.from) {
        return;
      }
      if (!$td.length) {
        this.render(date);
        this.highlightDay(date);
        return;
      }
      klass = "minical_highlighted";
      this.$cal.find("." + klass).removeClass(klass);
      return $td.addClass(klass);
    },
    selectDay: function(date, external) {
      var event_name;
      event_name = external ? 'change.minical_external' : 'change.minical';
      this.selected_day = date;
      this.markSelectedDay();
      this.$el.val(date ? this.date_format(this.selected_day) : '').trigger(event_name);
      return this.fireCallback('date_changed');
    },
    markSelectedDay: function() {
      var klass;
      klass = 'minical_selected';
      this.$cal.find('td').removeClass(klass);
      return this.$cal.find("." + (date_tools.getDayClass(this.selected_day))).addClass(klass);
    },
    moveToDay: function(x, y) {
      var $selected, move_from, move_to;
      $selected = this.$cal.find(".minical_highlighted");
      if (!$selected.length) {
        $selected = this.$cal.find(".minical_day").eq(0);
      }
      move_from = $selected.data("minical_date");
      move_to = new Date(move_from);
      move_to.setDate(move_from.getDate() + x + y * 7);
      this.highlightDay(move_to);
      return false;
    },
    positionCalendar: function() {
      var height, offset, overlap, position;
      if (this.inline) {
        return this.$cal;
      }
      offset = this.align_to_trigger ? this.$trigger[this.offset_method]() : this.$el[this.offset_method]();
      height = this.align_to_trigger ? this.$trigger.outerHeight() : this.$el.outerHeight();
      position = {
        left: "" + (offset.left + this.offset.x) + "px",
        top: "" + (height + offset.top + this.offset.y) + "px"
      };
      this.$cal.css(position);
      overlap = this.$cal.width() + this.$cal[this.offset_method]().left - $(window).width();
      if (overlap > 0) {
        this.$cal.css("left", offset.left - overlap - 10);
      }
      return this.$cal;
    },
    clickDay: function(e) {
      var $td;
      $td = $(e.target).closest('td');
      if ($td.hasClass("minical_disabled")) {
        return false;
      }
      this.selectDay($td.data('minical_date'));
      this.$cal.trigger('hide.minical');
      return false;
    },
    hoverDay: function(e) {
      return this.highlightDay($(e.target).closest("td").data('minical_date'));
    },
    hoverOutDay: function(e) {
      return this.$cal.find('.minical_highlighted').removeClass('minical_highlighted');
    },
    nextMonth: function(e) {
      var next;
      next = new Date(this.$cal.find(".minical_day").eq(0).data("minical_date"));
      next.setMonth(next.getMonth() + 1);
      this.render(next);
      return false;
    },
    prevMonth: function(e) {
      var prev;
      prev = new Date(this.$cal.find(".minical_day").eq(0).data("minical_date"));
      prev.setMonth(prev.getMonth() - 1);
      this.render(prev);
      return false;
    },
    showCalendar: function(e) {
      $(".minical").not(this.$cal).trigger('hide.minical');
      if (this.$cal.is(":visible") || this.$el.is(":disabled")) {
        return;
      }
      this.highlightDay(this.selected_day || this.detectInitialDate());
      this.positionCalendar().show();
      this.attachCalendarEvents();
      return e && e.preventDefault();
    },
    hideCalendar: function(e) {
      if (this.inline) {
        return;
      }
      this.$cal.hide();
      this.detachCalendarEvents();
      return false;
    },
    attachCalendarEvents: function() {
      if (this.inline) {
        return;
      }
      this.detachCalendarEvents();
      $(document).on("keydown.minical_" + this.id, $.proxy(this.keydown, this)).on("click.minical_" + this.id + " touchend.minical_" + this.id, $.proxy(this.outsideClick, this));
      if (this.move_on_resize) {
        return $(window).on("resize.minical_" + this.id, $.proxy(this.positionCalendar, this));
      }
    },
    detachCalendarEvents: function() {
      $(document).off("keydown.minical_" + this.id).off("click.minical_" + this.id + " touchend.minical_" + this.id);
      return $(window).off("resize.minical_" + this.id);
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
      this.checkToHideCalendar();
      if (keys[key]) {
        return keys[key]();
      } else if (!e.metaKey && !e.ctrlKey) {
        return !mc.read_only;
      }
    },
    preventKeystroke: function(e) {
      return this.read_only;
    },
    outsideClick: function(e) {
      var $t;
      $t = $(e.target);
      this.$last_clicked = $t;
      if ($t.parent().is(".minical_clear")) {
        this.$el.minical('clear');
        return false;
      }
      if ($t.is(this.$el) || $t.is(this.$trigger) || $t.closest(".minical").length) {
        return true;
      }
      return this.$cal.trigger('hide.minical');
    },
    checkToHideCalendar: function() {
      var mc;
      mc = this;
      return setTimeout(function() {
        if (!mc.$el.add(mc.$trigger).is(":focus")) {
          return mc.$cal.trigger("hide.minical");
        }
      }, 50);
    },
    initTrigger: function() {
      if ($.isFunction(this.trigger)) {
        this.$trigger = $.proxy(this.trigger, this.$el)();
      } else {
        this.$trigger = this.$el.find(this.trigger);
        if (!this.$trigger.length) {
          this.$trigger = this.$el.parent().find(this.trigger);
        }
      }
      if (this.$trigger.length) {
        return this.$trigger.data("minical", this).on("focus.minical click.minical", (function(_this) {
          return function() {
            return _this.$cal.trigger('show.minical');
          };
        })(this));
      } else {
        this.$trigger = $.noop;
        return this.align_to_trigger = false;
      }
    },
    detectDataAttributeOptions: function() {
      var attr, range, _i, _len, _ref, _results;
      _ref = ['from', 'to'];
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        range = _ref[_i];
        attr = this.$el.attr("data-minical-" + range);
        if (attr && /^\d+$/.test(attr)) {
          _results.push(this[range] = new Date(+attr));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    },
    detectInitialDate: function() {
      var initial_date, millis;
      initial_date = this.$el.attr("data-minical-initial") || this.$el.val();
      millis = /^\d+$/.test(initial_date) ? initial_date : initial_date ? Date.parse(initial_date) : new Date().getTime();
      millis = parseInt(millis) + (this.add_timezone_offset ? new Date().getTimezoneOffset() * 60 * 1000 : 0);
      return new Date(millis);
    },
    external: {
      clear: function() {
        var mc;
        mc = this.data('minical');
        this.trigger('hide.minical');
        return mc.selectDay(false);
      },
      destroy: function() {
        var mc;
        mc = this.data('minical');
        this.trigger('hide.minical');
        mc.$cal.remove();
        return mc.$el.removeClass('minical_input').removeData('minical');
      },
      select: function(date) {
        return this.data('minical').selectDay(date, true);
      }
    },
    init: function() {
      var mc;
      this.id = $(".minical").length;
      mc = this;
      this.detectDataAttributeOptions();
      this.$cal = this.buildCalendarContainer();
      if (!(!this.$el.val() && !this.initialize_with_date)) {
        this.selectDay(this.detectInitialDate());
      }
      this.offset_method = this.$cal.parent().is("body") ? "offset" : "position";
      this.initTrigger();
      this.$el.addClass("minical_input");
      this.$cal.on("click.minical", "td a", $.proxy(this.clickDay, this)).on("mouseenter.minical", "td a", $.proxy(this.hoverDay, this)).on("mouseleave.minical", $.proxy(this.hoverOutDay, this)).on("click.minical", "a.minical_next", $.proxy(this.nextMonth, this)).on("click.minical", "a.minical_prev", $.proxy(this.prevMonth, this));
      if (this.inline) {
        return this.showCalendar();
      } else {
        this.$el.on("focus.minical click.minical", (function(_this) {
          return function() {
            return _this.$cal.trigger('show.minical');
          };
        })(this)).on("hide.minical", $.proxy(this.hideCalendar, this)).on("keydown.minical", function(e) {
          return mc.preventKeystroke.call(mc, e);
        });
        return this.$cal.on("hide.minical", $.proxy(this.hideCalendar, this)).on("show.minical", $.proxy(this.showCalendar, this));
      }
    }
  };

  $.fn.minical = function(opts) {
    var $els;
    $els = this;
    if (opts && minical.external[opts]) {
      return minical.external[opts].apply($els, Array.prototype.slice.call(arguments, 1));
    } else {
      return $els.each(function() {
        var $e, mc;
        $e = $(this);
        mc = $.extend(true, {
          $el: $e
        }, minical, opts);
        $e.data("minical", mc);
        return mc.init();
      });
    }
  };

}).call(this);
