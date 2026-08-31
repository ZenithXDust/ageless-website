/* ==========================================================================
   BOOKING PICKER
   Builds the day and time choices on booking.html and keeps the summary panel
   in step with whatever the visitor has chosen.

   An important limitation, stated plainly because it shapes everything below:
   this website has no server. Nothing typed into a page like this can be
   stored or emailed anywhere on its own. So this picker does not book an
   appointment. It helps someone decide exactly what they want, then hands them
   a phone number with their choice written out beside it, so the call takes
   thirty seconds instead of five minutes. The page says so in plain words
   rather than pretending otherwise.

   If you later want real booking that confirms itself, that needs either a
   booking service or a small back end, and it is a decision worth making on
   purpose.
   ========================================================================== */

(function () {
  "use strict";

  var form = document.querySelector("[data-booking]");
  if (!form) return;

  // A form with nowhere to send to would reload the page if it were ever
  // submitted, wiping the visitor's choices. It cannot happen today, because
  // there is no submit button and no text field, but that would change the
  // moment anybody adds one. Stopping it here means it can never happen.
  form.addEventListener("submit", function (event) {
    event.preventDefault();
  });

  // ---------------------------------------------------------------------
  // The visitor's three choices live here. Everything else is drawn from it.
  // ---------------------------------------------------------------------
  var choice = { service: null, day: null, time: null };

  var DAYS_AHEAD = 14;          // Two weeks of dates, all seven days a week
  var FIRST_HOUR = 9;           // 9:00 AM
  var LAST_HOUR = 21;           // 9:00 PM

  var DOW = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
  var MON = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
             "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
  var DOW_FULL = ["Sunday", "Monday", "Tuesday", "Wednesday",
                  "Thursday", "Friday", "Saturday"];
  var MON_FULL = ["January", "February", "March", "April", "May", "June",
                  "July", "August", "September", "October", "November", "December"];

  var dayList = form.querySelector("[data-day-list]");
  var timeList = form.querySelector("[data-time-list]");
  var summary = form.querySelector("[data-summary]");
  var callLink = form.querySelector("[data-call-link]");
  var copyBtn = form.querySelector("[data-copy]");
  var copyNote = form.querySelector("[data-copy-note]");

  // ---------------------------------------------------------------------
  // Turn an hour number into something a person reads, e.g. 13 becomes 1:00 PM
  // ---------------------------------------------------------------------
  function hourLabel(hour) {
    var suffix = hour < 12 ? "AM" : "PM";
    var display = hour % 12;
    if (display === 0) display = 12;
    return display + ":00 " + suffix;
  }

  // ---------------------------------------------------------------------
  // Build the next fourteen days as buttons.
  // aria-pressed is what tells a screen reader which day is currently chosen.
  // ---------------------------------------------------------------------
  function buildDays() {
    var today = new Date();
    for (var i = 0; i < DAYS_AHEAD; i++) {
      var date = new Date(today.getFullYear(), today.getMonth(), today.getDate() + i);

      var li = document.createElement("li");
      var btn = document.createElement("button");
      btn.type = "button";
      btn.className = "day-btn";
      btn.setAttribute("aria-pressed", "false");

      // The visible label is short. The spoken label is the full date, so a
      // screen reader says "Monday, 25 August" and not "Mon 25 Aug".
      var full = DOW_FULL[date.getDay()] + ", " + date.getDate() + " " + MON_FULL[date.getMonth()];
      btn.setAttribute("aria-label", i === 0 ? full + " (today)" : full);

      btn.innerHTML =
        '<span class="dow">' + (i === 0 ? "Today" : DOW[date.getDay()]) + "</span>" +
        '<span class="dom">' + date.getDate() + "</span>" +
        '<span class="mon">' + MON[date.getMonth()] + "</span>";

      btn.addEventListener("click", (function (label, button) {
        return function () {
          choice.day = label;
          markPressed(dayList, button);
          render();
        };
      })(full, btn));

      li.appendChild(btn);
      dayList.appendChild(li);
    }
  }

  // ---------------------------------------------------------------------
  // Build the hourly slots from 9:00 AM to 9:00 PM
  // ---------------------------------------------------------------------
  function buildTimes() {
    for (var hour = FIRST_HOUR; hour <= LAST_HOUR; hour++) {
      var label = hourLabel(hour);

      var li = document.createElement("li");
      var btn = document.createElement("button");
      btn.type = "button";
      btn.className = "time-btn";
      btn.setAttribute("aria-pressed", "false");
      btn.textContent = label;

      btn.addEventListener("click", (function (value, button) {
        return function () {
          choice.time = value;
          markPressed(timeList, button);
          render();
        };
      })(label, btn));

      li.appendChild(btn);
      timeList.appendChild(li);
    }
  }

  // Only one button in a group can be pressed at a time.
  function markPressed(container, pressedButton) {
    var buttons = container.querySelectorAll("button");
    for (var i = 0; i < buttons.length; i++) {
      buttons[i].setAttribute("aria-pressed", buttons[i] === pressedButton ? "true" : "false");
    }
  }

  // ---------------------------------------------------------------------
  // Service type. These are real radio inputs, so arrow keys move between them
  // and a screen reader announces them as one group without any help from us.
  // ---------------------------------------------------------------------
  var radios = form.querySelectorAll('input[name="service"]');
  for (var r = 0; r < radios.length; r++) {
    radios[r].addEventListener("change", function (event) {
      choice.service = event.target.getAttribute("data-label");
      render();
    });
  }

  // ---------------------------------------------------------------------
  // Write the current choice into the summary, and into the phone link.
  // The summary sits inside an aria-live region on the page, which means a
  // screen reader reads out each change as it happens rather than leaving the
  // person to go hunting for what moved.
  // ---------------------------------------------------------------------
  function plainSummary() {
    return "Ageless booking request. " +
      "Service: " + (choice.service || "not chosen") + ". " +
      "Day: " + (choice.day || "not chosen") + ". " +
      "Time: " + (choice.time || "not chosen") + " Eastern.";
  }

  function render() {
    var rows = [
      { label: "Service", value: choice.service },
      { label: "Day", value: choice.day },
      { label: "Time", value: choice.time ? choice.time + " Eastern" : null }
    ];

    var html = "<dl>";
    rows.forEach(function (row) {
      html += "<dt>" + row.label + "</dt>";
      html += row.value
        ? "<dd>" + row.value + "</dd>"
        : '<dd class="incomplete">Not chosen yet</dd>';
    });
    html += "</dl>";
    summary.innerHTML = html;

    // The phone link works from the very first moment, chosen slot or not.
    // Someone who would rather just talk to a person should never be made to
    // finish a three step picker first.
    if (callLink) {
      callLink.textContent = isComplete()
        ? "Call to confirm this time"
        : "Call 437-457-5307";
    }
  }

  function isComplete() {
    return choice.service && choice.day && choice.time;
  }

  // ---------------------------------------------------------------------
  // Copy to clipboard, so the details can be pasted into a text message.
  // The clipboard interface is blocked in some browsers when a page is opened
  // straight off the hard drive rather than from a web address, so this is
  // wrapped in a try and falls back to selecting the text by hand.
  // ---------------------------------------------------------------------
  if (copyBtn) {
    copyBtn.addEventListener("click", function () {
      var text = plainSummary();
      var done = function (ok) {
        copyNote.textContent = ok
          ? "Copied. You can paste it into a text message."
          : "Copy did not work in this browser. Select the details above and copy them by hand.";
      };
      try {
        if (navigator.clipboard && navigator.clipboard.writeText) {
          navigator.clipboard.writeText(text).then(function () { done(true); },
                                                   function () { done(false); });
        } else {
          done(false);
        }
      } catch (error) {
        done(false);
      }
    });
  }

  buildDays();
  buildTimes();
  render();
})();
