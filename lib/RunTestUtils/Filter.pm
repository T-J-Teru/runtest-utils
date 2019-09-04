package RunTestUtils::Filter;

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

=pod

=head1 NAME

RunTestUtils::Filter - Parent class for all filter objects.

=head1 SYNOPSIS

All filters should inherit from this and override the filter_testname
method.

  use base qw/RunTestUtils::Filter/;

  sub filter_testname {
    my ($self, $tool, $path, $name) = @_;

    # Filter $name

    return $name;
  }

=head1 METHODS

The methods for this module are listed here:

=over 4

=cut

#========================================================================#

=pod

=item I<Public>: B<filter_testname>

Sub-classes must override this method.  It takes 4 parameters, the first is
the object itself all of the rest are strings.  These are, the name of the
tool being filtered, the path of the tests script within the testsuite from
which this test came, and the original full test name as it appears in the
summary file.

This method should return the filtered test name string.

=cut

sub filter_testname {
  my $self = shift;
  croak ("failed to override filter_testname method");
}

#========================================================================#

=pod

=item I<Public>: B<new>

Create a new instance of RunTestUtils::Filter and then call initialise on
it.  Expects to be passed the I<-tool> named parameter like this:

  package MyFilter;

  use base qw/RunTestUtils::Filter/;

  sub filter_testname {
    # ...
  }

  MyFilter->new (-tool => 'some_tool');

=cut

sub new {
  my $class = shift;

  #-----------------------------#
  # Don't change this method    #
  # Change 'initialise' instead #
  #-----------------------------#

  my $self  = bless {}, $class;
  $self->initialise(@_);
  return $self;
}

#========================================================================#

=pod

=item I<Private>: B<initialise>

Initialise this instance of this class.

=cut

sub initialise {
  my $self = shift;
  my %args = @_;

  my $tool = $args{-tool};
  (defined $tool) or
    die "Missing '--tool' argument";

  RunTestUtils::FilterManager::register_filter ($tool, $self);
}

#========================================================================#

=pod

=back

=cut

#========================================================================#
#Return value of true so that this file can be used as a module.
1;
