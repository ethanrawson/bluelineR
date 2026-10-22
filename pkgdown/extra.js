// The README's logo has a version for GitHub's dark mode. This site is always
// light, so it keeps the light one.
document.addEventListener("DOMContentLoaded", function () {
  document.querySelectorAll("picture source[media*='dark']").forEach(function (s) { s.remove(); });
});
