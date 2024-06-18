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
# generate stop watch for execution timing
$Timer = [System.Diagnostics.Stopwatch]::StartNew()


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
    $ModuleResults = $funcs | ForEach-Object {
        #
        $func = $_
        # get attributes - filters out attributes from other sources
        $AttVals = $func.ScriptBlock.Attributes | where-object { $_.TypeId.name -eq $TestAtt }
        # Each iteration of $AttVals is its own test.
        $FuncResults = $AttVals | ForEach-Object { 
            #
            # input args remap - needed to splatter the array of variables
            $InputArgs = $_.IArgs;
            # create result
            $SingleTestResult = 
            #
            # Test catch
            try {
                # invoke test
                #$result = & $func.Name @InputArgs
                return [TestFuncResult]::new(
                    (& $func.Name @InputArgs), 
                    $func.Name, 
                    $InputArgs
                )
            }
            catch {
                return [TestFuncResult]::new(
                    [ResultType]::ExceptionError, 
                    $_, 
                    $func.Name, 
                    $InputArgs
                )
            }
            #
            # Test Job return - represents a single test - use `$SingleTestResult`
            return $SingleTestResult
        }
        #
        # Results from all test permuations of a single function -  use `$FuncResults`
        return $FuncResults
    }   
    #
    # Full single module output - reps all tests in a single module file - use `$ModuleResults`
    return $ModuleResults
}
#
#
# Execute test(s)
#$Modules2Test[0] | ForEach-Object { (Invoke-Command $TestBlock -args @($_, $LibPath, $TestAttributeName)) }
$FinalOutput = $Modules2Test | ForEach-Object { (pwsh -c $TestBlock -args @($_, $LibPath, $TestAttributeName)) }
#
# Output of ALL tests ran for all modules
$FinalOutput
#
# Stat output
#
#
# Stop the stopwatch; capture output.
$Timer.Stop(); $Runtime =  $Timer.Elapsed
#
#










