package com.media
{
	import as3wavesound.WavSound;
	
	import com.common.SoundStream;
	
	import flash.utils.ByteArray;

	public class Playlist
	{
		private var _arrayStream:Array;
		private var _currentSound:Number;
		private var _currentSoundStream:SoundStream;
		private var _callBack:Function;
		
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
		
		public function play():void
		{
			if(_currentSound >= _arrayStream.length)
				return;
			_currentSoundStream = _arrayStream[_currentSound];
			_currentSoundStream.play();
			_currentSoundStream.checkStream(_callBack);
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