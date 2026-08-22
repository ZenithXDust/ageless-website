/* ==========================================================================
   MOBILE MENU
   The only job of this file is to open and close the navigation on a phone.

   Two things worth knowing if you are reading this to learn:

   1. The menu is closed by CSS, not by JavaScript. All this script does is add
      or remove the class "is-open". If JavaScript fails to load, the CSS falls
      back to showing the menu rather than hiding it forever, so the site is
      never left with navigation the visitor cannot reach.

   2. aria-expanded is the part that matters for accessibility. A sighted
      person can see whether the menu is open. A screen reader user cannot, so
      the button has to say so out loud, and that attribute is how it does it.
   ========================================================================== */

(function () {
  "use strict";

  var toggle = document.querySelector(".nav-toggle");
  var nav = document.querySelector(".site-nav");

  // If either piece is missing, do nothing rather than throwing an error.
  if (!toggle || !nav) return;

  function setOpen(open) {
    nav.classList.toggle("is-open", open);
    toggle.setAttribute("aria-expanded", open ? "true" : "false");
    toggle.textContent = open ? "Close" : "Menu";
  }

  // Start closed. This runs only when the script loads, which means a visitor
  // without JavaScript never has the menu hidden from them.
  setOpen(false);

  toggle.addEventListener("click", function () {
    var isOpen = toggle.getAttribute("aria-expanded") === "true";
    setOpen(!isOpen);
  });

  // Escape closes the menu and puts keyboard focus back on the button, so the
  // person is not left stranded somewhere in the page.
  document.addEventListener("keydown", function (event) {
    if (event.key === "Escape" && toggle.getAttribute("aria-expanded") === "true") {
      setOpen(false);
      toggle.focus();
    }
  });
})();
