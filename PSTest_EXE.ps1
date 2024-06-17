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
    # filters all the commands that contain the test class attribute [TestFunc()]
    $funcs = get-module | Foreach-Object { 
        Get-Command -Module $_ | Where-Object { $_.ScriptBlock.Attributes.TypeId.name -eq $TestAtt } 
    }
    # Iterate all in-scope functions - testing each one
    $FuncResults = $funcs | ForEach-Object {
        #
        $func = $_
        # get attributes - filters out attributes from other sources
        $AttVals = $func.ScriptBlock.Attributes | where-object { $_.TypeId.name -eq $TestAtt }
        # Each iteration of $AttVals is its own test.
        $result = $AttVals | ForEach-Object { 
            #
            # Test catch
            try {
                #Write-Host $func
                $TestExpression = $func.Name + " " + $_.IArgs
                return Invoke-Expression $TestExpression
            }
            catch {
                return $_ | ConvertTo-Json
            }
        }

        
        return ($func.Name + " => " +  ($result -join " ; "))
    }
    
    
    
    
    
    #
    return $FuncResults
}
#
#
# Execute test(s)
#$Modules2Test[0] | ForEach-Object { (Invoke-Command $TestBlock -args @($_, $LibPath, $TestAttributeName)) }
$output = $Modules2Test[0] | ForEach-Object { (pwsh -c $TestBlock -args @($_, $LibPath, $TestAttributeName)) }
#
$output









