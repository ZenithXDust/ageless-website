/* ==========================================================================
   PLACEHOLDERS

   Some facts about this business are not decided yet: the package names, the
   prices, the exact registered legal name. Rather than invent them, or leave
   a hole in the page, every undecided fact is written as a span carrying two
   things:

     - a token, so it can be found later
     - real fallback text that is true and publishable on its own

       <span class="tbd" data-tbd="PACKAGE_1_PRICE">Call for pricing</span>

   The fallback is the important half. If nobody ever fills that token in, a
   visitor still reads an honest, correct sentence. A raw token, a bare dollar
   sign, or the word TODO must never reach a reader.

   This file exists so that the person filling them in can SEE them. It marks
   every placeholder in amber with a dashed outline, but only when the page is
   being looked at locally: opened straight off the disk, or served from
   localhost. On the live domain this file does nothing at all, and the
   fallback text reads as ordinary copy, which is exactly what it is.

   THIS IS THE SAME IDEA AS js/photos.js

   That file reserves a space for a photograph and, when the photograph does
   not exist yet, removes the space rather than showing a broken image icon.
   The page is complete either way. This file applies the same rule to words
   instead of pictures: the page is complete and correct whether or not the
   real number has been decided, and the unfinished state is visible to the
   owner without ever being visible to a visitor.

   To fill one in: look the token up in PLACEHOLDERS.md, then replace the
   whole span with the real text. Running tools/check-tbd.sh lists everything
   still outstanding, with the file and line number of each.
   ========================================================================== */

(function () {
  "use strict";

  // Is this a local copy, or the published site?
  //
  // Three situations count as local:
  //
  //   file:       the HTML file was opened by double clicking it. Browsers
  //               report an empty hostname in that case, which is why the
  //               empty string is checked as well.
  //   localhost   a local web server, for example python -m http.server
  //   127.0.0.1   the same machine by number. ::1 is the IPv6 spelling, and
  //               some browsers report it wrapped in square brackets.
  //
  // Anything else, which in practice means the published GitHub Pages
  // address, counts as live, and this file stops here without touching the
  // page at all.
  var host = window.location.hostname;

  var isLocal =
    window.location.protocol === "file:" ||
    host === "" ||
    host === "localhost" ||
    host === "127.0.0.1" ||
    host === "::1" ||
    host === "[::1]";

  if (!isLocal) {
    return;
  }

  // The amber marking itself lives in css/style.css, under the selector
  // `html.tbd-show .tbd`. This line is the only thing that switches it on.
  //
  // Doing it in that order matters, and it is worth being clear about why.
  // `.tbd` on its own has no styling whatsoever. So if this script fails to
  // load, is blocked by an extension, or the visitor has JavaScript turned
  // off, the result is plain unmarked text on the live site rather than amber
  // highlighting on a customer's screen. The failure mode points the safe
  // way, which is the same reason photos.js removes a slot instead of leaving
  // a broken image behind.
  document.documentElement.classList.add("tbd-show");

  var marks = document.querySelectorAll(".tbd");

  Array.prototype.forEach.call(marks, function (mark) {
    var token = mark.getAttribute("data-tbd") || "UNNAMED";

    // Name each placeholder on hover, so that working out which token is
    // which does not mean opening the HTML. This only ever runs locally, so
    // it cannot affect what a visitor sees or what a screen reader announces
    // on the live site.
    if (!mark.getAttribute("title")) {
      mark.setAttribute(
        "title",
        "Placeholder " + token + ". Fallback text shown. See PLACEHOLDERS.md."
      );
    }
  });

  // A count in the console, so it is obvious at a glance whether the page
  // being looked at still has anything outstanding on it.
  if (window.console && window.console.log) {
    window.console.log(
      "[placeholders] " +
        marks.length +
        " on this page. Run tools/check-tbd.sh for the full list."
    );
  }
})();
