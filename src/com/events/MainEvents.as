package com.events
{
	import flash.events.Event;
	
	public class MainEvents extends Event
	{
		public static const PLAY_URL:String 	 = "playURL";
		public static const DONE_STEP:String 	 = "saveRecording";
		public static var STOP_RECORD:String = "stopRecording";
		public static var START_RECORD:String = "startRecording";
		public static const UPLOAD_URL:String 	 = "uploadURL";
		//public static const RECORD_SOUND:String 	 = "startRecord";		
		public static const MICROPHONE_ACCESS:String 	 = "microphoneAccess";
		public static const PLAY_DONE:String 	 = "playDone";
		public static const RECORD_DONE:String 	 = "saveRecordingDone";		
		public static const UPLOAD_PROGESS:String 	 = "uploadProgess";
		public static const ERROR_RECORD:String = "recordError";
		public static const SHOW_MICSETTING:String = "userClickRecord";		
		public static const STARTUP:String = "flashLoaded";	
		public static const RESIZED:String = "resized";				
		public static var VOLUME_IN:String = "volumeIn";
		public static var VOLUME_OUT:String = "volumeOut";		
		public static var SHOW_MICROPHONE:String = "showMicrophone";		
		public static var GET_MIC_NUM:String = "showNumberOfMicrophone";
		public static var MIC_NUMBER:String = "micNumber";
		public static var CALLBACK_INTERVAL:String = "showPlaybackProgress";
		public static var CALLBACK_FUNCTION:String = "playbackProgress";
		public static var PLAY:String = "play";
		public static var START_UPLOAD:String = "startUpload";
		
		private var _url:String = "";
		private var _time:Number= 0 ;
		private var _name:String = "";
		private var _micAccess:Boolean = false;
		private var _uploadPercent:Number = 0;
		private var _volume:Number;
		public var micNum:Number;
		public var interval:Number;
		public var uploadFile:Array;
		public static var GET_PARAMETERS:String = "getParameters";
		public static var SET_PARAMETERS:String = "setParameters";
		public static var PAUSE:String = "pause_resume";
		public static var START_RECORD_AS3:String = "startRecordingAs3";
		public static var STOP_RECORD_AS3:String = "stopRecordingAs3";
		public static var RECORDING_TIMEOUT:String = "recordingTimeout";
		public static var DONE_STEP_AS3:String = "saveRecordingAs3";
		
		public static var GET_SOUNDS:String = "getSounds";
		
		public static var PUSH_SOUND:String = "pushSounds";
		
		public function MainEvents(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public function get volume():Number
		{
			return _volume;
		}

		public function set volume(value:Number):void
		{
			_volume = value;
		}

		public function get uploadPercent():Number
		{
			return _uploadPercent;
		}

		public function set uploadPercent(value:Number):void
		{
			_uploadPercent = value;
		}

		public function get micAccess():Boolean
		{
			return _micAccess;
		}

		public function set micAccess(value:Boolean):void
		{
			_micAccess = value;
		}

		public function get name():String
		{
			return _name;
		}

		public function set name(value:String):void
		{
			_name = value;
			
		}

		public function get time():Number
		{
			return _time;
		}

		public function set time(value:Number):void
		{
			_time = value;
		}

		public function get url():String
		{
			return _url;
		}

		public function set url(value:String):void
		{
			_url = value;
		}

	}
}