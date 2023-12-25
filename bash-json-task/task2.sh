#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <output.txt>"
    exit 1
fi

input_file=$1
output_file="output.json"

testName=""
tests=()
success=0
failed=0
totalDuration=0

while IFS= read -r line; do
    if [[ $line =~ \[([^\]]+)\] ]]; then
        testName="${BASH_REMATCH[1]}"
        testName="${testName#"${testName%%[![:space:]]*}"}"
        testName="${testName%"${testName##*[![:space:]]}"}"
    fi

    if [[ $line =~ ^(not )?ok[[:space:]]+([0-9]+)[[:space:]]+(expecting .+),[[:space:]]+([0-9]+)ms$ ]]; then
        name="${BASH_REMATCH[3]}"
        status=${BASH_REMATCH[1]}
        status="${status:+false}"
        status="${status:-true}"
        duration="${BASH_REMATCH[4]}ms"

        tests+=("{\"name\": \"$name\", \"status\": $status, \"duration\": \"$duration\"}")

        if $status; then
            ((success++))
        else
            ((failed++))
        fi

        # totalDuration=$((totalDuration + ${BASH_REMATCH[4]}))
    fi
done <"$input_file"

last_line=$(grep -Eo '[0-9]+ \(of [0-9]+\) tests passed, [0-9]+ tests failed, rated as [0-9.]+%, spent [0-9]+ms$' "$input_file")
totalDuration=$(echo "$last_line" | awk '{print $NF}' | tr -d 'ms')

totalTests=$((success + failed))
rating=$(awk -v s="$success" -v t="$totalTests" 'BEGIN {printf "%.2f\n", s/t*100}')

./jq -n --arg testName "$testName" \
    --argjson tests "$(
        IFS=','
        echo "[${tests[*]}]"
    )" \
    --argjson success "$success" \
    --argjson failed "$failed" \
    --argjson rating "$rating" \
    --arg totalDuration "${totalDuration}ms" \
    '{
    "testName": $testName,
    "tests": $tests,
    "summary": {
      "success": $success,
      "failed": $failed,
      "rating": $rating,
      "duration": $totalDuration
    }
  }' >"$output_file"

echo "Conversion complete! The JSON data is stored in $output_file."
