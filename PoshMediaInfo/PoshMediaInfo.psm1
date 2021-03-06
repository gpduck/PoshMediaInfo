$Script:ModuleRoot = $PSScriptRoot
$Script:ffmpeg = Join-Path $Moduleroot "Binaries\ffmpeg.exe"

dir (Join-Path $Script:ModuleRoot "ExportedFunctions\*.ps1") | %{
	. $_.Fullname
}

#Helper function used by New-FfmpegOutfileOptions to convert parameters to ffmpeg arguments.
function AddOption {
	param(
		$Name,
		$Value,
		[String[]]$Array
	)
	if($Value) {
		$Array += $Name
		$Array += $Value
	}
	,$Array
}


<#
  .SYNOPSIS
    Replace the set of valid values on a funciton parameter that was defined
    using ValidateSet.

  .DESCRIPTION
    Replace the set of valid values on a funciton parameter that was defined
    using ValidateSet.

  .PARAMETER  Command
    A FunctionInfo object for the command that has the parameter validation to
    be updated.  Get this using:
    
    Get-Command -Name YourCommandName

  .PARAMETER  ParameterName
    The name of the parameter that is using ValidateSet.
  
  .PARAMETER  NewSet
    The new set of valid values to use for parameter validation.

  .EXAMPLE
    Define a test function:
    
    PS> Function Test-Function {
      param(
        [ValidateSet("one")]
        $P
      )
    }
    
    PS> Update-ValidateSet -Command (Get-Command Test-Function) -ParameterName "P" -NewSet @("one","two")
    
    After running Update-ValidateSet, Test-Function will accept the values "one"
    and "two" as valid input for the -P parameter.

  .OUTPUTS
    Nothing

  .NOTES
    This function is updating a private member of ValidateSetAttribute and is
    thus not following the rules of .Net and could break at any time.  Use at
    your own risk!
    
    Author : Chris Duck

  .LINK
    http://blog.whatsupduck.net
#>
function Update-ValidateSet {
  param(
    [ValidateNotNullOrEmpty()]
    [System.Management.Automation.FunctionInfo]$Command,

    [ValidateNotNullOrEmpty()]
    [string]$ParameterName,

    [ValidateNotNullOrEmpty()]
    [String[]]$NewSet
  )
  #Find the parameter on the command object
  $Parameter = $Command.Parameters[$ParameterName]
  if($Parameter) {
    #Find all of the ValidateSet attributes on the parameter
    $ValidateSetAttributes = @($Parameter.Attributes | Where-Object {$_ -is [System.Management.Automation.ValidateSetAttribute]})
    if($ValidateSetAttributes) {
      $ValidateSetAttributes | ForEach-Object {
        #Get the validValues private member of the ValidateSetAttribute class
        $ValidValuesField = [System.Management.Automation.ValidateSetAttribute].GetField("validValues", [System.Reflection.BindingFlags]::NonPublic -bor [System.Reflection.BindingFlags]::Instance)
        #Update the validValues array on each instance of ValidateSetAttribute
        $ValidValuesField.SetValue($_, $NewSet)
      }
    } else {
      Write-Error -Message "Parameter $ParameterName in command $Command doesn't use [ValidateSet()]"
    }
  } else {
    Write-Error -Message "Parameter $ParameterName was not found in command $Command"
  }
}

#patch up arguments using ValidateSet to the values that the current version of ffmpeg supports
Update-ValidateSet -Command (Get-Command New-FfmpegOutfileOptions) -ParameterName AudioCodecName -NewSet (@("COPY","NONE") + (Get-FfmpegCodec -Type Audio -Flags Encoding).Name)
Update-ValidateSet -Command (Get-Command New-FfmpegOutfileOptions) -ParameterName VideoCodecName -NewSet (@("COPY","NONE") + (Get-FfmpegCodec -Type Video -Flags Encoding).Name)
Update-ValidateSet -Command (Get-Command New-FfmpegOutfileOptions) -ParameterName SubtitleCodecName -NewSet (@("COPY","NONE") + (Get-FfmpegCodec -Type Subtitle -Flags Encoding).Name)

Update-ValidateSet -Command (Get-Command New-FfmpegInfileOptions) -ParameterName FormatName -NewSet (Get-FfmpegFormat -Flags Demuxing | Select-Object -Property Name -Unique).Name
Update-ValidateSet -Command (Get-Command New-FfmpegOutfileOptions) -ParameterName FormatName -NewSet (Get-FfmpegFormat -Flags Muxing | Select-Object -Property Name -Unique).Name