<#
.SYNOPSIS
    A script to run tests on PowerShell modules.

.DESCRIPTION
    This script imports the modules from a specified path, runs tests on functions that have a specific attribute, and outputs the results.

.PARAMETER TestPath
    The path to the directory containing the test modules. The script will attempt to test all modules in this directory. Only functions that have the PSTest() attribute will be evaluated.

.PARAMETER LibPath
    The path to the PSTest.psd1 library module.

.PARAMETER TestAttributeName
    The name of the attribute that the script looks for in the functions to be tested.

.PARAMETER FullDump
    A boolean value indicating whether to output all tests run for all modules.

.PARAMETER TestExtensions
    The file extensions of the modules to be tested.

.EXAMPLE
    PS C:\> .\YourScript.ps1 -TestPath ".\Tests\" -LibPath ".\PSTest.psd1" -TestAttributeName "PSTestAttribute" -FullDump $false -TestExtensions "*.psm1"

.INPUTS
    None. You cannot pipe objects to YourScript.ps1.

.OUTPUTS
    None. This script does not generate any output.

.NOTES
    Version:        1.0
    Author:         James Immer
    Creation Date:  06/18/2024
    Purpose/Change: Initial Commit
#>


param(
    # path to the test modules
    # will attempt to test all modules in the dir
    # Only functions that have the PSTest() attribute will be evaluated
    $TestPath = ".\Tests\",
    $LibPath = ".\PSTest.psd1",
    $TestAttributeName = "PSTestAttribute",
    [bool]$FullDump = $false,
    $TestExtensions = "*.psm1"
)
#
# Import testlib obj
. ([scriptblock]::create("using module $LibPath"))
# 
# generate stop watch for execution timing
$Timer = [System.Diagnostics.Stopwatch]::StartNew()
#
#
# get powershell modules in the path
$Modules2Test = Get-ChildItem -Path $TestPath -Filter $TestExtensions -Verbose
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
    # filters all the commands that contain the test class attribute [PSTest()]
    $funcs = get-module | Foreach-Object { 
        Get-Command -Module $_ | Where-Object { $_.ScriptBlock.Attributes.TypeId.name -eq $TestAtt } 
    }
    #
    # Iterate all in-scope functions - testing each one
    # Full single module output - reps all tests in a single module file - use `$ModuleResults`
    return $funcs | ForEach-Object {
        #
        $func = $_
        # get attributes - filters out attributes from other sources
        $AttVals = $func.ScriptBlock.Attributes | where-object { $_.TypeId.name -eq $TestAtt }
        #
        # Each iteration of $AttVals is its own test.
        # Results from all test permuations of a single function
        return $AttVals | ForEach-Object { 
            #
            # input args remap - needed to splatter the array of variables
            $InputArgs = $_.IArgs;
            $Assertion = $_.Assert;
            #
            # Test Job return - represents a single test
            $PermuationResult = try {
                # invoke test
                $TestResult = & $func.Name @InputArgs
                # Run if block if test should be asserted
                if ($Assertion -and $TestResult -ne $Assertion ) {
                    return [PSTestResult]::new(
                        [ResultType]::AssertionError, 
                        $testresult, 
                        $func.Name, 
                        $InputArgs
                    )
                }
                # Test should NOT be asserted
                else {
                    return [PSTestResult]::new(
                        $testresult, 
                        $func.Name, 
                        $InputArgs
                    )
                }
            }
            # Job failed the test
            catch {
                return [PSTestResult]::new(
                    [ResultType]::ExceptionError, 
                    $_, 
                    $func.Name, 
                    $InputArgs
                )
            }
            #
            #
            # Test Job return - represents a single test - return on try/catch does not work in PS
            return $PermuationResult
        }
    }
    # end of scriptblock
}
#
# Execute test(s)
$FinalOutput = $Modules2Test | ForEach-Object { (pwsh -c $TestBlock -args @($_, $LibPath, $TestAttributeName)) }
#
# [Stat output]
#
# Stop the stopwatch; capture output.
$Timer.Stop(); $Runtime = $Timer.Elapsed
#
# Count number that were successful
$SuccCount = ($FinalOutput | Where-Object { $_.ResultType -eq [ResultType]::Success }).Count
$FailCount = $FinalOutput.Count - $SuccCount
#
# verbose output
Write-Host "`nSuccess: "-NoNewline
Write-Host "$SuccCount" -ForegroundColor Green -NoNewline
Write-Host " | "  -NoNewline
Write-Host "Failure: " -NoNewline
Write-Host "$FailCount" -ForegroundColor Red -NoNewline
Write-Host " | "  -NoNewline
Write-Host ("Total: {0} | Runtime: ({1})s ({2})ms`n" -f 
    $FinalOutput.Count, $Runtime.Seconds, $Runtime.Milliseconds ) -NoNewline
#
# Output of ALL tests ran for all modules
if ($FullDump) { Write-Output $FinalOutput }