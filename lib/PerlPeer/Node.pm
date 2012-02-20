package PerlPeer::Node;

use 5.12.0;

use strict;
use warnings;

use Mojo::UserAgent;
use Mojo::JSON;
use Mojo::ByteStream qw/b/;
use AnyEvent;

use Carp qw/confess/;

use overload '""' => \&to_string;

use Data::UUID;

my $uuid    = Data::UUID->new();
my $timeout = 15;
my $json    = Mojo::JSON->new();

sub new {
  my $class = shift;
  confess "called as object method" if ref $class;

  my $args = shift || {};

  confess "no parent supplied" if (! $args->{parent});
  confess "no port supplied"   if (! $args->{port});
  confess "no ip supplied"     if (! $args->{ip});

  my $self = { uuid    => $args->{uuid},
	       ip      => $args->{ip},
	       port    => $args->{port},
	       timeout => time() + $timeout,
	       parent  => $args->{parent},
	     };

  bless $self, __PACKAGE__;
  return $self;
}

# accessors

sub uuid {
  my $self = shift;
  return $self->{uuid};
}

sub ip {
  my $self = shift;
  return $self->{ip};
}

sub port {
  my $self = shift;
  return $self->{port};
}

sub parent {
  my $self = shift;
  return $self->{parent};
}

# checks

sub has_timed_out {
  my $self = shift;
  return 1 if ($self->{timeout} < time());
  return 0;
}

# action methods

sub ping_if_necessary {
  my $self = shift;
  my $all_nodes = shift;

  if ($self->{ping_cv}) {
    warn "ping already in progress";
    return;
  }

  # ping if less than half of our timeout is left
  if ($self->{timeout} - $timeout/2 < time()) {

    my $url = "http://" . $self->ip . ":" . $self->port . "/REST/1.0/ping?";
    my $nodedata = $json->encode($all_nodes);

    $self->{ping_ua} = Mojo::UserAgent->new;
    $self->{ping_cv} = AE::cv;

    # set up what we do when there is a response
    $self->{ping_cv}->cb(
			 sub { 
			   my ($node, $tx) = (shift->recv); 
			   $node->ping_received($tx); 
			 });

    # do the ping (POST)
    $self->{ping_ua}->post($url
			   => {'Content-Type' => 'application/json'}
			   => $nodedata => sub {
			     my ($ua, $tx) = @_;
			     $self->{ping_cv}->send($self, $tx);
			   });
  }
}

sub ping_received {
  my $self = shift;
  my $tx   = shift;

  if ($tx && $tx->res && $tx->res->code && $tx->res->code == 200) {
    my $response;
    eval { $response = $tx->res->json; };
    if (!$@ && $response->{result} eq 'ok') {
      # UUID better match too, if we know the uuid yet (we may not)
      if (! $self->uuid || ($response->{uuid} eq $self->uuid)) {
	# reset the timer and set the uuid
	$self->{timeout} = time() + $timeout;
	$self->{uuid}    = $response->{uuid};
      }

      else {
	warn "uuid does not match!\n";
	warn "expected " . $self->uuid . "\n";
	warn "got      " . $response->{uuid} . "\n";
      }
    }
    else {
      warn "something bad happened: $@\n";
    }
  }
  else {
    say " * $self - bad ping response";
    say "   body . " . $tx->res->body;
  }

  # whatever happened, we are done with the request, so kill
  # the event and ua.
  undef $self->{ping_cv};
  undef $self->{ping_ua};

}

# helpers

sub to_string {
  my $self = shift;
  return sprintf("%s | %s | %s (%s secs)",
		 $self->{uuid}  ? $self->{uuid} : "[undef]",
		 $self->{ip}    ? $self->{ip} : "[undef]",
		 $self->{port}  ? $self->{port} : "[undef]",
		 $self->{timeout} - time(),
		);
}

1;
