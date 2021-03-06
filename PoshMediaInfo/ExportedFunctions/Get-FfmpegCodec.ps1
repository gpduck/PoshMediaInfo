<#
.SYNOPSIS
	Returns a list of valid ffmpeg codecs.
	
.DESCRIPTION
	Parses the output from ffmpeg.exe -codecs and returns objects representing
	valid codecs.
#>
function Get-FfmpegCodec {
	[OutputType([ffmpeg.Codec])]
	param(
		[string]$Name,
		[ffmpeg.CodecType]$Type,
		[ffmpeg.CodecFlags]$Flags
	)
	$FoundSeparator = $false
	$AllCodecs = &$ffmpeg -codecs 2> $null | %{
		if($_.trim() -eq "-------") {
			$FoundSeparator = $true
		} elseif($FoundSeparator) {
			$Split = $_.Trim().Split(" ", 3, [StringSplitOptions]::RemoveEmptyEntries)
			[ffmpeg.CodecFlags]$CodecFlags = [ffmpeg.CodecFlags]::None
			[ffmpeg.CodecType]$CodecType = [ffmpeg.CodecType]::Unknown
			if($Split[0][0] -eq "D") {
				$CodecFlags = $CodecFlags -bor [ffmpeg.CodecFlags]::Decoding
			}
			if($Split[0][1] -eq "E") {
				$CodecFlags = $CodecFlags -bor [ffmpeg.CodecFlags]::Encoding
			}
			if($Split[0][3] -eq "I") {
				$CodecFlags = $CodecFlags -bor [ffmpeg.CodecFlags]::IntraFrame
			}
			if($Split[0][4] -eq "L") {
				$CodecFlags = $CodecFlags -bor [ffmpeg.CodecFlags]::Lossy
			}
			if($Split[0][5] -eq "S") {
				$CodecFlags = $CodecFlags -bor [ffmpeg.CodecFlags]::Lossless
			}
			if($Split[0][2] -eq "V") {
				$CodecType = [ffmpeg.CodecType]::Video
			}
			if($Split[0][2] -eq "A") {
				$CodecType = [ffmpeg.CodecType]::Audio
			}
			if($Split[0][2] -eq "S") {
				$CodecType = [ffmpeg.CodecType]::Subtitle
			}
			$EncDecRegex = [regex]"(?:(?<Type>decoders|encoders): (?<Values>[\w\s_]+))"
			$EncDecMatches = [regex]::Matches($Split[2], $EncDecRegex)
			$Encoders = @()
			$Decoders = @()
			if($EncDecMatches.Count -gt 0) {
				$TypeGroupNumber = $EncDecRegex.GroupNumberFromName("Type")
				$ValuesGroupNumber = $EncDecRegex.GroupNumberFromName("Values")
				$EncDecMatches | ForEach-Object {
					Set-Variable -Name $_.Groups[$TypeGroupNumber].Value -Value $_.Groups[$ValuesGroupNumber].Value.Trim().Split(" ")
				}
			}
			New-Object ffmpeg.Codec -Property @{
				Name = $Split[1]
				Flags = $CodecFlags
				Type = $CodecType
				Description = $Split[2]
				Encoders = $Encoders
				Decoders = $Decoders
			}
		}
	}
	
	$AllCodecs | Where-Object {
		$NameMatch = if($Name) {
			$_.Name -eq $Name
		} else {
			$true
		}
		
		$TypeMatch = if($Type) {
			$_.Type -eq $Type
		} else {
			$true
		}
		
		$FlagsMatch = if($Flags) {
			$_.Flags -band $Flags
		} else {
			$true
		}
		
		$NameMatch -and $TypeMatch -and $FlagsMatch
	}
}
Export-ModuleMember -Function Get-FfmpegCodec