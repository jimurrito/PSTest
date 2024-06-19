#Requires -modules PSTestLib

#
# Test Function
function Test-Function2 {
    [PSTest(("hello2", "world2"))]
    param(
        [string]$var1,
        [string]$var2
    )
    return "$var1 $var2!"
}

function Test-FunctionIgnore {
    # This function will be ignored
    # [PSTest(("Second", "Test"))]
    param(
        [string]$var1,
        [string]$var2
    )
    return "$var1 $var2!"
}

function Test-FunctionFail {
    [PSTest()]
    param(
        [string]$var1,
        [string]$var2
    )
    throw "Test-Failure-Output"
}