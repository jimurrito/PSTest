# Entry point to run the tests
param(
    # path to the test modules
    # will attempt to test all modules in the dir
    # Only functions that have the TestFunc() attribute will be evaluated
    $TestPath = ".\Tests\",
    $LibPath = ".\PSTest.psd1",
    $TestAttributeName = "TestFuncAttribute"
)
#
#
# get powershell modules in the path
$Modules2Test = Get-ChildItem -Path $TestPath -Filter "*.psm1" -Verbose
#
#
#
# Ran for each module, in an isolated powershell session
$TestBlock = {
    #
    param(
        [string]$testModPath,
        [string]$libPath,
        [string]$TestAtt
    )
    # Import testlib obj
    . ([scriptblock]::create("using module $libPath"))
    # Import module that needs to be tested
    Import-Module $testModPath
    # filters all the commands that contain the test class
    $funcs = get-module | foreach-object { 
        Get-Command -Module $_ | Where-Object { $_.ScriptBlock.Attributes.TypeId.name -eq $TestAtt } 
    }
    #
    
    
    
    
    #
    return $funcs
}
#
#
# Execute test(s)
$Modules2Test | ForEach-Object { (pwsh -c $TestBlock -args @($_, $LibPath, $TestAttributeName)) }
#










