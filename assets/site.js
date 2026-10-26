// Picks the page language like the app does: an explicit choice first
// (?lang= or the picker), otherwise the browser's language when the app
// supports it, otherwise English. Loaded in <head> without defer so the right
// language is shown on the first paint; style.css hides the other ones.
(function () {
  var SUPPORTED = ["en", "de", "fr", "uk", "es", "ja", "pt"];
  var STORAGE_KEY = "training-tracker-lang";
  var root = document.documentElement;

  function supported(code) {
    if (!code) return null;
    var base = String(code).toLowerCase().split(/[-_]/)[0];
    return SUPPORTED.indexOf(base) >= 0 ? base : null;
  }

  function stored() {
    try { return localStorage.getItem(STORAGE_KEY); } catch (e) { return null; }
  }

  function detect() {
    var query = null;
    try { query = new URLSearchParams(location.search).get("lang"); } catch (e) {}
    var explicit = supported(query) || supported(stored());
    if (explicit) return explicit;
    var list = navigator.languages && navigator.languages.length ? navigator.languages : [navigator.language];
    for (var i = 0; i < list.length; i++) {
      var match = supported(list[i]);
      if (match) return match;
    }
    return "en";
  }

  function apply(lang) {
    root.setAttribute("data-lang", lang);
    root.setAttribute("lang", lang);
    var title = document.querySelector('[data-title] > [lang="' + lang + '"]');
    if (title) document.title = title.textContent;
    var picker = document.getElementById("language");
    if (picker) picker.value = lang;
  }

  root.classList.add("js");
  apply(detect());

  document.addEventListener("DOMContentLoaded", function () {
    apply(root.getAttribute("data-lang"));
    var picker = document.getElementById("language");
    if (!picker) return;
    picker.addEventListener("change", function () {
      apply(picker.value);
      try { localStorage.setItem(STORAGE_KEY, picker.value); } catch (e) {}
      try {
        var url = new URL(location.href);
        url.searchParams.delete("lang");
        history.replaceState(null, "", url);
      } catch (e) {}
    });
  });
})();
