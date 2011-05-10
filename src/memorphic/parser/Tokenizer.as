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
	import flash.errors.EOFError;

	/**
	 * 
	 * Outstanding issues:
	 * 
	 * 	1. Lookahead is not possible in determining if a token should be discarded. Currently this 
	 * 		causes tokenPosition to become out of sync, because the lookAhead token is given the 
	 * 		index tokenPosition+1, but the removal of the previous token means that this index
	 * 		is 1 too high. My initial solution was to produce flagged "skip" tokens, which would 
	 * 		be ignored by nextToken(), which would cause it to invoke itself again, but that caused
	 * 		some parse errors, that I could not identify the cause of.
	 * 
	 * 	2. There is no enforcment that the input stream is completely tokenized and that those 
	 * 		tokens are all consumed. The solution is probably to return an EOFToken when the 
	 * 		inputStream is exhausted and the AST grammar can check for the existance of that token 
	 * 		after the last pattern is matched. Currently SyntaxTree.verifyTree() is checking for
	 * 		bytesRemaining()>0, which is probably not reliable. SyntaxTree could also test for 
	 * 		an EOFError being thrown.
	 * 
	 */
	public class Tokenizer
	{

		/**
		 * The token that was most recently created
		 */ 
		protected var token:Token;
		
		private var tokenPatterns:Array; // of TokenPattern

		private var inputStream:String;
		private var inputStreamPosition:int;
		private var unparsedStream:String;
		private var tokenPosition:int;
		
		private var stateCache:Array; // of TokenizerState
		

		public function Tokenizer()
		{
			tokenPatterns = new Array();
		}



		
		/**
		 * Adds the definition of a new TokenPattern, used for parsing the input string into tokens
		 */
		public function addTokenPattern(pattern:TokenPattern):void
		{
			tokenPatterns.push(pattern);
		}



		/**
		 * 
		 * 
		 */
		public function get rawData():String
		{
			return inputStream;
		}		
		
		public function set rawData(input:String):void
		{
			inputStream = input;
			unparsedStream = input;
			reset();
		}




		/**
		 * Factory method for Tokens. Override and extend in subclasses. Return null to indicate
		 * that the token is discarded, so the tokenizer will try to parse another one.
		 */
		protected function createToken(pattern:TokenPattern, value:String, sourceIndex:int, prev:Token=null):Token
		{
			return new Token(pattern.name, value, sourceIndex);
		}
	

		protected function skipToken(token:Token):Token
		{
			token.discard = true;
			return token;
		}
		
		protected function tokenWasSkipped(token:Token):Boolean
		{
			return token==null || token.discard;
		}


		/**
		 * @return the next token in the stream, or throw an EOFError if there are no more valid tokens
		 */
		public final function nextToken():Token
		{
			
			tokenPosition++;
			var cachedState:TokenizerState
			if((cachedState = stateCache[tokenPosition] as TokenizerState))
			{
				restoreState(cachedState);
			}else{
				token = parseNextToken();
				// NOTE: we are setting the array index instead of using push() because it is possible for there to
				// be gaps. That happens in the situation where we need to do a lookAhead in order to create a token
				
				
				
				// TODO: fix this. For some reason, things break when we cache the state
				// commenting out the following line disables all token caching
				// stateCache[tokenPosition] = getState();
				
				
			}
		//	if(token.discard){
		//		token = nextToken();
		//	}
			return token;
		}
		





		protected function parseNextToken():Token
		{
			var token:Token;
			var biggestMatch:String = "";
			var biggestMatchLength:int = 0;
			var curResult:String;
			var matchingProduction:TokenPattern;
			var matchResult:Array;
			var matchPosition:int;

	
			// XXX: should this be an ordered loop?
			// TODO: decide if we can flag patterns to tell this loop to bail after a match
			for each(var tokenProduction:TokenPattern in tokenPatterns){
				
				curResult = tokenProduction.matchFromStart(unparsedStream);
				if(curResult && curResult.length > biggestMatchLength){
					biggestMatch = curResult;
					biggestMatchLength = biggestMatch.length;
					matchingProduction = tokenProduction;
				}
			}
			
			if(matchingProduction){
				
				matchPosition = inputStreamPosition;
				inputStreamPosition += biggestMatch.length;
				unparsedStream = inputStream.substr(inputStreamPosition);
				var tok:Token = createToken(matchingProduction, biggestMatch, matchPosition, this.token);
				
				if(tokenWasSkipped(tok)){
					return parseNextToken();
				}else{
					return tok;
				}

			}else{
				throw new EOFError();			
			}


		}




		/**
		 * Start getting tokens from the beginning
		 */
		public function reset():void
		{
			token = null;
			inputStreamPosition = 0;
			tokenPosition = -1;
			stateCache = [];
		}


		/**
		 * Skip the specified number of tokens.
		 */
		public function skipAhead(numTokens:int=1):void
		{
			if (numTokens < 1){
				throw new RangeError();
			}
			
			var n:int = numTokens;
			while(n--){
				nextToken();
			}
		}

		
		/**
		 * Get a subsequent token, without affecting the tokenizer state
		 * @param offset int The number of tokens to look ahead
		 * @return the token that is ahead from the current token by the specified amount
		 */
		public function lookAhead(offset:int=1):Token
		{
			if (offset < 1){
				throw new RangeError();
			}
			
			var tokenIndex:int = tokenPosition + offset - 1;

	
			var state:TokenizerState = getState();
			
			var lookAheadToken:Token;
			try{
				for(var i:int=0; i<offset; i++){
					lookAheadToken = nextToken();
				}
			}catch(e:EOFError){
				lookAheadToken = new EOFToken(inputStream.length);
			}

			restoreState(state);
			return lookAheadToken;
			
		}



		/**
		 * This is not an optimized way of getting this information; it's really just for debugging
		 * and error messages
		 */
		public function getTokenMetrics(token:Token):TokenMetrics
		{
			var inputToToken:String = inputStream.substr(0,token.sourceIndex);
			var linesToToken:Array = inputToToken.split("\n");
			var lineCount:int = linesToToken.length;
			var lastLineIndex:int = inputToToken.lastIndexOf("\n");
			var column:int = 0;
			if(lastLineIndex > -1){
				column = String(linesToToken[lineCount-1]).length - inputToToken.length + lastLineIndex;
			}
			return new TokenMetrics(token.sourceIndex, linesToToken.length, column, token.value.length);
		}


		/**
		 * Captures the state of  the tokenizer so that it may be restored later.
		 */
		public function getState():TokenizerState
		{

				return new TokenizerState(
					TokenizerState.constructorKey,
					token,
					inputStreamPosition,
					tokenPosition
				);

		}




		/**
		 * restores the tokenizer state to a memento(TM) created from getState()
		 */
		public function restoreState(state:TokenizerState):void
		{
			inputStreamPosition = state.inputStreamPosition;
			tokenPosition = state.tokenPosition;
			unparsedStream = inputStream.substr(inputStreamPosition);
			token = state.token;
		}
		
		protected static function buildRegExpORList2(...rest):String
		{
			var str:String = Array.prototype.join.apply(rest, " ");
			return (buildRegExpORList(str));
		}
		
		protected static function buildRegExpORList(str:String):String
		{
			str = regExpEscape(str);
			var parts:Array = str.split(/\s/);
			return parts.join("|");
		}
		
		private static function regExpEscape(str:String):String
		{
			return str.replace(/([\-\+\=\|\(\)\*\[\]\.\@\,\:\$\"\'\\\/\!])/g, "\\$&");
		}
	}


}
