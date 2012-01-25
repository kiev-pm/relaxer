(function($) {

    function display_match_error(e) {
        // TODO: show pretty error message somewhere
        alert("Relaxer error: " + e.message);
    }

    function display_match_results(e) {
        $("#result").empty();

        for (var i = 0; i < e.results.length; i++) {
            if (e.results[i].found <= 0) {
                continue;
            }
            var match = e.results[i];
            var tokens = collect_tokens(match.matches);
            var output = apply_tokens(e.string, tokens);

            $("#result").append(output);
            $("#result").append('<br />');
        }

        // Install popovers on created elements
        activate_popovers($('#result'));
    }
    
    function collect_tokens(matches) {
        var tokens = [];
        for (var m = 0; m < matches.length; m++) {
            tokens.push({
                str: '<div class="match num_' + (m + 1) + '">',
                num: -100,
                pos: matches[m].from
            }); 
            tokens.push( {
                str: '</div>',
                num: -100,
                pos: matches[m].to                                
            });
            
            for (var g = 0; g < matches[m].groups.length; g++) {
                var group = matches[m].groups[g];
                tokens.push({
                    str: '<span class="group num_' + (g + 1) + '">',
                    num: g + 1,
                    pos: group.from
                });
                tokens.push({
                    str: '</span>',
                    num: g + 1,
                    pos: group.to      
                });
            }
        }
        return tokens; 
    }
    
    function apply_tokens(str, tokens) {
        tokens.sort(function(a, b) {
            var res = b.pos - a.pos;
            if (res != 0) {
                return res;
            }
            return b.num - a.num;
        });
        for (var i = 0; i< tokens.length; i++) {
            var pos   = tokens[i].pos;
            var token = tokens[i].str;
            str = str.substr(0,pos) + token + str.substr(pos)
        }
        return str;
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
        event_data['match_type'] = "match";
        event_data['type'] = 'relaxer_match_highlight';

        $(e.target).trigger(event_data);
    }

    function unhighlight_group(e) {
        var event_data = get_match_elem_info($(this));

        // TODO: match / replace
        event_data['match_type'] = "match";
        event_data['type'] = 'relaxer_match_unhighlight';

        $(e.target).trigger(event_data);
    }

    function get_match_elem_info(elem) {
        // TODO: Store match number and group name in right way
        var elem_data = {};

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

    $(document).bind('relaxer_match_highlight', function(e) {
        $(e.target).addClass('highlighted');
    });
    $(document).bind('relaxer_match_unhighlight', function(e) {
        $(e.target).removeClass('highlighted');
    });

})(jQuery);
