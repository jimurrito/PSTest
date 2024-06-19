# PSTest
Module testing framework for Powershell functions and cmdlets. Writen natively in Powershell for maximum compatiblity.

> **Note**
> Currently, only Powershell Core is supported. However, a backwards compatible version with Legacy Powershell will be comming soon. As of now, Powershell Core is required to run this framework. [See Upcomming Changes for more info.](#upcomming-changes)

## How does it work?
This framework has two components:
1. [`PSTestLib`](https://www.powershellgallery.com/packages/PSTestLib) This is the module that contains the Attribute required to run the tests; `[PSTest()]`. Any function or cmdlet that has this attribute will be considered for testing. Each instance of the attribute represents a single test of the function. This means multiple declarations of the attribute are encouraged.
2. [`PSTestX.ps1`](https://www.powershellgallery.com/packages/PSTestX) This is the script that processes the test(s) itself. Any functions/cmdlets with the `[PSTest()]` attribute are scoped for testing. Test test arguments and optional test parameters are consumed. Final result summary will be presented to the console afterwards.

More in-depth information on this flow will be explained below.

## Installing PSTest
> PowerShell Gallery method will add the script and an alias to your PATH variable.
- **PowerShell Gallery/Nuget**
  - `install-script PSTestX`
  - This should also install/import PSTestLib

- **Git**
  - `git clone https://github.com/jimurrito/PSTest`
  - `import-module path/to/PSTestLib.psd1`

## How to use PSTest

### Using `[PSTest()]`
This attribute is the core component of PSTest. Adding this to a function will allow it to be considered for testing. Here is an example of a function that could be tested with PSTest.

```Powershell
using module PSTestLib

function Test-Function {
    [PSTest(("hello", "world"))]
    param(
        [string]$var1,
        [string]$var2
    )
    return "$var1 $var2!"
}
```

> **Note**
> These attribute calls will fail without using the `using` macro in powershell.
> `using module PSTestLib` is the easiest way to import the classes into your current powershell session. This needs to be put at the very top of your script or module.

Each instance of this attribute, is it's own isolated tested. **This means multiple declarations of the attribute, for multiple tests of the same function, are encouraged**. Here is an example of doing the second declaration.

```Powershell
using module PSTestLib

function Test-FunctionDouble {
    [PSTest(("hello", "world1"))]
    [PSTest(("hello", "world2"))]
    param(
        [string]$var1,
        [string]$var2
    )
    return "$var1 $var2!"
}
```

### Optional Parameters for `[PSTest()]`

#### `Assert`

To aid in testing, you can use a 2nd argument, or the named `Assert` parameter, to perform an assert operation on the test output. This argument takes a script block as a value. This block needs to return a boolean or truthful value. If not, the test will show as a failure.

```Powershell
using module PSTestLib

function Test-FunctionFail {
    [PSTest(("hello", "world"))]
    [PSTest(("hello", "mars"), {$r -eq "hello world!"})]
    # Optional varient using named parameters.
    # [PSTest(IArgs=("hello", "mars"),Assert={$r -eq "hello world!"})]
    param(
        [string]$var1,
        [string]$var2
    )
    return "$var1 $var2!"
}
```

In the example above, we use `{$r -eq "hello world!"}` as the assertion argument. `$r` represents the successful value returned the test execution. This is not a placeholder variable, `$r` is the default argument symbol used by PSTest. You change this if needed.


#### `AssertVar`

Following the above named parameter `Assert`, `AssertVar` allows you to set a custom variable that would be used in the assertion statments.

```Powershell
using module PSTestLib

function Test-FunctionFail {
    [PSTest(("hello", "world"))]
    [PSTest(("hello", "mars"), {$altname -eq "hello world!"}, '$altname')]
    # Optional varient using named parameters.
    # [PSTest(IArgs=("hello", "mars"),Assert={$r -eq "hello world!"},AssertVar='$altname')]
    param(
        [string]$var1,
        [string]$var2
    )
    return "$var1 $var2!"
}
```
Value should be contained in single-quotes `''` to avoid creating a formatted string.


### Using `PSTestX`

In Powershell Core; we use the pre-packaged test modules under `.\Tests` to test using PSTest.
```
PS C:\PSTest> .\PSTestX -Path .\Tests

Success: 4 | Failure: 1 | Total: 5 | Runtime: (1)s (118)ms
```

This output is helpful, but we can get more information using the `-FullDump $true` parameter.


```Powershell
PS C:\PSTest> .\PSTestX -Path .\Tests -FullDump $true

Success: 6 | Failure: 2 | Total: 8 | Runtime: (1)s (643)ms


TestFn                     TestArgs         Result         ResultType
------                     --------         ------         ----------
Test-Function              {hello, world}   hello world!   Success
Test-FunctionAssertSuccess {hello, world}   hello world!   Success
Test-FunctionDouble        {double, Test1}  double Test1!  Success
Test-FunctionDouble        {double, Test2}  double Test2!  Success
Test-Function2             {hello2, world2} hello2 world2! Success
Test-FunctionFail                           Test-Failure   ExceptionError
Test-FunctionAssertFail    {hello, world}   hello world!   AssertionError
Test-FunctionAssertSuccess {hello, world}   hello world!   Success

```
This output is an array of the powershell class `PSTestResult`. This output is capturable with a variable for further diagnosis or analysis.

```Powershell
PS C:\PSTest> $Results = .\PSTestX -Path .\Tests -FullDump $true

Success: 6 | Failure: 2 | Total: 8 | Runtime: (1)s (700)ms
```

We can filter out all the successful tests using the ResultType property and class.
```Powershell
PS C:\PSTest> $FailResult = $Results | where-object {$_ -eq [ResultType]::ExceptionError}; $FailResult.Result

Exception: Test-Failure-Output
```

This output is helpful, but only to an extent. If you need more percision, you can convert this output to a Json String for easy viewing.
```Powershell
PS C:\PSTest> $FailResult.Result | ConvertTo-Json

{
  "Exception": {
    "ErrorRecord": "Test-Failure-Output",
    "WasThrownFromThrowStatement": true,
    "TargetSite": null,
    "Message": "Test-Failure-Output",
    "Data": {},
    "InnerException": null,
    "HelpLink": null,
    "Source": null,
    "HResult": -2146233087,
    "StackTrace": null
  },
  <....>
}
```

More information on how to parse this output can be found in the class description for [`PSTestResult`](lib/PSTestLib.psm1).

### Optional parameters for `PSTestX`

#### `-FullDump` << [bool]
This will output the full set of test results to the pipeline. Without it, only the summary output will be provided. This switch is required if you want to parse the full output of the test.

#### `-TestPath` << [string]
This will be the path to the directory holding the target modules.

#### `-TestExtensions` << [string]
This will filter what files are checked for `[PSTest()]` attribute.
You will need to define the input as a pattern. The default extension is `*.psm1`. However, if the target needed to be a script file, `*.ps1`. This can be used to your advantage if you only want to test one file. Instead of a patter, just provide the fully qualified path to the file. Example: `-TestExtension /path/to/test.psm1`.


## Upcomming changes

- Parallel Test execution.
- Backwards compatibility for Legacy Powershell (< 5.1) and .Net Framework (< 4.0).
- Test-Stepping; blocks moving to a next test until the user confirms in the console.
