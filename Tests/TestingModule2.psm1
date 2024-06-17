Import-Module "$PSScriptRoot\..\PSTest.psd1"

#
# Test Function
function Test-Function2 {
    # The Presence of this attribute will trigger PSTest to run the job.
    [TestFunc(("hello2", "world2"))]
    # Multiple can be placed on a single function for multiple tests
    # [TestFunc(("Second", "Test"))]
    param(
        [string]$var1,
        [string]$var2
    )
    return "$var1 $var2!"
}

function Test-Function3 {
    # The Presence of this attribute will trigger PSTest to run the job.
    # Multiple can be placed on a single function for multiple tests
    # [TestFunc(("Second", "Test"))]
    param(
        [string]$var1,
        [string]$var2
    )
    return "$var1 $var2!"
}

function Test-FunctionFail {
    [TestFunc(("Planned-Failure"))]
    param(
        [string]$var1,
        [string]$var2
    )
    throw "Test-Failure"
}