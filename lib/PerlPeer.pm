package PerlPeer;

use strict;
use warnings;

use Mojo::Base 'Mojolicious';

use Mojo::Server::Daemon;
use EV;
use AnyEvent;
use Data::UUID;

# This method will run once at server start
sub startup {
  my $self = shift;

  # Routes
  my $r = $self->routes;

  # Normal route to controller
  $r->route('/')->to('interface#root');

  # RESTful routes
  # routes for the remote nodes to hit
  $r->route('/REST/1.0/ping')->via(qw/POST/)->to('rest#ping');
  $r->route('/REST/1.0/files')->to('rest#files');
  $r->route('/REST/1.0/file/:uuid')->to('rest#file_get_by_uuid');

  # routes for the local interface to use
  # XXX should check it is the local user!
  $r->route('/REST/1.0/files/all')->to('rest#files_all');

}

1;
