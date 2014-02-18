package com.events
{
	import flash.events.Event;
	
	public class ControlEvents extends Event
	{
		public static const PLAY_CLICK:String = "playClickCtr";
		public static const STOP_RECORD:String = "stopRecordingCtr";	
		public static const REPLAY_CLICK:String = "replayRecordingCtr";	
		public static const SHOW_MICROPHONE:String = "showMicrophoneCtr";
		public static const PLAY_URL:String 	 = "playURLCtr";
		public static const START_RECORD:String = "startRecordingCtr";		
		public static const DONE_STEP:String 	 = "saveRecordingCtr";		
		public static const VOLUME_IN:String = "volumeInCtr";
		public static const VOLUME_OUT:String = "volumeOutCtr";
		public static const GET_MIC_NUM:String = "showNumberOfMicrophoneCtr";
		public static const CALLBACK_INTERVAL:String = "showPlaybackProgressCtr";
		public static const PLAY:String = "playCtr";
		public static const PAUSE:String = "pause_resumeCtr";
		public static const GET_PARAMETERS:String = "getParametersCtr";
		public static const GET_SOUNDS:String = "getSoundsCtr";
		public static const UPLOAD_URL:String 	 = "uploadURLCtr";
		public static const START_UPLOAD:String = "startUploadCtr";
		public var micNum:Number = 0;
		public var volume:Number = 100;
		public var name:String = "";
		public var time:Number = 0;
		public var url:String = "";
		public var uploadFile:Array = null;
		public var interval:Number = 0;
		public static var STOP:String = "stopCtr";
		public function ControlEvents(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}