# DevOps-Essentials: Final Task 2

Company DEF decided to use testing tool for their employees. But current tool has no json output that can be using for later data processing.

1. Need to parce output.txt to convert into output.json:

## Example:

### this is output.txt:

```
[ Asserts Samples ], 1..2 tests
-----------------------------------------------------------------------------------
not ok  1  expecting command finishes successfully (bash way), 7ms
ok  2  expecting command prints some message (the same as above, bats way), 10ms
-----------------------------------------------------------------------------------
1 (of 2) tests passed, 1 tests failed, rated as 50%, spent 17ms
```

### should be output.json:

```json
{
  "testName": "Asserts Samples",
  "tests": [
    {
      "name": "expecting command finishes successfully (bash way)",
      "status": false,
      "duration": "7ms"
    },
    {
      "name": "expecting command prints some message (the same as above, bats way)",
      "status": true,
      "duration": "10ms"
    }
  ],
  "summary": {
    "success": 1,
    "failed": 1,
    "rating": 50,
    "duration": "17ms"
  }
}
```

2. Count of tests can be more than 2
3. Rating is a number and can be float or int (for example 50.23, 50, 100)
4. Sripts should has name task2.sh
5. Path to output.txt file should be as argument to the script.

> # If you need to use additional tools like `jq` please use it directly from this repository in your script: `./jq`

> ## Also you can use some specific tools in this approach

# Definition of done.

Developed bash script which automatically convert output.txt to json based on the example above.
