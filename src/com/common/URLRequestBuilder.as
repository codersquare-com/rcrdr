package com.common
{
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;

	public class URLRequestBuilder
	{
		private static const MULTIPART_BOUNDARY:String  = "----------196f00b77b968397849367c61a2080";
		private static const MULTIPART_MARK:String      = "--";
		private static const LF:String                  = "\r\n";
		
		/** The variables to encode within a URLRequest */
		private var variables:URLVariables;
		
		/**
		 * Constructor.
		 *
		 * @param variables The URLVariables to encode within a URLRequest.
		 */
		public function URLRequestBuilder(variables:URLVariables)
		{
			this.variables = variables;
		}
		
		/**
		 * Build a URLRequest instance with the correct encoding given the URLVariables
		 * provided to the constructor.
		 *
		 * @return URLRequest instance primed and ready for submission
		 */
		public function build():URLRequest
		{
			var request:URLRequest = new URLRequest();
			if (isMultipartData)
			{
				request.data = buildMultipartBody();
				addMultipartHeadersTo(request);
			}
			else
			{
				request.method = URLRequestMethod.POST;
				request.data = variables;
			}
			return request;
		}
		
		/**
		 * Determines whether, given the URLVariables instance provided to the constructor, the
		 * URLRequest should be encoded using <code>multipart/form-data</code>.
		 */
		private function get isMultipartData():Boolean
		{
			for each (var variable:* in variables)
			{
				if (variable is URLFileVariables)
					return true;
			}
			return false;
		}
		
		/**
		 * Build a ByteArray instance containing the <code>multipart/form-data</code> encoded URLVariables.
		 *
		 * @return ByteArray containing the encoded variables
		 */
		private function buildMultipartBody():ByteArray
		{
			var body:ByteArray = new ByteArray();
			
			// Write each encoded field into the request body
			for (var id:String in variables)
				body.writeBytes(encodeMultipartVariable(id, variables[id]));
			
			// Mark the end of the request body
			// Note, we writeUTFBytes and not writeUTF because it can corrupt parsing on the server
			body.writeUTFBytes(MULTIPART_MARK + MULTIPART_BOUNDARY + MULTIPART_MARK + LF);
			return body;
		}
		
		/**
		 * Encode a variable using <code>multipart/form-data</code>.
		 *
		 * @param id    The unique id of the variable
		 * @param value The value of the variable
		 */
		private function encodeMultipartVariable(id:String, variable:Object):ByteArray
		{
			if (variable is URLFileVariables)
				return encodeMultipartFile(id, URLFileVariables(variable));
			else
				return encodeMultipartString(id, variable.toString());
		}
		
		/**
		 * Encode a file using <code>multipart/form-data</code>.
		 *
		 * @param id   The unique id of the file variable
		 * @param file The URLFileVariable containing the file name and file data
		 *
		 * @return The encoded variable
		 */
		private function encodeMultipartFile(id:String, file:URLFileVariables):ByteArray
		{
			var field:ByteArray = new ByteArray();
			// Note, we writeUTFBytes and not writeUTF because it can corrupt parsing on the server
			field.writeUTFBytes(MULTIPART_MARK + MULTIPART_BOUNDARY + LF +
				"Content-Disposition: form-data; name=\"" + id +  "\"; " +
				"filename=\"" + file.name + "\"" + LF +
				"Content-Type: application/octet-stream" + LF + LF);
			
			field.writeBytes(file.data);
			field.writeUTFBytes(LF);
			return field;
		}
		
		/**
		 * Encode a string using <code>multipart/form-data</code>.
		 *
		 * @param id   The unique id of the string
		 * @param text The value of the string
		 *
		 * @return The encoded variable
		 */
		private function encodeMultipartString(id:String, text:String):ByteArray
		{
			var field:ByteArray = new ByteArray();
			// Note, we writeUTFBytes and not writeUTF because it can corrupt parsing on the server
			field.writeUTFBytes(MULTIPART_MARK + MULTIPART_BOUNDARY + LF +
				"Content-Disposition: form-data; name=\"" + id + "\"" + LF + LF +
				text + LF);
			return field;
		}
		
		/**
		 * Add the relevant <code>multipart/form-data</code> headers to a URLRequest.
		 */
		private function addMultipartHeadersTo(request:URLRequest):void
		{
			request.method         = URLRequestMethod.POST;
			request.contentType    = "multipart/form-data; boundary=" + MULTIPART_BOUNDARY;
			request.requestHeaders =
				[
					new URLRequestHeader("Accept", "*/*"), // Allow any type of data in response
					new URLRequestHeader("Cache-Control", "no-cache")
				];
			
			// Note, the headers: Content-Length and Connection:Keep-Alive are auto set by URLRequest
		}
	}
}