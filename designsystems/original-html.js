
// Just wrap each item in a section, and output the HTML as provided by API
// No CSS/styling is performed
window.polySolvePage = function(page, options, callback) {
    var html = "<!doctype html>\n<html><head><meta charset=\"utf-8\"></head><body>";
    var line = "\n";
    var ind = "  ";
    page.items.forEach(function(item) {
        html += line+ind+"<section>";
        item.content.forEach(function(block) {
            html += line+ind+ind+block.html;
        });
        html += line+ind+"</section>"
    });
    html += line+"</body></html>"
    var err = null;
    var details = {};
    return callback(err, html, details);
};
