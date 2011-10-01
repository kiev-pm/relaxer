#!/usr/bin/env plackup

use Relaxer::API;

Relaxer::API->new->to_psgi_app;
