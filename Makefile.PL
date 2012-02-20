use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
	      NAME => 'PerlPeer',
	      VERSION   => '0.01',
	      PREREQ_PM => {'Mojolicious' => '2.50',
			    'AnyEvent'    => '6.14',
			    'EV'          => '4.11',
			    'Data::UUID'  => '1.217',
			    'Number::Format' => '1.73',
			   },
	      test      => {TESTS => 't/*.t'}
	     );
