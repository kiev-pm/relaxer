(function($) {
    function activate_popovers(e) {
        // Activate popovers and deny live event on this object
        $('.group', this).twipsy({
            live: true,
            title: get_popover_text,
            offset: 5,
            html: true
        });
        $('.group', this).mouseover(highlight_group);
        $('.group', this).mouseout(unhighlight_group);

        $(this).addClass('twipsed');
        $(this).trigger(e);
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

    $(document).on("mouseover", ".match:not(.twipsed)", activate_popovers);

})(jQuery);
