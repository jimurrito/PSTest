<#
.SYNOPSIS
    A class that represents a test function attribute.

.DESCRIPTION
    The TestFuncAttribute class extends the System.Attribute class and includes three properties: IArgs and Assert. 
    It also includes three constructors.

.CLASS
    TestFuncAttribute

.PROPERTY
    IArgs
    An array that holds input arguments for the function to be tested.

.PROPERTY
    Assert
    An assertion for the function to be tested.

.CONSTRUCTOR
    TestFuncAttribute()
    A constructor that takes no arguments.

.CONSTRUCTOR
    TestFuncAttribute($IArgs)
    A constructor that takes an array of input arguments for the function to be tested.

.CONSTRUCTOR
    TestFuncAttribute($IArgs, $Assert)
    A constructor that takes an array of input arguments and an assertion for the function to be tested.
#>

class TestFuncAttribute : System.Attribute {
    # An array to hold input arguments for the function to be tested
    $IArgs
    # An assertion for the function to be tested
    $Assert

    # Constructor with no arguments
    TestFuncAttribute() {}

    # Constructor with input arguments but no assertion
    TestFuncAttribute($IArgs) {
        $this.IArgs = $IArgs
    }

    # Constructor with both input arguments and assertion
    TestFuncAttribute($IArgs, $Assert) {
        $this.IArgs = $IArgs
        $this.Assert = $Assert
    }
}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

<#
.SYNOPSIS
    A class that represents the result of a test function.

.DESCRIPTION
    The TestFuncResult class has four properties: ResultType, ErrorType, Result, and Test. 
    It also includes two constructors and a method to convert the result to a JSON string.

.CLASS
    TestFuncResult

.PROPERTY
    ResultType
    An enum that represents the type of result. It can be either Success or Error. 
    The default value is Success.

.PROPERTY
    ErrorType
    An enum that represents the type of error. It can be either Assert or Exception. 
    The default value is $null.

.PROPERTY
    Result
    An object that represents the result of the test function.

.PROPERTY
    Test
    A string that represents the function that was run.

.PROPERTY
    TestArgs
    Object that contains the input arguments for the function.

.CONSTRUCTOR
    TestFuncResult([object]$result, [string]$test)
    A constructor that takes a result object, a test function name, and its arguments. 
    It sets the ResultType to Success.

.CONSTRUCTOR
    TestFuncResult([ResultType] $resultType, [object]$result, [string]$test, [ErrorType] $ErrorType)
    A constructor that takes a result type, a result object, a test function name, and an error type, 
    and sets the corresponding properties.

.METHOD
    ResultToString()
    A method that converts the Result object to a JSON string.

.ENUM
    ResultType
    An enum that represents the type of result. It can be either Success or Error.

.ENUM
    ErrorType
    An enum that represents the type of error. It can be either Assert or Exception.
#>


class TestFuncResult {
    [string] $TestFn; # the function that was ran
    [object] $TestArgs
    [object] $Result;
    [ResultType] $ResultType = [ResultType]::Success;

    # default (Success + message + test)
    TestFuncResult([object]$result, [string]$testfn, [object] $testArgs) {
        $this.Result = $result;
        $this.TestFn = $testfn;
        $this.TestArgs = $testArgs;
    }
    # Full
    TestFuncResult([ResultType] $resultType, [object]$result, [string]$testfn, [object] $testArgs) {
        $this.Result = $result;
        $this.ResultType = $resultType;
        $this.TestFn = $testfn;
        $this.TestArgs = $testArgs;
    }
    #
    # Convert result to JSON
    [string] ResultToString(){
        return $this.Result | ConvertTo-Json
    }
}


enum ResultType {
    Success
    ExceptionError
    AssertionError
}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #


