package com.events
{
	import flash.events.Event;
	
	public class MainEvents extends Event
	{
		public static const PLAY_URL:String 	 = "playURL";
		public static const DONE_STEP:String 	 = "doneStep";
		public static const UPLOAD_URL:String 	 = "uploadURL";
		public static const RECORD_SOUND:String 	 = "recordSound";
		
		public static const MICROPHONE_ACCESS:String 	 = "microphoneAccess";
		public static const PLAY_DONE:String 	 = "playDone";
		public static const RECORD_DONE:String 	 = "recordDone";
		
		public static const UPLOAD_PROGESS:String 	 = "uploadProgess";
		public static var ERROR_RECORD:String = "recordError";
		public static var SHOW_MICSETTING:String = "userClickRecord";
		
		private var _url:String = "";
		private var _time:Number= 0 ;
		private var _name:String = "";
		private var _micAccess:Boolean = false;
		private var _uploadPercent:Number = 0;
		public function MainEvents(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
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