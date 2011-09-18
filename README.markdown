# Jquery.minical

## Usage

`$("my_text_input").minical();`

## Options

- `start_date`: defaults to today
- `offset`: relative to bottom left of input
  - `x`
  - `y`
- `date_format(Date)`: output of date object to text input (defaults to m/d/yyyy)

## Calendar construction

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
