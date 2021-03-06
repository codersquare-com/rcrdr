package com.media
{	
	
	import com.common.SoundStream;
	import com.controler.JScontroler;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
		
	public class NetSoundStream extends EventDispatcher implements SoundStream{
		private var oSoundChannel:SoundChannel;
		private var isMute:Boolean;
		private var loader:URLLoader;
		private var iVolumeFirst:Number;
		private var _oSound:Sound;
		private var iVolume:Number;
		private var percentLoaded:Number;
		private var iPosition:Number;
		private var url:String;
		private var downloadCallback:Function;
		private var downloadCallbackInterVal:Timer;
		private var _curp:Number;
		private var _time:Number;
		public function getName():String{
			return url;
		}
		
		public function NetSoundStream(downloadProgress:Function) {
			this.oSoundChannel = new SoundChannel();
			this.oSound = new Sound();
			this.iVolume=1;
			this.iPosition=0;
			_curp = 0;
			_time = 0;
			isMute=false;
			downloadCallback = downloadProgress;
			downloadCallbackInterVal = new Timer(2000);
			downloadCallbackInterVal.addEventListener(TimerEvent.TIMER,dctimer);
		}
		
		protected function soundCompleteHandler(event:Event):void
		{
			JScontroler.getInstance().debug("SoundComplete event");
			_callback(url);
		}
		
		protected function dctimer(event:TimerEvent):void
		{			
			downloadCallback(url,percentLoaded);
		}		
				
		public function get oSound():Sound
		{
			return _oSound;
		}

		public function set oSound(value:Sound):void
		{
			_oSound = value;
		}

		public function startup(obj:Object):void {			
			var myURLReq:URLRequest = new URLRequest(obj as String);
			url = obj as String;
			oSound = new Sound();
			oSound.addEventListener(Event.COMPLETE, completeHandler);
			oSound.addEventListener(Event.ID3, id3Handler);
			oSound.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			oSound.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			oSound.load(myURLReq);			
			downloadCallbackInterVal.start();			
			JScontroler.getInstance().debug("Start load file");
		}
		
		protected function ioErrorHandler(event:IOErrorEvent):void
		{
			//trace("ioErrorHandler" + event);
			JScontroler.getInstance().debug("Play URL error: ioErrorHandler" + event);
			downloadCallbackInterVal.stop();			
		}
		
		private function completeHandler(event:Event):void {			
			//trace("completeHandler: " + event);
			downloadCallbackInterVal.stop();
		}
				
		private function id3Handler(event:Event):void {
			//trace("id3Handler: " + event);
		}
		
		private function progressHandler(event:ProgressEvent):void {
			percentLoaded=Math.ceil(event.bytesLoaded/event.bytesTotal*100);
		}
		
		
		public function play(startTime:Number = 0, loops:int = 0, sndTransform:SoundTransform = null):void {			
			var sound:SoundTransform;
			iPosition = startTime > 0 ? startTime :  iPosition;
			oSoundChannel=oSound.play(iPosition);
			oSoundChannel.addEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
			
			sound=oSoundChannel.soundTransform;
			if (isMute) {
				sound.volume=0;
			} else {
				sound.volume=iVolume;
			}
			oSoundChannel.soundTransform=sound;
			JScontroler.getInstance().debug("Start play file");
		}
		public function pause():void {
			iPosition=oSoundChannel.position;
			oSoundChannel.stop();
		}
		public function stop():void {
			updatePos(0);
			//if (_callback != null)
			//	_callback("");
			clearInterval(activeProcess);
			oSoundChannel.removeEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
			oSoundChannel.stop();
		}
		
		public function updatePos(position:Number):void {
			iPosition=position*oSound.length;
		}
		
		public function updateVolume(volume:Number):void {
			var sound:SoundTransform;
			if (isMute) {
				setMute();
			}
			if (oSoundChannel!=null) {
				iVolume=volume;
				sound=oSoundChannel.soundTransform;
				sound.volume=iVolume;
				oSoundChannel.soundTransform=sound;
			} else {
				iVolume=volume;
			}
		}		
		
		public function setMute():void {
			var sound:SoundTransform;
			isMute = isMute ? (false) : (true);
			sound=oSoundChannel.soundTransform;
			if (isMute) {
				sound.volume=0;
				oSoundChannel.soundTransform=sound;
			} else if (oSoundChannel != null) {
				sound.volume=iVolume;
				oSoundChannel.soundTransform=sound;
			}
		}
		
		public function get _percentplayed():Number {
			return Math.ceil(oSoundChannel.position / oSound.length * 1000) / 1000 * (percentLoaded / 100) * 100;
		}
		
		public function timeTotal():Number
		{
			return _timeTotal;
		}
			
		public function get _timePlayed():Number {
			return Math.round(oSoundChannel.position);
		}
		public function get position():Number {
			return Math.round(oSoundChannel.position);
		}
		
		public function getInterval():Number
		{
			return position;
		}
		
		
		public function get _timeTotal():Number {
			return oSound.length;
		}
		
		var activeProcess:Number;
		var _callback:Function = null;
		public function checkStream(callback:Function):void {
			//activeProcess=setInterval(activeProcessFunction, 200);
			JScontroler.getInstance().debug("Add callback");
			_callback = callback;
			
//			function activeProcessFunction() : void{
//				
//				if (_curp == _percentplayed)
//					_time ++;
//				else {
//					_time = 0;
//					_curp = _percentplayed;
//				}
//				
//				if (_time >= 5){
//					//callback(url);
//					clearInterval(activeProcess);
//				}
//					
//				if (percentLoaded==100 && _percentplayed > 99.5) {
//					//callback(url);
//					clearInterval(activeProcess);
//				}
//			}
		}				
	}
}