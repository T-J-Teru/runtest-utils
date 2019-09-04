package RunTestUtils::SumFile;

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
use RunTestUtils::TestResult;
use boolean;

=pod

=head1 NAME

RunTestUtils::SumFile - Information extracted from a DeJaGNU summary file.

=head1 SYNOPSIS

The following parses a summary file, the name of which is in I<$filename>
and then obtains the list of results.

  use RunTestUtils::SumFile;

  my $summary_file = RunTestUtils::SumFile->parse ($filename);
  my @results = $summary_file->results ();

=head1 METHODS

The methods for this module are listed here:

=over 4

=cut

#========================================================================#

=pod

=item I<Public>: B<results>

Return a list of RunTestUtils::TestResult object that are the results in
this summary file.

=cut

sub results {
  my $self = shift;
  return @{$self->{__results__}};
}

#========================================================================#

=pod

=item I<Public>: B<tool>

Return a string that is the name of the tool for which these test were run
on.

B<NOTE:> Currently the tool name returned is always "unknown".

=cut

sub tool {
  my $self = shift;
  return $self->{__tool__};
}

#========================================================================#

=pod

=item I<Public>: B<parse>

A function to parse the contents of a summary file, return a
RunTestUtils::SumFile object.

=cut

sub parse {
  my $class = shift;
  my $filename = shift;

  # Extract the tool name from the summary file.
  my $toolname = _parse_tool_name ($filename);

  # Parse the results from the summary file.
  my @results = _parse_results ($filename, $toolname);

  # Create a new object and return.
  my $self  = bless {}, $class;
  $self->{__results__} = \@results;
  $self->{__tool__} = $toolname;
  return $self;
}

#========================================================================#

=pod

=item I<Private>: B<_parse_results>

A function to parse the test results out of a summary file, returns a list
of RunTestUtils::TestResult object.

=cut

sub _parse_results {
  my $filename = shift;
  my $toolname = shift;

  my @results;
  open my $in, $filename
    or croak ("Failed to open '$filename': $!");

  my $expfile = { __full_name__ => undef,
                  __file__ => undef,
                  __dir__ => undef };
  my $using_running_lines = true;

  while (<$in>)
  {
    # Some testsuites (like GCC) don't prefix all test results with the
    # name of the exp file being run, instead, we must pull the name from
    # the previous Running line.
    if (m#^Running .*/testsuite/(.*) \.\.\.$#)
    {
      # Some testsuites, such as GDB when run in parallel, don't produce
      # Running lines at all, and we should grab the name of the exp file
      # from the prefix on each test status line.  However, if we get into
      # a state where we're mixing these two models then things are going
      # to go wrong.  If we saw our first test status line before we saw a
      # 'Running' line, then we don't expect to ever see a running line.
      if (not ($using_running_lines))
      {
        print "Line: $_";
        croak "Found a 'Running' line after a test status line";
      }

      $expfile->{ __full_name__ } = $1;
      ($expfile->{ __dir__ }, $expfile->{ __file__ })
        = _split_full_exp_file_name ($expfile->{ __full_name__ });
    }

    # This is a test status line.
    if (m/^(UNSUPPORTED|FAIL|PASS|XFAIL|XPASS|UNRESOLVED|KFAIL|KPASS|UNTESTED): /)
    {
      my $status = $1;

      # Discard the status from the front of the line.
      $_ =~ s/^[^:]+:\s*//;

      my ($file, $dir, $testname);

      # Now if it looks like this line has a exp filename prefix then we
      # can extract this, and possibly cross-check it with the previous
      # 'Running' line, or, if there was no previous 'Running' line, this
      # will provide the name of the exp file that produced this test.
      if ($_ =~ m/(^[^: ]+\.exp):\s*(.*)$/)
      {
        my $curr_expfile;
        ($curr_expfile, $testname) = ($1, $2);

        if (not (defined ($expfile->{__full_name__})))
        {
          # We've found a status result before an 'Running' line.  We allow
          # this so long as we never seen any Running lines.  Some '.sum'
          # files don't seem to have the 'Running' lines at all.
          $using_running_lines = false;

          # Use file and directory name from the line.
          ($dir, $file) = _split_full_exp_file_name ($curr_expfile);
        }
        elsif ($curr_expfile ne $expfile->{ __full_name__ })
        {
          print "Line: $_";
          croak ("expected a test in '".$expfile->{ __full_name__ }
                   ."' but found one in '".$curr_expfile."'");
        }
        else
        {
          $file = $expfile->{__file__};
          $dir = $expfile->{__dir__};
        }
      }
      # There was no exp filename prefix, we rely on their having been a
      # previous 'Running' line we can get the name of the exp file from.
      else
      {
        $testname = $_;
        chomp $testname;

        if (not (defined ($expfile->{__full_name__})))
        {
          print "Line: $_";
          croak ("no previous Running line found before test without ".
                   "test file prefix");
        }
        $file = $expfile->{__file__};
        $dir = $expfile->{__dir__};
      }

      # Check everything is valid.
      assert (defined ($testname));
      assert (defined ($status));
      assert (defined ($dir));
      assert (defined ($file));

      # Create the new result.
      my $test = RunTestUtils::TestResult->new (-directory => $dir,
                                                -filename => $file,
                                                -testname => $testname,
                                                -status => $status,
                                                -tool => $toolname);
      defined $test or die;
      push @results, $test;
    }
  }

  close $in
    or croak ("Failed to close '$filename': $!");

  return @results;
}

#========================================================================#

=pod

=item I<Private>: B<_parse_tool_name>

Parse the name of the tool for which the tests were run from filename
passed as a parameter.

=cut

sub _parse_tool_name {
  my $filename = shift;

  open my $in, $filename
    or croak ("Failed to open '$filename': $!");

  my $toolname = "unknown";
  while (<$in>)
  {
    if (m/^\s+=== (\S+) tests ===/)
    {
      $toolname = $1;
      last;
    }
  }

  close $in
    or croak ("Failed to close '$filename': $!");

  return $toolname;
}

#========================================================================#

=pod

=item I<Private>: B<_split_full_exp_file_name>

Static function that takes a single parameter, the full name of an exp
file, and returns a list of two elements, all parts of the full name upto
the actual filename, and the actual filename.

So, 'a/b/c.exp' will return ('a/b', 'c.exp').

=cut

sub _split_full_exp_file_name {
  my $fullname = shift;

  my $rev = reverse ($fullname);
  $rev =~ m#^([^/]+)/(.*)#;
  my $file = reverse ($1);
  my $dir = reverse ($2);

  return ($dir, $file);
}

#============================================================================#

=pod

=back

=cut

#============================================================================#
#Return value of true so that this file can be used as a module.
1;
