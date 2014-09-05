#!/usr/bin/perl -w

# rec.pl
# michael dungan - mpd@rochester.rr.com
#
# some recipe thing i made because all the
# existing ones suck ass and require
# things like mysql for some reason.
# do you really think the average user of
# software like this has mysql installed?
#
# $Log: rec.pl,v $
# Revision 2.9  2003/07/28 00:32:57  vega
# small cleanups.
#
# Revision 2.8  2003/03/17 07:46:05  vega
# a couple of fixes, and rewrites to consolidate repeated code.
#
# Revision 2.7  2002/07/09 15:19:55  vega
# set_status implemented, and all code changed to use it instead.
#
# Revision 2.6  2002/05/27 21:26:18  vega
# search functionality implemented.
# this code is version 2.00.
#
# Revision 2.5  2002/05/16 23:33:41  vega
# search interface implemented. actual searching isn't.
#
# Revision 2.4  2002/04/12 19:18:49  vega
# fixed stupid bug that clobbered existing recipes if a new one
# with the same name was added, or an existing recipe was
# edited to have a new name that was the same as one already there.
#
# Revision 2.3  2002/04/12 03:51:46  vega
# more cleanups and GUI enhancement.
# first check-in of post-1.1 code.
#
# Revision 2.2  2002/04/08 18:36:01  vega
# whitespace checks when creating a new recipe or
# editing an existing one.
#
# Revision 2.1  2002/04/08 17:55:33  vega
# Mousewheel support added.
# <Esc> will now also dismiss a Viewing window.
# Minor cleanups and bugfixes.
#
# Revision 2.0  2002/04/05 20:23:57  vega
# Minor cleanups. First check-in of post-1.0 code.
#
# Revision 1.18  2002/04/04 05:06:10  vega
# Ready for release. All known bugs fixed and
# desired features for 1.0 implemented.
#
# Revision 1.17  2002/04/03 20:12:22  vega
# more cleanups. can specify path to cookbook as an argument.
# will eventually be re-written to use Getopt::Std.
# Once that's finished, this will be ready for release.
#
# Revision 1.16  2002/04/03 04:23:16  vega
# more cleanups. about ready for release.
#
# Revision 1.15  2002/04/02 18:42:21  vega
# very, very usable now. near release quality.
#
# Revision 1.14  2002/04/02 06:05:52  vega
# Can add new recipes now. I would consider this the
# beginning of the beta stage, as the app is somewhat
# useable now.
#
# Revision 1.13  2002/04/02 01:28:36  vega
# opens and reads files. saving is next, then new/edit recipe.
#
# Revision 1.12  2002/04/01 17:57:49  vega
# new viewing window implemented.
# double-click recipe in main window to view implemented.
#
# Revision 1.11  2002/03/31 15:40:52  vega
# Jibes w/ Recipe.pm now. Multiple recipes work in a toy
# environment. Now need to create dialog for viewing a
# recipe. Then code for reading from files is next.
#
# Revision 1.10  2002/03/30 21:52:15  vega
# screwy. need to find a way to store a copy of an object,
# not a reference to the object itself (in %cookbook, that is.)
#
# Revision 1.9  2002/03/30 20:22:08  vega
# can get to information now for viewing.
# need to create full window for easier viewing,
# however. a dialog won't cut it.
#
# Revision 1.8  2002/03/30 19:58:01  vega
# more work done. need to re-do ingredient/directions
# accessors in Recipe.pm now.
#
# Revision 1.7  2002/03/30 00:56:36  vega
# more file reading work. beginning of integration w/
# Recipe module.
#
# Revision 1.6  2002/03/29 03:19:47  vega
# open file dialog stuff finished.
#
# Revision 1.5  2002/03/29 00:54:20  vega
# done. next is opening and reading files.
#
# Revision 1.4  2002/03/29 00:39:36  vega
# working in making windows play nice.
# next step is finishing the new recipe gui -
# needs title, number of services label/entry
#
# Revision 1.3  2002/03/28 15:12:09  vega
# small bugfix.
#
# Revision 1.2  2002/03/28 15:10:40  vega
# new recipe window mostly finished. need callbacks.
#
# Revision 1.1  2002/03/28 04:17:19  vega
# Initial revision
#
#
use strict;
use Tk;
use Tk::Dialog;
use Tk::FileDialog;
use File::Basename;
use Getopt::Std;
use Rec::Recipe '0.61';

#----------
# globals
#----------
my $VER = '2.02';
my $RCSID = '$Id: rec.pl,v 2.9 2003/07/28 00:32:57 vega Exp $';

#----------
# main window - just easier to leave it global
#----------
my $main;			# main window
my $menubar;		# upper menubar
my $filebutton;		# "File" in menubar
my $filemenu;		# $filemenus menu
my $searchframe;	# frame containing all searching stuff
my $searchentry;	# fairly obvious
my $searchbutton;	# the button that begins a search
my $resetbutton;	# the button that resets a search
my $recipebutton;	# "Recipe" in menubar
my $recipemenu;		# $recipes menu
my $helpbutton;		# "Help" in menubar
my $helpmenu;		# $helpmenus menu
my $recipe_lb;		# listbox for recipes
my $buttonbar;		# frame for buttonbox below listbox
my $new_button;		# "New" button in buttonbar
my $open_button;	# "Open" button in buttonbar
my $edit_button;	# "Edit" button in buttonbar
my $save_button;	# "Save" button in buttonbar
my $view_button;	# "View" button in buttonbar
my $delete_button;	# "Delete" button in buttonbar
my $status;			# Status bar at bottom

