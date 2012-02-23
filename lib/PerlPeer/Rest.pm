package PerlPeer::Rest;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::JSON;
use Number::Format qw/format_bytes/;

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

# all files we know about
sub files_all {
  my $self = shift;
  my $config = $self->config;
  my $stats  = {};

  my @all_files = ();
  foreach my $node ($config->{nodes}->list) {
    $stats->{total_nodes}++;
    push @all_files, @{ $node->files->as_hashref };
  }

  $stats->{total_files} = scalar @all_files;
  $stats->{total_bytes} += $_->{size} foreach @all_files;

  $stats->{$_} = format_bytes($stats->{$_}) foreach (qw/total_files total_bytes/);
  
  # sort for presentation
  # newest at the top
  @all_files = sort { $b->{mtime} <=> $a->{mtime} } @all_files;

  $self->render( json => { result => 'ok',
			   files => \@all_files,
			   stats => $stats });


}

1;
