# jQuery.minical

## Usage

$my_cool_input.minical()

## Requirements

- jQuery (tested through 2.0.3)
- [jquery.minical.coffee](https://github.com/camerond/jquery-minical/blob/master/source/javascripts/jquery.minical.js.coffee) (or the [generated javascript](https://github.com/camerond/jquery-minical/blob/master/source/javascripts/jquery.minical.plain.js))
- [jquery.minical.sass](https://github.com/camerond/jquery-minical/blob/master/source/stylesheets/jquery.minical.css.sass) (or the [generated css](http://camerond.github.io/jquery-minical/stylesheets/jquery.minical.plain.css))
- [jquery_minical_icons.png](https://github.com/camerond/jquery-minical/blob/master/source/images/jquery_minical_icons.png)

Feel free to [check out the source on GitHub](https://github.com/camerond/jquery-minical).

## Why It's Awesome

Minical is teeny (~4KB minified and gzipped), with no dependencies other than its icon PNG and stylesheet (which has SASS variables for easy customization).

It has full keyboard support and also defaults to make the associated input read-only, so its value can only be changed by the date format specified in the plugin. (It also works great on mobile, with just enough touch event handling to behave properly.)

To aid in customization and general sanity, its markup is also nice and lean. Here's the DOM construction of Minical:

- `ul.minical` contains all elements, with id `#minical_calendar_0` and so on (for multiple instances on a page).
  - `li` - given class `.minical_jan` and so on for each month.
    - `article`
      - `header`
        - `a.minical_next`
        - `a.minical_prev`
        - `h1`
      - `section`
        - `table`
          - `thead`
            - `tr`
              - `th`
          - `tbody`
            - `tr`
              - `td.minical_day` for each day of current month
              - `td.minical_day_[m_d_yyyy]` for each unique day (e.g. `minical_day_1_1_2011`)
              - `td.minical_today` for the current day
              - `td.minical_past_month` for days of previous month
              - `td.minical_future_month` for days of next month
              - `td.minical_disabled` for unselectable days
              - `td.minical_selected` for the currently selected day
              - `td.minical_highlighted` for the currently highlighted day
                - `a`

## Options

- `offset`: positions calendar relative to the bottom-left corner of the input
  - `x` defaults to 0
  - `y` defaults to 5
- `trigger`: A function (run in the context of the minical-enhanced input) that returns a jQuery object of the desired trigger, or a string selector to specify a trigger element (like the calendar icon in the examples). The string selector can be a child or sibling of the element on which you call `.minical()`.
- `align_to_trigger`: (boolean) align the calendar to the trigger instead of the input. Defaults to `true`.
- `read_only`: makes the date/text input only modifiable by the calendar. Defaults to `true`.
- `date_format`: allows you to output a custom date format from the chosen Date object (defaults to MM/DD/YYYY)
- `from` and `to`: date objects specifying min and max valid dates.
- `date_changed`: callback that fires after the input or dropdowns have changed value.
- `month_drawn`: callback that fires when a new month is rendered.
- `appendCalendarTo`: function; should return jQuery element. Minical appends to `body` by default.

## Initializing

Javascript date parsing is a pain, and it's entirely possible that the date format you want displayed in your input is not one that JS can parse. If your page ever loads with a value already in the Minical-enabled input, Minical needs a Javascript-parseable date in order to set its initial value properly.

In this case, you can just output a `data-minical-initial` attribute on your input element, give it a Javascript-parseable string, and Minical will initialize using that attribute instead of attempting to parse the value of your input.

Either string or integer formats will work, but the most foolproof `data-minical-initial` attribute seems to be JavaScript's conversion of a date object to an integer (e.g. `+my_date_object`):

```
<input data-minical-initial="1386967591204">
```

## What about dropdowns?

If you've been using Minical a while, you might notice that it no longer supports month/day/year in `<select>` tags. That feature caused a ton of complexity and while it seemed like a good idea at the time, I've literally never used it. Version 0.7 includes a _ton_ of code cleanup, and I stripped the dropdown support in the process.