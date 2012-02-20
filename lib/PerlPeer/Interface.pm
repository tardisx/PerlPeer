package PerlPeer::Interface;
use Mojo::Base 'Mojolicious::Controller';

# This action will render a template
sub root {
  my $self = shift;
  my $config = $self->config();

  $self->stash->{nodes} = $config->{nodes};

  $self->render();
}

1;
