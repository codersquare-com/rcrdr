package com.controler
{
	import acodec.IEncoder;
	import acodec.MicRecorder;
	import acodec.encoder.Mp3Encoder;
	import acodec.encoder.WaveEncoder;
	
	import com.common.Uploader;
	import com.common.Variables;
	import com.events.ButtonEvents;
	import com.events.MainEvents;
	import com.media.Playlist;
	
	import deng.fzip.FZip;
	
	import flash.events.ActivityEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.SampleDataEvent;
	import flash.events.StatusEvent;
	import flash.events.TimerEvent;
	import flash.media.Microphone;
	import flash.system.Security;
	import flash.utils.ByteArray;
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
			//JScontroler.getInstance().addEventListener(MainEvents.START_RECORD, recordClick);
			JScontroler.getInstance().addEventListener(MainEvents.STOP_RECORD_AS3, stopRecorder);
			JScontroler.getInstance().addEventListener(ButtonEvents.REPLAY_CLICK_AS3, replayClick);
			
			// control js auto event
			JScontroler.getInstance().addEventListener(MainEvents.PLAY_URL, playURL);
			JScontroler.getInstance().addEventListener(MainEvents.START_RECORD_AS3, startRecording);
			JScontroler.getInstance().addEventListener(MainEvents.DONE_STEP_AS3, doneStep);
			JScontroler.getInstance().addEventListener(MainEvents.VOLUME_IN, volumeIn);
			JScontroler.getInstance().addEventListener(MainEvents.VOLUME_OUT, volumeOut);
			JScontroler.getInstance().addEventListener(MainEvents.SHOW_MICROPHONE, showMicrophone);
			JScontroler.getInstance().addEventListener(MainEvents.GET_MIC_NUM, showNumberOfMicrophone);
			JScontroler.getInstance().addEventListener(MainEvents.CALLBACK_INTERVAL, showPlaybackProgress);
			JScontroler.getInstance().addEventListener(MainEvents.PLAY, play);
			JScontroler.getInstance().addEventListener(MainEvents.UPLOAD_URL, uploadUrl);
			JScontroler.getInstance().addEventListener(MainEvents.GET_PARAMETERS, getParams);
			JScontroler.getInstance().addEventListener(MainEvents.START_UPLOAD, startUpload);
			JScontroler.getInstance().addEventListener(MainEvents.PUSH_SOUND, pushSounds);
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
		
		protected function pushSounds(event:MainEvents):void
		{
			var fh:FileHandler = new FileHandler();
			
			var isDone:Number;//=
			var isUpload:Boolean = true;
			var j:Number = 0,i:Number = 0;
			if(event.uploadFile == null){
				isDone = encoders.length;
				for(i= 0; i< encoders.length; i++)
				{
					if((encoders[i] as Mp3Encoder).status == Variables.MP3_ENCODED_MP3) {
						fh.addFile((encoders[i] as Mp3Encoder).name,(encoders[i] as Mp3Encoder).getMp3Array(null,i));
						isDone --;
					}
					else {						
						isUpload = false;
						(encoders[i] as Mp3Encoder).getMp3Array(addJtoI,i);
					}
				}
			}
			else
			{
				isDone = event.uploadFile.length;
				
				for(i = 0; i< event.uploadFile.length; i++)
				{
					for(j  = 0; j < encoders.length;j++)
					{
						if( (encoders[j] as Mp3Encoder).name == event.uploadFile[i])
						{
							if((encoders[j] as Mp3Encoder).status == Variables.MP3_ENCODED_MP3) {
								fh.addFile(event.uploadFile[i],(encoders[j] as Mp3Encoder).getMp3Array(null,j));
								isDone --;
							}
							else
								(encoders[i] as Mp3Encoder).getMp3Array(addJtoI,j);
						}
					}
				}
			}
			
			function addJtoI(index:int):void
			{
				fh.addFile(event.uploadFile[index],(encoders[index] as Mp3Encoder).getMp3Array(null,index));
				isDone --;
				if(isDone <=0)
				{					
					var uld:Uploader = new Uploader;
					uld.sendRequest(fh);
					isUpload = false;
				}
			}
			if(isUpload){
				var uld:Uploader = new Uploader;
				uld.sendRequest(fh);
			}
		}
		
		
		
		protected function getParams(event:MainEvents):void
		{
			var me:MainEvents = new MainEvents(MainEvents.SET_PARAMETERS, true);			
			me.name = event.name;
			switch (event.name) {
				case Variables.VOLUME_OUT:
					me.url = "" +  playlist.vol *100;
					break;
				case Variables.VOLUME_IN:
					
					me.url = "" +  _gain;
					break;
			}
			
			JScontroler.getInstance().dispatchEvent(me);
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
			var isStoping:Boolean = _recorder.stop();
			if(!isStoping) {	
				addCurrentRecordToPlaylist1();
			}
		}
		
		protected function startRecording(event:MainEvents):void
		{			
			JScontroler.getInstance().dispatchEvent(new MainEvents(MainEvents.SHOW_MICSETTING,true));
			if(status == Variables.INITIAL){
				if(_main.stage.stageWidth > 150 && _main.stage.stageHeight > 150)
					showSetting(null);
				else {
					_main.stage.addEventListener(Event.RESIZE, onStageResize, false, 0, true);
					
					addEventListener(MainEvents.RESIZED, showSetting);
				}
				trace(_main.stage.stageWidth, _main.stage.stageHeight);
			}
			if (encoders.length > 0 )
			{
				if((encoders[curEncoderIndex] as IEncoder).name == event.name)
				{// dang record roi
					try{
						var isStoping:Boolean = _recorder.stop();
						if(!isStoping) {	
							_recorder.record();
							status = Variables.RECORD;
						}else
							status = Variables.RE_RECORD;
						playlist.STOPALL();					
					} catch (e:Error) {}
					//_recorder.record();
					return;
				}
			}
			trace("new record"  + event.name);
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
		
		private function addCurrentRecordToPlaylist1():void {			
			playlist.AddWavSound((encoders[curEncoderIndex] as IEncoder).getByteArray(),encoders[curEncoderIndex].name);
			PLAY();
			var me:MainEvents = new MainEvents(MainEvents.RECORD_DONE,true);
			me.time = playlist.getSoundTime(encoders[curEncoderIndex].name);
			me.name = encoders[curEncoderIndex].name;
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
			if (this.status == Variables.DONE)
			{
				addCurrentRecordToPlaylist1();
				JScontroler.getInstance().dispatchEvent(new MainEvents(MainEvents.RECORDING_TIMEOUT,true));
			}
			
			if (this.status == Variables.RECORD ||this.status== Variables.RECORDDONE) {
				// use tmp sound				
				if(event == null)
					playlist.AddWaveSoundAndPlay((encoders[curEncoderIndex] as IEncoder).getByteArray(), event == null);
				trace("xx",curEncoderIndex);
			}
			
			if (this.status == Variables.RE_RECORD) {
				_recorder.record();
				this.status = Variables.RECORD;
			}
		}
		
		protected function record_timeout(event:TimerEvent):void
		{
			doneStep(null);
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
			if(this.status == Variables.RECORD || status== Variables.RECORDDONE){			
				var isStoping:Boolean = _recorder.stop();
				if(!isStoping)
				{			
					// stoped
					user_record_done(null);
				}
			}
			trace("replay record");
		}
		
		protected function stopRecorder(event:MainEvents):void
		{
			if(timer != null)
				timer.removeEventListener(TimerEvent.TIMER_COMPLETE,record_timeout);
			try {
				this.status = Variables.RECORDDONE;
				var isStoping:Boolean = _recorder.stop();
				if(!isStoping) {					
					this.status = Variables.READY;
					//addCurrentRecordToPlaylist();
				}
				
			}catch (e:Error)
			{
				this.status = Variables.READY;
			}
			trace("record done");
		}
		
		//		protected function recordClick(event:ButtonEvents):void
		//		{
		//			if(status == Variables.INITIAL){
		//				if(_main.stage.stageWidth > 150 && _main.stage.stageHeight > 150)
		//					showSetting(null);
		//				else {
		//					_main.stage.addEventListener(Event.RESIZE, onStageResize, false, 0, true);				
		//					addEventListener(MainEvents.RESIZED, showSetting);
		//				}
		//				trace(_main.stage.stageWidth, _main.stage.stageHeight);
		//			}
		//			
		//			if(status == Variables.RECORD )
		//			{
		//				try{
		//					var isStoping:Boolean = _recorder.stop();
		//					if(!isStoping) {	
		//						_recorder.record();
		//						this.status = Variables.RECORD;
		//					}else
		//						status = Variables.RE_RECORD;
		//					playlist.STOPALL();					
		//				} catch (e:Error) {}
		//			}
		//			trace("Record click");
		//		}
		
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
			
			var tmp:Mp3Encoder = new Mp3Encoder;
			_recorder.startup(tmp,_gain, _mic,_micNum);
			_recorder.check();			
			_recorder.microphone.addEventListener(StatusEvent.STATUS, this.userAccessMicEvent, false, 0, true); 			
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