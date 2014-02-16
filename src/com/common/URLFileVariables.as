package com.common
{
	import flash.utils.ByteArray;

	public class URLFileVariables
	{
		private var _name:String;
		private var _data:ByteArray;
		
		/**
		 * Constructor.
		 *
		 * @param data The contents of the file to be sent to the server
		 * @param name The name to be given to the file on the server, e.g. <code>user_image.jpg</code>
		 */
		public function URLFileVariables(data:ByteArray, name:String)
		{
			_data = data;
			_name = name;
		}
		
		/**
		 * The name to be given to the file on the server
		 */
		public function get name():String
		{
			return _name;
		}
		
		/**
		 * The contents of the file
		 */
		public function get data():ByteArray
		{
			return _data;
		}
	}
}