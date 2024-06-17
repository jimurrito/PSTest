<#
.SYNOPSIS
    This is a custom attribute class for unit testing in PowerShell.

.DESCRIPTION
    The TestFunctAttribute class provides a structure for creating unit tests for functions in PowerShell. 
    It includes properties for input arguments and assertions, and constructors for different testing scenarios.

.EXAMPLE
    [TestFunctAttribute(("arg1", "arg2"), $true)]
    function TestFunction {
        # Function code here
    }

.NOTES
    Remember to replace 'arg1', 'arg2', and $true with the actual input arguments and assertion for your function.
#>
class TestFuncAttribute : System.Attribute {
    # An array to hold input arguments for the function to be tested
    $IArgs
    # An assertion for the function to be tested
    $Assert

    # Constructor with no arguments
    TestFuncAttribute() {}

    # Constructor with input arguments but no assertion
    TestFuncAttribute($IArgs) {
        $this.IArgs = $IArgs
    }

    # Constructor with both input arguments and assertion
    TestFuncAttribute($IArgs, $Assert) {
        $this.IArgs = $IArgs
        $this.Assert = $Assert
    }
}
