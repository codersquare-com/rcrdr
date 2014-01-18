package com.media
{
	import as3wavesound.WavSound;
	import as3wavesound.WavSoundChannel;
	
	import com.common.SoundStream;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class WaveSoundStream extends EventDispatcher implements SoundStream
	{		
		private var oSoundChannel:WavSoundChannel;
		private var isMute:Boolean;
		private var iVolumeFirst:Number;
		private var _oSound:WavSound;
		private var iVolume:Number;
		private var percentLoaded:Number;
		private var iPosition:Number;
		
		public function WaveSoundStream()
		{
		}
		
		public function startup(obj:Object):void
		{
		}
		
		public function play():void
		{
		}
		
		public function pause():void
		{
		}
		
		public function stop():void
		{
		}
		
		
	}
}