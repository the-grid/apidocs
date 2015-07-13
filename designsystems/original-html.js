
// Just wrap each item in a section, and output the HTML as provided by API
// No CSS/styling is performed
window.polySolvePage = function(page, options, callback) {
    var html = "";
    var ind = "  ";
    page.content.forEach(function(item) {
        html += ind+"<section>"
        item.blocks.forEach(function(block) {
            html += ind+ind+block.html;
        });
        html += ind+"</section>"
    }
    var err = null;
    var details = {};
    return callback(err, html, details);
};
