(function($) {

    function display_match_error(e) {
        alert("Relaxer error: " + e.message);
    }

    function display_match_results(e) {
        $("#result").empty();

        for (var i = 0; i < e.results.length; i++) {
            var output = "";
            var match = e.results[i];
            var pos = 0;
            for (var m = 0; m < match.matches.length; m++) {
                output += e.string.substring(pos, match.matches[m].from);
                output += '<div class="match num_' + (m + 1) + '">';
                pos = match.matches[m].from;
                for (var g = 0; g < match.matches[m].groups.length; g++) {
                    var group = match.matches[m].groups[g];
                    output += e.string.substring(pos, group.from);
                    output += '<span class="group num_' + (g + 1) + '">';
                    output += e.string.substring(group.from, group.to);
                    output += '</span>';
                    pos = group.to;
                }
                output += e.string.substring(pos, match.matches[m].to);
                output += '</div>';
                pos = match.matches[m].to;
            }
            output += e.string.substring(pos, e.string.length);
            $("#result").append(output);
            $("#result").append('<br />');
        }

        // Install popovers on created elements
        activate_popovers($('#result'));
    }

    function activate_popovers(obj) {
        $('.group', obj).twipsy({
            live: true,
            title: get_popover_text,
            offset: 5,
            html: true
        });

        $('.group', obj).mouseover(highlight_group);
        $('.group', obj).mouseout(unhighlight_group);
    };

    function highlight_group(e) {
        $(this).addClass('highlighted');
    }

    function unhighlight_group(e) {
        $(this).removeClass('highlighted');
    }

    function get_popover_text(item) {
        var classes = $(this).attr('class');
        var match = classes.match(/(^|\s)num_(\d+)/);
        if (match) {
            return "Text matched by group.<br />Content in variable $" + match[2];
        }
        return "JavaScript error";
    }

    $(function() {
        $(document).bind('relaxer_match_done', display_match_results);
        $(document).bind('relaxer_match_error', display_match_error);
    });

})(jQuery);
