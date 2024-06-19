<#PSScriptInfo

.VERSION 1.2024061803

.GUID a1626141-f76e-4301-8ec3-d03f6bfd4d2f

.AUTHOR Jimurrito

.COMPANYNAME Virtrillo Software Solutions

.COPYRIGHT (c) 2024 Jimurrito. All rights reserved.

.TAGS Testing Framework Unit-testing Assertion-testing Assertion cmdlet-testing function-testing

.LICENSEURI https://www.gnu.org/licenses/gpl-3.0.en.html

.PROJECTURI https://github.com/jimurrito/PSTest

.ICONURI

.EXTERNALMODULEDEPENDENCIES PSTestLib

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES https://github.com/jimurrito/PSTest

#>


<#
.SYNOPSIS
    A script to run tests on PowerShell modules.

.DESCRIPTION
    This script imports the modules from a specified path, runs tests on functions that have a specific attribute, and outputs the results.

.PARAMETER TestPath
    The path to the directory containing the test modules. The script will attempt to test all modules in this directory. Only functions that have the PSTest() attribute will be evaluated.

.PARAMETER FullDump
    A switch value indicating whether to output full test results from the test runs.

.PARAMETER TestExtensions
    The file extensions of the modules to be tested.

.EXAMPLE
    PS C:\path\to\PSTest> .\PSTestX.ps1 -TestPath ".\Tests\" -FullDump $true
    
    or if installed

    PSTestX  -TestPath ".\Tests\" -FullDump $true

.OUTPUTS
    [ResultType] class that can be found in PSTestLib
#>
#
#Requires -modules PSTestLib
#
#
param(
    # path to the test modules
    # will attempt to test all modules in the dir
    # Only functions that have the PSTest() attribute will be evaluated
    [string]$TestPath = "$PWD",
    [switch]$FullDump,
    [string]$TestExtensions = "*.psm1"
)
# using module PSTestLib
try { . ([scriptblock]::create("using module PSTestLib")) } catch { . ([scriptblock]::create("using module .\PSTestLib\PSTestLib.psd1")) }
#
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
    #Requires -modules PSTestLib
    #
    param(
        [string]$testModPath,
        [string]$TestAtt
    )
    # Import testlib obj
    try { . ([scriptblock]::create("using module PSTestLib")) } catch { . ([scriptblock]::create("using module .\PSTestLib\PSTestLib.psd1")) }
    #
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
            $AssertVar = $_.AssertVar;
            #
            # Test Job return - represents a single test
            $PermuationResult = try {
                # invoke test
                $TestResult = & $func.Name @InputArgs
                # Copy to custom var for assert ($r by default)
                Invoke-Expression ($AssertVar + '= $TestResult')       
                # Run if block if test should be asserted
                if ($Assertion -and !(& $Assertion)) {
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
$FinalOutput = $Modules2Test | ForEach-Object { (pwsh -c $TestBlock -args @($_, "PSTestAttribute")) }
#
# [FOR TESTING ONLY - Runs in current session instread of new one(s).]
# $FinalOutput = $Modules2Test | ForEach-Object { (& $TestBlock $_ "PSTestAttribute") }
#
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