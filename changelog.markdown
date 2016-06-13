# Changelog

## 0.9.5

- Allow for negative values
- Fix assignment of default trigger (#10)
- Fix DST timezone offset (#12)

## 0.9.4

- namespace `select` external method's change event so it doesn't collide with regular change event

## 0.9.3

- add simpler `select` external method

## 0.9.2

- add `show_clear_link` option

## 0.9.1

- Fix issue with Minical hiding properly when tabbing through inputs

## 0.9

- refactor Sass variables completely
- remove legacy .js and .css files
- remove image-based next & prev month icons, replace with characters

## 0.8

- add `inline` option to append the calendar directly after the input instead of as a popover

## 0.7.2

- add explicit $el.minical(`clear`) for clearing input
- add option to disable automatically initializing the field with a date

## 0.7.1

- tiny but necessary bugfix: rerender selected day properly on month switch

## 0.7.0

- big cleanup & rewrite, improving readability and efficiency a bunch
- add support for $el.minical('destroy')
- add 'show.minical' and 'hide.minical' events on calendar element
- remove all functionality related to <select> tag support

## 0.6.1

- supports `data-minical-from` and `data-minical-to` attributes for setting selectable date bounds
- prevent keyboard from selecting disabled days
- added default styles for disabled days
- fix 1-day-off bug with selecting new month when date limits are set right at the end of a calendar
- added this damn Changelog

## < 0.6.1

- here be dragons
