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

  while (<$in>)
  {
    if (m/^(UNSUPPORTED|FAIL|PASS|XFAIL|XPASS|UNRESOLVED|KFAIL|KPASS|UNTESTED): /)
    {
      my $status = $1;
      $_ =~ s/^[^:]+:\s*//;

      $_ =~ m/(^[^:]+):\s*(.*)$/;
      my $testname = $2;

      my $rev = reverse $1;
      $rev =~ m#^([^/]+)/(.*)#;
      my $file = reverse ($1);
      my $dir = reverse ($2);

      my $test = TestResult->new (-directory => $dir,
                                  -filename => $file,
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
