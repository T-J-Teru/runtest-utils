package RunTestUtils::Filter::GDB;

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

use base qw/RunTestUtils::GenericFilter/;
use RunTestUtils::FilterManager;

sub filter_testname {
  my $self = shift;
  my $tool = shift;
  my $path = shift;
  my $name = shift;

  # Apply filters from parent.
  my $testname = $self->SUPER::filter_testname ($tool, $path, $name);

  # Now apply any filters specific to this tool.
  # ...

  return $testname;
}

RunTestUtils::Filter::GDB->new (-tool => "gdb");

return 1;
