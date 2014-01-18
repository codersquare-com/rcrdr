package com.media
{
	import acodec.encoder.Mp3Encoder;
	
	import com.common.SoundStream;
	import com.common.Variables;
	
	import flash.utils.ByteArray;
	
	public class LocalSoundStream extends NetSoundStream implements SoundStream
	{
		private var type:String;
		public function LocalSoundStream()
		{
			super();			
		}
		
		public override function startup(obj:Object):void {			
			var mp3encode:Mp3Encoder = obj as Mp3Encoder;
			if(mp3encode.status == Variables.MP3_ENCODED_MP3)
				this.oSound.loadCompressedDataFromByteArray(mp3encode.getByteArray(), mp3encode.getByteArray().length);
		}
		
		
	}
}