#----------
# misc - These would eventually be put into a cookbook object,
#        but the goal is simplicity, so I'm not going to.
#----------
my %cookbook;					# current cookbook in memory.
my $cb_path = './';				# sane default path to cookbook file
my $cb_file = 'cookbook.rec';	# default name
my $cb = $cb_path.$cb_file;		# full pathname of current cookbook
my $need_to_save;				# check on exit - do we need to save cookbook?

my %arguments;					# hash for getopts storage

my $TRUE = 1;
my $FALSE = 0;




getopts('hf:', \%arguments);

$arguments{h} && &usage;

&create_mainwindow;

# filename given as argument will override the REC_BOOKBOOK env var
my $new_cb;
$new_cb = $ENV{REC_COOKBOOK} if $ENV{REC_COOKBOOK};
$new_cb = $arguments{f} if $arguments{f};
$cb = $new_cb;
$cb_path = dirname($cb);
$cb_file = basename($cb);
&open_cookbook if( -r $new_cb );

#----------
# begin MainLoop
#----------
MainLoop;

# end "main"

sub usage {
	my $bn = basename($0);
	print STDERR "Usage: $bn [-h] [-f FILENAME]\n\n".
	             "\t-h - Print this message and exit\n".
	             "\t-f FILENAME - Cookbook to open at start. ".
	             "Overrides the REC_COOKBOOK\n".
	             "\t              environment variable.\n".
	             "\n\n";
	exit;
} # &usage

# button subroutines
sub exit_choice {

	if($need_to_save) {
		my $dialog_delete = $main->Dialog(
			-title		=> 'Save cookbook?',
			-text		=> 'Do you wish to save your cookbook?',
			-default_button => 'Cancel',
			-buttons	=> ['Yes', 'No', 'Cancel']);
	
		my $yn = $dialog_delete->Show;
		if($yn eq 'Cancel') {
			&set_status($status, 'Quit canceled.');
			return;
		}
		&save_choice if $yn eq 'Yes';
	}
    exit;
} # &exit_choice

sub new_choice {

    &set_status($status, 'New file.');
	&create_newrecipewindow;

} # &new_choice

sub open_choice {
	&set_status($status, 'Open cookbook.');
	my $open_dialog = $main->FileDialog(-Title=>'Open Cookbook',
	                                    -Create=>0,
	                                    -FPat=>'*.rec',
	                                    -Path=>$cb_path,
	                                    -File=>$cb_file,
	                                    -OKButtonLabel=>'Open',
	                                    -ShowAll=>'YES');

	# bind mouse wheel to scrollbar
	&bind_mouse_wheel($open_dialog);
	
	my $new_cb = $open_dialog->Show;

	# check if 'cancel' pressed
	unless(defined($new_cb)) {
		&set_status($status, 'Open canceled.');
		return;
	}

	$cb = $new_cb;
	$cb_path = dirname($cb);
	$cb_file = basename($cb);

	&open_cookbook;
} # &open_choice

#----------
# open_cookbook
# call this once we know the name of the book we want to open
# args: none
#  - *should* accept path to the cookbook, or even just a reference
#    to a Cookbook object that I'm not going to write. I don't
#    want any more modules than I already have for this project.
#----------
sub open_cookbook {
	my $tmp_title = undef;
	my $tmp_serves = undef;
	my @tmp_ings;
	my @tmp_dirs;

	my $cmd;			# the first part of the line.
	my $line;			# the rest of the line

	my $newrec;			# the recipe just read in

	return unless open(CB, $cb);

	# get rid of what's there now, both in %cookbook and
	# in the listbox on the main window.
	&delete_all;

	# read in cookbook.
	while(<CB>) {

		next if /^\s+$/;

		chomp;

		# format is like:
		# title:	A Recipe
		#         ^--- this is a TAB, not spaces.
		($cmd, $line) = split /:\t/;

		# are we at the end of this recipe?
		if( $cmd =~ /\s*---END\s*/ ) {

			# need a real title to hash correctly.
			# don't destroy window, though, in case user can repent.
			if(!defined($tmp_title) || $tmp_title =~ /^\s*$/) {
				&error_dialog('No title defined. Recipe not added.');
				undef $tmp_title;
				undef $tmp_serves;
				undef @tmp_ings;
				undef @tmp_dirs;
				next;
			}

			# create and save new recipe
			$newrec = new Rec::Recipe;
			$newrec->title($tmp_title);
			$newrec->serves($tmp_serves);
			$newrec->ingredients(@tmp_ings);
			$newrec->directions(@tmp_dirs);
			$cookbook{$tmp_title} = $newrec;

			# blanking these are necessary
			undef $tmp_title;
			undef $tmp_serves;
			undef @tmp_ings;
			undef @tmp_dirs;
			next;
		}

		# strip any leading or trailing whitespace from $line
		# done here, because when the end of a recipe is hit,
		# there is no $line defined.
		for($line) {
			s/^\s+//;
			s/\s+$//;
		}

		if( $cmd =~ /\s*title\s*/ ) {
			&error_dialog('second title found: $tmp_title')
				if defined($tmp_title);
			$tmp_title = $line;
		}
		elsif( $cmd =~ /\s*serves\s*/ ) {
			&error_dialog('second serves found: $tmp_serves')
				if defined($tmp_serves);
			$tmp_serves = $line;
		}
		elsif( $cmd =~ /\s*ing\s*/ ) {
			push(@tmp_ings, $line);
		}
		elsif( $cmd =~ /\s*step\s*/ ) {
			push(@tmp_dirs, $line);
		}
	}
	close CB or &error_dialog("Can't close $cb: $!");

	&set_status($status, "$cb opened.");
	$main->configure(-title=>"rec $VER - $cb_file");

	$need_to_save = $FALSE;

	&refresh_main;
} # &open_cookbook

