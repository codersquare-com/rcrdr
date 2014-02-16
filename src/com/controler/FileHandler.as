package com.controler
{
	import deng.fzip.FZip;
	
	import flash.utils.ByteArray;

	public class FileHandler
	{
		private var _zip:FZip;
		
		public function FileHandler()
		{
			_zip = new FZip;
		}
		
		public function get zip():FZip
		{
			return _zip;
		}

		public function addFile(name:String, data:Object) : void {
			zip.addFile(name,data as ByteArray);
		}
		
		public function addCallback(uploadCallback:Function):void
		{
			
		}
	}
}