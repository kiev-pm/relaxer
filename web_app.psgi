use Plack::Builder;
use Plack::Util;
use Plack::App::File;
use FindBin;

use Relaxer::API;

use lib "$FindBin::Bin/lib";

my $api_app = Relaxer::API->new->to_psgi_app;

builder {
	enable "Plack::Middleware::Static",
		path => sub { s{^/static/}{} }, root => 'htdocs/static/';
	enable "Plack::Middleware::ContentLength";
	mount '/api' => $api_app;
	mount '/' => Plack::App::File->new(file => 'htdocs/static/index.html');
	
}
