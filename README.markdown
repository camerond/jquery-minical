# Jquery.minical

## Usage

- `$("my_text_input").minical();`

## Requirements

- jQuery, [jquery.minical.js](htts://github.com/camerond/jquery-minical/blob/master/public/javascript/jquery.minical.js), [jquery.minical.sass](https://github.com/camerond/jquery-minical/blob/master/views/stylesheets/jquery.minical.sass) (or the [generated css](http://localhost:9292/stylesheets/jquery.minical.css)), and [jquery_minical_icons.png](https://github.com/camerond/jquery-minical/blob/master/public/images/jquery_minical_icons.png). [See the source on GitHub](https://github.com/camerond/jquery-minical).

## Options

- `start_date` (Date object) defaults to today
- `selected_day` (Date object) allows you to predefine a selected day
- `offset` relative to bottom left of input
  - `x`
  - `y`
- `date_format(Date)` output of date object to text input (defaults to m/d/yyyy)

## Why I made this instead of using the [jQuery UI Datepicker](http://jqueryui.com/demos/datepicker/):

### Usability issues.

jQuery UI's datepicker appears when you use `tab` to highlight the input, but isn't actually keyboard-accessible. It allows you to type (numbers only) in the input, but its date-parsing is literal to a fault (type 5/1/111 and you get May 1, 111).

Minical disables the text input while the calendar is visible, and doesn't appear on tab, so it's (appropriately) not utilized for keyboard-only browsing.

### Portability issues.

The UI datepicker requires a bunch of dependencies and the class names are nigh impetrenable. We ([Hashrocket](http://hashrocket.com)) don't use a lot of jQuery UI in projects, so we needed something light and independent. Minical is reliant upon one 16x32 PNG (for the back/forward buttons) and a SASS file (complete with color variables for ease of use).

If you don't want to use SASS, you can always just pull the [generated stylesheet](http://jquery-minical.heroku.com/stylesheets/jquery.minical.css).

Here's the DOM construction of Minical:

- `ul#minical` contains all elements
  - `li` - contains each month, with class `.minical_jan` and so on for each month.
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
              - `td.minical_previous_day` for shown days of previous month
              - `td.minical_upcoming_day` for shown days of next month
              - `td.minical_day` for current day
              - `td.minical_selected` for selected day
                - `a`

### Can you make it animate / display more than one month / select a range / display on the page permanently / select the time also / fix me a delicious omelet?

I'll be adding features as required by Hashrocket projects, and don't have any intention of reaching feature parity with a robust platform like jQuery UI. Just use the Datepicker if you need that stuff (I'm not certain whether it makes omelets, however).