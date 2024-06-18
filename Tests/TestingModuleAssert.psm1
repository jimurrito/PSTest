Import-Module "$PSScriptRoot\..\PSTest.psd1"
#
# Test Functions
function Test-FunctionAssertSuccess {
    [PSTest(("hello", "world"),"hello world!")]
    param(
        [string]$var1,
        [string]$var2
    )
    return "$var1 $var2!"
}

function Test-FunctionAssertFail {
    [PSTest(("hello", "world"),"hello mars!")]
    param(
        [string]$var1,
        [string]$var2
    )
    return "$var1 $var2!"
}