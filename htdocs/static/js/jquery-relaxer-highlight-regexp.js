(function($) {
    var saved_groups;
    function relax_textarea(textarea) {
        var div = $("<div class='medium relaxed_textarea'></div>");
        div.hide();
        div.attr('id', textarea.attr('id') + "_relaxed");
        div.css('position', 'absolute');
        var positioningProps = ['fontFamily', 'fontSize', 'fontWeight', 'fontStyle', 'color', 'textTransform', 'textDecoration', 'letterSpacing', 'wordSpacing', 'lineHeight', 'textAlign', 'verticalAlign', 'direction', 'backgroundColor', 'backgroundImage', 'backgroundRepeat', 'backgroundPosition', 'backgroundAttachment', 'opacity', 'width', 'height', 'top', 'right', 'bottom', 'left', 'marginTop', 'marginRight', 'marginBottom', 'marginLeft', 'paddingTop', 'paddingRight', 'paddingBottom', 'paddingLeft', 'borderTopWidth', 'borderRightWidth', 'borderBottomWidth', 'borderLeftWidth', 'borderTopColor', 'borderRightColor', 'borderBottomColor', 'borderLeftColor', 'borderTopStyle', 'borderRightStyle', 'borderBottomStyle', 'borderLeftStyle', 'overflowX', 'overflowY', 'whiteSpace', 'clip', '-webkit-box-shadow', '-webkit-box-shadow', 'box-shadow'];
        $(positioningProps).each(function(index, prop) {
            div.css(prop, textarea.css(prop) || "");
        });
        textarea.before(div);
        div.offset(textarea.offset());
        div.text(textarea.val());
        div.show();
        div.css("z-index", textarea.css('z-index') + 1);
    };

    function strain_textarea(textarea) {
        $('span', '#' + textarea.attr("id") + "_relaxed").twipsy('hide');
        $('#' + textarea.attr("id") + "_relaxed").remove();
        textarea.show();
    };

    function save_match_groups(e) {
        saved_groups = e.groups;
    }

    $(function() {
        $(document).bind('relaxer_match_highlight', function(e) {
            relax_textarea($('#regexp_match'))
            var text = $('#regexp_match_relaxed').text();
            var group = saved_groups[e.number - 1];
            var start = text.substring(0, group.from);
            var end = text.substring(group.to+1, text.length);
            var span = $('<span class="group" title="Matched regexp" />');
            span.text(text.substring(group.from, group.to+1));
            $('#regexp_match_relaxed').empty().append(start).append(span).append(end);
            span.twipsy({
                placement: "below",
                offset: 7
            }).twipsy("show");
            span.addClass('highlighted');
            span.css('marginRight', '-1px');
            span.css('marginLeft', '-1px');
        });

        $(document).bind('relaxer_match_unhighlight', function(e) {
            strain_textarea($('#regexp_match'));
        });
        $(document).bind('relaxer_match_done', save_match_groups);
    });

})(jQuery);
