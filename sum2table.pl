#!/usr/bin/perl

use warnings;
use strict;
no indirect;
no autovivification;

#========================================================================#

=pod

=head1 NAME

sum2table - render one or two DeJaGnu sum files as a table

=head1 OPTIONS

B<sum2table> [-h|--help]
             [--sort=SPEC]
             [--filter=PATTERN]
             SUM_FILE_1 [ SUM_FILE_2 ]

=head1 SYNOPSIS

With one summary file, write the file as a table.  Each row has the name of
a testfile (like gdb.base/break.exp) followed by the number of passes,
failures, etc.

When passed two summary files, the first is used as a benchmark level, the
second summary file in then superimposed as an increment or decrement on
the initial benchmark value.

Lets, imagine running a test file 'tool/test.exp', the results might look
like this when only one summary file is passed:

  |               | FAIL | PASS |
  -------------------------------
  | tool/test.exp |    3 |    5 |

Then, when we pass two summary files the table might change to this:

  |               |      FAIL |      PASS |
  -----------------------------------------
  | tool/test.exp |    3 (+2) |    5 (-2) |

This indicates that in the second summary file we have 2 less passes and 2
extra failures.

The columns are ordered so that "interesting" (as in columns that indicate
bad changes) are placed first, the column ordering is:

  FAIL UNRESOLVED UNSUPPORTED UNTESTED PASS XFAIL KFAIL XPASS KPASS

Only columns that contain a result are displayed.

By default the results are sorted by the name of the test file name,
however, the I<--sort> command line option allows sorting to be performed
based on other columns.  The --sort option takes a SPEC, the SPEC is made
from two parts, a column name and a sort type.

Valid column names are things like PASS, FAIL, UNSUPPORTED, etc.

The sort type is one of 'new', 'old', or 'diff'.  The 'new' type sorts
tests with the highest new value to the top, 'old' sorts the highest old
value to the top, and finally, 'diff' sorts based on the difference between
the new and old values.

An example of a SPEC would be 'unresolved:diff', so tests with the biggest
difference in the number of unresolved tests will be sorted to the top of
the table.

It is possible to list many sort specifiers, separating them with a comma,
the table rows are sorted based on each of the specifiers in turn.  So
this:

  fail:diff,unresolved:diff

Will sort the table rows so that rows with the highest 'diff' in the fail
column are first, followed by rows with the highest 'diff' in the
unresolved column.

The 'diff' type is the default, so the previous example can be shortened to
this:

  fail,unresolved

If the magic value 'BAD' is used for SPEC then this expands to:

  fail:diff,unresolved:diff,unsupported:diff,untested:diff

if two filenames are given, which will list all of the tests that have
gotten worse at the top.  Alternatively, if 'BAD' is used for SPEC and only
one filename is given, then this expands to:

  fail:new,unresolved:new,unsupported:new,untested:new

which will list all of the tests with failures at the top.

When performing a comparison between two summary files, testnames might
have '(+)' or '(-)' appended to them.  The '(+)' indicates a test that only
appears in the second summary file, while a '(-)' indicates a test that is
present in the first, but is missing from the second.

The I<--filter> option allows the user to filter which test results are
printed.  The filter option can be given multiple times, and test name that
matches any of the filters will be displayed, all non matching testnames
are removed from the table.  The value passed to the filter is treated as a
regular expression.

=cut

#========================================================================#

use lib "$ENV{HOME}/lib";
use GiveHelp qw/usage/;         # Allow -h or --help command line options.
use boolean;
use List::Util qw/max/;
use List::MoreUtils qw/uniq/;
use Getopt::Long;
use Carp::Assert;

#========================================================================#

my @all_possible_status_types = qw/FAIL UNRESOLVED UNSUPPORTED UNTESTED
                                   PASS XFAIL KFAIL XPASS KPASS/;

#========================================================================#

exit (main ());

#========================================================================#

=pod

=head1 METHODS

The following methods are defined in this script.

=over 4

=cut

#========================================================================#

=pod

=item B<fill_in_sort_indexes>

Currently undocumented.

=cut

sub fill_in_sort_indexes {
  my $sort_spec = shift;
  my $status_types = shift;

  foreach my $sort (@{$sort_spec})
  {
    # As we only display the columns that will actuall have results in
    # them, so we need to trim out sort specifiers that are not needed, and
    # also figure out the column indexes for the things we will sort on.
    my $found = false;
    my $index = 1;
    foreach (@{$status_types})
    {
      if ($_ eq $sort->{-field})
      {
        $found = true;
        last;
      }
      $index++;
    }
    # Set -index to be the index of the column we'll be sorting on.  Start
    # at 1 as the first column (column 0 of the table holds the name of the
    # test file).  If the column is not found in the table then set the
    # index to undef, we'll filter the sort list below.
    $sort->{-index} = $found ? $index : undef;
  }

  # Trim out columns where the index is undef, these are columns that will
  # not appear in our result table.  We need to be careful here not to
  # change the array reference that SORT_SPEC points to, as SORT_SPEC is
  # passed by value into this function, and we want our changes to the
  # referenced array to be seen in the caller.
  @{$sort_spec} = grep { defined ($_->{-index}) } @{$sort_spec};
}

