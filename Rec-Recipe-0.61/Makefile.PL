use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

my @l;

push (@l, 'rec.pl');

WriteMakefile(
	'NAME'	=> 'Rec::Recipe',
	'AUTHOR' => 'Michael Dungan <mpd@rochester.rr.com>',
	# install rec.pl to /usr/local/bin by default.
	'PREFIX' => '/usr/local',
	'VERSION_FROM' => 'Recipe.pm', # finds $VERSION
	'ABSTRACT_FROM' => 'Recipe.pm', # finds $ABSTRACT
	'EXE_FILES' => \@l
);
