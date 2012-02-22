package PerlPeer::Rest;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::JSON;

my $json = Mojo::JSON->new();

# respond to a ping
sub ping {
  my $self   = shift;
  my $config = $self->config;
  my $nodes  = $self->req->json;

  # Add all the nodes that have been advertised to us by the pinger.
  foreach (@$nodes) {
    # add nodes that have a UUID
    $config->{nodes}->add_if_necessary($_)
      if ($_->{uuid});
  }

  $self->render( json => { result => 'ok', 'uuid' => $config->{nodes}->self->uuid } );
}

# list my files
sub files {
  my $self = shift;
  my $config = $self->config;

  my $files_hashref = $config->{nodes}->self->files->as_hashref;
  $self->render( json => { result => 'ok', files => $files_hashref } );
}

1;
