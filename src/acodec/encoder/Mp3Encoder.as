package acodec.encoder
{
	import acodec.IEncoder;
	
	import com.common.Variables;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.ProgressEvent;
	import flash.utils.ByteArray;
	
	import fr.kikko.lab.ShineMP3Encoder;
	
	public class Mp3Encoder extends EventDispatcher implements IEncoder
	{
		private var _wave:WaveEncoder;
		private var _volume:Number;
		private var mp3Shine:ShineMP3Encoder = null;
		private var _status:String;
		private var _name:String;
		/**
		 * 
		 * @param volume
		 * 
		 */	
		public function Mp3Encoder(volume:Number=1)
		{
			_volume = volume;
			_wave = new WaveEncoder(_volume);
			_status = Variables.MP3_ENCODER_INIT;
		}
		
		public function get status():String
		{
			return _status;
		}

		public function get wave():WaveEncoder
		{
			return _wave;
		}

		public function encodeMp3():void {	
			if(wave.getByteArray().length ==0)
				return;
			mp3Shine = new ShineMP3Encoder(wave.getByteArray());
			mp3Shine.addEventListener(Event.COMPLETE, mp3EncodeComplete);
			mp3Shine.addEventListener(ProgressEvent.PROGRESS, mp3EncodeProgress);
			mp3Shine.addEventListener(ErrorEvent.ERROR, mp3EncodeError);
			mp3Shine.start();
		}
		
		/**
		 * 
		 * @param samples
		 * @param channels
		 * @param bits
		 * @param rate
		 * @return 
		 * 
		 */		
		public function encode( samples:ByteArray, channels:int=2, bits:int=16, rate:int=44100 ):void
		{			
			//if(status == Variables.MP3_ENCODED_WAV){
				//dispatchEvent(new Event(Event.COMPLETE));
				//return;
			//}
			_wave = new WaveEncoder(_volume);
			wave.addEventListener(Event.COMPLETE, waveCompleteHandler);
			wave.encode(samples,channels,bits,rate);	
		}
		
		protected function waveCompleteHandler(event:Event):void
		{
			wave.removeEventListener(Event.COMPLETE, waveCompleteHandler);
			dispatchEvent(new Event(Event.COMPLETE));			
			_status = Variables.MP3_ENCODED_WAV;
		}
		
		public function getByteArray():ByteArray
		{
			//if(mp3Shine != null)
				//return mp3Shine.mp3Data;
			return wave.getByteArray();
		}
		
		public function clone():IEncoder
		{
			var tmp:IEncoder = new Mp3Encoder(_volume);
			(tmp as Mp3Encoder).setData(wave,_status,_name,mp3Shine);
			return tmp;
		}
		
		public function setData(w:WaveEncoder,status:String,name:String, mp3:ShineMP3Encoder):void
		{
			_wave = null;
			_wave = w.clone() as WaveEncoder;
			_status = status;
			_name = name;
			mp3Shine = null;
			if(mp3 != null) {
				mp3Shine = new ShineMP3Encoder(null);
				mp3Shine.mp3Data.writeBytes(mp3.mp3Data);
			}
				
		}
		
		protected function mp3EncodeError(event:Event):void
		{
			dispatchEvent(new Event(ErrorEvent.ERROR));
		}
		
		protected function mp3EncodeProgress(event:Event):void
		{
			_status = Variables.ERROR;
		}
		
		protected function mp3EncodeComplete(event:Event):void
		{
			mp3Shine.removeEventListener(Event.COMPLETE,mp3EncodeComplete);
			dispatchEvent(new Event(Event.COMPLETE));			
			_status = Variables.MP3_ENCODED_MP3;
		}
		
		public function get name():String
		{
			return _name ;
		}
		
		public function set name(n:String):void
		{
			_name = n;
		}
	}
}