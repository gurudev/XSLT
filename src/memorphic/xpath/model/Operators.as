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

package memorphic.xpath.model
{
	public class Operators
	{
		
		public static const OR:String = "or";
		public static const AND:String = "and";
		public static const EQUALS:String = "=";
		public static const NOT_EQUALS:String = "!=";
		public static const MULTIPLY:String = "*";
		public static const DIVIDE:String = "div";
		public static const MODULO:String = "mod";
		public static const ADD:String = "+";
		public static const SUBTRACT:String = "-";
		public static const LESS_THAN:String = "<"; 
		public static const GREATER_THAN:String = ">"; 
		public static const LESS_THAN_OR_EQUAL:String = "<=";
		public static const GREATER_THAN_OR_EQUAL:String = ">=";  
		public static const UNION:String = "|"; 
		
		public static function isOperator(value:String):Boolean{
			switch(value){
			case OR: case AND: case EQUALS: case NOT_EQUALS:
			case MULTIPLY: case DIVIDE: case MODULO: case ADD:
			case SUBTRACT: case LESS_THAN: case GREATER_THAN:
			case LESS_THAN_OR_EQUAL: case GREATER_THAN_OR_EQUAL:
			case UNION:
				return true;
			default:
				return false;
			}
		}
	}
}