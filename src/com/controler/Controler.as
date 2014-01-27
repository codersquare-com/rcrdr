package com.controler
{
	import acodec.IEncoder;
	import acodec.MicRecorder;
	import acodec.encoder.Mp3Encoder;
	import acodec.encoder.WaveEncoder;
	
	import com.common.Variables;
	import com.events.ButtonEvents;
	import com.events.MainEvents;
	import com.media.Playlist;
	
	import flash.events.ActivityEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.SampleDataEvent;
	import flash.events.StatusEvent;
	import flash.events.TimerEvent;
	import flash.media.Microphone;
	import flash.system.Security;
	import flash.utils.Timer;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;

	public class Controler extends EventDispatcher
	{
		private var _main:VietEDPlayer;
		private var status:String;
		private var _mic:Microphone;
		private var _recorder:MicRecorder;
		private var encoders:Array = new Array;
		private var playlist:Playlist;
		private var timer:Timer;
		private var _gain:Number;
		private var curEncoderIndex:Number;
		private var _micNum:Number;
		private var _interval:Number;
		private var interValProcess:uint;
		private var interValRuning:Boolean;
		
		public function Controler(main:VietEDPlayer)
		{
			_main = main;
			// control button
			JScontroler.getInstance().addEventListener(ButtonEvents.PLAY_CLICK, playClick);
			JScontroler.getInstance().addEventListener(ButtonEvents.RECORD_CLICK, recordClick);
			JScontroler.getInstance().addEventListener(ButtonEvents.RECORD_DONE_CLICK, recordDoneClick);
			JScontroler.getInstance().addEventListener(ButtonEvents.REPLAY_CLICK, replayClick);
			
			// control js auto event
			JScontroler.getInstance().addEventListener(MainEvents.PLAY_URL, playURL);
			JScontroler.getInstance().addEventListener(MainEvents.RECORD_SOUND, recordSound);
			JScontroler.getInstance().addEventListener(MainEvents.DONE_STEP, doneStep);
			JScontroler.getInstance().addEventListener(MainEvents.VOLUME_IN, volumeIn);
			JScontroler.getInstance().addEventListener(MainEvents.VOLUME_OUT, volumeOut);
			JScontroler.getInstance().addEventListener(MainEvents.SHOW_MICROPHONE, showMicrophone);
			JScontroler.getInstance().addEventListener(MainEvents.GET_MIC_NUM, showNumberOfMicrophone);
			JScontroler.getInstance().addEventListener(MainEvents.CALLBACK_INTERVAL, showPlaybackProgress);
			JScontroler.getInstance().addEventListener(MainEvents.PLAY, play);
			JScontroler.getInstance().addEventListener(MainEvents.UPLOAD_URL, uploadUrl);
			
			JScontroler.getInstance().addEventListener(MainEvents.START_UPLOAD, startUpload);
			status = Variables.INITIAL;			
			playlist = new Playlist;
			_recorder = new MicRecorder;
			playlist.addCallBack(soundCompleteHandler);
			_recorder.addCallBack(stopRecord, startRecord);
			// startup
			JScontroler.getInstance().dispatchEvent(new MainEvents(MainEvents.STARTUP,true));
			_gain = 70;
			_micNum = -1;
			interValProcess = 0;
			interValRuning = false;
		}
		
		private function uploadCallback():void {
			
		}
		
		protected function startUpload(event:MainEvents):void
		{
			// startupload
			var fileHandler:FileHandler = new FileHandler;
			fileHandler.addCallback(uploadCallback);
			for each ( var name:String in event.uploadFile) {
				
			}
		}
		
		protected function uploadUrl(event:MainEvents):void
		{
			Variables.UPLOAD_URL = event.url;
		}
		
		protected function play(event:MainEvents):void
		{
			playlist.playSpecial(event.name, event.time);
		}		
		
		protected function showPlaybackProgress(event:MainEvents):void
		{
			_interval = event.interval;
			if(interValRuning)
				clearInterval(interValProcess);
			interValRuning = false;
			if(_interval > 0) {
			interValRuning = true;
			var ac:MainEvents = new MainEvents(MainEvents.CALLBACK_FUNCTION,true);
			interValProcess=setInterval(activeProcessFunction, _interval);
				function activeProcessFunction() : void{
					JScontroler.getInstance().dispatchEvent(ac);
				}
			}
		}
		
		protected function showNumberOfMicrophone(event:MainEvents):void
		{
			var ma:MainEvents = new MainEvents(MainEvents.MIC_NUMBER,true);
			ma.micNum = Microphone.names.length;
			JScontroler.getInstance().dispatchEvent(ma);
		}
		
		protected function showMicrophone(event:MainEvents):void
		{
			_micNum = event.micNum;
			if(_main.stage.stageWidth > 150 && _main.stage.stageHeight > 150)
				showSetting(null);
			else {
				_main.stage.addEventListener(Event.RESIZE, onStageResize, false, 0, true);
				
				addEventListener(MainEvents.RESIZED, showSetting);
			}
		}
		
		protected function volumeOut(event:MainEvents):void
		{
			if(playlist != null)
				playlist.updateVolume(event.volume / 100);
		}
		
		protected function volumeIn(event:MainEvents):void
		{
			if(_recorder != null) {
				_gain = event.volume;
				_recorder.gain = _gain;
			}
			
		}
		private function stopRecord() :void {
			JScontroler.getInstance().dispatchEvent(new MainEvents(MainEvents.STOP_RECORD,true));
		}
		private function startRecord() : void {
			JScontroler.getInstance().dispatchEvent(new MainEvents(MainEvents.START_RECORD,true));
		}
		protected function doneStep(event:Event):void
		{
			this.status = Variables.DONE;			
		}
		
		protected function recordSound(event:MainEvents):void
		{
			if(this.status != Variables.INITIAL || this.status != Variables.READY)
				JScontroler.getInstance().dispatchEvent(new MainEvents(MainEvents.ERROR_RECORD,true));
			this.status = Variables.RECORD;
			var iencoder:IEncoder = new Mp3Encoder;
			iencoder.name = event.name;
			encoders.push(iencoder);
			curEncoderIndex =  encoders.length - 1;
			_recorder.startup(iencoder,_gain,_mic,_micNum);
			_recorder.record();
			_recorder.addEventListener(Event.COMPLETE, user_record_done);
			
			timer= new Timer(1000,event.time);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, record_timeout);
			timer.start();
		}
		
		private function addCurrentRecordToPlaylist():void {			
			playlist.AddWavSound((encoders[curEncoderIndex] as IEncoder).getByteArray(),encoders[curEncoderIndex].name);
			PLAY();
			var me:MainEvents = new MainEvents(MainEvents.RECORD_DONE,true);
			me.time = playlist.getSoundTime(encoders[curEncoderIndex].name);
			JScontroler.getInstance().dispatchEvent(me);
			
			(encoders[curEncoderIndex] as IEncoder).addEventListener(Event.COMPLETE, encodeMp3Done);
			(encoders[curEncoderIndex] as IEncoder).encodeMp3();
			trace("user record done");
		}
		
		private function encodeMp3Done(e:Event):void
		{
			trace("encode mp3 done");
		}
		
		protected function user_record_done(event:Event):void
		{
			if(this.status == Variables.RECORDDONE){
				this.status = Variables.READY;
				addCurrentRecordToPlaylist();
			} 
			
			if (this.status == Variables.RECORD) {
				// use tmp sound
				playlist.AddWaveSoundAndPlay((encoders[curEncoderIndex] as IEncoder).getByteArray());
			}
			
			if (this.status == Variables.RE_RECORD) {
				_recorder.record();
				this.status = Variables.RECORD;
			}
		}
		
		protected function record_timeout(event:TimerEvent):void
		{
			recordDoneClick(null);
		}
		
		private function soundCompleteHandler(name:String):void {
			this.status= Variables.READY;
			var ms:MainEvents = new MainEvents(MainEvents.PLAY_DONE, true);
			ms.name = name;
			JScontroler.getInstance().dispatchEvent(ms);
		}
		
		protected function playURL(event:MainEvents):void
		{
			playlist.AddSound(event.url);
			PLAY();
		}		
		
		private function PLAY():void
		{
			if(this.status == Variables.READY || this.status == Variables.INITIAL)
			{
				playlist.play();				
			}
			
		}		
		
		protected function replayClick(event:ButtonEvents):void
		{
			if(this.status == Variables.RECORD){			
				var isStoping:Boolean = _recorder.stop();
				if(!isStoping) {			
					// stoped
					user_record_done(null);
				}
			}
			trace("replay record");
		}
		
		protected function recordDoneClick(event:ButtonEvents):void
		{
			if(timer != null)
				timer.removeEventListener(TimerEvent.TIMER_COMPLETE,record_timeout);
			try {
				this.status = Variables.RECORDDONE;
				var isStoping:Boolean = _recorder.stop();
				if(!isStoping) {					
					this.status = Variables.READY;
					addCurrentRecordToPlaylist();
				}
					
			}catch (e:Error)
			{
				this.status = Variables.READY;
			}
			trace("record done");
		}
		
		protected function recordClick(event:ButtonEvents):void
		{
			if(status == Variables.INITIAL){
				if(_main.stage.stageWidth > 150 && _main.stage.stageHeight > 150)
					showSetting(null);
				else {
					_main.stage.addEventListener(Event.RESIZE, onStageResize, false, 0, true);
				
					addEventListener(MainEvents.RESIZED, showSetting);
				}
				trace(_main.stage.stageWidth, _main.stage.stageHeight);
			}
			
			if(status == Variables.RECORD )
			{
				try{
					var isStoping:Boolean = _recorder.stop();
					if(!isStoping) {	
						_recorder.record();
					}else
						status = Variables.RE_RECORD;
					playlist.STOPALL();					
				} catch (e:Error) {}
				_recorder.record();
			}
			trace("Record click");
		}
		
		protected function onStageResize(event:Event):void
		{
			if(event != null)
				_main.stage.removeEventListener(Event.RESIZE, onStageResize);
			dispatchEvent(new MainEvents(MainEvents.RESIZED,true));
			trace(_main.stage.stageWidth, _main.stage.stageHeight);
		}
		
		protected function showSetting(event:Event):void
		{
			if(event != null)
				removeEventListener(MainEvents.RESIZED, showSetting);
			JScontroler.getInstance().dispatchEvent(new MainEvents(MainEvents.SHOW_MICSETTING,true));
			var tmp:Mp3Encoder = new Mp3Encoder;
			_recorder.startup(tmp,_gain, _mic,_micNum);
			_recorder.check();			
			_recorder.microphone.addEventListener(StatusEvent.STATUS, this.userAccessMicEvent); 			
		}
		
		protected function userAccessMicEvent(event:StatusEvent):void
		{
			_recorder.stop();
			var e:MainEvents = new MainEvents(MainEvents.MICROPHONE_ACCESS,true);
			e.micAccess = false;
			if (event.code == "Microphone.Unmuted") 
			{
				e.micAccess = true;
			}
			JScontroler.getInstance().dispatchEvent(e);
			trace(event);
		}
		
		protected function statusHandler(event:StatusEvent):void
		{
			trace(event);
		}
		
		protected function activityHandler(event:ActivityEvent):void
		{
			trace(event);			
		}
		
		
		protected function playClick(event:ButtonEvents):void
		{
			if(this.status == Variables.DONE)
				playlist.PLAYALL();
			
		}
		
		public function startup():void
		{
			// TODO Auto Generated method stub
			
		}
	}
}