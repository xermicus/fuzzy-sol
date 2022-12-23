#!/bin/bash

cmd="solang compile --target $1 $2 2>&1"

bin="/home/glow/code/solang/target/release/solang"
out=$($bin compile -o /dev/null --target $1 $2 2>&1)
ret=$?

if [ $ret -eq 0 ] || [ $ret -eq 1 ]; then
	exit 0
fi


sol=$(cat $2)
report=$2.md
ver=$($bin --version)
cat<<EOF>>$report
# \`compile\` crash
**file**: $2

**cmd**: $cmd

**ret**: $ret 

**ver**: $ver

# Compiler Message
\`\`\`
$out
\`\`\`

# Contract source
\`\`\`solidity
$sol
\`\`\`
EOF

sed -i "s/\r//g" $report

