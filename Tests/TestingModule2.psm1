Import-Module "$PSScriptRoot\..\PSTest.psd1"

#
# Test Function
function Test-Function2 {
    # The Presence of this attribute will trigger PSTest to run the job.
    [TestFunc(("hello2", "world2"))]
    param(
        [string]$var1,
        [string]$var2
    )
    return "$var1 $var2!"
}

function Test-FunctionIgnore {
    # This function will be ignored
    # [TestFunc(("Second", "Test"))]
    param(
        [string]$var1,
        [string]$var2
    )
    return "$var1 $var2!"
}

function Test-FunctionFail {
    [TestFunc()]
    param(
        [string]$var1,
        [string]$var2
    )
    throw "Test-Failure"
}