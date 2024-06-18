Import-Module "$PSScriptRoot\..\PSTest.psd1"
#
# Test Function
function Test-Function {
    # The Presence of this attribute will trigger PSTest to run the job.
    [TestFunc(("hello", "world"))]
    # Multiple can be placed on a single function for multiple tests
    # [TestFunc(("Second", "Test"))]
    param(
        [string]$var1,
        [string]$var2
    )
    return "$var1 $var2!"
}

function Test-FunctionDouble {
    # each instance here should be its own test
    [TestFunc(("double", "Test1"))]
    [TestFunc(("double", "Test2"))]
    param(
        [string]$var1,
        [string]$var2
    )
    return "$var1 $var2!"
}