#========================================================================#

=pod

=item B<build_sort_spec>

Currently undocumented.

=cut

sub build_sort_spec {
  my $spec_string = shift;

  my @spec = ();
  foreach my $spec (split /,/, $spec_string)
  {
    my ($field, $type) = split /:/, $spec;
    my $found = false;

    (defined $field)
      or die "Missing sort field from --sort=$spec_string\n";

    foreach (@all_possible_status_types)
    {
      if (uc ($field) eq $_)
      {
        $found = true;
        last;
      }
    }
    ($found) or
      die "Unknown sort field '$field' in $spec_string\n";
    $field = uc ($field);

    (defined $type) or $type = "diff";
    $found = false;
    foreach (qw/new old diff/)
    {
      if (lc($type) eq $_)
      {
        $found = true;
        last;
      }
    }
    ($found) or
      die "Unknown sort type '$type' in $spec_string";
    $type = lc ($type);

    my $sort = { -field => $field,
                 -type => $type };
    push @spec, $sort;
  }

  return \@spec;
}

#========================================================================#

=pod

=item B<compare_rows>

Takes two rows from the results table as the first two parameters, and a
reference to a list of sort specifications as the third parameter.  Return
-1, 0, +1 as a result based on the required sort ordering as defined by the
sort specifications.

Each sort specification is a hash with the keys I<-index> and I<-type>, the
type is a string I<old>, I<new>, or I<diff>.  The index is the index into
the row of the table (which should not be 0).

=cut

sub compare_rows {
  my $row_a = shift;
  my $row_b = shift;
  my $spec_list = shift;

  assert (ref ($spec_list) eq 'ARRAY');

  if (scalar(@{$spec_list}) == 0)
  {
    # No compare spec left, sort by testname.
    return ($row_a->[0]->{__string__}
              cmp $row_b->[0]->{__string__});
  }

  # OK, we have a compare spec available, grab it, but first, copy the
  # compare spec array so we're not corrupting the parents value.
  my @all_spec = @{$spec_list};
  my $spec = shift @all_spec;
  my $cmp = 0;
  my $index = $spec->{-index};

  assert ($index != 0);

  if ($spec->{-type} eq "old")
  {
    $cmp = $row_b->[$index]->{__old_value__}
      <=> $row_a->[$index]->{__old_value__};
  }
  elsif ($spec->{-type} eq "new")
  {
    $cmp = $row_b->[$index]->{__new_value__}
      <=> $row_a->[$index]->{__new_value__};
  }
  elsif ($spec->{-type} eq "diff")
  {
    $cmp = ($b->[$index]->{__new_value__}
              - $row_b->[$index]->{__old_value__})
      <=> ($row_a->[$index]->{__new_value__}
           - $row_a->[$index]->{__old_value__});
  }

  if ($cmp == 0)
  {
    $cmp = compare_rows ($row_a, $row_b, \@all_spec);
  }

  return $cmp;
}

#========================================================================#

=pod

=item B<build_table_columns>

Currently undocumented.

=cut

sub build_table_columns {
  my $testname = shift;
  my $results_1 = shift;
  my $results_2 = shift;
  my $status_types = shift;

  my @columns = ();
  my $suffix = "";
  if (defined ($results_2))
  {
    if (not (exists ($results_1->{-by_testname}->{$testname})))
    {
      $suffix = " (+)";
    }
    elsif (not (exists ($results_2->{-by_testname}->{$testname})))
    {
      $suffix = " (-)";
    }
    else
    {
      $suffix = "    ";
    }
  }
  push @columns, { __string__ => $testname.$suffix };

  foreach (@{$status_types})
  {
    my $val = $results_1->{-by_testname}->{$testname}->{$_};
    $val = 0 unless (defined ($val));

    my $other = $results_2->{-by_testname}->{$testname}->{$_};
    $other = $val unless (defined ($other));

    my $str = "".$val;
    if ($other != $val)
    {
      $str .= " (";
      if ($other > $val)
      {
        $str .= "+".($other - $val);
      }
      else
      {
        $str .= "-".($val - $other);
      }
      $str .= ")";
    }
    push @columns, { __string__ => $str,
                     __old_value__ => $val,
                     __new_value__ => $other };
  }

  return @columns;
}

