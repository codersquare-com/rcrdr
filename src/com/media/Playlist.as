package com.media
{
	import as3wavesound.WavSound;
	
	import com.common.SoundStream;
	
	import flash.sensors.Accelerometer;
	import flash.utils.ByteArray;

	public class Playlist
	{
		private var _arrayStream:Array;
		private var _currentSound:Number;
		private var _currentSoundStream:SoundStream;
		private var _callBack:Function;
		private var _tmpSoundStream:SoundStream;
		
		public function updateVolume(vol:Number) :void {
			if(_currentSoundStream != null)
				_currentSoundStream.updateVolume(vol);
			if(_tmpSoundStream != null)
				_tmpSoundStream.updateVolume(vol);
		}
		
	
		
		public function Playlist()
		{
			_arrayStream = new Array();
			_currentSound = 0;
		}
		
		public function AddSound(url:String):void {
			var ss:SoundStream = new NetSoundStream();
			ss.startup(url);
			_arrayStream.push(ss);
			_currentSound = _arrayStream.length - 1;			
		}
		
		public function AddWavSound(byte:ByteArray):void {
			var ss:SoundStream = new WavSound(byte);
			_arrayStream.push(ss);
			_currentSound = _arrayStream.length - 1;			
		}
		
		public function STOPALL() :void {
			try {
				_tmpSoundStream.stop();
				_currentSoundStream.stop();
			}catch (e:Error)
			{
				trace("tmp stopped");
			}
		}
		public function AddWaveSoundAndPlay(byte:ByteArray) : void {
			try {
				_tmpSoundStream.stop();
			}catch (e:Error)
			{
				trace("tmp stopped");
			}
			_tmpSoundStream = new WavSound(byte);
			_tmpSoundStream.play();
		}
		
		public function play():void
		{
			if(_currentSound >= _arrayStream.length)
				return;
			try {
				// stop tmp
				_tmpSoundStream.stop();
			}catch (e:Error)
			{
				trace("tmp stopped");
			}
			_currentSoundStream = _arrayStream[_currentSound];
			_currentSoundStream.checkStream(_callBack);
			_currentSoundStream.play();
			trace("play");
		}
				
		public function PLAYALL() :void {
			_currentSound = 0;
			_callBack = NEXT;	
			play();		
		}
		
		public function NEXT():void {
			if(_currentSound >= _arrayStream.length)
				return;
			_currentSound ++;
			_callBack = NEXT;	
			play();		
		}
		
		public function addCallBack(callBack:Function):void {
			_callBack = callBack;				
		}
	}
}