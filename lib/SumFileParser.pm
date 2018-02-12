package SumFileParser;

use strict;
use warnings;
no indirect;
no autovivification;

use Carp;
use Carp::Assert;
use TestResult;

=pod

=head1 NAME

SumFileParser - Parse DeJaGNU test summary files.

=head1 SYNOPSIS

  use SumFileParser;

  my @results = SumFileParser::parse ($filename);

Returns a list of TestResult objects parsed from the summary file
I<$filename>.

=head1 METHODS

The methods for this module are listed here:

=over 4

=cut

#============================================================================#

=pod

=item I<Public>: B<parse>

A function to parse the contents of a summary file, returns a list of
TestResult objects.

=cut

sub parse {
  my $filename = shift;

  my @results;
  open my $in, $filename
    or croak ("Failed to open '$filename': $!");

  my $expfile = { __full_name__ => undef,
                  __file__ => undef,
                  __dir__ => undef };

  while (<$in>)
  {
    if (m#^Running .*/testsuite/(.*) \.\.\.$#)
    {
      $expfile->{ __full_name__ } = $1;

      my $rev = reverse ($expfile->{ __full_name__ });
      $rev =~ m#^([^/]+)/(.*)#;
      $expfile->{ __file__ } = reverse ($1);
      $expfile->{ __dir__ } = reverse ($2);
    }

    if (m/^(UNSUPPORTED|FAIL|PASS|XFAIL|XPASS|UNRESOLVED|KFAIL|KPASS|UNTESTED): /)
    {
      my $status = $1;
      $_ =~ s/^[^:]+:\s*//;

      my ($file, $dir, $testname);
      if ($_ =~ m/(^[^: ]+):\s*(.*)$/)
      {
        my ($curr_expfile, $rev);
        ($curr_expfile, $testname) = ($1, $2);

        if ($curr_expfile ne $expfile->{ __full_name__ })
        {
          print "Line: $_";
          croak ("expected a test in '".$expfile->{ __full_name__ }
                   ."' but found one in '".$curr_expfile."'");
        }
      }
      else
      {
        $testname = $_;
        chomp $testname;
      }

      assert (defined ($testname));

      my $test = TestResult->new (-directory => $expfile->{ __dir__ },
                                  -filename => $expfile->{ __file__ },
                                  -testname => $testname,
                                  -status => $status);
      defined $test or die;
      push @results, $test;
    }
  }

  close $in
    or croak ("Failed to close '$filename': $!");

  return @results;
}

#============================================================================#

=pod

=back

=head1 AUTHOR

Andrew Burgess, 20 May 2016

=cut

#============================================================================#
#Return value of true so that this file can be used as a module.
1;
