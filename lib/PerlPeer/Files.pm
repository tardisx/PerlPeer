package PerlPeer::Files;

# a container holding the files for a node

use 5.12.0;

use strict;
use warnings;

use Data::UUID;
use File::Find qw/find/;
use Scalar::Util qw/refaddr/;

use PerlPeer::File;

use Carp qw/confess/;

sub new {

  my $class = shift;
  my $args = shift || {};

  confess "called as object method" if ref $class;

  my $self = {};
  bless $self, __PACKAGE__;

  # initialise
  $self->{files}  = [];

  return $self;
}

sub list {
  my $self = shift;
  return @{ $self->{files} };
}


sub add_all_in_path {
  my $self = shift;
  my $path = shift;

  # omg I hate File::Find
  find({ no_chdir => 1,
	 wanted   => sub { 
	   my $filename = $_;
	   return unless -f $filename;
	   return if     -z $filename;
	   my $file = PerlPeer::File->new_from_local_file(
							  { parent => $self,
							    filename => $filename,
							  });
	   push @{ $self->{files} }, $file;
	   return;
	 },
       }, $path);
  return;
}


1;
