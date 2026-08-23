/* ==========================================================================
   PHOTO SLOTS

   The site has places reserved for photographs. This file checks whether the
   photo file actually exists yet, and:

     - if it does, puts the photo on the page
     - if it does not, removes the empty space entirely

   That second part is the whole point. Without it, a reserved space for a
   photo that has not been taken yet shows a broken image icon, which looks
   worse than having no photo at all. This way the page is complete either
   way, and adding a photograph later means dropping a correctly named file
   into the images folder. No HTML has to be edited.

   To add one: save the file into images/ using the exact name listed in
   PHOTOS.md, and it appears the next time the page loads.
   ========================================================================== */

(function () {
  "use strict";

  var slots = document.querySelectorAll("[data-photo]");

  Array.prototype.forEach.call(slots, function (slot) {
    var file = slot.getAttribute("data-photo");
    var description = slot.getAttribute("data-alt") || "";

    // A detached Image is used purely as a test: it never touches the page
    // unless the file loads successfully.
    var probe = new Image();

    probe.onload = function () {
      var img = document.createElement("img");
      img.src = "images/" + file;
      img.alt = description;
      img.className = "photo";
      // The real dimensions are known now, so setting them stops the page
      // jumping about as the picture arrives.
      img.width = probe.naturalWidth;
      img.height = probe.naturalHeight;
      slot.appendChild(img);
      slot.hidden = false;
    };

    probe.onerror = function () {
      // No such file yet. Take the reserved space back out of the page.
      var band = slot.closest ? slot.closest(".photo-band") : null;
      if (slot.parentNode) slot.parentNode.removeChild(slot);

      // Some slots sit inside their own full-width section. Removing just the
      // picture would leave that section behind as a band of empty padding,
      // so if nothing is left inside it, the section goes too.
      if (band && !band.querySelector(".photo-slot") && band.parentNode) {
        band.parentNode.removeChild(band);
      }
    };

    probe.src = "images/" + file;
  });
})();
