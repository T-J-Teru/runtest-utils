# Compare a summary file where something used to pass to one where it
# now fails, this is a bad result.
tool: compare-tests
sum1: one-test-all-passes.sum
sum2: one-test-mixed.sum
stdout: ---
exitvalue: 1
---
\* PASS -> FAIL:	\[BAD\]
	toolname.subdir/testscript.exp: bbbb