#========================================================================#

=pod

=item B<process_file>

Currently undocumented.

=cut

sub process_file {
  my $filename = shift;

  my $results = { -by_testname => {},
                  -status_types => {} };
  return $results if (not (defined ($filename)));

  (-f $filename) and (-r $filename)
    or die "File '$filename' is not a readable file\n";

  open my $fh, $filename
    or die "Faield to open '$filename': $!";
  while (<$fh>)
  {
    if (m/^((?:[XK]?(?:PASS|FAIL))|UNSUPPORTED|UNRESOLVED|UNTESTED): /)
    {
      my $status = $1;
      my ($testname) = m/^[^:]+: ([^:]+):/;

      $results->{-by_testname}->{$testname} = {}
        unless (exists ($results->{-by_testname}->{$testname}));
      $results->{-by_testname}->{$testname}->{$status} = 0
        unless (exists ($results->{-by_testname}->{$testname}->{$status}));
      $results->{-by_testname}->{$testname}->{$status}++;
      $results->{-status_types}->{$status} = true;
    }
  }

  close $fh or
    die "Failed to close '$filename': $!";

  return $results;
}

#========================================================================#

=pod

=item B<main>

Currently undocumented.

=cut

sub main {
  my @filters = ();
  my $sort = undef;
  GetOptions ("sort=s" => \$sort,
              "filter=s" => \@filters);

  my $filename = shift @ARGV;
  (defined $filename) or usage ();
  my $filename_2 = shift @ARGV;

  if (defined ($sort))
  {
    if ($sort eq "BAD")
    {
      if (defined ($filename_2))
      {
        $sort = "fail:diff,unresolved:diff,unsupported:diff,untested:diff";
      }
      else
      {
        $sort = "fail:new,unresolved:new,unsupported:new,untested:new";
      }
    }
    $sort = build_sort_spec ($sort);
  }


  my $results_1 = process_file ($filename);
  my $results_2 = undef;
  $results_2 = process_file ($filename_2) if (defined $filename_2);

  my @status_types = ();
  foreach (@all_possible_status_types)
  {
    if (exists ($results_1->{-status_types}->{$_})
          or exists ($results_2->{-status_types}->{$_}))
    {
      push @status_types, $_;
    }
  }

  if (defined ($sort))
  {
    fill_in_sort_indexes ($sort, \@status_types);
  }

  # Build sorted list of all test names for which we will display results.
  my @all_test_names = (keys (%{$results_1->{-by_testname}}),
                        keys (%{$results_2->{-by_testname}}));
  @all_test_names = sort (@all_test_names);
  @all_test_names = uniq (@all_test_names);

  # Filter the list of test names based on the --filter command line
  # option(s).
  if (scalar (@filters) > 0)
  {
    my @r;

    @filters = map { qr/$_/ } @filters;

    foreach my $n (@all_test_names)
    {
      my $found = false;

      foreach my $re (@filters)
      {
        if ($n =~ $re)
        {
          $found = true;
          last;
        }
      }
      push @r, $n if ($found);
    }

    @all_test_names = @r;
  }

  # Initialise the list of widths of each columns.
  my @widths = (0);
  foreach (@status_types)
  {
    push @widths, length ($_);
  }

  # Build up the rows of the table, and finish computing the widths of all
  # of the columns.
  my @rows;
  foreach my $testname (@all_test_names)
  {
    my @columns = build_table_columns  ($testname, $results_1,
                                        $results_2, \@status_types);
    push @rows, \@columns;

    for (my $i = 0; $i < scalar (@columns); $i++)
    {
      if (length ($columns[$i]->{__string__}) > $widths[$i])
      {
        $widths[$i] = length ($columns[$i]->{__string__});
      }
    }
  }

  # Sort the rows of the table based on any --sort command line option.
  if (defined ($sort))
  {
    @rows = sort { compare_rows ($a, $b, $sort) } @rows;
  }

  # Build up the printf format string, and print the rows of the table.
  my $format = "|";
  my $div_length = 1;

  foreach (@widths)
  {
    $format .= " %".$_."s |";
    $div_length += 3 + $_;
  }
  $format .= "\n";

  my @params = ("");
  foreach (@status_types)
  {
    push @params, $_;
  }

  printf $format, @params;
  print "-"x$div_length."\n";

  foreach my $row (@rows)
  {
    printf $format, map { $_->{__string__} } @{$row};
  }

  return 0;
}

#========================================================================#

=pod

=back

=head1 AUTHOR

Andrew Burgess, 04 Jun 2017

=cut
