# Compare a summary file where something used to fail to one where it
# now passes.  This is a good result.
tool: compare-tests
sum1: one-test-mixed.sum
sum2: one-test-all-passes.sum
stdout: ---
exitvalue: 0
---
\* FAIL -> PASS:
	toolname.subdir/testscript.exp: bbbb
