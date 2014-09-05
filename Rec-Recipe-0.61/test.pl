#!/usr/bin/perl -w
# just some sanity checks for the module itself. nothing interesting here.

use Test::More tests => 10;
use Rec::Recipe;

$title = q(foo recipe);
$serves = 3;
@ings = qw(beef lamb chicken water);
@dirs = ('throw everything into a pot','heat up and stir','eat it');
$r = Rec::Recipe->new();
@ingret = $r->ingredients(@ings);
@ingret2 = $r->ingredients();

@dirret = $r->directions(@dirs);
@dirret2 = $r->directions();

ok(defined $r, 'new() returned something.' );
is($r->title($title), $title, 'assigning title.');
is($r->title(), $title, 'accessing title.');
is($r->serves($serves), $serves, 'assigning servings.');
is($r->serves(), $serves, 'accessing servings.');
$cmp = compare_arrays(\@ings, \@ingret);
ok($cmp, 'assigning ingredients.');
$cmp = compare_arrays(\@ings, \@ingret2);
ok($cmp, 'accessing ingredients.');
$cmp = compare_arrays(\@dirs, \@dirret);
ok($cmp, 'assigning directions.');
$cmp = compare_arrays(\@dirs, \@dirret2);
ok($cmp, 'accessing directions.');

sub compare_arrays {
	my ($first, $second) = @_;
	no warnings;
	return 0 unless @$first == @$second;
	for(my $i = 0; $i < @$first; ++$i) {
		return 0 if $first->[$i] ne $second->[$i];
	}
	return 1;
}


BEGIN {
	use_ok(qw{Rec::Recipe});
}
