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
    Write-Host "$var1 $var2!"
}

function Test-Function3 {
    # The Presence of this attribute will trigger PSTest to run the job.
    # Multiple can be placed on a single function for multiple tests
    # [TestFunc(("Second", "Test"))]
    param(
        [string]$var1,
        [string]$var2
    )
    Write-Host "$var1 $var2!"
}



<#
# Simplied way of validating
$func = get-command -name Test-Function
$InArgs = $func.ScriptBlock.Attributes.IArgs
Invoke-Expression ("$func {0} {1}" -f $InArgs)
#>