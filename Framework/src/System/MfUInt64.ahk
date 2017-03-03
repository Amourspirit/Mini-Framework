;{ License
/* This file is part of Mini-Framework For AutoHotkey.
 * 
 * Mini-Framework is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 2 of the License.
 * 
 * Mini-Framework is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with Mini-Framework.  If not, see <http://www.gnu.org/licenses/>.
 */
; End:License ;}

Class MfUInt64 extends MfPrimitive
{
;{ Static Properties
	TypeCode[]
	{
		get {
			return 122
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}

; End:Static Methods ;}
;{ Constructor
	__New(uInt) {
		if (this.__Class != "MfUInt64")
		{
			throw new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Sealed_Class","MfUInt64"))
		}
		base.__New(uInt, false, false)
	}
; End:Constructor ;}
;{ _ConstructorParams
	_ConstructorParams(MethodName, args*) {

		p := Null
		cnt := MfParams.GetArgCount(args*)

	
		if ((cnt > 0) && MfObject.IsObjInstance(args[1], MfParams))
		{
			p := args[1] ; arg 1 is a MfParams object so we will use it
			; can be up to five parameters
			; Two parameters is not a possibility
			if (p.Count > 3)
			{
				e := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", MethodName))
				e.SetProp(A_LineFile, A_LineNumber, MethodName)
				throw e
			}
		}
		else
		{

			p := new MfParams()
			p.AllowEmptyString := false ; no strings for parameters in this case
			p.AllowOnlyAhkObj := false ; needed to allow for undefined to be added
			p.AllowEmptyValue := true ; all empty/null params will be added as undefined

			;p.AddInteger(0)
			;return p
			
			; can be up to five parameters
			; Two parameters is not a possibility
			if (cnt > 3)
			{
				e := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", MethodName))
				e.SetProp(A_LineFile, A_LineNumber, MethodName)
				throw e
			}
			
			i := 1
			while i <= cnt
			{
				arg := args[i]
				try
				{
					if (IsObject(arg))
					{
						if (i > 1) ; all booleans from here
						{
							T := new MfType(arg)
							if (T.IsNumber)
							{
								; convert all mf number object to boolean
								b := new MfBool()
								b.Value := arg.Value > 0
								p.Add(b)
							}
							else
							{
								p.Add(arg)
							}
						}
						else
						{
							p.Add(arg)
						}
					} 
					else
					{
						if (MfNull.IsNull(arg))
						{
							pIndex := p.Add(arg)
						}
						else if (i = 1) ; uint64
						{

							; cannot construct an instacne of MfInt64 here with parameters
							; we are already calling from the constructor
							; create a new instance without parameters and set the properties
							try
							{

							}
							catch e
							{
								ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToInt64"), e)
								ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
								throw ex
							}
							if Mfunc.IsInteger(arg)
							{
								_val := new MfInt64()
								_val.ReturnAsObject := false
								_val.Value := arg
								pIndex := p.Add(_val)
							}
							Else
							{
								ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToInt64"), e)
								ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
								throw ex
							}
							
						}
						else ; all params past 1 are boolean
						{
							pIndex := p.AddBool(arg)
						}
					}
				}
				catch e
				{
					ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Error_on_nth", i), e)
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				i++
			}
			
		}
		;return new MfParams()
		return p
	}
; End:_ConstructorParams ;}
;{ Methods
;{ GetValue
	GetValue(args*)  {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		i := MfParams.GetArgCount(args*)
		if ((i = 0) || (i > 3))
		{
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", A_ThisFunc))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		CanThrow := False
		bAllow := False
		_default := 0
		obj := args[1]
		if (i = 1)
		{
			CanThrow := True
		}
		else if (i = 2)
		{
			try
			{
				_default := MfUInt64._GetValue(args[2])
			}
			catch e
			{
				CanThrow := true
			}
		}
		else
		{
			; 3 params obj, default, AllowAny
			; if AllowAny is true then default can be anything, otherwise default must be a valid integer
			try
			{
				bAllow := MfBool._GetValue(args[3])
			}
			catch e
			{
				err := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToBoolean"), e)
				err.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_InvalidCastException"), "AllowAny", err)
				ex.SetProp(err.File, err.Line, A_ThisFunc)
				throw ex
			}
			
			if (bAllow = true)
			{
				_default := args[2]
			}
			else
			{
				try
				{
					_default := MfUInt64._GetValue(args[2])
				}
				catch e
				{
					CanThrow := true
				}
			}
		}
		retval := CanThrow = true? 0:_default
		if (CanThrow = true)
		{
			try
			{
				retval := MfUInt64._GetValue(obj)
			}
			catch e
			{
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToInt64"), e)
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		}
		else
		{
			try
			{
				retval := MfUInt64._GetValue(obj)
			}
			catch e
			{
				retval := _default
			}
		}
		return retval
	}
; End:GetValue ;}
;{ 	_GetValue
	; internal method
	_GetValue(obj) {
		WasFormat := A_FormatInteger
		try
		{
			retval := "0"

			if (IsObject(obj)) {
				if (MfObject.IsObjInstance(obj, MfUInt64))
				{
					return obj.Value
				}
				T := new MfType(obj)
				else if (T.IsIntegerNumber)
				{
					retval := obj.Value + ""
					if ((retval < MfUInt64.MinValue) || (retval > MfUInt64.MaxValue))
					{
						ex := new MfArgumentOutOfRangeException("obj"
							, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper"
							,MfUInt64.MinValue, MfUInt64.MaxValue))
						ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
						throw ex
					}
				}
				else if (t.IsFloat)
				{
					if ((obj.LessThen(MfUInt64.MinValue)) || (obj.GreaterThen(MfUInt64.MaxValue))) {
						ex := new MfArgumentOutOfRangeException("obj"
							, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper"
							,MfUInt64.MinValue, MfUInt64.MaxValue))
						ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
						throw ex
					}
					if (obj.LessThen(0.0))
					{
						retval := Ceil(obj.Value) + ""
					} else {
						retval := Floor(obj.Value) + ""
					}
				}
				else
				{
					ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("NullReferenceException_Object_Param", "int"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
			} else {
				retval := MfUInt64._GetValueFromVar(obj)
			}
		}
		Catch e
		{
			throw e
		}
		return retval
	}
; 	End:_GetValue ;}
;{ 	_GetValueFromVar
	; internal method
	_GetValueFromVar(varInt) {
		
		retval := "" ; necessary for integer fast
		try
		{
			if (varInt ~= "^[0-9]{1,20}$")
			{
				iComp := this._CompareLongIntStrings(varInt, MfUInt64.MaxValue)
				if (iComp > 0)
				{
					ex := new MfArgumentOutOfRangeException("varInt"
						, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper"
						,MfUInt64.MinValue, MfUInt64.MaxValue))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				retval := varInt
			}
			else if (varInt ~= "^\+[0-9]{1,20}$")
			{
				; remove the leading +
				varInt := SubStr(varInt, 2, StrLen(varInt) - 1)
				
				iComp := this._CompareLongIntStrings(varInt, MfUInt64.MaxValue)
				if (iComp > 0)
				{
					ex := new MfArgumentOutOfRangeException("varInt"
						, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper"
						,MfUInt64.MinValue, MfUInt64.MaxValue))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				retval := varInt
			}
			else {
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_IntegerVar", "varInt"), "varInt")
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		}
		catch e
		{
			if ((MfObject.IsObjInstance(e, MfException)) && (e.Source = A_ThisFunc))
			{
				throw e
			}
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
		return retval
	}
; 	End:_GetValueFromVar ;}
; End:Methods ;}
;{ Properties
;{ 	MaxValue
/*
	Property: MaxValue [get]
		Represents the largest possible value of an MfUInt64. This field is constant.
	Value:
		Var integer
	Gets:
		Gets the largest possible value of an MfUInt64.
	Remarks:
		Constant Property
		Can be accessed using MfUInt64.MaxValue
		Value = "18446744073709551615" (0x1999999999999999) hex
*/
	MaxValue[]
	{
		get {
			return "18446744073709551615"   ;  0x1999999999999999
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:MaxValue ;}
;{ 	MinValue
/*
	Property: MinValue [get]
		Represents the smallest possible value of an MfUInt64. This field is constant.
	Value:
		Var integer
	Gets:
		Gets the smallest possible value of an MfUInt64.
	Remarks:
		Can be accessed using MfUInt64.MinValue
		Value = -9223372036854775808 (-0x8000000000000000) hex
*/
	MinValue[]
	{
		get {
			return "0" ; 
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:MinValue ;}
; End:Properties ;}
;{ BigInteger-Calculation with AHK
;	https://autohotkey.com/board/topic/3474-biginteger-calculation-with-ahk/

	;**************************************************************************
	;****** Internal Help-functions
	;**************************************************************************
	;//returns the maximum of x and y
	_Max(x,y) { 
	   IfLess x,%y%, Return y 
	   Return x 
	} 

	;//simplyfies the use of Transform
	_Mod(In_Dividend, In_Divisor) {
	   Transform, Ret_Val, Mod, %In_Dividend%, %In_Divisor%
	   return Ret_Val  
	}

	;//simplyfies the use of Transform
	_Div(In_Dividend,In_Divisor) {
	   Transform, Ret_Val, Floor, In_Dividend/In_Divisor
	   return, Ret_Val
	}

	;//Also usefull for any AHK-script. Swap the values of two variables
	_Swap_Values(Byref val1, ByRef Val2) {
	   local dummy
	   dummy := val1
	   val1 := val2
	   val2 := dummy
	}

	;//Is removing leading zeros from an LongInt String. If the String holds
	;//an leading Minus it is kept -0000123 => -123 and 00985 => 985
	_RemoveLeadingZeros(ByRef LongIntString) {
	  local LCh, ZCh, WS
	  WS = %LongIntString%
	  StringLeft, LCh, WS, 1 
	  if (LCh = "-")
	    StringTrimLeft, WS, WS, 1
	  loop
	  {
	    StringLeft, ZCh, WS, 1 
	    if (ZCh = "0")
	      StringTrimLeft, WS, WS, 1
	    else
	      break  
	  }
	  If (WS = "")   ;//If it is empty now make it 0
	    WS = 0
	  if (LCh = "-") ;//Add minus again if there was one
	    WS = -%WS%
	  LongIntString = %WS% ;//returns result BYREF !!!!
	}

	;//This function is comparing IntegerStrings (also WITH leading Minus)
	;//Leading Zeros are removed by default to make comparison possible
	;//If First  is smaller than Second -1 is returned
	;//If First and Second are equal 0 is returned
	;//If First is  bigger than Second  1 is returned
	;//If one of the Strings is empty it is assumed to be 0
	_CompareLongIntStrings(ByRef FirstLongString, Byref SecondLongString) {
	  local FSize, FCh, SSize, SCh, Output, Ret_Val
	  this._RemoveLeadingZeros(FirstLongString)
	  this._RemoveLeadingZeros(SecondLongString)
	  StringLen, FSize, FirstLongString
	  StringLen, SSize, SecondLongString
	  StringLeft, FCh, FirstLongString, 1 
	  StringLeft, SCh, SecondLongString, 1 
	  if (FCh = "-") and (SCh <> "-")
	     Ret_Val = -1
	  else   
	  if (SCh = "-") and (FCh <> "-")
	     Ret_Val = 1
	  else   
	  {
	    if (FSize > SSize)
	    {
	      if (FCh = "-") and (SCh = "-") 
	         Ret_Val = -1
	      else
	         Ret_Val = 1
	    }
	    else
	    if (SSize > FSize)
	    {
	      if (FCh= "-" ) and (SCh = "-") 
	         Ret_Val = 1
	      else
	         Ret_Val = -1
	    }
	    else
	    if (SSize = FSize)
	    {
	      Ret_Val = 0 ;//assume we find no difference
	      loop, %SSize%
	      {
	        StringMid, Dig1, FirstLongString, %A_index%, 1 
	        StringMid, Dig2, SecondLongString, %A_index%, 1 
	        if (Dig1<>Dig2)  ;//Found a different digit
	        {
	          if (Dig1>Dig2)
	          {
	            If (FCh = "-") and (SCh = "-")
	               Ret_Val = -1
	            else
	               Ret_Val = 1
	            break   
	          }     
	          else
	          if (Dig2 > Dig1)
	          {
	            If (FCh = "-") and (SCh = "-")
	               Ret_Val = 1
	            else
	               Ret_Val = -1
	            break   
	          }     
	        }
	      } 
	    }
	  }
	  
	  return, Ret_Val 
	}

	;//Returns 1 if LongIntString has a leading Minus else returns 0
	_IsNeg(LongIntString) {
	  local MCh
	  StringLeft, MCh,LongIntString, 1 
	  if (MCh = "-")
	    return, 1
	  else  
	    return, 0  
	}

	;//Returns a LongIntString with removed Minus, what 
	;//simply means it returns an ABS'd LongIntString
	_ABSLongintString(LongIntString) {
	  local MCh
	  StringLeft, MCh, LongIntString, 1 
	  if (MCh = "-")
	  {
	    StringTrimLeft,LongIntString, LongIntString, 1
	    return %LongIntString%
	  } 
	  else
	    return %LongIntString%
	}

	;//Is adding leading zeros to the strings so they have same length
	;//leading Minus is kept. We add 3 reserve-zeros
	_MakeFitLength(ByRef FirstLongString,Byref SecondLongString) {
	   local LS1Size, LS2Size, FCh, SCh, Maxi, L1Diff, L2Diff
	   this._RemoveLeadingZeros(FirstLongString)
	   this._RemoveLeadingZeros(SecondLongString)
	   StringLeft, FCh, FirstLongString, 1 
	   StringLeft, SCh, SecondLongString, 1 
	   ;//remove minus first if there are one
	   if (FCh="-")
	    StringTrimLeft,FirstLongString,FirstLongString,1
	   if (SCh="-")
	    StringTrimLeft,SecondLongString,SecondLongString,1
	   StringLen, LS1Size, FirstLongString
	   StringLen, LS2Size, SecondLongString
	   Maxi := this._Max(LS1Size,LS2Size)
	   L1Diff := Maxi-LS1Size+3
	   L2Diff := Maxi-LS2Size+3
	   loop, %L1Diff%
	      FirstLongString=0%FirstLongString%
	   loop, %L2Diff%
	      SecondLongString=0%SecondLongString%
	   ;//Put back Minus if there was one
	   if (FCh="-")
	    FirstLongString=-%FirstLongString%
	   if (SCh="-")
	    SecondLongString=-%SecondLongString%
	}

	;//This function is subtracting Second from first and ALWAYS awaits
	;//positiveONLY Strings (leading zeros already removed), AND that First is 
	;//bigger than second so the result always will be positive e.g. 1000-456=544. 
	;//This function is only for internal use and called by the real ADD-SUB-Functions
	_ABSLongIntStringSub(FirstLongString,SecondLongString) {
	   local MaxLength, ResultString, Erg, value1, value2, Sum, Rem
	   Rem = 0
	   ResultString =
	   StringLen, MaxLength, FirstLongString
	   loop, %MaxLength%
	   {
	      StringMid,value1,FirstLongString,MaxLength+1-A_index,1 
	      StringMid,value2,SecondLongString,MaxLength+1-A_index,1 
	      Sum := value1-(value2+rem)
	      Rem := this._Div((9-sum),10)
	      Erg := this._Mod((sum+10),10)
	      ResultString=%Erg%%ResultString%
	   }
	  return, %Resultstring%
	}

	;//This is the REAL Function that is able to subtract one LongIntString
	;//from another. Is subtracting Second from First (LongStrings) and returns the 
	;//Result as STRING. Now is supporting positive AND negative Long-Integers
	_LongIntStringSub(FirstLongString, SecondLongString) {
	   local WS1, WS2, WSResult, FIsNeg, SIsNeg, ABSCompi
	   ;//remember the minus
	   FIsNeg := this._IsNeg(FirstLongString)
	   SIsNeg := this._IsNeg(SecondLongString)
	   ;//remove the minus on workstrings
	   WS1 := this._ABSLongIntString(FirstLongString)
	   WS2 := this._ABSLongIntString(SecondLongString)
	   ;//compare absolute size of BigNums
	   ABSCompi := this._CompareLongintStrings(WS1,WS2,0)
	   ;//Make Strings same length with added zeroes
	   this._MakeFitLength(WS1,WS2)
	   If (FIsNeg="0" and SIsNeg="1") ;//First pos, second neg.  "x - -y" => "(x+y)"
	     WSResult := this._ABSLongIntStringAdd(WS1,WS2)
	   else
	   If (FIsNeg="1" and SIsNeg="0") ;//First neg, sec pos. "-x - y" => "-(x+y)"
	     WSResult := -this._ABSLongIntStringAdd(WS1,WS2)
	   else
	   If (FIsNeg="1" and SIsNeg="1") ;//Both are negative
	   {
	      if (ABSCompi=0)  ;//Both are same ABS-size. E.G. -5 - -5 => Result 0
	        return, 0
	      else
	      if (ABSCompi=1)  ;//E.G. -1000 - -20 = -980 => Result negative
	         WSResult := -this._ABSLongIntStringSub(WS1,WS2)
	      else
	      if (ABSCompi=-1) ;//E.G. -20 - -1000 = +980 => Result positive
	         WSResult := this._ABSLongIntStringSub(WS2,WS1)
	   }   
	   else
	   If (FIsNeg="0" and SIsNeg="0") ;//Both are positive
	   {
	      if (ABSCompi=0)  ;//Both are same ABS-size. E.G. 5 - 5 => Result 0
	        return, 0
	      else
	      if (ABSCompi=1)  ;//E.G. 1000 - 20 = 980 => Result positive
	         WSResult := this._ABSLongIntStringSub(WS1,WS2)
	      else
	      if (ABSCompi=-1) ;//E.G. 20 - 1000 = -980 => Result negative
	         WSResult := -this._ABSLongIntStringSub(WS2,WS1)
	   }
	   this._RemoveLeadingZeros(WSResult)
	   return, %WSResult%
	}

	;//This function is adding First and Second and always awaits Strings
	;//(minuses removed) and prepared with MakeFitLength()
	;//This function is only for internal use and called by the real ADD-SUB-Functions
	_ABSLongIntStringAdd(FirstLongString, SecondLongString) {
	   local MaxLength, ResultString, Erg, value1, value2, sum, Rem
	   Rem = 0
	   ResultString =
	   StringLen, MaxLength, FirstLongString
	   loop, %MaxLength%
	   {
	      StringMid,value1,FirstLongString,MaxLength+1-A_index,1 
	      StringMid,value2,SecondLongString,MaxLength+1-A_index,1 
	      Sum := Value1+Value2+rem
	      Erg := this._Mod(Sum,10)
	      Rem := this._Div(Sum,10)
	      ResultString=%Erg%%ResultString%
	   }
	  return, %Resultstring%
	}

	;//Is adding two LongIntSTRINGS
	_LongIntStringAdd(FirstLongString, SecondLongString) {
	   local WS1, WS2, WSResult, FIsNeg, SIsNeg, ABSCompi
	   ;//remember the minus
	   FIsNeg := this._IsNeg(FirstLongString)
	   SIsNeg := this._IsNeg(SecondLongString)
	   ;//remove the minus on workstrings
	   WS1 := this._ABSLongIntString(FirstLongString)
	   WS2 := this._ABSLongIntString(SecondLongString)
	   ;//compare absolute size of BigNums
	   ABSCompi := this._CompareLongintStrings(WS1,WS2,0)
	   ;//Make Strings same length with added zeroes
	   this._MakeFitLength(WS1,WS2)
	   If (FIsNeg="0" and SIsNeg="0") ;//Both positive =>Result positive
	     WSResult := this._ABSLongIntStringAdd(WS1,WS2)
	   else
	   If (FIsNeg="1" and SIsNeg="1") ;//Both negative =>Result negative
	     WSResult := -this._ABSLongIntStringAdd(WS1,WS2)
	   else
	   If (FIsNeg="1" and SIsNeg="0") ;//First negative, Second positive, further checking
	   {
	      if (ABSCompi=0)  ;//Both are same ABS-size. E.G. -5 + 5 => Result 0
	        return, 0
	      else
	      if (ABSCompi=1)  ;//E.G. -1000 + 20 = -980 => Result negative
	         WSResult := -this._ABSLongIntStringSub(WS1,WS2)
	      else
	      if (ABSCompi=-1) ;//-20 + 1000 = +980 => Result positive
	         WSResult := this._ABSLongIntStringSub(WS2,WS1)
	   }
	   else
	   If (FIsNeg="0" and SIsNeg="1") ;//First positive, Second negative, further checking
	   {
	      if (ABSCompi=0)  ;//Both are same ABS-size. E.G. 5 + -5 => Result 0
	        return, 0
	      else
	      if (ABSCompi=1)  ;//E.G. 1000 + -20 = +980 => Result positive
	         WSResult := this._ABSLongIntStringSub(WS1,WS2)
	      if (ABSCompi=-1) ;//E.G. 20 + -1000 = -980 => Result negative
	         WSResult := -this._ABSLongIntStringSub(WS2,WS1)
	   }
	   this._RemoveLeadingZeros(WSResult)
	   return, %WSResult%
	}


	_StringGetChar(In_String,In_Posi,Param3) {
	  local Length, Ret_Val
	  Ret_Val = 
	  StringLen, Length, In_String
	  if (In_Posi>Length)or(length=0)or(In_Posi<1)
	     return Ret_Val
	  If (Param3=R)
	     StringMid,Ret_Val,In_String,Length+1-In_Posi,1 
	  else        
	     StringMid,Ret_Val,In_String,In_Posi,1 
	  return, %Ret_Val%   
	}

	;//Is multiplying FirstLongString and SecondLongString
	_LongIntStringMult(FirstLongString, SecondLongString) {
	  local ResultString, MulRes, RightVal, LeftVal, Loop1Count, OutLoopCounter
	  local Loop2Count, InLoopCounter, ABSCompi, Help, ZeroAdd, FIsNeg, SIsNeg
	  ;//remember the minus
	  FIsNeg := this._IsNeg(FirstLongString)
	  SIsNeg := this._IsNeg(SecondLongString)
	  ;//remove the minus on workstrings
	  WS1 := this._ABSLongIntString(FirstLongString)
	  WS2 := this._ABSLongIntString(SecondLongString)
	  ;//compare absolute size of BigNums
	  ABSCompi := this._CompareLongintStrings(WS1,WS2,0)
	  if (ABSCompi=1)   ;//We do BiggerNum * SmallerNum
	      this._Swap_Values(WS1,WS2)
	  StringLen, Loop1Count, WS1
	  StringLen, Loop2Count, WS2
	  OutLoopCounter=0
	  loop, %Loop1Count% 
	  {
	     OutLoopCounter+=1
	     Help =
	     Rem = 0
	     InLoopCounter=0
	     loop, %loop2Count%
	     {
	        InLoopCounter += 1
	        RightVal := this._StringGetChar(WS2,InLoopCounter,R)
	        LeftVal := this._StringGetChar(WS1,OutLoopCounter,R)
	        MulRes := (LeftVal*RightVal)+rem
	        rem := this._Div(Mulres,10)
	        Rest := this._Mod(Mulres,10)
	        Help = %Rest%%Help%
	     }     
	     Help = %rem%%Help%  ;/Not sure if thies right ???
	     ZeroAdd := OutLoopCounter-1
	     loop, %ZeroAdd%
	        Help=%Help%0          
	     this._MakeFitLength(ResultString,Help)
	     ResultString := this._ABSLongIntStringAdd(ResultString,Help)
	  }
	  this._RemoveLeadingZeros(ResultString)
	  If ((FIsNeg = "1") and (SIsNeg = "0")) or ((FIsNeg = "0") and (SIsNeg = "1"))
	    return, -%Resultstring%
	  else
	    return, %Resultstring%
	}
; End:BigInteger-Calculation with AHK ;}
}