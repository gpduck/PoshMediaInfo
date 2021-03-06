<#
.SYNOPSIS
	Generates a list of outfile options for ffmpeg.

.DESCRIPTION
	Use with Start-Ffmpeg's -OutfileOptions parameter to generate a valid set of
	ffmpeg options.
	
	This function mostly just provides PowerShell based help and tab completion
	for ffmpeg.

.PARAMETER Path
	Path to an output file.

.PARAMETER FormatName
	One of the formats provided by Get-FfmpegFormat that describes the input file.

.EXAMPLE
	$InFile = New-FfmpegInfileOptions -Path .\InFile.wmv
	$OutFile = New-FfmpegOutfileOptions -Path .\OutFile.mp4 -VideoCodec mpeg4
	Start-Ffmpeg -InfileOptions $InFile -OutFileOptions $OutFile
	
	Convert a wmv file to mpeg4
#>
function New-FfmpegOutfileOptions {
	[OutputType([String[]])]
	param(
		$Path,
		
		[ValidateSet("")]
		$FormatName,
		
		[Alias("acodec")]
		[ValidateSet("")]
		$AudioCodecName,
		
		[Alias("ab")]
		$AudioBitrate,
		
		[Alias("ac")]
		$AudioChannels,
		
		[Alias("ar")]
		$AudioFrequency,
		
		[Alias("aq")]
		$AudioQuality,
		
		[switch]$NewAudio,
		
		[Alias("an")]
		[switch]$NoAudio,

		[Alias("aspect")]
		$VideoAspect,
		
		[ValidateSet("")]
		$VideoCodecName,
		
		[Alias("b")]
		$VideoBitrate,
		
		[Alias("r")]
		$VideoFrameRate,
		
		[Alias("vlang")]
		$VideoLanguage,
		
		[Alias("vf")]
		$VideoFilters,
		
		[Alias("sameq")]
		[Switch]$VideoSameQuantizer,
		
		[Alias("pass")]
		[ValidateRange(1,2)]
		[int]$VideoPass,
		
		[Alias("vn")]
		[Switch]$NoVideo,
		
		[Switch]$NewVideo,
		
		[Alias("s")]
		[ValidateScript({
			if($_ -match "[\d]+x[\d]+") {
				return $true
			}
			if(Get-FfmpegVideoSize -Name $_) {
				return $true
			}
			throw "VideoSize must be in the format WxH or be one of the names accepted by Get-FfmpegVideoSize"
		})]
		$VideoSize,
		
		[ValidateSet("")]
		$SubtitleCodecName,
		
		[Alias("slang")]
		$SubtitleLanguage,
		
		[switch]$NewSubtitle
	)
	$Options = @()

	if($AudioCodecName -or $NoAudio) {
		if($AudioCodecName -eq "NONE" -or $NoAudio) {
			$Options += "-an"
		} else {
			$Options += "-acodec"
			$Options += $AudioCodecName
		}
	}
	
	$Options = AddOption "-ab" $AudioBitrate $Options
	$Options = AddOption "-ac" $AudioChannels $Options
	$Options = AddOption "-ar" $AudioFrequency $Options
	$Options = AddOption "-aq" $AudioQuality $Options
	
	if($NewAudio) {
		$Options += "-newaudio"
	}
	
	$Options = AddOption "-aspect" $VideoAspect $Options
	
	if($VideoCodecName -or $NoVideo) {
		if($VideoCodecName -eq "NONE" -or $NoVideo) {
			$Options += "-vn"
		} else {
			$Options += "-vcodec"
			$Options += $VideoCodecName
		}
	}

	$Options = AddOption "-b" $VideoBitrate $Options
	$Options = AddOption "-r" $VideoFrameRate $Options
	$Options = AddOption "-s" $VideoSize $Options
	$Options = AddOption "-vlang" $VideoLanguage $Options
	$Options = AddOption "-vf" $VideoFilters $Options
	$Options = AddOption "-pass" $VideoPass $Options
	
	if($VideoSameQuantizer) {
		$Options += "-sameq"
	}
	
	if($NewVideo) {
		$Options += "-newvideo"
	}
	
	if($SubtitleCodecName) {
		if($SubtitleCodecName -eq "NONE") {
			$Options += "-sn"
		} else {
			$Options += "-scodec"
			$Options += $SubtitleCodecName
		}
	}
	
	$Options = AddOption "-slang" $SubtitleLanguage $Options
	$Options = AddOption "-f" $FormatName $Options
	
	if($Path) {
		$Options += $Path
	}
	
	,$Options
}
Export-ModuleMember -Function New-FfmpegOutfileOptions