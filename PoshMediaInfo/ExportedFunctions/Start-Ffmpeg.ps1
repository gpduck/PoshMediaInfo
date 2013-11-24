<#
.SYNOPSIS
	Generates a list of outfile options for ffmpeg.

.DESCRIPTION
	Use with Start-Ffmpeg's -OutfileOptions parameter to generate a valid set of
	ffmpeg options.
	
	This function mostly just provides PowerShell based help and tab completion
	for ffmpeg.

.PARAMETER Path
	Path to an output file.  Relative paths are resolved in PowerShell and passed
	to ffmpeg as a fully qualified path.

.PARAMETER FormatName
	One of the formats provided by Get-FfmpegFormat that describes the input file.

.EXAMPLE
	$InFile = New-FfmpegInfileOptions -Path .\InFile.wmv
	$OutFile = New-FfmpegOutfileOptions -Path .\OutFile.mp4 -VideoCodec mpeg4
	Start-Ffmpeg -InfileOptions $InFile -OutFileOptions $OutFile
	
	Convert a wmv file to mpeg4
#>
function Start-Ffmpeg {
	[CmdletBinding(SupportsShouldProcess)]
	param(
		[switch]$Clobber,
		
		[String[][]]$InfileOptions,
		
		[String[][]]$OutfileOptions

	)
	process {
		$ffmpegGlobalOptions = @()
		$ffmpegInfileOptions = @()
		$ffmpegOutfileOptions = @()
		
		#Generate Global Options
		if($Clobber) {
			$ffmpegGlobalOptions += "-y"
		}
		
		#Generate InfileOptions
		
		#Generate OutfileOptions
		if($AudioCodecName) {
			if($AudioCodecName -eq "NONE") {
				$ffmpegOutfileOptions += "-an"
			} else {
				$ffmpegOutfileOptions += "-acodec",$AudioCodecName
			}
		}
		if($VideoCodecName) {
			if($VideoCodecName -eq "NONE") {
				$ffmpegOutfileOptions += "-vn"
			} else {
				$ffmpegOutfileOptions += "-vcodec",$VideoCodecName
			}
		}
		if($SubtitleCodecName) {
			if($SubtitleCodecName -eq "NONE") {
				$ffmpegOutfileOptions += "-sn"
			} else {
				$ffmpegOutfileOptions += "-scodec",$SubtitleCodecName
			}
		}
		if($PsCmdlet.ShouldProcess("ffmpeg $ffmpegGlobalOptions $($InfileOptions | %{ $_ -join ' '}) $($OutfileOptions | %{ $_ -join ' '})")) {
			&$ffmpeg $ffmpegGlobalOptions $InfileOptions $OutfileOptions
		}
	}
}
Export-ModuleMember -Function Start-Ffmpeg