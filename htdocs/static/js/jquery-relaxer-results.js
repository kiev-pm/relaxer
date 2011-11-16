(function($) {

    function display_match_error(e) {
        // TODO: show pretty error message somewhere
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

        // throw additional events
        $('.group', obj).mouseover(highlight_group);
        $('.group', obj).mouseout(unhighlight_group);
    };

    function highlight_group(e) {
        var event_data = get_match_elem_info($(this));

        // TODO: match / replace
        event_data['type'] = "match";

        $(document).trigger('relaxer_match_highlight', event_data);
    }

    function unhighlight_group(e) {
        var event_data = get_match_elem_info($(this));

        // TODO: match / replace
        event_data['type'] = "match";

        $(document).trigger('relaxer_match_unhighlight', event_data);
    }

    function get_match_elem_info(elem) {
        // TODO: Store match number and group name in right way
        var elem_data = {type: "match"};

        var num_match = elem.attr('class').match(/(^|\s)num_(\d+)(\s|$)/);
        if (num_match) {
            elem_data['number'] = num_match[2];
        }

        var group_match = elem.attr('class').match(/(^|\s)named_(\S+)(\s|$)/);
        if (group_match) {
            elem_data['named'] = group_match[2];
        }

        return elem_data;
    }

    function get_popover_text(item) {
        var data = get_match_elem_info($(this));
        return "Text matched by group.<br />Content in variable $" + data.number;
    }

    $(document).bind('relaxer_match_done', display_match_results);
    $(document).bind('relaxer_match_error', display_match_error);

    $(document).bind('relaxer_match_highlight', function() {
        $(this).addClass('highlighted');
    });
    $(document).bind('relaxer_match_unhighlight', function() {
        $(this).removeClass('highlighted');
    });

})(jQuery);
