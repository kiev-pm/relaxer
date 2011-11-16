(function($) {

    var methods = {
        init: function(options) {
            if (options == undefined || options.type == undefined || options.type == "match") {
                init_match(options);
            }
            else {
                init_replace(options);
            }
            return this;
        }
    };

    $.fn.relaxer = function(method) {

        // Method calling logic
        if (methods[method]) {
            return methods[method].apply(this, Array.prototype.slice.call(arguments, 1));
        } else if (typeof method === 'object' || !method) {
            return methods.init.apply(this, arguments);
        } else {
            $.error('Method ' + method + ' does not exist on jQuery.relaxer');
        }

    };

    function init_match(options) {
        $(this).submit(process_match_submit);
    }

    function init_replace(options) {
        alert("replace is not implemented yet!");
        //$(this).submit(process_match_submit);
    }

    function process_match_submit(e) {
        e.preventDefault();
        var form_data = {
            text: [$('[name=search_text]', e.target).val()],
            match: $('[name=regexp_match]', e.target).val(),
            flags: {
                i: $('[name=flag_i]:checked', e.target).length,
                s: $('[name=flag_s]:checked', e.target).length,
                m: $('[name=flag_m]:checked', e.target).length,
                x: $('[name=flag_x]:checked', e.target).length,
                a: $('[name=flag_a]:checked', e.target).length,
                u: $('[name=flag_u]:checked', e.target).length,
                l: $('[name=flag_l]:checked', e.target).length,
                g: $('[name=flag_g]:checked', e.target).length
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

            $(document).trigger({
                type: 'relaxer_match_done',
                string: form_data.text[0],
                results: data.results,
                groups: data.groups
            });
        });
    }

})(jQuery);
