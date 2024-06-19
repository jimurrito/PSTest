#Requires -modules PSTestLib
#
# Test Functions
function Test-FunctionAssertSuccess {
    [PSTest(("hello", "world"),{$r -eq "hello world!"})]
    param(
        [string]$var1,
        [string]$var2
    )
    return "$var1 $var2!"
}

function Test-FunctionAssertFail {
    [PSTest(("hello", "world"),{$r -eq "hello mars!"})]
    param(
        [string]$var1,
        [string]$var2
    )
    return "$var1 $var2!"
}