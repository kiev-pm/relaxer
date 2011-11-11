(function($) {
	$.extend({
		postJSON : function(url, data, cb) {
			$.ajax({
				type : "post",
				url : url,
				contentType : "application/json",
				data : JSON.stringify(data),
				success : cb
			});
		}
	});
}(jQuery));
