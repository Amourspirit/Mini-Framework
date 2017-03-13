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
class MfMath extends MfObject
{
	static m_PI = 3.1415926535897931
	static m_E := 2.7182818284590451
	;{ PI
		/*!
			Property: PI [get]
				Represents the ratio of the circumference of a circle to its diameter, specified by the constant, π.
			Value:
				Var representing the PI property of the instance
			Remarks:
				Readonly Property
		*/
		PI[]
		{
			get {
				return MfMath.m_PI
			}
			set {
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
				ex.SetProp(A_LineFile, A_LineNumber, "PI")
				Throw ex
			}
		}
	; End:PI ;}
	;{ E
		/*!
			Property: E [get]
				Represents the natural logarithmic base, specified by the constant, e.
			Value:
				Var representing the E property of the instance
			Remarks:
				Readonly Property
		*/
		E[]
		{
			get {
				return MfMath.m_E
			}
			set {
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
				ex.SetProp(A_LineFile, A_LineNumber, "E")
				Throw ex
			}
		}
	; End:E ;}
;{ Methods
;{ 	Abs
	Abs(obj, ReturnAsObject = false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		
		_ReturnAsObject := MfBool.GetValue(ReturnAsObject, false)
		if (IsObject(obj) = false)
		{
			; assume int 64 if is integer obj
			if(Mfunc.IsInteger(obj))
			{
				long := new MfInt64(obj)
				return MfMath.Abs(long, _ReturnAsObject)
			}
			if (Mfunc.IsFloat(obj)) {
				flt := new MfFloat(obj)
				return MfMath.Abs(flt, _ReturnAsObject)
			}
		}
		
		if (MfObject.IsObjInstance(obj, MfInt16))
		{
			if (obj.Value > 0)
			{
				return _ReturnAsObject = true?obj:obj.Value
			}
			i := MfMath._AbsHelperInt16(obj.Value)
			return _ReturnAsObject = true?new MfInt16(i, obj.ReturnAsObject):i
		}
		else if (MfObject.IsObjInstance(obj, MfInteger))
		{
			if (obj.Value > 0)
			{
				return _ReturnAsObject = true?obj:obj.Value
			}
			i := MfMath._AbsHelperInt32(obj.Value)
			return _ReturnAsObject = true?new MfInteger(i, obj.ReturnAsObject):i
		}
		else if (MfObject.IsObjInstance(obj, MfInt64))
		{
			if (obj.Value > 0)
			{
				return _ReturnAsObject = true?obj:obj.Value
			}
			i := MfMath._AbsHelperInt64(obj.Value)
			return _ReturnAsObject = true?new MfInt64(i, obj.ReturnAsObject):i
		}
		else if (MfObject.IsObjInstance(obj, MfFloat))
		{
			wf := Mfunc.SetFormat(MfSetFormatNumberType.Instance.FloatFast, obj.Format)
			try
			{
				if (obj.GreaterThenOrEqual(0.0))
				{
					if (_ReturnAsObject)
					{
						retval := new MfFloat(obj.Value,obj.ReturnAsObject,,obj.Format)
						return retval
					}
					return obj.Value
				}
				f := Abs(obj.Value)
				if (_ReturnAsObject)
				{
					retval := new MfFloat(f,obj.ReturnAsObject,,obj.Format)
					return retval
				}
				return f
			}
			catch e
			{
				throw e
			}
			finally
			{
				 Mfunc.SetFormat(MfSetFormatNumberType.Instance.FloatFast, wf)
			}
		}
		ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", A_ThisFunc))
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
; 	End:Abs ;}
;{ 	Round
	; rounds a float value
	; Parrams
	;	Float
	;	Float, digits
	;	Float, digits, Mode
	;	Float, mode
	; mode is MfMidpointRounding
	; if Float is passed in as a var then a var is returned as the rounded result
	; if Float is passed in as a Mffloat then a MfFloat is returned as the rounded result
	Round(args*) {
		pArgs := MfMath._RoundParams(A_ThisFunc, args*)
		pList := pArgs.ToStringList()
		s := Null
		pIndex := 0
		flt := Null
		iDec := 0
		Mpr := MfMidpointRounding.Instance.AwayFromZero
		if (pList.Count > 0)
		{
			s := pList.Item[pIndex].Value
			if (s = "MfFloat") 
			{
				flt := pArgs.Item[pIndex]
			}
			else
			{
				tErr := this._ErrorCheckParameter(pIndex, pArgs)
				if (tErr)
				{
					tErr.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					Throw tErr
				}
			}
		}

		if (pList.Count > 1)
		{
			pIndex++
			obj := pArgs.Item[pIndex]
			T := new MfType(obj)
			if (T.IsEnum || T.IsEnumItem)
			{
				; if Enum is in secondd position then there cannot be a third parameter
				if (pList.Count > 2)
				{
					e := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", A_ThisFunc))
					e.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw e
				}
				Mpr := obj
			}
			else if (T.IsIntegerNumber)
			{
				if (obj.Value < 0 || obj.Value > 15)
				{
					ex := new MfArgumentOutOfRangeException("digits", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_RoundingDigits"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				iDec := obj.Value
			}
			else
			{
				tErr := this._ErrorCheckParameter(pIndex, pArgs)
				if (tErr)
				{
					tErr.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					Throw tErr
				}
			}
		}
		if (pList.Count > 2)
		{
			pIndex++
			obj := pArgs.Item[pIndex]
			T := new MfType(obj)
			if (T.IsEnum || T.IsEnumItem)
			{
				Mpr := obj
			}
			else
			{
				tErr := this._ErrorCheckParameter(pIndex, pArgs)
				if (tErr)
				{
					tErr.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					Throw tErr
				}
			}
		}
		if (iDec < 0 || iDec > 15)
		{
			ex := new MfArgumentOutOfRangeException("digits", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_RoundingDigits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		AsVar := false
		if (pArgs.Data.Contains("AsVar") && (pArgs.Data.Item["AsVar"] = true))
		{
			AsVar := true
		}

		wf := Mfunc.SetFormat(MfSetFormatNumberType.Instance.FloatFast, flt.Format)
		try
		{
			tFloat := new MfFloat(flt,flt.ReturnAsObject,,flt.Format)

			if (Mpr.Equals(MfMidpointRounding.Instance.ToEven))
			{
				tFloat.Multiply(MfMath.roundPower10Double[iDec])
				if (tFloat.GreaterThenOrEqual(0.0))
				{
					i := Floor(tFloat.Value)
					tFloat.Subtract(i)
					if ((tFloat.GreaterThen(0.5)) || ((tFloat.Equals(0.5)) && (i & 1) != 0))
					{
						i++
					}
					tFloat.Value := 0.0
					tFloat.DecimalPlaces := iDec
					tFloat.Add(i)
					tFloat.Divide(MfMath.roundPower10Double[iDec])
					return AsVar = true?tFloat.Value:tFloat
				}
				else
				{
					i := Ceil(tFloat.Value)
					tFloat.Subtract(i)
					if ((tFloat.LessThen(-0.5)) || ((tFloat.Equals(-0.5)) && (i & 1) != 0))
					{
						i--
					}
					tFloat.Value := 0.0
					tFloat.DecimalPlaces := iDec
					tFloat.Add(i)
					tFloat.Divide(MfMath.roundPower10Double[iDec])
					return AsVar = true?tFloat.Value:tFloat
				}
			}
			else
			{
				; away from zero
				tFloat.Multiply(MfMath.roundPower10Double[iDec])
				if (tFloat.GreaterThenOrEqual(0.0))
				{
					i := Floor(tFloat.Value)
					tFloat.Subtract(i)

					if (tFloat.GreaterThenOrEqual(0.5))
					{
						i++
					}
					tFloat.Value := 0.0
					tFloat.DecimalPlaces := iDec
					tFloat.Add(i)
					tFloat.Divide(MfMath.roundPower10Double[iDec])
					return AsVar = true?tFloat.Value:tFloat
				}
				else
				{
					i := Ceil(tFloat.Value)
					tFloat.Subtract(i)
					if (tFloat.LessThenOrEqual(-0.5))
					{
						i--
					}
					tFloat.Value := 0.0
					tFloat.DecimalPlaces := iDec
					tFloat.Add(i)
					tFloat.Divide(MfMath.roundPower10Double[iDec])
					return AsVar = true?tFloat.Value:tFloat
				}
			}
		}
		catch e
		{
			throw e
		}
		Finally
		{
			Mfunc.SetFormat(MfSetFormatNumberType.Instance.FloatFast, wf)
		}
	}
; 	End:Round ;}
; End:Methods ;}
;{ Internal Methods
;{ 	_RoundParams
	; read parameters for MfMath.Round()
	_RoundParams(MethodName, args*) {

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
			p.AllowEmptyValue := false ; all empty/null params will be added as undefined

			;p.AddInteger(0)
			;return p
			
			; can be up to five parameters
			; Two parameters is not a possibility
			if ((cnt = 0) || (cnt > 3))
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
						p.Add(arg)
						if (i = 1) ; float
						{
							p.Data.Add("AsVar", false)
						}
					} 
					else
					{
						if (i = 1) ; float
						{

							; cannot construct an instacne of MfUInt64 here with parameters
							; we are already calling from the constructor
							; create a new instance without parameters and set the properties
							try
							{
								_val := new MfFloat()
								_val.ReturnAsObject := false
								_val.Value := MfFloat.GetValue(arg)
								pIndex := p.Add(_val)
							}
							catch e
							{
								ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToFloat"), e)
								ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
								throw ex
							}
							; add key, value to args data to flag that this float was added from a var
							p.Data.Add("AsVar", true)
							
						}
						else if (i = 2) ; can be int Decimal Places or MfMidPointRounding, assume Decimal places
						{
							try
							{
								_val := new MfInteger()
								_val.ReturnAsObject := false
								_val.Value := MfInteger.GetValue(arg)
								pIndex := p.Add(_val)
							}
							catch e
							{
								ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToInteger"), e)
								ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
								throw ex
							}
						}
						else ; can only be MfMidPointRounding
						{
							enum := MfEnum.ParseItem(MfMidpointRounding.GetType(), arg)
							pIndex := p.Add(enum)
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
; 	End:_RoundParams ;}
;{ 	_AbsHelperByte
	_AbsHelperByte(value) {
		if (value = -128)
		{
			ex := new  MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_NegateTwosCompNum"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		return -value
	}
; 	End:_AbsHelperByte ;}
;{ 	_AbsHelperInt16
	_AbsHelperInt16(value) {
		if (value = MfInt16.MinValue)
		{
			ex := new  MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_NegateTwosCompNum"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		return -value
	}
; 	End:_AbsHelperInt16 ;}
;{ 	_AbsHelperInt32
	_AbsHelperInt32(value) {
		if (value = MfInteger.MinValue)
		{
			ex := new  MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_NegateTwosCompNum"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		return -value
	}
; 	End:_AbsHelperInt32 ;}
;{ 	_AbsHelperInt64
	_AbsHelperInt64(value) {
		if (value = MfInt64.MinValue)
		{
			ex := new  MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_NegateTwosCompNum"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		return -value
	}
; 	End:_AbsHelperInt64 ;}
;{ 	_IsNotMfObj
	_IsNotMfObj(obj) {
		if (MfObject.IsObjInstance(obj))
		{
			return false
		}
		
		ex := new MfException(MfEnvironment.Instance.GetResourceString("NonMfObjectException_General"))
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		return ex
	}
; 	End:_IsNotMfObj ;}
; End:Internal Methods ;}
	;{ roundPower10Double
		static m_roundPower10Double := ""
	/*!
		Property: roundPower10Double [get]
			Gets the roundPower10Double value associated with the this instance
		Value:
			Var representing the roundPower10Double property of the instance
		Remarks:
			Internal Readonly Property
	*/
		roundPower10Double[index]
		{
			get {
				if (MfMath.m_roundPower10Double = "")
				{
					MfMath.m_roundPower10Double := Array(1.0
						,10.0
						,100.0
						,1000.0
						,10000.0
						,100000.0
						,1000000.0
						,10000000.0
						,100000000.0
						,1000000000.0
						,10000000000.0
						,100000000000.0
						,1000000000000.0
						,10000000000000.0
						,100000000000000.0
						,1.0e15)
				}
				_Index := index + 1 ; make it zero based
				return MfMath.m_roundPower10Double[_Index]
			}
			set {
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
				ex.SetProp(A_LineFile, A_LineNumber, "roundPower10Double")
				Throw ex
			}
		}
	; End:roundPower10Double ;}

}