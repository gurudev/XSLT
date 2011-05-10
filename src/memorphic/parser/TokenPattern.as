/*
	Copyright (c) 2007 Memorphic Ltd. All rights reserved.
	
	Redistribution and use in source and binary forms, with or without 
	modification, are permitted provided that the following conditions 
	are met:
	
		* Redistributions of source code must retain the above copyright 
		notice, this list of conditions and the following disclaimer.
	    	
	    * Redistributions in binary form must reproduce the above 
	    copyright notice, this list of conditions and the following 
	    disclaimer in the documentation and/or other materials provided 
	    with the distribution.
	    	
	    * Neither the name of MEMORPHIC LTD nor the names of its 
	    contributors may be used to endorse or promote products derived 
	    from this software without specific prior written permission.
	
	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
	"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
	LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
	A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT 
	OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
	SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT 
	LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
	DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY 
	THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
	(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
	OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

package memorphic.parser
{
	public class TokenPattern
	{


		/**
		 * A name by which this pattern may be referred to. This name will be assigned to tokens that match this 
		 * pattern for use by the Syntax tree and parser
		 */
		public var name:String;
		
		internal var matchFromStartPattern:RegExp;
		
		
		/**
		* [Not implemented]
		*/		
		public var captureGroupIndex:int;
		
		/**
		* [Not implemented]
		*/		
		public var multiMatch:Boolean;
		
		/**
		 *  The result of the previous time that <code>matchFromStart()</code> was executed
		 */
		public var lastMatch:Array = null;
		
		
		/**
		 * 
		 * @param name A name to assign to this pattern. This should be unique within the lexer and grammar
		 * @param pattern A string that will be converted into a regular expression which will match the token
		 * @param ignoreCase Determines if the regular expression will have its ignoreCase flag set
		 * @param multiMatch [Not implemented]
		 * @param captureGroupIndex [Not implemented]
		 * 
		 */		
		public function TokenPattern(
			name:String,
			pattern:String,
			ignoreCase:Boolean=false,
			multiMatch:Boolean=false,
			captureGroupIndex:int = 0
		){

			var modifiers:String = "x";
			if(ignoreCase){
				modifiers += "i";
			}
			this.name = name;
			this.multiMatch = multiMatch;
			this.captureGroupIndex = captureGroupIndex;
			// make sure the regExp matches the start of the string, but without introducing an
			// extra capturing group
			matchFromStartPattern = new RegExp("^(?:" + pattern +")", modifiers);
		}


		/**
		 * 
		 */
		public function matchFromStart(test:String):String
		{
			lastMatch = test.match(matchFromStartPattern);
			if(lastMatch){
				return lastMatch[captureGroupIndex] as String;
			}else{
				return "";
			}
		}
		
	}
}

