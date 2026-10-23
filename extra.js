// The site is dark, so it shows the logo with the white R: the README's
// <picture> drops its light fallback, and the logo beside page titles (the
// light one, as the README on GitHub uses) is swapped for the dark one.
document.addEventListener("DOMContentLoaded", function () {
  document.querySelectorAll("picture").forEach(function (p) {
    var dark = p.querySelector("source[media*='dark']"), img = p.querySelector("img");
    if (dark && img) { img.src = dark.getAttribute("srcset"); dark.remove(); }
  });
  document.querySelectorAll("img.logo, img[src$='figures/logo.png']").forEach(function (img) {
    var src = img.getAttribute("src");
    img.src = /figures\/logo\.png$/.test(src) ? src.replace(/logo\.png$/, "logo-dark.png")
                                             : src.replace(/logo\.png$/, "reference/figures/logo-dark.png");
  });
});
