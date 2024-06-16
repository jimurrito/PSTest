# PSTest
Module testing framework for Powershell.



# TEMP-NOTES

the desired functionality is for test functions to be created, and have an attribute attatched to it.

This attribute will tell PSTest that the function should be evaluated.

###### *-Idea-*

**PSTEST_Class.psm1**
```powershell
# Attribute class
class TestFunctAttribute : System.Attribute {
    # The arguments that will be passed to the function
    [array]$Args
    TestFunctAttribute([array]$Args) {
        $this.Args = $Args
    }
    TestFunctAttribute() {}
}
```

**TestMod.ps1**
```powershell
#psuedo test function
function Test-Function {
    [TestFunctAttribute(IArgs = ("hello", "world"))]
    param(
        [string]$var1,
        [string]$var2
    )
    Write-Host "$var1 $var2!"
}
```

The target of PSTEST will be TestMod.ps1. PSTEST will import the module to read its contents. Using `get-module` before and after, we can sus out the module name(s).
Using where-object, or equivalent, we will filter out only functions that have the `[TestFunc()]` attribute derived.

Pulling this attribute, we will have the parameters needed for testing the module. Using the function name, and arguments, we can invoke the expression from a string

```Powershell
# Simplied way of validating
$func = get-command -name Test-Function
$InArgs = $func.ScriptBlock.Attributes.IArgs
Invoke-Expression ("$func {0} {1}" -f $InArgs)

# Output
hello world!
```
__Any expression that does not throw an exception is considered a success.__

In this case, the functiuon printed `hello world!` and exited; no exception. This test will be considered a success.

Each test *should* run in its own powershell session, but a fresh one per full test run will also do.