sub save_choice {
    &set_status($status, 'Saving...');
	my $recipe;

	my $save_dialog = $main->FileDialog(-Title=>'Save Cookbook',
	                                    -FPat=>'*.rec',
	                                    -Path=>$cb_path,
	                                    -File=>$cb_file,
	                                    -OKButtonLabel=>'Save',
	                                    -ShowAll=>'YES');

	# bind mouse wheel to scrollbar
	&bind_mouse_wheel($save_dialog);

	my $new_cb = $save_dialog->Show;

	# check if 'cancel' pressed
	unless(defined($new_cb)) {
		&set_status($status, 'Save canceled.');
		return;
	}

	$cb = $new_cb;
	$cb_path = dirname($cb);
	$cb_file = basename($cb);
	
	unless(open(OUTFILE, ">$cb")) {
		&error_dialog("Can't open $cb: $!\n");
		&set_status($status, "Can't open $cb: $!");
		return;
	}

	foreach (sort keys %cookbook) {
		$recipe = $cookbook{$_};
		print OUTFILE "title:\t".$recipe->title."\n";
		print OUTFILE "serves:\t".$recipe->serves."\n";
		foreach my $ing ($recipe->ingredients) {
			print OUTFILE "ing:\t$ing\n";
		}
		foreach my $dir ($recipe->directions) {
			print OUTFILE "step:\t$dir\n";
		}
		print OUTFILE "---END\n";
	}
	close OUTFILE or &error_dialog("Can't close output file: $!");
	&set_status($status, "Cookbook saved to $cb.");
	$need_to_save = $FALSE;
} # &save_choice

sub about_choice {   
    &set_status($status, "About rec $VER");
	my $msg = "rec version $VER\n\ncopyright 2002-2003\n".
	          'Michael Dungan <mpd@rochester.rr.com>';

	my $dialog_about = $main->messageBox(
		-title		=> "rec - $VER: About",
		-message	=> "$msg",
		-type=>'OK',
		-default=>'OK');
} # &about_choice

sub view_choice {   
    &set_status($status, 'View selected recipe(s).');
	my @selected = $recipe_lb->curselection;
	return if @selected <= 0;
	foreach(@selected) {
		&view_recipe($recipe_lb->get($_));
	}
} # &view_choice

sub edit_choice {   
    &set_status($status, 'Edit selected recipe(s).');
	my @selected = $recipe_lb->curselection;
	return if @selected <= 0;
	foreach(@selected) {
		&edit_recipe($recipe_lb->get($_));
	}
} # &edit_choice

sub delete_choice {   
	&set_status($status, 'Delete selected recipe(s).');
	my @selected = $recipe_lb->curselection;
	return if @selected <= 0;

	my $r = 'recipes';
	$r = 'recipe' if @selected == 1;

	my $dialog_delete = $main->Dialog(
		-title		=> 'Delete',
		-text		=> "Delete selected $r?",
		-default_button => 'Cancel',
		-buttons	=> ['Ok', 'Cancel']);

	my $yn = $dialog_delete->Show;

	if($yn eq 'Cancel') {
		&set_status($status, 'Delete canceled.');
		return;
	}

	my $title;

	# must be reverse, as deleting from the listbox updates
	# the indices of the other elements immediately, so we
	# need to remove from the bottom->top.
	foreach(@selected) {
		$title = $recipe_lb->get($_);
		next unless $title;
		delete $cookbook{$title};
	}
	# for some reason, this must be done separately.
	# if you put this in foreach above, you WILL get
	# bugs.
	foreach(reverse sort @selected) {
		$recipe_lb->delete($_);
	}
	$r = 'Recipes';
	$r = 'Recipe' if @selected == 1;
	&set_status($status, "$r deleted.");

	&refresh_main;

	$need_to_save = $TRUE;
} # &delete_choice

