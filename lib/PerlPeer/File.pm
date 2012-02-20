package PerlPeer::File;

use 5.12.0;

use strict;
use warnings;

use Carp qw/confess/;

use overload '""' => \&to_string;

use Data::UUID;
use Number::Format qw/format_bytes/;

my $uuid = Data::UUID->new;

sub new {
  my $class = shift;
  confess "called as object method" if ref $class;

  my $args = shift || {};

  confess "no parent supplied" if (! $args->{parent});
  confess "no filename"        if (! $args->{filename});
  confess "no size"            if (! $args->{size});

  my $self = { uuid     => $args->{uuid} || $uuid->create_str,
	       filename => $args->{filename},
	       parent   => $args->{parent},
	       size     => $args->{size},
	     };

  bless $self, __PACKAGE__;
  return $self;
}

sub new_from_local_file {
  my $class    = shift;
  my $args     = shift;

  confess "called as object method" if ref $class;
  confess "no filename" unless $args->{filename};
  confess "'$args->{filename}' does not exist" unless -f $args->{filename};
  confess "no parent" unless $args->{parent};

  my $file_obj = __PACKAGE__->new({filename => $args->{filename},
				   size     => -s $args->{filename},
				   parent   => $args->{parent},
				  });
  return $file_obj;
}

# accessor

sub filename {
  my $self = shift;
  return $self->{filename};
}

sub size {
  my $self = shift;
  confess "size requested on file with no size" unless defined $self->{size};
  return $self->{size};
}

sub uuid {
  my $self = shift;
  return $self->{uuid};
}

# helper

sub nice_size {
  my $self = shift;
  return format_bytes($self->size);
}

sub nice_filename {
  my $self = shift;
  return $self->{filename};
}

sub to_string {
  my $self = shift;
  return $self->uuid . " - " . $self->nice_filename . " (" . $self->nice_size . ")";
}

1;
