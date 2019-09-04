package RunTestUtils::GenericFilter;

use strict;
use warnings;
no indirect;
no autovivification;

use base qw/RunTestUtils::Filter/;
use boolean;

=pod

=head1 NAME

RunTestUtils::GenericFilter - A generic filter.

=head1 SYNOPSIS

This currently contains all of the filtering rules in a single filter.  The
plan is to split these rules into tool specific filter objects to make
filter management easier.

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

  # Strip additional messages from the testname.
  my $testname = $name;
  $testname =~ s/\((?:first|second|third) time\)\s*//;
  $testname =~ s/\(timeout\)\s*//;
  $testname =~ s/struct_param_single_reg_loc"/struct_param_single_reg_loc/;
  $testname =~ s/\(PRMS:? [^)]+\)\s*//;
  $testname =~ s#(Couldn't compile) .*(gdb/testsuite/gdb.java/jnpe.java)#$1 $2#;
  $testname =~ s#(Couldn't compile) .*(gdb/testsuite/gdb.[^/]+/.*)#$1 $2#;
  $testname =~ s#(Cannot compile) .*(gdb/testsuite/gdb.[^/]+/.*)#$1 $2#;
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
  $testname =~ s#get integer valueof "\(int\) munmap \(\d+, 4096\)"#get integer valueof "\(int\) munmap \(ADDRESS, 4096\)"#;

  if (($path eq "gdb.base/break-interp.exp")
        or ($path eq "gdb.base/prelink.exp")
        or ($path eq "gdb.base/attach-pie-misread.exp")
        or ($path eq "gdb.threads/dlopen-libpthread.exp"))
  {
    $testname =~ s#copy libpthread-2\.\d+\.so to libpthread.so\.\d+#copy libpthread-2.VERSION.so to libpthread.so.VERSION#;
    $testname =~ s#copy ld-2\.\d+\.so to ld-linux-x86-64\.so\.\d+#copy ld-2.VERSION.so to ld-linux-x86-64.so.VERSION#;
    $testname =~ s#copy libc-2\.\d+\.so to libc\.so\.\d+#copy libc-2.VERSION.so to libc.so.VERSION#;
    $testname =~ s#copy libm-2\.\d+\.so to libm\.so\.\d+#copy libm-2.VERSION.so to libm.so.VERSION#;
    $testname =~ s#copy ld-2\.\d+\.so to break-interp-LDprelink(NO|YES)debug(IN|NO)#copy ld-2.VERSION.so to break-interp-LDprelink${1}debug${2}#;
  }

  if ($path eq "gdb.reverse/insn-reverse.exp")
  {
    $testname =~ s#0x[0-9a-f]{8,16}#HEX-ADDR#g;
  }

  if ($path eq "gdb.opt/inline-break.exp")
  {
    $testname =~ s#(address: break \*0x)[0-9a-f]{8,16}#$1HEX-ADDR#g;
  }

  if ($path eq "gdb.base/sss-bp-on-user-bp.exp")
  {
    $testname =~ s#b \*0x[0-9a-f]{8,16}#b \*0xHEX-ADDR#;
  }

  if ($path eq "gdb.threads/process-dies-while-handling-bp.exp")
  {
    $testname =~ s#(non_stop=off: cond_bp_target=0: inferior 1 exited) \([^)]+\)#$1 \(ERROR REASON\)#;
    $testname =~ s#(non_stop=on: cond_bp_target=1: inferior 1 exited) \([^)]+\)#$1 \(ERROR REASON\)#;
  }

  if ($path eq "gdb.guile/scm-ports.exp")
  {
    $testname =~ s#(get valueof "\$sp" )\([0-9]+\)#$1\(VALUE\)#;
  }

  if ($path eq "gdb.base/batch-exit-status.exp")
  {
    $testname =~ s#( -x )(.*)(gdb/testsuite/gdb.base/batch-exit-status.(:?bad|good)-commands)#$1$3#
  }

  if ($tool eq "gdb")
  {
    my $keep_parenthesis = false;

    # GDB has a rule that some text inside parenthesis at the end of the
    # test list should be ignored when comparing test names.  These
    # parenthesised expressions will give information like '(timeout)' or
    # '(GDB internal error)'.
    #
    # However, some tests unhelpfully have a parenthesised expression at
    # the end of the test name, which shouldn't be stripped off.  Here we
    # special case tests that shouldn't be stripped, but otherwise do the
    # stripping.
    if ($testname =~ m#\s+\(ref_val_struct_[^)]+\)$#)
    {
      $keep_parenthesis = true;
    }

    if ($path eq "gdb.fortran/complex.exp"
          and ($testname =~ m/print \$_creal \([^)]+\)$/))
    {
      $keep_parenthesis = true;
    }

    if (not ($keep_parenthesis))
    {
      $testname =~ s#\s+\([^)]+\)$##;
    }
  }

  return $testname;
}

#============================================================================#

=pod

=back

=head1 AUTHOR

Andrew Burgess, 04 May 2019

=cut

#============================================================================#
#Return value of true so that this file can be used as a module.
1;
