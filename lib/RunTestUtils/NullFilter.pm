package RunTestUtils::NullFilter;

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

use base qw/RunTestUtils::Filter/;
use boolean;

=pod

=head1 NAME

RunTestUtils::NullFilter - A null filter.

=head1 SYNOPSIS

This contains a null filter, that is a filter that never changes its input.

This class inherits from RunTestUtils::Filter.

=head1 METHODS

The methods for this module are listed here:

=over 4

=cut

#============================================================================#

=pod

=item I<Public>: B<filter_testname>

Override the filter_testname method to perform the filtering.  This is
currently just a dump of all the original filters into one place.

=cut

sub filter_testname {
  my $self = shift;
  my $tool = shift;
  my $path = shift;
  my $name = shift;

  # No filtering here.

  return $name;
}

#============================================================================#

=pod

=back

=cut

#============================================================================#
#Return value of true so that this file can be used as a module.
1;
