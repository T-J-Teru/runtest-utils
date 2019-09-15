package RunTestUtils::FilterManager;

# This file is part of runtest-utils.
#
# runtest-utils is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# runtest-utils is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with runtest-utls.  If not, see <https://www.gnu.org/licenses/>.

use strict;
use warnings;
no indirect;
no autovivification;

use Carp;
use Carp::Assert;
use Module::Load;
use boolean;

use RunTestUtils::GenericFilter;
use RunTestUtils::NullFilter;

my $FILTERS = {};

my $FILTERS_LOADED = false;

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

  my $filter = undef;
  if (not $FILTERS_LOADED)
  {
    $filter = RunTestUtils::NullFilter->new (-tool => $tool);
  }
  else
  {
    $filter = $FILTERS->{$tool};
    (defined $filter)
      or $filter = RunTestUtils::GenericFilter->new (-tool => $tool);
  }
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

  $FILTERS_LOADED = true;
}

#========================================================================#

=pod

=back

=cut

#========================================================================#
#Return value of true so that this file can be used as a module.
1;
