# runtest-utils

A set of scripts for comparing the summary files produced by DejaGNU.
Some projects that make use of DejaGNU for running tests don't have
zero test failures, as a result it is often necessary to run the tests
once before making a change then again after making the change and
compare the result summary files to identify any regressions.  These
scripts aim to make that comparison easier.

## compare-tests

This is the primary script for comparing two summary files.  Its basic
form is:

```
compare-tests BEFORE AFTER
```

This will produce a list of all the changes in test result from BEFORE
to AFTER.  If you are only interested in tests that have gotten worse,
for example gone from passing to failing, then add the `-b` flag:

```
compare-tests -b BEFORE AFTER
```

The script supports the `--help` flag which describes all available
arguments.

## sum2table

This formats the results from one or two summary files into a table
and sorts the lines in the table based on a user defined criteria.
The aim of the script is to help the user identify which test scripts
are responsible for the most failures.

When two summary files are provided the entries in the table are
formatted assuming that the first summary file is the before results
and the second summary file is the after results.  As an example, if
we ran `tool/test.exp` before making a change and got results like
this:

```
                === tool Summary ===

# of expected passes            5
# of unexpected failures        3
```

Then after our change we ran the same test again and got the results:

```
                === tool Summary ===

# of expected passes            3
# of unexpected failures        5
```

Using `sum2table BEFORE.sum` would give:

```
      |               | FAIL | PASS |
      -------------------------------
      | tool/test.exp |    3 |    5 |
```

And running `sum2table BEFORE.sum AFTER.sum` would give:

```
      |               |      FAIL |      PASS |
      -----------------------------------------
      | tool/test.exp |    3 (+2) |    5 (-2) |
```

The script supports the `--help` flag which describes all available
arguments.

## sum4way

This script can be used to help when rebasing a set of changes for a
tool.

Imagine a large set of changes for tool, initially the changes were
made against version 3 of the tool.  Now the changes have been rebased
to version 5 of the tool.  The user wants to see if the rebase has
introduced any regressions.  This script helps with this task.

The user runs 4 sets of tests:

1. The tests on version 3 without any changes, call these results A,
2. The tests on version 3 with the changes, call these results B,
3. The tests on version 5 without any changes, call these results C,
4. The tests on version 5 with the changes, call these results D.

Now the user can run:

```
sum4way A=/path/to/A B=/path/to/B C=/path/to/C D=/path/to/D
```

The script will then perform a 4 way comparison between all of the
summary files and identify tests in D that it thinks should be passing
that aren't.  These will be listed to the user.

The basic idea of the script is to look at the changes in test results
between B and D and report any regressions.  However, any regressions
introduced between A and C are removed from the report set (as these
are considered to be not the fault of the change).

Further, anything new in C that was not in A should not regress
between C and D; the change shouldn't break new functionality added to
the upstream project.

And finally, any new tests added between C and D but not in B are
expected to pass; new tests created as part of the rebase should be
pass.

The script supports the `--help` flag which describes all available
arguments.