#----------
# view_recipe
# arguments: 0: $title - string representing the title of the recipe to view.
#----------
sub view_recipe
{
	my $title = $_[0];
	my $rec = $cookbook{$title};

	# recipe window
	my $view_recipe_top = $main->Toplevel;
	$view_recipe_top->title($title);

	# title, serves frame
	my $view_title_frame = $view_recipe_top->Frame(
	                                              -relief=>'raised',
	                                              -borderwidth=>2);

	my $view_title_label = $view_title_frame->Label(
	                          -text=>"Title: $title");
	
	my $serves = $rec->serves;
	my $view_serves_label = $view_title_frame->Label(
	                          -text=>"Serves: $serves");
	
	$view_title_label->pack(-side=>'left');

	$view_serves_label->pack(-side=>'right');

	$view_title_frame->pack(-side=>'top', -fill=>'x');

	# ingredients/directions label frame
	my $ingdir_label_frame = $view_recipe_top->Frame(
	                              -relief=>'raised',
	                              -borderwidth=>2);

	# ingredients frame and label
	my $i_label_frame = $ingdir_label_frame->Frame(
	                              -borderwidth=>2);
	my $ingredients_label = $i_label_frame->Label(
	                          -text=>'Ingredients');
	
	# directionsframe and label
	my $d_label_frame = $ingdir_label_frame->Frame(
	                              -borderwidth=>2);
	my $directions_label = $d_label_frame->Label(
	                          -text=>'Directions');
	$i_label_frame->pack(-side=>'left');
	$d_label_frame->pack(-side=>'right');

	$ingredients_label->pack();
	$directions_label->pack();

	$ingdir_label_frame->pack(-side=>'top', -fill=>'x');

	# listbox frame
	my $view_recipe_frame = $view_recipe_top->Frame(
	                              -relief=>'raised',
	                              -borderwidth=>2);
	
	# Ingredients Textbox
	my $view_ing_tb = $view_recipe_frame->Scrolled('Text',
                                  -scrollbars=>'oe',
                                  -height=>20,
	                              -width=>40,
	                              -wrap=>'word',
	                              -background=>'white'
	                             );
	# bind mouse wheel to scrollbar
	&bind_mouse_wheel($view_ing_tb);

	#insert all the ingredients
	my @ings = $rec->ingredients;
	my $ingstr = join("\n\n", @ings);
	$view_ing_tb->insert('end', $ingstr);
	$view_ing_tb->configure(-state=>'disabled');
	
	# Directions Textbox
	my $view_dir_tb = $view_recipe_frame->Scrolled('Text',
                                  -scrollbars=>'oe',
	                              -height=>20,
	                              -width=>40,
	                              -wrap=>'word',
	                              -background=>'white'
	                             );
	# bind mouse wheel to scrollbar
	&bind_mouse_wheel($view_dir_tb);

	#insert directions
	my @dirs = $rec->directions;
	my $dirstr = join("\n\n", @dirs);
	$view_dir_tb->insert('end', $dirstr);
	$view_dir_tb->configure(-state=>'disabled');

	# pack to the left
	$view_ing_tb->pack(-side=>'left', -expand=>1, -fill=>'both');
	$view_dir_tb->pack(-side=>'left', -expand=>1, -fill=>'both');

	$view_recipe_frame->pack(-side=>'top', -expand=>1, -fill=>'both');

	# Dismiss button frame, w/ button
	my $view_recipe_buttonbar = $view_recipe_top->Frame(-relief=>'raised',
	                                                  -borderwidth=>2);

	my $view_recipe_dismiss_button = $view_recipe_buttonbar->Button(
	                                   text=>'Dismiss',
	                                   command=>sub {
	                                     $view_recipe_top->destroy
	                                   });

	$view_recipe_dismiss_button->pack(-side=>'right');

	$view_recipe_buttonbar->pack(-side=>'top',
	                            -fill=>'x');

	$view_recipe_top->bind('<Escape>'    => sub {$view_recipe_top->destroy});

} # &view_recipe

