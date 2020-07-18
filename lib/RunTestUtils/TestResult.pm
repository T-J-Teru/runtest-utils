package RunTestUtils::TestResult;

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

use boolean;

=pod

=head1 NAME

RunTestUtils::TestResult - A single test results from a DeJaGNU summary file.

=head1 SYNOPSIS

  use RunTestUtils::SumFile;

  my @results = RunTestUtils::SumFile->parse ($filename)->results ();
  foreach my $result (@results)
  {
    print $result->get_directory () ."/". $result->get_filename ()
		."\t". $result->get_status () ."\n";
  }


=head1 METHODS

The methods for this module are listed here:

=over 4

=cut

#========================================================================#

=pod

=item I<Public>: B<get_target>

Return a string, the name of the target for which this is a test result.

=cut

sub get_target {
  my $self = shift;
  return $self->{__target__};
}

#========================================================================#

=pod

=item I<Public>: B<get_original_testname>

Return the original testname for this test.  This is the unfiltered
testname.

=cut

sub get_original_testname {
  my $self = shift;
  return $self->{__original_testname__};
}

#========================================================================#

=pod

=item I<Public>: B<get_toolname>

Return the name of the tool for which this is a test result.

=cut

sub get_toolname {
  my $self = shift;
  return $self->{__tool__};
}

#========================================================================#

=pod

=item I<Public>: B<get_path>

Returns the result of I<get_directory> joined to I<get_filename> with a '/'
character between.

=cut

sub get_path {
  my $self = shift;
  return $self->get_directory () . "/" . $self->get_filename ();
}

#========================================================================#

=pod

=item I<Public>: B<is_pass>

Return true if this test should be considered a passing test.  Currently
this covers PASS, XPASS, KPASS.

=cut

sub is_pass {
  my $self = shift;
  my $status = $self->get_status ();
  return (($status eq "PASS")
            or ($status eq "XPASS")
            or ($status eq "KPASS"));
}

#============================================================================#

=pod

=item I<Public>: B<is_bad>

Return true if this test result is bad, so FAIL, UNRESOLVED, UNTESTED.

=cut

sub is_bad {
  my $self = shift;
  my $status = $self->get_status ();
  return (($status eq "FAIL")
            or ($status eq "UNTESTED")
            or ($status eq "UNRESOLVED"));
}

#========================================================================#

=pod

=item I<Public>: B<get_status>

Return the status of this test as a string.  This can be any of the valid
DeJaGnu test statuses.

=cut

sub get_status {
  my $self = shift;
  return $self->{ __status__ };
}

#========================================================================#

=pod

=item I<Public>: B<get_testname>

Return the name of this test.  The name is based on the string reported by
DeJaGnu, except that the results are filtered to remove some content that
changes based on environment, for example, path names, or process IDs.

=cut

sub get_testname {
  my $self = shift;

  # Return cached testname if it exists.
  return $self->{ __testname__ } if (exists $self->{ __testname__ });

  my $tool = $self->get_toolname ();
  my $filter = RunTestUtils::FilterManager::find_filter ($tool);

  my $testname = $self->{ __original_testname__ };
  $testname = $filter->filter_testname ($tool, $self->get_path (),
                                        $testname);

  # A few, very generic cleanups.
  $testname =~ s/\s*$//;
  $testname =~ s/^\s*//;

  # Cache and return the testname
  $self->{ __testname__ } = $testname;
  return $self->{ __testname__ };
}

#========================================================================#

=pod

=item I<Public>: B<get_filename>

Returns the test script filename without any leading directory, and
example, would be 'my-test.exp'.

=cut

sub get_filename {
  my $self = shift;
  return $self->{ __filename__ };
}

#========================================================================#

=pod

=item I<Public>: B<get_directory>

Returns the directory name containing the test script, these directories
are often used to split tests into related groups.  For example, a test
script with path '/a/b/c/tool.tests/my-test.exp' would return the string
'tool.tests' from this subroutine.

=cut

sub get_directory {
  my $self = shift;
  return $self->{ __directory__ };
}

#========================================================================#

=pod

=item I<Public>: B<get_id>

Returns a string that is, hopefully, unique for each test.  This is
currently made from the results of I<get_directory>, I<get_filename>, and
I<get_testname>, but this could change in the future.

Though this ID should be unique, currently, that's not guaranteed.

=cut

sub get_id {
  my $self = shift;
  return $self->get_directory () ."/".
    $self->get_filename () .": ".
    $self->get_testname ();
}

#========================================================================#

=pod

=item I<Public>: B<new>

Create a new instance of RunTestUtils::TestResult and then call initialise
on it.

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

#============================================================================#

=pod

=item I<Private>: B<initialise>

Initialise this instance of this class.

=cut

sub initialise {
  my $self = shift;
  my %args = @_;

  $self->{ __directory__ } = $args{ -directory };
  $self->{ __filename__ } = $args{ -filename };
  $self->{ __original_testname__ } = $args{ -testname };
  $self->{ __status__ } = $args{ -status };
  $self->{__tool__} = $args{ -tool };
  $self->{__target__} = $args { -target };
}

#============================================================================#

=pod

=back

=cut

#============================================================================#
#Return value of true so that this file can be used as a module.
1;
