package PerlPeer;

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

  # RESTful routs
  $r->route('/REST/1.0/ping')->via(qw/POST/)->to('rest#ping');
  $r->route('/REST/1.0/files')->to('rest#files');

}



1;