#----------
# create_mainwindow
#----------
sub create_mainwindow
{
	# main window
	$main = MainWindow->new(-width=>587, -height=>449);
	$main->title("rec - $VER");
	$main->minsize(qw(587 449));
	
	# menubar
	$menubar = $main->Frame(-relief=>'raised',
	    -borderwidth=>2);
	
	# File menu.
	$filebutton = $menubar->Menubutton(-text=>'File',
	    -underline => 0);
	
	# Menus are children of Menubuttons.
	$filemenu = $filebutton->Menu;
	
	# Associate Menubutton with Menu.
	$filebutton->configure(-menu=>$filemenu);
	
	# Create menu choices.
	$filemenu->command(-command => \&open_choice,
	    -label => 'Open',
	    -underline => 0);
	
	$filemenu->command(-command => \&save_choice,
	    -label => 'Save',
	    -underline => 0);
	
	$filemenu->separator;
	
	$filemenu->command(-label => 'Quit',
	    -command => \&exit_choice,
	    -underline => 0); 

	# Recipe menu.
	$recipebutton = $menubar->Menubutton(-text=>'Recipe',
	    -underline => 0);
	
	$recipemenu = $recipebutton->Menu;

	$recipebutton->configure(-menu=>$recipemenu);

	$recipemenu->command(-command => \&new_choice,
	    -label => 'New',
	    -underline => 0);

	$recipemenu->command(-command => \&edit_choice,
	    -label => 'Edit',
	    -underline => 0);
	
	$recipemenu->command(-command => \&delete_choice,
	    -label => 'Delete',
	    -underline => 0);

	$recipemenu->separator;

	$recipemenu->command(-command => \&view_choice,
	    -label => 'View',
	    -underline => 0);
	
	# Help menu.
	$helpbutton = $menubar->Menubutton(-text=>'Help',
	    -underline => 0);

	$helpmenu = $helpbutton->Menu;

	$helpmenu->command(-command => \&about_choice,
	    -label => 'About',
	    -underline => 0);

	$helpbutton->configure(-menu=>$helpmenu);



	# pack to the left
	$filebutton->pack(-side=>'left');
	$recipebutton->pack(-side=>'left');

	# except help.
	$helpbutton->pack(-side=>'right');

	$menubar->pack(-side=>'top', -fill=>'x');

	# frame containing search stuff
	$searchframe = $main->Frame(-borderwidth=>2);
	$searchentry = $searchframe->Entry(-width=>40);

	$searchentry->bind('<Return>' => \&search_choice);

	$searchbutton = $searchframe->Button(-text=>'Search',
	                                     -command=> \&search_choice);
	$resetbutton = $searchframe->Button(-text=>'Reset',
	                                    -command=>sub {
	                                      $searchentry->delete(0, 'end');
										  &set_status($status,
    										"Search reset.");
	                                      &refresh_main;
	                                     });
	$searchframe->pack;
	$searchentry->pack(-side=>'left');
	$searchbutton->pack(-side=>'left');
	$resetbutton->pack(-side=>'left');

	# listbox
	$recipe_lb = $main->Scrolled('Listbox',
                                 -scrollbars=>'osoe',
                                 -height => 20,
	                             -width => 60,
	                             -selectmode => 'extended'
	                            );

	# bind for double clicking
	$recipe_lb->bind('<Double-ButtonPress-1>' => \&view_choice);
	# bind to the mouse wheel
	&bind_mouse_wheel($recipe_lb);

   
	# Set to expand, with padding.
	$recipe_lb->pack(-side=>"top", -expand=>1, -fill=>'both');

	# button bar
	$buttonbar = $main->Frame(-borderwidth=>2);
	
	$new_button = $buttonbar->Button(text    => 'New',
	                       command => \&new_choice);
	
	$edit_button = $buttonbar->Button(text    => 'Edit',
	                       command => \&edit_choice);
	
	$open_button = $buttonbar->Button(text    => 'Open',
	                       command => \&open_choice);
	
	$save_button = $buttonbar->Button(text    => 'Save',
	                       command => \&save_choice);
	
	$view_button = $buttonbar->Button(text    => 'View',
	                       command => \&view_choice);
	
	$delete_button = $buttonbar->Button(text    => 'Delete',
	                       command => \&delete_choice);
	
	$delete_button->pack(-side=>'right');
	$view_button->pack(-side=>'right');
	$save_button->pack(-side=>'right');
	$open_button->pack(-side=>'right');
	$edit_button->pack(-side=>'right');
	$new_button->pack(-side=>'right');

	$buttonbar->pack(-fill=>'x');

	# status area
	$status = $main->Label(-text=>"rec - $VER",
	    -relief=>'sunken',
	    -borderwidth=>2,
	    -anchor=>"w");   

	$status->pack(-side=>'top', -fill=>'x');

	# key bindings
	$main->bind('<Control-n>' => \&new_choice);
	$main->bind('<Control-e>' => \&edit_choice);
	$main->bind('<Control-o>' => \&open_choice);
	$main->bind('<Control-s>' => \&save_choice);
	$main->bind('<Control-v>' => \&view_choice);
	$main->bind('<Control-d>' => \&delete_choice);
	$main->bind('<Delete>'    => \&delete_choice);
	$main->bind('<Control-q>' => \&exit_choice);
	
} # &create_mainwindow

