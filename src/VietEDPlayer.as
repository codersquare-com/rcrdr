package
{
	import acodec.IEncoder;
	import acodec.MicRecorder;
	import acodec.encoder.Mp3Encoder;
	
	import as3wavesound.*;
	
	import com.common.SoundStream;
	import com.controler.Controler;
	import com.controler.JScontroler;
	import com.events.ButtonEvents;
	import com.events.MainEvents;
	import com.media.LocalSoundStream;
	import com.media.NetSoundStream;
	
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.system.Security;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	
	import mx.core.ButtonAsset;
	
	public class VietEDPlayer extends Sprite
	{
		private var control:Controler;
		
		
		public function VietEDPlayer()
		{
			this.stage.align = StageAlign.TOP_LEFT;
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			Security.allowDomain("*");
			this.width = stage.stageWidth;
			this.height = stage.stageHeight;
			control = new Controler(this);			
			control.startup();
		}
		
	}
}

