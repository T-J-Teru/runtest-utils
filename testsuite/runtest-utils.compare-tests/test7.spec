# Something used to fail, but now passes.  However, we are only
# showing bad results, so there should be no output from this.
tool: compare-tests
sum1: one-test-mixed.sum
sum2: one-test-all-passes.sum
args: -b
exitvalue: 0