#----------
# create_newrecipewindow
#----------
sub create_newrecipewindow
{
	# recipe window
	my $new_recipe_top = $main->Toplevel(-width=>587, -height=>429);
	$new_recipe_top->title("rec - New Recipe");
	$new_recipe_top->minsize(qw(587 429));

	# title, serves frame
	my $new_title_frame = $new_recipe_top->Frame(
	                                              -relief=>'raised',
	                                              -borderwidth=>2);
	my $new_title_label = $new_title_frame->Label(
	                          -text=>'Title: ');
	my $new_title_entry = $new_title_frame->Entry(
	                          -width=>40,
	                          -background=>'white');
	
	$new_recipe_top->Advertise('title_entry'=>$new_title_entry);

	my $new_serves_label = $new_title_frame->Label(
	                          -text=>'Serves: ');
	my $new_serves_entry = $new_title_frame->Entry(
	                          -width=>4,
	                          -background=>'white');

	$new_recipe_top->Advertise('serves_entry'=>$new_serves_entry);
	
	$new_title_label->pack(-side=>'left');
	$new_title_entry->pack(-side=>'left');

	$new_serves_entry->pack(-side=>'right');
	$new_serves_label->pack(-side=>'right');

	$new_title_frame->pack(-side=>'top', -fill=>'x');

	# ingredients/directions label frame
	my $ingdir_label_frame = $new_recipe_top->Frame(
	                              -relief=>'raised',
	                              -borderwidth=>2);

	# ingredients frame and label
	my $i_label_frame = $ingdir_label_frame->Frame(
	                              -borderwidth=>2);
	my $ingredients_label = $i_label_frame->Label(
	                          -text=>'Ingredients');
	
	# directionsframe and label
	my $d_label_frame = $ingdir_label_frame->Frame(
	                              -borderwidth=>2);
	my $directions_label = $d_label_frame->Label(
	                          -text=>'Directions');
	$i_label_frame->pack(-side=>'left');
	$d_label_frame->pack(-side=>'right');

	$ingredients_label->pack();
	$directions_label->pack();

	$ingdir_label_frame->pack(-side=>'top', -fill=>'x');

	# listbox frame
	my $new_recipe_frame = $new_recipe_top->Frame(
	                                              -relief=>'raised',
	                                              -borderwidth=>2);
	
	# Ingredients Textbox
	my $new_ing_tb = $new_recipe_frame->Scrolled('Text',
                                  -scrollbars=>'oe',
                                  -height=>20,
	                              -width=>40,
	                              -wrap=>'word',
	                              -background=>'white'
	                             );
	
	# bind mouse wheel to scrollbar
	&bind_mouse_wheel($new_ing_tb);

	$new_recipe_top->Advertise('ing_box'=>$new_ing_tb);

	# Directions Textbox
	my $new_dir_tb = $new_recipe_frame->Scrolled('Text',
                                  -scrollbars=>'oe',
	                              -height=>20,
	                              -width=>40,
	                              -wrap=>'word',
	                              -background=>'white'
	                             );

	# bind mouse wheel to scrollbar
	&bind_mouse_wheel($new_dir_tb);

	$new_recipe_top->Advertise('dir_box'=>$new_dir_tb);

	# pack to the left
	$new_ing_tb->pack(-side=>'left', -expand=>1, -fill=>'both');
	$new_dir_tb->pack(-side=>'left', -expand=>1, -fill=>'both');

	$new_recipe_frame->pack(-side=>'top', -expand=>1, -fill=>'both');

	# OK button frame, w/ button
	my $new_recipe_buttonbar = $new_recipe_top->Frame(-relief=>'raised',
	                                                  -borderwidth=>2);

	my $new_recipe_ok_button = $new_recipe_buttonbar->Button(text=>'Ok',
	                               command=>[\&new_recipe_ok,
	                                         $new_recipe_top]);

	my $new_recipe_cancel_button = $new_recipe_buttonbar->
	                           Button(text=>'Cancel',
	                           command=>sub {
	                           &set_status($status, 'New recipe canceled');
	                           $new_recipe_top->destroy;
	                           } );


	$new_recipe_cancel_button->pack(-side=>'right');
	$new_recipe_ok_button->pack(-side=>'right');

	$new_recipe_buttonbar->pack(-side=>'top',
	                            -fill=>'x');
} # &create_newrecipewindow

#----------
# new_recipe_ok
# what happens when the "ok" button is clicked when created a new recipe.
# arguments:
#     0: new_recipe_top - ref to new recipe toplevel - need to destroy.
#----------
sub new_recipe_ok {
	my $new_recipe_top = $_[0];
	my $title = $new_recipe_top->Subwidget('title_entry')->get;

	# if a recipe with the same name is there already, this
	# is an error.
	if(exists $cookbook{$title}) {
		my $msg = "Duplicate title - \"$title.\" Recipe not saved.";
		&set_status($status, $msg);
		&error_dialog($msg);
		return;
	}

	# we need a real title to hash the recipe. therefore, it's
	# an error if there isn't one present.
	if( $title =~ /^\s*$/ ) {
		&set_status($status, 'No title entered. Recipe not saved.');
		&error_dialog('No title entered. Recipe not saved.');
		return;
	}

	# strip leading and trailing whitespace
	for($title) {
		s/^\s+//;
		s/\s+$//;
	}

	# truncate title to 40 characters
	$title = substr($title, 0, 40) if length($title) > 40;

	my $recipe = new Rec::Recipe;
	$recipe->title($title);

	my $serves = $new_recipe_top->Subwidget('serves_entry')->get;
	for($serves) {
		s/^\s+//;
		s/\s+$//;
	}
	# truncate serves to 4 characters
	$serves = substr($serves, 0, 4) if length($serves) > 4;
	$recipe->serves($serves);

	my $line;
	my @ings;
	my $ing_box = $new_recipe_top->Subwidget('ing_box');
	$line = $ing_box->get('1.0', 'end');
	@ings = split(/\n/, $line);

	foreach(@ings) {
		s/^\s+//;
		s/\s+$//;
	}

	$recipe->ingredients(@ings);

	my @dirs;
	my $dir_box = $new_recipe_top->Subwidget('dir_box');
	$line = $dir_box->get('1.0', 'end');
	@dirs = split(/\n/, $line);

	foreach(@dirs) {
		s/^\s+//;
		s/\s+$//;
	}

	$recipe->directions(@dirs);

	$cookbook{$title} = $recipe;
	$need_to_save = $TRUE;
	&refresh_main;
	&set_status($status, "\"$title\" added.");
	$new_recipe_top->destroy;
} # &new_recipe_ok

sub delete_all {
	undef %cookbook;
	$recipe_lb->delete(0,'end');
} # &delete_all

sub refresh_main {
	$recipe_lb->delete(0,'end');
	foreach(sort keys %cookbook) {
		$recipe_lb->insert('end', $_);
	}
} # &refresh_main

#----------
# error_dialog
# args: $msg: A string representing the message to put in the box.
#----------
sub error_dialog
{
	my $msg = shift;
	return unless $msg;

	my $dialog_error = $main->messageBox(
		-title		=> 'Error',
		-message	=> "$msg",
		-type=>'OK',
		-default=>'OK');
} # &error_dialog

