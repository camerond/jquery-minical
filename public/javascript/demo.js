$(function() {
  $("#input_example :text").minical({
    trigger: "span.calendar_icon"
  });
  $("#dropdown_example dd").minical({
    trigger: "span.calendar_icon",
    dropdowns: {
      "month": "select.month",
      "day": "select.day",
      "year": "select.year"
    }
  });
});