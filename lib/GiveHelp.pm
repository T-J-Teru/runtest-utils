package GiveHelp;

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

=pod

=head1 SYNOPSIS

Allows people to use a -h or --help option.

=head1 METHODS

This package has only a single BEGIN block, which checks for 
a -h or  --help option on the command line. If any of these
are found then it will exec perldoc on the original application
using the variable $0.

=over 4

=cut

#========================================================================#

use Getopt::Long;
use boolean;
use Pod::Usage;
use File::Basename;

require Exporter;
use base qw/Exporter/;
our @EXPORT_OK = qw/usage/;

#========================================================================#

=pod

=item B<usage>

Displays a usage message by printing the original modules
perldoc. This method doesn't return.

=cut

sub usage {
  my $message = shift;

  defined $message or
    $message = ( "Invalid use of ".basename($0).
                 ", please read help carefully and try again.\n\n");

  pod2usage({-message => $message,
             -verbose => 1,
             -exitval => 1});
  # Never gets here #

  die "No help available for $0\n";
}

#========================================================================#

=pod

=item B<BEGIN>

Check for command line arguments.

=cut

sub BEGIN {
  my $help = false;

  Getopt::Long::Configure('pass_through');
  GetOptions('help|h' => \$help);
  Getopt::Long::Configure('no_pass_through');

  if ($help) {
    usage(""); # Empty string to silence default message.
    # NEVER GETS HERE #
  }
}

#========================================================================#

=pod

=back 4

=cut

#========================================================================#
#Return value of true so that this file can be used as a module.
1;