#----------
# edit_recipe
# args: $rec_title: a string representing the title of the recipe to edit.
#----------
sub edit_recipe
{
	my ($rec_title) = @_;
	my $rec = $cookbook{$rec_title};

	# recipe window
	my $edit_recipe_top = $main->Toplevel;
	$edit_recipe_top->title($rec_title);

	# title, serves frame
	my $edit_title_frame = $edit_recipe_top->Frame(
	                                              -relief=>'raised',
	                                              -borderwidth=>2);

	my $edit_title_label = $edit_title_frame->Label(
	                          -text=>'Title: ');
	my $edit_title_entry = $edit_title_frame->Entry(
	                          -width=>40,
	                          -background=>'white');
	$edit_recipe_top->Advertise('title_entry'=>$edit_title_entry);
	$edit_title_entry->insert(0, $rec_title);
	
	my $edit_serves_label = $edit_title_frame->Label(
	                          -text=>'Serves: ');
	my $edit_serves_entry = $edit_title_frame->Entry(
	                          -width=>4,
	                          -background=>'white');

	$edit_recipe_top->Advertise('serves_entry'=>$edit_serves_entry);

	$edit_serves_entry->insert(0, $rec->serves);
	
	$edit_title_label->pack(-side=>'left');
	$edit_title_entry->pack(-side=>'left');

	$edit_serves_entry->pack(-side=>'right');
	$edit_serves_label->pack(-side=>'right');

	$edit_title_frame->pack(-side=>'top', -fill=>'x');

	# ingredients/directions label frame
	my $ingdir_label_frame = $edit_recipe_top->Frame(
	                              -relief=>'raised',
	                              -borderwidth=>2);

	# ingredients frame and label
	my $i_label_frame = $ingdir_label_frame->Frame(
	                              -borderwidth=>2);
	my $ingredients_label = $i_label_frame->Label(
	                          -text=>'Ingredients');
	
	# directionsframe and label
	my $d_label_frame = $ingdir_label_frame->Frame(
	                              -borderwidth=>2);
	my $directions_label = $d_label_frame->Label(
	                          -text=>'Directions');
	$i_label_frame->pack(-side=>'left');
	$d_label_frame->pack(-side=>'right');

	$ingredients_label->pack();
	$directions_label->pack();

	$ingdir_label_frame->pack(-side=>'top', -fill=>'x');

	# listbox frame
	my $edit_recipe_frame = $edit_recipe_top->Frame(
	                              -relief=>'raised',
	                              -borderwidth=>2);
	
	# Ingredients Textbox
	my $edit_ing_tb = $edit_recipe_frame->Scrolled('Text',
                                  -scrollbars=>'oe',
                                  -height=>20,
	                              -width=>40,
	                              -wrap=>'word',
	                              -background=>'white'
	                             );
	# bind mouse wheel to scrollbar
	&bind_mouse_wheel($edit_ing_tb);

	$edit_recipe_top->Advertise('ing_box'=>$edit_ing_tb);

	#insert all the ingredients
	my @ings = $rec->ingredients;
	my $ingstr = join("\n", @ings);
	$edit_ing_tb->insert('end', $ingstr);
	
	# Directions Textbox
	my $edit_dir_tb = $edit_recipe_frame->Scrolled('Text',
                                  -scrollbars=>'oe',
	                              -height=>20,
	                              -width=>40,
	                              -wrap=>'word',
	                              -background=>'white'
	                             );
	# bind mouse wheel to scrollbar
	&bind_mouse_wheel($edit_dir_tb);

	$edit_recipe_top->Advertise('dir_box'=>$edit_dir_tb);

	#insert directions
	my @dirs = $rec->directions;
	my $dirstr = join("\n", @dirs);
	$edit_dir_tb->insert('end', $dirstr);

	# pack to the left
	$edit_ing_tb->pack(-side=>'left', -expand=>1, -fill=>'both');
	$edit_dir_tb->pack(-side=>'left', -expand=>1, -fill=>'both');

	$edit_recipe_frame->pack(-side=>'top', -expand=>1, -fill=>'both');

	# Dismiss button frame, w/ button
	my $edit_recipe_buttonbar = $edit_recipe_top->Frame(-relief=>'raised',
	                                                  -borderwidth=>2);

	my $edit_recipe_cancel_button = $edit_recipe_buttonbar->Button(
	                                   -text=>'Cancel',
	                                   -command=>sub {
	                                     &set_status($status, 
	                                       "Edit \"$rec_title\" canceled."),
	                                     $edit_recipe_top->destroy
	                                   });

	my $edit_recipe_save_button = $edit_recipe_buttonbar->Button(
	                                   -text=>'Save',
	                                   -command=>[\&edit_rec_save,
	                                              $rec_title,
	                                              $edit_recipe_top]
	                                   );

	$edit_recipe_cancel_button->pack(-side=>'right');
	$edit_recipe_save_button->pack(-side=>'right');

	$edit_recipe_buttonbar->pack(-side=>'top',
	                             -fill=>'x');

} # &edit_recipe

