package RunTestUtils::FilterManager;

use strict;
use warnings;
no indirect;
no autovivification;

use Carp;
use Carp::Assert;
use Module::Load;

use RunTestUtils::GenericFilter;

my $FILTERS = {};

=pod

=head1 NAME

RunTestUtils::FilterManager - Manage all result filters.

=head1 SYNOPSIS

  Quick code sample should go here...

=head1 METHODS

The methods for this module are listed here:

=over 4

=cut

#========================================================================#

=pod

=item I<Public, Static>: B<register_filter>

Takes the name of a tool, and a filter object.  Registers the filter as
handling that tool.

=cut

sub register_filter {
  my $tool = shift;
  my $filter = shift;
  assert ($filter->isa ('RunTestUtils::Filter'));
  $FILTERS->{$tool} = $filter;
}

#========================================================================#

=pod

=item I<Public, Static>: B<find_filter>

Takes the name of a tool, finds a suitable filter object for that tool.  If
no suitable filter was found then a new RunTestUtils::GenericFilter is
created and returned.

=cut

sub find_filter {
  my $tool = shift;

  my $filter = $FILTERS->{$tool};
  (defined $filter)
    or $filter = RunTestUtils::GenericFilter->new (-tool => $tool);
  return $filter;
}

#========================================================================#

=pod

=item I<Public, Static>: B<load_filters>

Takes the path from which filter files should be loaded.

=cut

sub load_filters {
  my $path = shift;

  (-d $path) or
    croak ("invalid path for load_filters: $path");

  opendir my $dh, $path or
    croak ("failed to open filters directory $path: $!");

  while (readdir $dh)
  {
    next if (m/^\./);
    next unless (m/\.pm$/);
    Module::Load::load ("$path/$_");
  }

  closedir $dh or
    croak ("failed to close filters directory $path: $!");
}

#========================================================================#

=pod

=back

=head1 AUTHOR

Andrew Burgess, 04 May 2019

=cut

#========================================================================#
#Return value of true so that this file can be used as a module.
1;
