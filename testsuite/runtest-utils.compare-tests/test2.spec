# Second summary file is missing.
tool: compare-tests
sum1: one-test-all-passes.sum
sum2: missing.sum
stderr: ---
exitvalue: 1
---
Failed to open '.*/missing.sum': No such file or directory.*
