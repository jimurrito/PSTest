#Requires -modules PSTestLib
#
# Test Function
function Test-Function {
    # The Presence of this attribute will trigger PSTest to run the job.
    [PSTest(("hello", "world"))]
    param(
        [string]$var1,
        [string]$var2
    )
    return "$var1 $var2!"
}

function Test-FunctionDouble {
    # Each instance here will be its own test
    [PSTest(("double", "Test1"))]
    [PSTest(("double", "Test2"))]
    param(
        [string]$var1,
        [string]$var2
    )
    return "$var1 $var2!"
}