(function($) {
    function process_regexp_submit(e) {
        e.preventDefault();
        var form_data = {
            text: [$('#search_text').val()],
            match: $('#regexp_match').val(),
            replace: $('#regexp_replace').val(),
            flags: {
                i: $('#flag_i:checked').length,
                s: $('#flag_s:checked').length,
                m: $('#flag_m:checked').length,
                x: $('#flag_x:checked').length,
                a: $('#flag_a:checked').length,
                u: $('#flag_u:checked').length,
                l: $('#flag_l:checked').length,
                g: $('#flag_g:checked').length
            }
        };

        $.postJSON('/api/execute', form_data, function(data) {
            if (data.status != 1) {
                $(document).trigger({
                    type: 'relaxer_match_error',
                    message: data.errmsg
                });
                return;
            }

          //  preprocess_results(form_data.string[0], data.results);
            $(document).trigger({
                type: 'relaxer_match_done',
                string: form_data.text[0],
                results: data.results
            });
        });
    }

    function preprocess_results(text, results) {
        for (var i = 0; i < results.length; i++) {
            if (!results[i].found) continue;
            for (var j = 0; j < results[i].matches.length; j++) {
                var match = results[i].matches[j];
                extract_text_to_match(text, match);
            }
        }
    }

    function extract_text_to_match(text, match) {
        match.text = text.substr(match.from, match.to - match.from);
        for (var i = 0; i < match.groups.length; i++) {
            var group = match.groups[i];
            group.text = text.substr(group.from, group.to - group.from);
        }
    }

    function handle_match_error(e) {
        alert("Relaxer error: " + e.message);
    }

    function draw_results_tree(e) {
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
    }

    $(function() {
        $("#match_regexp_form").submit(process_regexp_submit);
        $(document).bind('relaxer_match_done', draw_results_tree);
        $(document).bind('relaxer_match_error', handle_match_error);
    });

})(jQuery);
