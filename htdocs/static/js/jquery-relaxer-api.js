(function($) {

    /* Relaxer API JavaScript bindings
     *
     * Usage:
     *
     *     $("form.selector").relaxer();
     *     $("form.selector").relaxer({type: "match"});
     *     $("form.selector").relaxer({type: "replace"});  // not supported yet
     *
     * Binds given form to Relaxer API.
     * Plugin expects the form to have following elements:
     * 
     *     [name=regexp_match]
     *     textarea or input containing regexp
     *     required
     *
     *     [name=search_text]
     *     textarea or input containing text
     *     required
     *
     *     checkbox[name=flag_(i|s|m|x|a|u|l|g)]
     *     checkbocks that represents regexp flags
     *     optional
     *
     *
     *  Plugin emits following events:
     *
     *  relaxer_match_done
     *  Relaxer API successfull completed match of given text against given regexp
     *  This event guaraniee that regexp compiled successfully and there was no errors during match.
     *  This even does not guaranee something was mached, only match finished with no errors.
     *  To find what was matched you need to loop over `event.results` array and look into  `found` property of each element
     *  Event object fields:
     *  
     *      event.string       // string that was used to match
     *      event.results      // array of matches
     *      event.groups       // information about groups in regexp
     *      event.regexp       // original regexp
     *
     *  relaxer_match_error
     *  Relaxer API returned error after trying to execute given regexp
     *  Opposite to `relaxer_match_done`
     *  Usually this means that regexp contains error.
     *
     *  Event object fields:
     *
     *      event.string // string that was used to match
     *      event.results      // array of matches
     *      event.groups       // information about groups in regexp
     *      event.regexp       // original regexp
     */

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
            // TODO: add types of errror: regep, network, unknown
            // TODO: catch network errors of postJSON and rethrow them as relaxer_match_error
            if (data.status != 1) {
                $(document).trigger({
                    type: 'relaxer_match_error',
                    message: data.errmsg,
                    regexp: form_data.match,
                    string: form_data.text[0]
                });
                return;
            }

            $(document).trigger({
                type: 'relaxer_match_done',
                results: data.results,
                string: form_data.text[0],
                regexp: form_data.match,
                groups: data.groups
            });
        });
    }

})(jQuery);
