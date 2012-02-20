use Mojo::Base -strict;

use Test::More tests => 6;
use Test::Mojo;

use_ok 'PerlPeer';
use_ok 'PerlPeer::Nodes';
use_ok 'PerlPeer::Files';

my $t = Test::Mojo->new('PerlPeer');
$t->app->config->{nodes} = PerlPeer::Nodes->new('127.0.0.1', 1234);
$t->app->config->{nodes}->self->set_files(PerlPeer::Files->new());

$t->get_ok('/')
  ->status_is(200)
  ->content_like(qr/perlpeer/i);
