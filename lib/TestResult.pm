package TestResult;

use strict;
use warnings;
no indirect;
no autovivification;

=pod

=head1 NAME

TestResult - A single test results from a DeJaGNU summary file.

=head1 SYNOPSIS

  Quick code sample should go here...

=head1 METHODS

The methods for this module are listed here:

=over 4

=cut

#============================================================================#

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

Currently undocumented.

=cut

sub get_status {
  my $self = shift;
  return $self->{ __status__ };
}

#========================================================================#

=pod

=item I<Public>: B<get_testname>

Currently undocumented.

=cut

sub get_testname {
  my $self = shift;

  # Return cached testname if it exists.
  return $self->{ __testname__ } if (exists $self->{ __testname__ });

  # Strip additional messages from the testname.
  my $testname = $self->{ __original_testname__ };
  $testname =~ s/\((?:first|second|third) time\)\s*//;
  $testname =~ s/\(timeout\)\s*//;
  $testname =~ s/struct_param_single_reg_loc"/struct_param_single_reg_loc/;
  $testname =~ s/\(PRMS:? [^)]+\)\s*//;
  $testname =~ s#(Couldn't compile) .*(gdb/testsuite/gdb.java/jnpe.java)#$1 $2#;
  $testname =~ s#(Couldn't compile) .*(gdb/testsuite/gdb.[^/]+/.*)#$1 $2#;
  $testname =~ s#\(open '.*(gdb/testsuite/gdb.[^/']+/[^']+)'\)#(open '$1')#;
  $testname =~ s#print characters#print elements#;
  $testname =~ s#with characters set to#with elements set to#;
  $testname =~ s#((?:(?:verbose (?:off|on)|replace)): python exec \(open \(').*/gdb\.python/(?:py-pp-registration/)?py-pp-registration\.py('\)\.read \(\)\))#$1gdb.python/py-pp-registration.py$2#;
  $testname =~ s#(get python valueof "sep_objfile\.build_id") \([0-9a-f]+\)#$1 \(HASH\)#;
  $testname =~ s#(python print \(gdb\.lookup_objfile) \("[0-9a-f]+", (by_build_id=True\)\.filename\))#$1 \(HASH\), $2#;
  $testname =~ s#source .*/(gdb.python/py-completion.py)#source $1#;
  $testname =~ s#(set env LD_LIBRARY_PATH=).*(gdb.base/print-file-var-dlopen/)#$1$2#;
  $testname =~ s#(get integer valueof "\$sp") \(\d+\)#$1#;
  $testname =~ s#.*(gdb\.base/break-fun-addr/break-fun-addr[12]:)#$1#;
  $testname =~ s#(generate-core-file) .*(gdb\.btrace/gcore/core)#$1 $2#;
  $testname =~ s#(set env LD_LIBRARY_PATH=).*(gdb/testsuite/gdb.base/):#$1$2#;
  $testname =~ s#"mypid" \(\d+\)#"mypid" \(XXXX\)#;
  $testname =~ s#threaded: attempt \d+: attach \(pass (\d)\), pending signal catch#threaded: attempt XX: attach \(pass $1\), pending signal catch#;

  $testname =~ s/\s*$//;

  # Cache and return the testname
  $self->{ __testname__ } = $testname;
  return $self->{ __testname__ };
}

#========================================================================#

=pod

=item I<Public>: B<get_filename>

Currently undocumented.

=cut

sub get_filename {
  my $self = shift;
  return $self->{ __filename__ };
}

#========================================================================#

=pod

=item I<Public>: B<get_directory>

Currently undocumented.

=cut

sub get_directory {
  my $self = shift;
  return $self->{ __directory__ };
}

#========================================================================#

=pod

=item I<Public>: B<get_id>

Currently undocumented.

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

Create a new instance of TestResult and then call initialise
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
