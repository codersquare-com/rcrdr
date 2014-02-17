package com.events
{
	import flash.events.Event;
	
	public class MainEvents extends Event
	{		
		public static const PLAY_CLICK:String = "playClick";
		public static const STOP_RECORD:String = "stopRecording";	
		public static const REPLAY_CLICK:String = "replayRecording";	
		public static const SHOW_MICROPHONE:String = "showMicrophone";
		public static const PLAY_URL:String 	 = "playURL";
		public static const START_RECORD:String = "startRecording";		
		public static const DONE_STEP:String 	 = "saveRecording";		
		public static const VOLUME_IN:String = "volumeIn";
		public static const VOLUME_OUT:String = "volumeOut";
		public static const GET_MIC_NUM:String = "showNumberOfMicrophone";
		public static const CALLBACK_INTERVAL:String = "showPlaybackProgress";
		public static const PLAY:String = "play";
		public static const PAUSE:String = "pause_resume";
		public static const GET_PARAMETERS:String = "getParameters";
		public static const GET_SOUNDS:String = "getSounds";
		public static const UPLOAD_URL:String 	 = "uploadURL";
		public static const START_UPLOAD:String = "startUpload";
		
			
		public function MainEvents(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}