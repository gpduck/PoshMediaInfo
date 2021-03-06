Add-Type -TypeDefinition @"
using System;

namespace ffmpeg {
	public enum CodecType { Unknown, Audio, Video, Subtitle };
	[Flags]
	public enum CodecFlags {
		None = 0x0,
		Decoding = 0x1,
		Encoding = 0x2,
		IntraFrame = 0x4,
		Lossy = 0x8,
		Lossless = 0x10
	}
	
	public class Codec {
		public String Name;
		public CodecFlags Flags;
		public CodecType Type;
		public String Description;
		public System.Collections.IList Encoders;
		public System.Collections.IList Decoders;
	}
	
	[Flags]
	public enum FormatFlags {
		None = 0x0,
		Demuxing = 0x1,
		Muxing = 0x2
	}
	
	public class Format {
		public String Name;
		public FormatFlags Flags;
		public String Description;
	}
}
"@