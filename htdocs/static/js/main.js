var test_data = {
	'status' : 1,
	'errmsg' : '',
	'results' : [ {
		'matches' : [ {
			'to' : '5',
			'from' : '3',
			'groups' : [ {
				'to' : '4',
				'from' : '3'
			} ]
		}, {
			'to' : '11',
			'from' : '9',
			'groups' : [ {
				'to' : '10',
				'from' : '9'
			} ]
		} ],
		'found' : 1
	} ]
};

var test_text = 'qwertyuiosdsdf asd gfdjgkdjfgh dflgbjndlkbjnochjbndf f';

var match = {
	'to' : '5',
	'from' : '3',
	'groups' : [ 
	    {
		'to' : '4',
		'from' : '3'
	     }
	]
};

process_regexp_submit();
function process_regexp_submit() {
	var data; //TODO get data
//	$.postJSON(url, data, function(data) {
		preprocess_results(test_text, test_data.results);
		draw_results_tree(test_data.results);
//	});
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
	console.log(JSON.stringify(results));

}



	  