# Recipe.pm
# michael dungan - mpd@rochester.rr.com
# definition of a recipe object
#
# $Log: Recipe.pm,v $
# Revision 2.3  2003/07/28 00:33:08  vega
# more export stuff removed.
#
# Revision 2.2  2003/07/27 23:49:47  vega
# Small fixes. Explicitly export nothing.
#
# Revision 2.1  2002/04/12 01:48:01  vega
# pod stuff added.
#
# Revision 2.0  2002/04/05 20:23:23  vega
# Minor cleanups. First check-in of post-1.0 code.
#
# Revision 1.5  2002/04/03 20:15:29  vega
# cleanups. This should be ready for 1.0 release.
#
# Revision 1.4  2002/04/01 17:57:14  vega
# fixed yet another bug w/ accessors. It seems to be
# working correctly for real this time.
#
# Revision 1.3  2002/03/31 15:37:55  vega
# re-wrote major portions of module. it seems to
# work pretty well now, though.
#
# Revision 1.2  2002/03/30 20:21:39  vega
# fixed 2 small bugs in list accessors,
# bumped VERSION to 0.2.
#
# Revision 1.1  2002/03/30 00:57:53  vega
# Initial revision
#
#
package Rec::Recipe;
use strict;
use vars qw(@ISA $VERSION $RCSID);

use Carp;
use Exporter;

$RCSID = '$Id: Recipe.pm,v 2.3 2003/07/28 00:33:08 vega Exp $';

$VERSION =	'0.61';
@ISA =		qw(Exporter);

#----------
# constructor
#----------
sub new {
	my $this = shift;
    my $classname  = ref($this) || $this;	
    my $self;
	$self = {
	    INGREDIENTS  => [],
	    DIRECTIONS   => [],
	    SERVES       => undef,
	    TITLE        => undef
	};
    bless($self, $classname);
    return $self;
}

#----------
# Accessors/Mutators
#----------
sub title {
    my $self = shift;
    $self->{TITLE} = shift if (@_);
    return $self->{TITLE};
}
   
sub serves {
    my $self = shift;
    $self->{SERVES} = shift if (@_);
    return $self->{SERVES};
}
   
sub ingredients {
    my $self = shift;
    @{ $self->{INGREDIENTS} } = @_ if (@_);
    return @{ $self->{INGREDIENTS} };
}

sub directions {
    my $self = shift;
    @{ $self->{DIRECTIONS} } = @_ if (@_);
    return @{ $self->{DIRECTIONS} };
}

1;

__END__

=head1 NAME

Rec::Recipe - Module for storage and manipulation of recipe data.

=head1 SYNOPSIS

use Rec::Recipe;

$recipe = Rec::Recipe->new();

$recipe->title('Recipe Title');

$recipe->serves(4);

$recipe->ingredients(qw(eggs fish cheese));

$recipe->directions('Mix ingredients in a bowl.', 'Eat quickly.');

=head1 DESCRIPTION

Recipe provides an abstract class to manipulate a recipe used for
cooking. The objects can then be used in a cookbook program.

=head2 Class Methods

=over 4

=item * title($new_title)

Optionally takes a string representing the new title for the
recipe in question.
If no title given, just returns the current title.

=item * serves($new_serves)

Optionally takes a string representing the new value of how
many people the recipe serves.
If no value given, just returns the current value.

=item * ingredients(@new_ingredients)

Optionally takes a list of strings, each representing an
ingredient. In the future, an ingredient module may be
written.
If no value given, just returns the current value.

=item * directions(@new_directions)

Optionally takes a list of strings, each representing a step
in the recipe.
If no value given, just returns the current value.

=back

=head1 AUTHOR

Michael Dungan <mpd@rochester.rr.com>

=cut
