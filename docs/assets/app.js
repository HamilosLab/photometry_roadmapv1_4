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

  function asList(x) {
    return Array.isArray(x) ? x : [];
  }

  function toEntries(data) {
    var out = [];
    var cls = data.class || {};

    asList(cls.properties).forEach(function (p) {
      out.push({
        type: "property",
        name: p.name,
        display: cls.name + "." + p.name,
        summary: p.description || "",
        params: [],
        returns: [],
        notes: [],
        aiGenerated: !!p.aiGenerated,
      });
    });

    asList(cls.methods).forEach(function (m) {
      out.push({
        type: "method",
        name: m.name,
        display: m.signature || (m.name + "(...)"),
        summary: m.description || "",
        params: asList(m.params),
        returns: asList(m.returns),
        notes: asList(m.notes),
        aiGenerated: !!m.aiGenerated,
      });
    });

    asList(data.functions).forEach(function (f) {
      out.push({
        type: "function",
        name: f.name,
        display: f.name + "()",
        file: f.file,
        summary: f.description || "",
        params: [],
        returns: [],
        notes: [],
        aiGenerated: !!f.aiGenerated,
      });
    });

    return out;
  }

  function searchText(e) {
    var parts = [e.name, e.display, e.summary];
    e.params.forEach(function (p) { parts.push(p.name, p.description); });
    e.returns.forEach(function (r) { parts.push(r.name, r.description); });
    parts = parts.concat(e.notes);
    return parts.filter(Boolean).join(" ");
  }

  function renderSummary(summary) {
    if (!summary) {
      return '<p class="entry-summary empty">No description available.</p>';
    }
    return summary
      .split("\n")
      .map(function (line) { return line.trim(); })
      .filter(Boolean)
      .map(function (line) { return '<p class="entry-summary">' + escapeHtml(line) + "</p>"; })
      .join("");
  }

  function renderParamList(title, items) {
    if (!items.length) return "";
    var rows = items
      .map(function (item) {
        return (
          '<dt><code>' + escapeHtml(item.name) + "</code></dt>" +
          '<dd>' + escapeHtml(item.description || "") + "</dd>"
        );
      })
      .join("");
    return (
      '<div class="entry-section"><h4>' + title + "</h4><dl class=\"entry-dl\">" + rows + "</dl></div>"
    );
  }

  function renderNotes(notes) {
    if (!notes.length) return "";
    var items = notes.map(function (n) { return "<li>" + escapeHtml(n) + "</li>"; }).join("");
    return '<div class="entry-section"><h4>Notes</h4><ul class="entry-notes">' + items + "</ul></div>";
  }

  function renderEntry(e) {
    var badge = e.aiGenerated
      ? '<span class="badge-ai" title="Drafted by AI from source inspection; verify before relying on it.">AI-drafted</span>'
      : "";
    var fileTag = e.file ? '<span class="entry-file">' + escapeHtml(e.file) + "</span>" : "";

    return (
      '<div class="entry">' +
      '<div class="entry-header">' +
      '<span class="entry-tag ' + e.type + '">' + e.type + "</span>" +
      '<span class="entry-name">' + escapeHtml(e.display) + "</span>" +
      fileTag +
      badge +
      "</div>" +
      renderSummary(e.summary) +
      renderParamList("Parameters", e.params) +
      renderParamList("Returns", e.returns) +
      renderNotes(e.notes) +
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
      entries = toEntries(data).map(function (e) {
        e._search = searchText(e);
        return e;
      });
      fuse = new Fuse(entries, {
        keys: ["name", "display", "_search"],
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
