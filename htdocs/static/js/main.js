function process_regexp_submit() {
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
    		alert(data.errmsg);
    		return;
    	}
    	
		preprocess_results(form_data.text[0], data.results);
		draw_results_tree(data.results);
   });
}


function preprocess_results(text, results) {
	for ( var i = 0; i < results.length; i++ ) {
		if (! results[i].found) continue;
		for ( var j = 0; j < results[i].matches.length; j++ ) {
			var match = results[i].matches[j];
			extract_text_to_match(text, match);
		}
	}
}

function extract_text_to_match(text, match) {
	match.text = text.substr(match.from, match.to - match.from);
	for ( var i = 0; i < match.groups.length; i++ ) {
		var group = match.groups[i];
		group.text = text.substr(group.from, group.to - group.from);
	}
}

function draw_results_tree(results) {
	$("#result").empty().append(JSON.stringify(results));
}



	  