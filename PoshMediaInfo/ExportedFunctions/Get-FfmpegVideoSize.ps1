<#
.SYNOPSIS
	Maps the video size aliases to the WxH size string

.DESCRIPTION
	Maps the video size aliases to the WxH size string

.PARAMETER Name
	The video size alias to map.
	
.EXAMPLE
	Get-FfmpegVideoSize -Name hd720
	
	1280x720
#>
function Get-FfmpegVideoSize {
	[OutputType([string])]
	param(
		[ValidateSet("wvga","hd720","sxga","vga","16cif","hd480","svga","wquxga","qxga","cif","qcif","hsxga","whsxga","ega","woxga","cga","qsxga","xga","whuxga","wqsxga","hd1080","uxga","4cif","sqcif","wuxga","qvga","qqvga","wsxga")]
		$Name
	)
	$Sizes = @{
		sqcif = "128x96";
		qcif = "176x144";
		cif = "352x288";
		"4cif" = "704x576";
		"16cif" = "1408x1152";
		qqvga = "160x120";
		qvga = "320x240";
		vga = "640x480";
		svga = "800x600";
		xga = "1024x768";
		uxga = "1600x1200";
		qxga = "2048x1536";
		sxga = "1280x1024";
		qsxga = "2560x2048";
		hsxga = "5120x4096";
		wvga = "852x480";
		wsxga = "1600x1024";
		wuxga = "1920x1200";
		woxga = "2560x1600";
		wqsxga = "3200x2048";
		wquxga = "3840x2400";
		whsxga = "6400x4096";
		whuxga = "7680x4800";
		cga = "320x200";
		ega = "640x350";
		hd480 = "852x480";
		hd720 = "1280x720";
		hd1080 = "1920x1080";
	}
	$Sizes[$Name]
}
Export-ModuleMember -Function Get-FfmpegVideoSize