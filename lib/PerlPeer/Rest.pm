package PerlPeer::Rest;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::JSON;

my $json = Mojo::JSON->new();

# This action will render a template
sub ping {
  my $self   = shift;
  my $config = $self->config;
  my $nodes  = $self->req->json;

  foreach (@$nodes) {
    # add nodes that have a UUID
    $config->{nodes}->add_if_necessary($_)
      if ($_->{uuid});
  }

  $self->render( json => { result => 'ok', 'uuid' => $config->{nodes}->self->uuid } );
}

1;
