<#
.SYNOPSIS
	Generates a list of infile options for ffmpeg.

.DESCRIPTION
	Use with Start-Ffmpeg's -InfileOptions parameter to generate a valid set of
	ffmpeg options.
	
	This function mostly just provides PowerShell based help and tab completion
	for ffmpeg.

.PARAMETER Path
	Path to an input file.

.PARAMETER FormatName
	One of the formats provided by Get-FfmpegFormat that describes the input file.

.EXAMPLE
	$InFile = New-FfmpegInfileOptions -Path .\InFile.wmv
	$OutFile = New-FfmpegOutfileOptions -Path .\OutFile.mp4 -VideoCodec mpeg4
	Start-Ffmpeg -InfileOptions $InFile -OutFileOptions $OutFile
	
	Convert a wmv file to mpeg4
#>
function New-FfmpegInfileOptions {
	[OutputType([String[]])]
	param(
		[Parameter(Mandatory=$true)]
		$Path,
		[ValidateSet("")]
		$FormatName
	)
	$Options = @()
	
	if($FormatName) {
		$Options += "-f"
		$Options += $FormatName
	}
	
	$Options += "-i"
	$Options += $Path
	
	,$Options
}
Export-ModuleMember -Function New-FfmpegInfileOptions