package PerlPeer::Files;

# a container holding the files for a node

use 5.12.0;

use strict;
use warnings;

use Data::UUID;

use Scalar::Util qw/refaddr/;

use Carp qw/confess/;

sub new {

  my $class = shift;
  my $args = shift || {};

  confess "called as object method" if ref $class;
  confess "no parent supplied" if !$args->{parent};

  my $self = {};
  bless $self, __PACKAGE__;

  # initialise
  $self->{parent} = $args->{parent};
  $self->{files}  = [];

  return $self;
}

sub files {
  my $self = shift;
  return @{ $self->{files} };
}


1;
