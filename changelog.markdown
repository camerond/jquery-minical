# Changelog

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
