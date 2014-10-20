# jQuery.minical

## Usage

Include [jquery.minical.coffee](https://github.com/camerond/jquery-minical/blob/master/source/javascripts/jquery.minical.js.coffee) and [jquery.minical.sass](https://github.com/camerond/jquery-minical/blob/master/source/stylesheets/jquery.minical.css.sass), then:

`$my_cool_input.minical()`

Feel free to [check out the source on GitHub](https://github.com/camerond/jquery-minical).

## Why It's Awesome

Minical is teeny (~300 lines of Coffeescript), and has no dependencies other than jQuery. It has full keyboard support. It's an easy way to get your users to input a readable, parsable date value.

## Skinning

Minical exposes a few Sass variables for easy skinning:

- `$mc_font-family`
- `$mc_background`
- `$mc_border`
- `$mc_text`
- `$mc_highlight`

## Initializing

JavaScript date parsing is a pain, and it's entirely possible that the date format you want displayed in your input won't be one that JS can parse. If your page ever loads with a value already in the Minical-enabled input, Minical needs a JavaScript-parseable date in order to set its initial value properly.

In this case, you can just output a `data-minical-initial` attribute on your input element, give it a Javascript-parseable string, and Minical will initialize using that attribute instead of attempting to parse the value of your input. (Minical will also write that value to the input via the `date_format` method, so you don't even need to set an initial value for the input itself.)

Either string or integer formats will work, but the most foolproof `data-minical-initial` attribute seems to be JavaScript's conversion of a date object to an integer (e.g. `+my_date_object`). This renders a value of `12/13/2013` using the default date_format method:

```
<input data-minical-initial="1386967591204">
```

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
- `initialize_with_date`: defaults to true; Minical will write the initial date to the input (either via data-minical-initial or just by displaying today)
- `show_clear_link`: defaults to false; displays a 'clear date' link in the calendar popout