#----------
# edit_rec_save - save a freshly edited recipe to the cookbook
# arguments: 0 - the old title of the recipe, to delete from cookbook
#            1 - reference to the toplevel widget, as it needs to be destroyed
#----------
sub edit_rec_save
{
	my ($old_title, $edit_recipe_top) = @_;
	my $recipe = $cookbook{$old_title};

	my $title_entry = $edit_recipe_top->Subwidget('title_entry');
	my $title = $title_entry->get;

	# if a recipe with the same name is there already, this
	# is an error, but only if the new title is different
	# from the old one.
	if($title ne $old_title) {
		if(exists $cookbook{$title}) {
			my $msg = "Duplicate title - \"$title.\" Recipe not saved.";
			&set_status($status, $msg);
			&error_dialog($msg);
			# reset edit window's title
			$title_entry->delete(0, 'end');
			$title_entry->insert(0, $old_title);
			return;
		}
	}

	# we need a real title to hash the recipe. therefore, it's
	# an error if there isn't one present.
	if( $title =~ /^\s*$/ ) {
		&set_status($status, 'No title entered. Recipe not saved.');
		return;
	}

	# good to go here.
	for($title) {
		s/^\s+//;
		s/\s+$//;
	}
	$recipe->title($title);

	my $serves = $edit_recipe_top->Subwidget('serves_entry')->get;
	for($serves) {
		s/^\s+//;
		s/\s+$//;
	}
	$recipe->serves($serves);

	my $line;

	my @ings;
	my $ing_box = $edit_recipe_top->Subwidget('ing_box');
	$line = $ing_box->get('1.0', 'end');
	@ings = split(/\n/, $line);
	foreach(@ings) {
		s/^\s+//;
		s/\s+$//;
	}
	$recipe->ingredients(@ings);

	my @dirs;
	my $dir_box = $edit_recipe_top->Subwidget('dir_box');
	$line = $dir_box->get('1.0', 'end');
	@dirs = split(/\n/, $line);
	foreach(@dirs) {
		s/^\s+//;
		s/\s+$//;
	}
	$recipe->directions(@dirs);

	delete $cookbook{$old_title};
	$cookbook{$title} = $recipe;
	$need_to_save = $TRUE;
	&refresh_main if $title ne $old_title;
	&set_status($status, "\"$title\" saved.");
	$edit_recipe_top->destroy;
} # &edit_rec_save

# the user wants to search for a string
sub search_choice {
	my @recipes;	# all the recipes
	my $str = $searchentry->get;
	return unless $str;
	my $regstr = &glob2pat($str);
	$regstr = qr/$regstr/;
	my $result_count = 0;

	$recipe_lb->delete(0,'end');
	SEARCHLOOP:
	foreach(sort keys(%cookbook)) {
		#search through the current recipe
		my $recipe = $cookbook{$_};
		#search parts of recipe. go to next recipe if a match is found
		if(lc($_) =~ /$regstr/) { # title check
			$recipe_lb->insert('end', $_);
			$result_count++;
			next;
		}
		# repeat for ingredients (no reason that I can think
        #                         of to do w/ directions)
		my @ings = $recipe->ingredients;
		foreach my $ing (@ings) {
			if(lc($ing) =~ /$regstr/) {
				$recipe_lb->insert('end', $_);
				$result_count++;
				next SEARCHLOOP;
			}
		}
	}
	&set_status($status, "$result_count results returned.");
}

# set_status
# throw a line into the status bar
# args: $stat - the status bar
#       $str  - the string to put there
sub set_status {
	my ($stat, $str) = @_;
	$stat->configure(text=>$str);
}

# I didn't write this one. It was taken from a posting by Slaven Rezic
# on comp.lang.perl.tk. It should be mostly platform independent.
# Please send patches if it isn't.
#
# bind_mouse_wheel - bind the mouse wheel to the given scrolled widget
# arguments : reference to scrolled widget to bind the wheel to.
sub bind_mouse_wheel {

	my($w) = @_;

	if ($^O eq 'MSWin32') {
		$w->bind('<MouseWheel>' =>
			[ sub { $_[0]->yview('scroll', -($_[1] / 120) * 3, 'units') },
				Ev('D') ]
		);
	}
	else {
		# Support for mousewheels on Linux commonly comes through
		# mapping the wheel to buttons 4 and 5.  If you have a
		# mousewheel ensure that the mouse protocol is set to
		# "IMPS/2" in your /etc/X11/XF86Config (or XF86Config-4)
		# file:
		#
		# Section "InputDevice"
		#     Identifier  "Mouse0"
		#     Driver      "mouse"
		#     Option      "Device" "/dev/mouse"
		#     Option      "Device" "/dev/sysmouse" <-- FreeBSD
		#     Option      "Protocol" "IMPS/2"
		#     Option      "Emulate3Buttons" "off"
		#     Option      "ZAxisMapping" "4 5"
		# EndSection

		$w->bind('<4>' => sub {
			$_[0]->yview('scroll', -3, 'units') unless $Tk::strictMotif;
		});

		$w->bind('<5>' => sub {
			$_[0]->yview('scroll', +3, 'units') unless $Tk::strictMotif;
		});
	}
} # &bind_mouse_wheel

# glob2pat
# change a shell-wildcard type pattern into a perl regular expression
# arg: $globstr: the wildcard pattern to convert
# This was taken directly from the Perl Cookbook with one small modification
sub glob2pat {
	my $globstr = shift;
	my %patmap = (
		'*' => '.*',
		'?' => '.',
		'[' => '[',
		']' => ']',
	);
	$globstr =~ s{(.)} { $patmap{$1} || "\Q$1" }ge;
	return '^.*' . $globstr . '.*$';
}  

