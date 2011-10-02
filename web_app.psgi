use Plack::Builder;
use Plack::Util;
use Plack::App::File;
use FindBin;

use lib "$FindBin::Bin/lib";

my $api_app = Plack::Util::load_psgi("$FindBin::Bin/api.psgi");

builder {
	enable "Plack::Middleware::Static",
		path => sub { s{^/static/}{} }, root => 'htdocs/static/';
	enable "Plack::Middleware::ContentLength";
	mount '/api' => $api_app;
	
}
