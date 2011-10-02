use Plack::Builder;


builder {
	enable "Plack::Middleware::Static",
		path => sub { s{^/static/}{} }, root => 'htdocs/static/';
	enable "Plack::Middleware::ContentLength";
	# TODO place app	
}
