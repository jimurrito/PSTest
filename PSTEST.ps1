#
# https://powershell.one/powershell-internals/attributes/custom-attributes
#
# Defines a custom attribute
class TestFunctAttribute : System.Attribute {
    [array]$IArgs

    TestFunctAttribute([array]$IArgs) {
        $this.$IArgs = $IArgs
    }
    TestFunctAttribute() {}
}
#
# This would be the test function
function Test-Function {
    [TestFunctAttribute(IArgs = ("hello", "world"))]
    param(
        [string]$var1,
        [string]$var2
    )
    Write-Host "$var1 $var2!"
}

#
# Simplied way of validating
$func = get-command -name Test-Function
$InArgs = $func.ScriptBlock.Attributes.IArgs

Invoke-Expression ("$func {0} {1}" -f $InArgs)

