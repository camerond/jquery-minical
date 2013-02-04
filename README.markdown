# jQuery.minical

## Usage

Call `.minical()` on a text (or date) input, or the element containing a set of month/day/year dropdowns.

## Requirements

- jQuery (1.7+)
- [jquery.minical.coffee](https://github.com/camerond/jquery-minical/blob/master/views/coffeescript/jquery.minical.coffee) (or the [generated javascript](https://github.com/camerond/jquery-minical/blob/master/public/javascript/jquery.minical.js))
- [jquery.minical.sass](https://github.com/camerond/jquery-minical/blob/master/views/stylesheets/jquery.minical.sass) (or the [generated css](http://jquery-minical.heroku.com/stylesheets/jquery.minical.css))
- [jquery_minical_icons.png](https://github.com/camerond/jquery-minical/blob/master/public/images/jquery_minical_icons.png)

Feel free to [check out the source on GitHub](https://github.com/camerond/jquery-minical).

## Why It's Awesome

Minical is teeny (~4KB minified and gzipped), with no dependencies other than its icon PNG and stylesheet (which has SASS variables for easy customization).

It has full keyboard support (press enter to open/close the calendar, arrows to choose a day, enter to select a day) and also defaults to make the associated input read-only, so its value can only be changed by the date format specified in the plugin. (It also works great in iOS, with just enough touch event handling to behave properly.)

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
              - `td.minical_day` for each day
              - `td.minical_day_[m_d_yYYY]` a unique class (e.g. `minical_day_1_1_2011`) for each day
              - `td.minical_today` for the current day
              - `td.minical_past_month` for days of previous month
              - `td.minical_future_month` for days of next month
              - `td.minical_disabled` for unselectable days
              - `td.minical_selected` for the currently selected day in inputs/dropdowns
              - `td.minical_highlighted` for the currently highlighted day
                - `a`

## Options

- `offset`: positions calendar relative to the bottom-left corner of the input
  - `x` defaults to 0
  - `y` defaults to 5
- `trigger`: a string selector to specify a trigger element (like the calendar icon in the examples). It can be a child or sibling of the element on which you call `.minical()`.
- `align_to_trigger`: set to `true` to align the calendar to the trigger instead of the input. (Defaults to true if a trigger is available)
- `read_only`: makes the date/text input only modifiable by the calendar (defaults to true)
- `date_format`: allows you to output a custom date format from the chosen Date object (defaults to MM/DD/YYYY)
- `from` and `to`: date objects specifying min and max valid dates (defaults to null, autodetected if using dropdowns)
- `date_changed`: callback that fires after the input or dropdowns have changed value
- `month_drawn`: callback that fires when a new month is rendered
- `appendCalendarTo`: should return a jQuery object; the calendar element will attach to this (defaults to `<body>`)

## Attributes

Javascript date parsing is a pain, and it's entirely possible that the date format you want displayed in your input is not one that JS can parse. If your page ever loads with a value already in the Minical-enabled input, Minical needs a Javascript-parseable date in order to set its initial value properly. In this case, you can just output a `data-minical-initial` attribute on your input element, give it a Javascript-parseable string, and Minical will initialize using that attribute instead of attempting to parse the value of your input.

### If you're using `<select>` tags (like in the second example above):

- `dropdowns.month`, `dropdowns.day`, `dropdowns.year` string selectors specifying each select tag

## Sweet! Can you make it animate / display more than one month / select a range / display on the page permanently / select the time also / fix me a delicious omelet?

I'll be adding features as required by Hashrocket projects, and don't have any intention of reaching feature parity with a robust platform like jQuery UI. Just use the jQuery UI Datepicker if you need that stuff (I'm not certain whether it makes omelets, however).
