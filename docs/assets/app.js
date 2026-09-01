(function () {
  "use strict";

  var resultsEl = document.getElementById("results");
  var searchBoxEl = document.getElementById("search-box");
  var countEl = document.getElementById("result-count");
  var entries = [];
  var fuse = null;

  function escapeHtml(str) {
    return String(str)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;");
  }

  function toEntries(data) {
    var out = [];
    var cls = data.class || {};

    (cls.properties || []).forEach(function (p) {
      out.push({
        type: "property",
        name: p.name,
        display: cls.name + "." + p.name,
        description: p.description || "",
      });
    });

    (cls.methods || []).forEach(function (m) {
      out.push({
        type: "method",
        name: m.name,
        display: m.signature || (m.name + "(...)"),
        description: m.description || "",
      });
    });

    (data.functions || []).forEach(function (f) {
      out.push({
        type: "function",
        name: f.name,
        display: f.name + "()",
        file: f.file,
        description: f.description || "",
      });
    });

    return out;
  }

  function renderEntry(e) {
    var descClass = e.description ? "entry-description" : "entry-description empty";
    var descText = e.description ? escapeHtml(e.description) : "No description available.";
    var fileTag = e.file ? '<span class="entry-file">' + escapeHtml(e.file) + "</span>" : "";

    return (
      '<div class="entry">' +
      '<div class="entry-header">' +
      '<span class="entry-tag ' + e.type + '">' + e.type + "</span>" +
      '<span class="entry-name">' + escapeHtml(e.display) + "</span>" +
      fileTag +
      "</div>" +
      '<div class="' + descClass + '">' + descText + "</div>" +
      "</div>"
    );
  }

  function render(list) {
    countEl.textContent = list.length + " of " + entries.length + " entries";
    resultsEl.innerHTML = list.map(renderEntry).join("");
  }

  function onSearchInput() {
    var query = searchBoxEl.value.trim();
    if (!query) {
      render(entries);
      return;
    }
    var results = fuse.search(query).map(function (r) { return r.item; });
    render(results);
  }

  fetch("api-data.json")
    .then(function (resp) { return resp.json(); })
    .then(function (data) {
      entries = toEntries(data);
      fuse = new Fuse(entries, {
        keys: ["name", "display", "description"],
        threshold: 0.35,
        ignoreLocation: true,
      });
      render(entries);
      searchBoxEl.addEventListener("input", onSearchInput);
    })
    .catch(function (err) {
      resultsEl.innerHTML =
        '<p class="muted">Could not load api-data.json (' + escapeHtml(err.message) +
        "). Run tools/docgen/generate_api_json.m in MATLAB to generate it.</p>";
    });
})();
