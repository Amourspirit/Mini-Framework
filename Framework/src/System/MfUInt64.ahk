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
	__New(args*) {
		if (this.__Class != "MfUInt64")
		{
			throw new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Sealed_Class","MfUInt64"))
		}

		_int := "0"
		_returnAsObject := false
		_readonly := false

		pArgs := this._ConstructorParams(A_ThisFunc, args*)

		pList := pArgs.ToStringList()
		s := Null
		pIndex := 0
		if (pList.Count > 0)
		{
			s := pList.Item[pIndex].Value
			if ((s = "MfInteger") 
				|| (s = "MfInt64")
				|| (s = "MfInt16")
				|| (s = "MfByte"))
			{
				_int := pArgs.Item[pIndex].Value
				if (_int < 0)
				{
					ex := new MfArgumentOutOfRangeException("varInt"
						, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper"
						,MfUInt64.MinValue, MfUInt64.MaxValue))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				_int .= ""
			}
			else if (s = "MfUInt64")
			{
				_int := pArgs.Item[pIndex].Value
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
			s := pList.Item[pIndex].Value
			if (s = "MfBool")
			{
				_returnAsObject := pArgs.Item[pIndex].Value
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
			s := pList.Item[pIndex].Value
			if (s = "MfBool")
			{
				_readonly := pArgs.Item[pIndex].Value
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
	
		base.__New(_int, _returnAsObject, _readonly)
		this.m_isInherited := false
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

							; cannot construct an instacne of MfUInt64 here with parameters
							; we are already calling from the constructor
							; create a new instance without parameters and set the properties
							try
							{
								_val := new MfUInt64()
								_val.ReturnAsObject := false
								_val.Value := MfUInt64._GetValueFromVar(arg) ; string value
								pIndex := p.Add(_val)
							}
							catch e
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
	Add(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		this.VerifyReadOnly(this, A_LineFile, A_LineNumber, A_ThisFunc)

		if (MfNull.IsNull(value))
		{
			ex := new MfArgumentNullException("value")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_value := "0"
		if (IsObject(value))
		{
			tryAgain := false
			try
			{
				_value :=  MfInt64.GetValue(value)
				_value .= ""
			}
			catch
			{
				tryAgain := true
			}
			if (tryAgain = true)
			{
				try
				{
					_value :=  MfUInt64.GetValue(value)
				}
				catch e
				{
					ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_InvalidCastException"), "value", e)
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
			}
		}
		else
		{
			try
			{
				_value :=  MfUInt64._GetValueFromVar(value, true) ; get possible negative value
			}
			catch e
			{
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_InvalidCastException"), "value", e)
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		}
		
		_newValue := this._LongIntStringAdd(this.Value, _value)
		iComp := this._CompareLongIntStrings(_newValue, MfUInt64.MaxValue)
		if (iComp > 0)
		{
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Arg_ArithmeticExceptionOver"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		iComp := this._CompareLongIntStrings(_newValue, MfUInt64.MinValue)
		if (iComp < 0)
		{
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Arg_ArithmeticExceptionUnder"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_newValue .= ""
		this.Value := _newValue
		return this._ReturnUInt64(this)
	}
;{ 	CompareTo()			- Overrides	- MfObject
	CompareTo(obj) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfNull.IsNull(value)) {
			return 1
		}
		if (!MfObject.IsObjInstance(obj, MfUInt64)) {
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Object_Equals"),"obj")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_value1 := this.Value . ""
		_value2 := obj.value . ""
		return this._CompareLongIntStrings(_value1, _value2)
		
	}
; End:CompareTo(c) ;}
;{ 	Divide
	Divide(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		this.VerifyReadOnly(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfNull.IsNull(value))
		{
			ex := new MfArgumentNullException("value")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (this.Equals("0"))
		{
			return this._ReturnUInt64(this)
		}
		_value := 0
		try
		{
			_value :=  MfInt64.GetValue(value)
		}
		catch e
		{
			ex := new MfArithmeticException(MfEnvironment.Instance.GetResourceString("Arg_InvalidCastException"), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (_value = 0)
		{
			ex := new MfDivideByZeroException()
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		; divisor must be greater than 0 of UInt otherwise result will be negative
		if (_value < 0)
		{
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Arg_ArithmeticExceptionUnder"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		; with floor divide  any result less then 1 will be zero
		_newValue := this._LongIntStringDivide(this.Value, _value, r)
		iComp := this._CompareLongIntStrings(_newValue, MfUInt64.MaxValue)
		if (iComp > 0)
		{
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Arg_ArithmeticExceptionOver"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		iComp := this._CompareLongIntStrings(_newValue, MfUInt64.MinValue)
		if (iComp < 0)
		{
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Arg_ArithmeticExceptionUnder"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_newValue .= ""
		this.Value := _newValue
		return this._ReturnUInt64(this)

	}
; 	End:Divide ;}
;{ 	Equals()			- Overrides - MfObject
	Equals(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfNull.IsNull(value))
		{
			return false
		}
		retval := false
		_value := "0"
		try
		{
			_value1 := this.Value . ""
			_value2 :=  MfUInt64.GetValue(value)
			
			retval := this._CompareLongIntStrings(_value1, _value2) = 0
		}
		catch 
		{
			retval := false
		}
		return retval
	}
; 	End:Equals ;}
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
;{ 	GreaterThen
	GreaterThen(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		retval := false
		if (MfNull.IsNull(value)) {
			return retval
		}
		if (MfObject.IsObjInstance(value, MfUInt64)) {
			_value1 := this.Value
			_value2 := value.Value
			return this._CompareLongIntStrings(_value1, _value2) > 0
		}
		try
		{
			_value1 := this.Value
			_value2 :=  MfUInt64.GetValue(value)
			retval := this._CompareLongIntStrings(_value1, _value2) > 0
		}
		Catch e
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_InvalidCastException"), "value", e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		return retval
	}
; 	End:GreaterThen ;}
;{ 	GreaterThenOrEqual
	GreaterThenOrEqual(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		retval := false
		if (MfNull.IsNull(value)) {
			return retval
		}
		if (MfObject.IsObjInstance(value, MfUInt64)) {
			_value1 := this.Value
			_value2 := value.Value
			return this._CompareLongIntStrings(_value1, _value2) >= 0
		}
		try
		{
			_value1 := this.Value
			_value2 :=  MfUInt64.GetValue(value)
			retval := this._CompareLongIntStrings(_value1, _value2) >= 0
		}
		Catch e
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_InvalidCastException"), "value", e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		return retval
	}
; 	End:GreaterThenOrEqual ;}
;{ 	LessThen
	LessThen(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		retval := false
		if (MfNull.IsNull(value)) {
			return retval
		}
		if (MfObject.IsObjInstance(value, MfUInt64)) {
			_value1 := this.Value
			_value2 := value.Value
			return this._CompareLongIntStrings(_value1, _value2) < 0
		}
		try
		{
			_value1 := this.Value
			_value2 :=  MfUInt64.GetValue(value)
			retval := this._CompareLongIntStrings(_value1, _value2) < 0
		}
		Catch e
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_InvalidCastException"), "value", e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		return retval
	}
; 	End:LessThen ;}
;{ 	LessThenOrEqual
	LessThenOrEqual(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		retval := false
		if (MfNull.IsNull(value)) {
			return retval
		}
		if (MfObject.IsObjInstance(value, MfUInt64)) {
			_value1 := this.Value
			_value2 := value.Value
			return this._CompareLongIntStrings(_value1, _value2) <= 0
		}
		try
		{
			_value1 := this.Value
			_value2 :=  MfUInt64.GetValue(value)
			retval := this._CompareLongIntStrings(_value1, _value2) <= 0
		}
		Catch e
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_InvalidCastException"), "value", e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		return retval
	}
; 	End:LessThenOrEqual ;}
;{ 	Multiply
	Multiply(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		this.VerifyReadOnly(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfNull.IsNull(value))
		{
			ex := new MfArgumentNullException("value")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (this.Equals("0"))
		{
			return this._ReturnUInt64(this)
		}
		_value := 0
		try
		{
			_value :=  MfUInt64.GetValue(value)
		}
		catch e
		{
			ex := new MfArithmeticException(MfEnvironment.Instance.GetResourceString("Arg_InvalidCastException"), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (_value = "0")
		{
			return this._ReturnUInt64(this)
		}
		_newVal := this._LongIntStringMult(this.Value, _value)


		iComp := this._CompareLongIntStrings(_newVal, MfUInt64.MaxValue)
		if (icomp > 0)
		{
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Arg_ArithmeticExceptionOver"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		iComp := this._CompareLongIntStrings(_newVal, MfUInt64.MinValue)
		if (icomp < 0)
		{
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Arg_ArithmeticExceptionUnder"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_newVal .= ""
		this.Value := _newVal
		return this._ReturnUInt64(this)

	}
; 	End:Multiply ;}
;{ 	Parse()
	Parse(args*) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfObject.IsObjInstance(args[1], MfParams)) {
			objParams := args[1] ; arg 1 is a MfParams object so we will use it
		} else {
			objParams := new MfParams()
			for index, arg in args
			{
				objParams.Add(arg)
			}
		}
		retval := MfNull.Null
		try {
			strP := objParams.ToString()
			if (strP = "MfUInt64")
			{
				retval := objParams.Item[0].Value
			}
			else if (strP = "MfChar")
			{
				c := objParams.Item[0]
				if (MfChar.IsDigit(c)) {
					retval := MfInt64.GetValue(MfCharUnicodeInfo.GetDecimalDigitValue(c))
				}
			}
			else if (strP = "MfString")
			{
				strV := objParams.Item[0].Value
				retval := MfUInt64.GetValue(strV)
			}
			else if (strP = "MfInt64")
			{
				retval := objParams.Item[0].Value
			}
		}
		catch e
		{
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (!MfNull.IsNull(retval))
		{
			iComp := this._CompareLongIntStrings(retval, MfUInt64.MaxValue)
			if (iComp > 0)
			{
				ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Arg_ArithmeticExceptionOver"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			iComp := this._CompareLongIntStrings(retval, MfUInt64.MinValue)
			if (iComp < 0)
			{
				ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Arg_ArithmeticExceptionUnder"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			if (objParams.Data.Contains("ReturnAsObject") && (objParams.Data.Item["ReturnAsObject"] = true))
			{
				return new MfUInt64(retval, true)
			}
			else
			{
				return retval . ""
			}
			
		}
		ex := new MfFormatException(MfEnvironment.Instance.GetResourceString("Format_InvalidString"))
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
; End:Parse() ;}
;{ BitAnd
	BitAnd(Value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		this.VerifyReadOnly(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfNull.IsNull(value))
		{
			ex := new MfArgumentNullException("value")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (this.Equals("0"))
		{
			return
		}
		_value := 0
		try
		{
			_value :=  MfUInt64.GetValue(value)
		}
		catch e
		{
			ex := new MfArithmeticException(MfEnvironment.Instance.GetResourceString("Arg_InvalidCastException"), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}

		strBinary1 := this._LongIntStringToBin(this.Value)
		strBinary2 := this._LongIntStringToBin(_value)
		
		iLenBinary1 := StrLen(strBinary1)
		iLenBinary2 := StrLen(strBinary2)

		if (iLenBinary1 > iLenBinary2)
		{
			strBinary2 := MfString.PadLeft(strBinary2, iLenBinary1, "0")
		}
		else if (iLenBinary2 > iLenBinary1)
		{
			strBinary1 := MfString.PadLeft(strBinary1, iLenBinary2, "0")
		}

		
		lstBinary1 := Mfunc.StringSplit(strBinary1)
		lstBinary2 := Mfunc.StringSplit(strBinary2)

		Count1 := lstBinary1.Count
		;Count2 := lstBinary2.Count
		strAnd := ""


		loop, %Count1%
		{
			iValue := lstBinary1[A_Index] + 0
			if (iValue = 1)
			{
				iValue2 := lstBinary2[A_Index] + 0
				if (iValue2 = 1)
				{
					strAnd .= "1"
				}
				Else
				{
					strAnd .= "0"
				}
			}
			else
			{
				strAnd .= "0"
			}
		}

		_newVal := this._LongBinStringToLongInt(strAnd)
		iComp := this._CompareLongIntStrings(_newVal, MfUInt64.MaxValue)
		if (icomp > 0)
		{
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Arg_ArithmeticExceptionOver"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		iComp := this._CompareLongIntStrings(_newVal, MfUInt64.MinValue)
		if (icomp < 0)
		{
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Arg_ArithmeticExceptionUnder"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		this.Value := _newVal
	}
; End:BitAnd ;}
;{ BitNot
	BitNot() {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		this.VerifyReadOnly(this, A_LineFile, A_LineNumber, A_ThisFunc)
		
		if (this.Equals("0"))
		{
			return
		}
		
		strBinary := this._LongIntStringToBin(this.Value)
			
		strNot := ""
		; flip all the bits
		Loop, Parse, strBinary
		{
			iValue := A_LoopField + 0
			if (iValue = 1)
			{
				strNot .= "0"
			}
			else
			{
				strNot .= "1"
			}
		}
		; flip all 64 bit leading bits to 1
		strNot := MfString.PadLeft(strNot, 64, "1")

		_newVal := this._LongBinStringToLongInt(strNot)
		iComp := this._CompareLongIntStrings(_newVal, MfUInt64.MaxValue)
		if (icomp > 0)
		{
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Arg_ArithmeticExceptionOver"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		iComp := this._CompareLongIntStrings(_newVal, MfUInt64.MinValue)
		if (icomp < 0)
		{
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Arg_ArithmeticExceptionUnder"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		this.Value := _newVal
	}
; End:BitNot ;}
;{ BitOr
	BitOr(Value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		this.VerifyReadOnly(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfNull.IsNull(value))
		{
			ex := new MfArgumentNullException("value")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (this.Equals("0"))
		{
			return
		}
		_value := 0
		try
		{
			_value :=  MfUInt64.GetValue(value)
		}
		catch e
		{
			ex := new MfArithmeticException(MfEnvironment.Instance.GetResourceString("Arg_InvalidCastException"), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}

		strBinary1 := this._LongIntStringToBin(this.Value)
		strBinary2 := this._LongIntStringToBin(_value)
		
		iLenBinary1 := StrLen(strBinary1)
		iLenBinary2 := StrLen(strBinary2)

		if (iLenBinary1 > iLenBinary2)
		{
			strBinary2 := MfString.PadLeft(strBinary2, iLenBinary1, "0")
		}
		else if (iLenBinary2 > iLenBinary1)
		{
			strBinary1 := MfString.PadLeft(strBinary1, iLenBinary2, "0")
		}

		
		lstBinary1 := Mfunc.StringSplit(strBinary1)
		lstBinary2 := Mfunc.StringSplit(strBinary2)

		Count1 := lstBinary1.Count
		strAnd := ""


		loop, %Count1%
		{
			iValue1 := lstBinary1[A_Index] + 0
			iValue2 := lstBinary2[A_Index] + 0

			if ((iValue1 = 1) || (iValue2 = 1))
			{
				strAnd .= "1"
			}
			else
			{
				strAnd .= "0"
			}
		}

		_newVal := this._LongBinStringToLongInt(strAnd)
		iComp := this._CompareLongIntStrings(_newVal, MfUInt64.MaxValue)
		if (icomp > 0)
		{
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Arg_ArithmeticExceptionOver"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		iComp := this._CompareLongIntStrings(_newVal, MfUInt64.MinValue)
		if (icomp < 0)
		{
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Arg_ArithmeticExceptionUnder"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		this.Value := _newVal
	}
; End:BitOr ;}
;{ BitXor
	BitXor(Value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		this.VerifyReadOnly(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfNull.IsNull(value))
		{
			ex := new MfArgumentNullException("value")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (this.Equals("0"))
		{
			return
		}
		_value := 0
		try
		{
			_value :=  MfUInt64.GetValue(value)
		}
		catch e
		{
			ex := new MfArithmeticException(MfEnvironment.Instance.GetResourceString("Arg_InvalidCastException"), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}

		strBinary1 := this._LongIntStringToBin(this.Value)
		strBinary2 := this._LongIntStringToBin(_value)
		
		iLenBinary1 := StrLen(strBinary1)
		iLenBinary2 := StrLen(strBinary2)

		if (iLenBinary1 > iLenBinary2)
		{
			strBinary2 := MfString.PadLeft(strBinary2, iLenBinary1, "0")
		}
		else if (iLenBinary2 > iLenBinary1)
		{
			strBinary1 := MfString.PadLeft(strBinary1, iLenBinary2, "0")
		}

		
		lstBinary1 := Mfunc.StringSplit(strBinary1)
		lstBinary2 := Mfunc.StringSplit(strBinary2)

		Count1 := lstBinary1.Count
		strAnd := ""


		loop, %Count1%
		{
			iValue1 := lstBinary1[A_Index] + 0
			iValue2 := lstBinary2[A_Index] + 0

			if ((iValue1 = 0) && (iValue2 = 0))
			{
				strAnd .= "0"
			}
			else if ((iValue1 = 1) && (iValue2 = 1))
			{
				strAnd .= "0"
			}
			else
			{
				strAnd .= "1"
			}
		}

		_newVal := this._LongBinStringToLongInt(strAnd)
		iComp := this._CompareLongIntStrings(_newVal, MfUInt64.MaxValue)
		if (icomp > 0)
		{
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Arg_ArithmeticExceptionOver"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		iComp := this._CompareLongIntStrings(_newVal, MfUInt64.MinValue)
		if (icomp < 0)
		{
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Arg_ArithmeticExceptionUnder"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		this.Value := _newVal
	}
; End:BitXor ;}
;{ BitShiftLeft
	BitShiftLeft(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		this.VerifyReadOnly(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfNull.IsNull(value))
		{
			ex := new MfArgumentNullException("value")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (this.Equals("0"))
		{
			return
		}
		_value := 0
		try
		{
			_value :=  MfUInt64.GetValue(value)
		}
		catch e
		{
			ex := new MfArithmeticException(MfEnvironment.Instance.GetResourceString("Arg_InvalidCastException"), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}

		strBinary := this._LongIntStringToBin(this.Value)
		iTotalWidth := 64 + _value
		
		strBinary := MfString.PadLeft(strBinary, 64, "0")
		strBinary := MfString.PadRight(strBinary, iTotalWidth, "0")
		strSubBinary := MfString.Substring(strBinary, iTotalWidth - 64 , 64)
		_newVal := this._LongBinStringToLongInt(strSubBinary)
		iComp := this._CompareLongIntStrings(_newVal, MfUInt64.MaxValue)
		if (icomp > 0)
		{
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Arg_ArithmeticExceptionOver"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		iComp := this._CompareLongIntStrings(_newVal, MfUInt64.MinValue)
		if (icomp < 0)
		{
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Arg_ArithmeticExceptionUnder"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		this.Value := _newVal
	}
; End:BitShiftLeft ;}
;{ BitShiftRight
	BitShiftRight(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		this.VerifyReadOnly(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfNull.IsNull(value))
		{
			ex := new MfArgumentNullException("value")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (this.Equals("0"))
		{
			return
		}
		_value := 0
		try
		{
			_value :=  MfUInt64.GetValue(value)
		}
		catch e
		{
			ex := new MfArithmeticException(MfEnvironment.Instance.GetResourceString("Arg_InvalidCastException"), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
		strBinary := this._LongIntStringToBin(this.Value)
		
		iTotalWidth := 64 + _value
		strBinary := MfString.PadLeft(strBinary, iTotalWidth, "0")
	
		strSubBinary := MfString.Substring(strBinary, 0, 64)

		_newVal := this._LongBinStringToLongInt(strSubBinary)
		iComp := this._CompareLongIntStrings(_newVal, MfUInt64.MaxValue)
		if (icomp > 0)
		{
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Arg_ArithmeticExceptionOver"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		iComp := this._CompareLongIntStrings(_newVal, MfUInt64.MinValue)
		if (icomp < 0)
		{
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Arg_ArithmeticExceptionUnder"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		this.Value := _newVal
	}
; End:BitShiftRight ;}
;{	Subtract()
	Subtract(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		this.VerifyReadOnly(this, A_LineFile, A_LineNumber, A_ThisFunc)

		if (MfNull.IsNull(value))
		{
			ex := new MfArgumentNullException("value")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_value := "0"
		if (IsObject(value))
		{
			tryAgain := false
			try
			{
				_value :=  MfInt64.GetValue(value)
				_value .= ""
			}
			catch
			{
				tryAgain := true
			}
			if (tryAgain = true)
			{
				try
				{
					_value :=  MfUInt64.GetValue(value)
				}
				catch e
				{
					ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_InvalidCastException"), "value", e)
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
			}
		}
		else
		{
			try
			{
				_value :=  MfUInt64._GetValueFromVar(value, true) ; get possible negative value
			}
			catch e
			{
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_InvalidCastException"), "value", e)
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		}
		
		_newValue := this._LongIntStringSub(this.Value, _value)
		iComp := this._CompareLongIntStrings(_newValue, MfUInt64.MaxValue)
		if (iComp > 0)
		{
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Arg_ArithmeticExceptionOver"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		iComp := this._CompareLongIntStrings(_newValue, MfUInt64.MinValue)
		if (iComp < 0)
		{
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Arg_ArithmeticExceptionUnder"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_newValue .= ""
		this.Value := _newValue
		return this._ReturnUInt64(this)
	}
; End:Subtract() ;}
;{ 	ToString()			- Overrides	- MfPrimitive
/*
	Method: ToString()
		Overrides MfPrimitive.ToString()

	OutputVar := instance.ToString()

	ToString()
		Gets a string representation of the MfUInt64 instance.
	Returns
		Returns string var representing current instance Value.
	Throws
		Throws MfNullReferenceException if called as a static method
*/
	ToString() {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		retval := this.Value
		return retval . ""
	}
;  End:ToString() ;}
;{ 	TryParse()
	TryParse(byref int, args*) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		_isObj := false
		if (IsObject(Int)) {
			if (MfObject.IsObjInstance(int, "MfUInt64")) {
				_isObj := true
			} else {
				; Int is an object but not an MfUInt64 instance
				; only MfUInt64 is allowed as object
				return false
			}
		}
		retval := false
		try {
			iVal := MfUInt64.Parse(args*)
			if (_isObj = true)
			{
				int.Value := iVal.Value
			}
			else
			{
				int := iVal.Value
			}
		} catch e {
			retval := false
		}
		return retval
	}
; End:TryParse() ;}
; End:Methods ;}
;{ Internal Methods
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
				if (T.IsIntegerNumber)
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
	_GetValueFromVar(varInt, AllowNegative=false) {
		
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
			else if ((AllowNegative = true) && (varInt ~= "^-[0-9]{1,20}$"))
			{
				tmpVarInt := SubStr(varInt, 2, StrLen(varInt) - 1) ; get abs number
				iComp := this._CompareLongIntStrings(tmpVarInt, MfUInt64.MaxValue)
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
;{ _ReturnUInt64
	_ReturnUInt64(obj) {
		if (MfObject.IsObjInstance(obj, MfUInt64)) {
			if (obj.ReturnAsObject) {
				return obj
			} else {
				return obj.Value
			}
		}
		retval := this.ReturnAsObject? new MfUInt64(obj, true):obj
		return retval
	}
; End:_ReturnUInt64 ;}
;{ _LongIntStringDivide
/*
	Method: _LongIntStringDivide()
	Parameters:
		dividend
			String Integer Number
		divisor
			Integer to Divide by. Must be less then or equal to MfInt64.MaxValue
			Must be integer number
		remainder
			The integer reminder of result of the division
	Returns:
		The result of the division as integer value string var
	Remarks:
		Mimicks Long Divison, in theroy as no limits to the size of dividend
*/
	_LongIntStringDivide(dividend, divisor, ByRef remainder) {
		q := ""
		sNum := ""
		iLength := StrLen(dividend)
		cMod := 0
		remainder := 0
		loop, parse, dividend
		{
			sNum .= A_LoopField
			cNum := sNum + 0 ; convert to int
			if ( (cNum = 0) && (A_Index > 1) && (A_Index < iLength))
			{
				q .= "0"
				sNum := ""
				continue
			}
			if ( (cNum < divisor) && (A_Index < iLength) )
			{
				if (A_Index > 1)
				{
					q .= "0"
				}
				continue
			}
			cQ := cNum // divisor
			q .= cQ . ""
			cMod := Mod(cNum, divisor)
			if (cMod = 0 )
			{
				sNum := ""
			}
			else
			{
				sNum := cMod . ""
			}
			
		}
		remainder := cMod
		this._RemoveLeadingZeros(q)
		return q
	}
; End:_LongIntStringDivide ;}
;{ _LongIntStringToBin
/*
	Method: _LongIntStringToBin()
	Parameters:
		strN
			String Integer Number
	Returns:
		The the representation of strN as string Binary
*/	
	 _LongIntStringToBin(strN) {
		r := ""
		retval := ""
		uInt := new MfUInt64(strN)
		While uInt.GreaterThen("0")
		{
			result := MfUInt64._LongIntStringDivide(uInt.Value, 2, r)
			uInt.Value := result
			r := r + 0 ; convert to integer
			if (r = 0)
			{
				retval := "0" . retval
			}
			else
			{
				retval := "1" . retval
			}
		}
		
		return retval
	}
; End:_LongIntStringToBin ;}
;{ _LongBinStringToLongInt
/*
	Method: _LongBinStringToLongInt()
		Converts Binary String of numbers to Unsigned Integer string
	Parameters:
		strN
			String Binary Number such as "1100101010001"
	Returns:
		The the representation of strN as string Unsigned Integer64
*/	
	_LongBinStringToLongInt(strN) {
		strR := MfString.Reverse(strN)
		iLength := StrLen(strR)
		uInt := new MfUInt64("0")
		uIntCount := new MfUInt64("1")
		Loop, Parse, strR
		{
			if (A_Index > 1)
			{
				uIntCount.Multiply(2)
			}
			i := A_LoopField + 0
			if (i = 1)
			{
				uInt.Add(uIntCount.Value)
			}
		}
		return uInt.Value
	}
; End:_LongBinStringToLongInt ;}
;{ _LongIntStringToHex
/*
	Method: _LongIntStringToHex()
		Converts Unsigned Integer String of numbers to Hex
	Parameters:
		strN
			String Unsigned Integer Number
	Returns:
		The the representation of strN as string of hex
*/	
	_LongIntStringToHex(strN) {
		
		r := ""
		retval := ""
		uInt := new MfUInt64(strN)
		While uInt.GreaterThen("0")
		{
			result := MfUInt64._LongIntStringDivide(uInt.Value, 16, r)
			uInt.Value := result
			r := r + 0 ; convert to integer
			if (r <= 9)
			{
				retval := r . retval
			}
			else if (r = 10)
			{
				retval := "A" . retval
			}
			else if (r = 11)
			{
				retval := "B" . retval
			}
			else if (r = 12)
			{
				retval := "C" . retval
			}
			else if (r = 13)
			{
				retval := "D" . retval
			}
			else if (r = 14)
			{
				retval := "E" . retval
			}
			else
			{
				retval := "F" . retval
			}
		}
		return retval
	}
; End:_LongIntStringToHex ;}
;{ _LongIntStringToOctal
/*
	Method: _LongIntStringToOctal()
		Converts Unsigned Integer String of numbers to Octal
	Parameters:
		strN
			String Unsigned Integer Number
	Returns:
		The the representation of strN as string of Octal
*/	
	_LongIntStringToOctal(strN) {
		
		r := ""
		retval := ""
		uInt := new MfUInt64(strN)
		While uInt.GreaterThen("0")
		{
			result := MfUInt64._LongIntStringDivide(uInt.Value, 8, r)
			uInt.Value := result
			r := r + 0 ; convert to integer
			if (r <= 7)
			{
				retval := r . retval
			}
			else if (r = 8)
			{
				retval := "10" . retval
			}
			
		}
		return retval
	}
; End:_LongIntStringToOctal ;}
; End:Internal Methods ;}
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
		Value = "0"
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
	   ABSCompi := this._CompareLongintStrings(WS1, WS2, 0)
	   ;//Make Strings same length with added zeroes
	   this._MakeFitLength(WS1, WS2)
	   If (FIsNeg = "0" and SIsNeg = "1") ;//First pos, second neg.  "x - -y" => "(x+y)"
	     WSResult := this._ABSLongIntStringAdd(WS1, WS2)
	   else
	   If (FIsNeg = "1" and SIsNeg = "0") ;//First neg, sec pos. "-x - y" => "-(x+y)"
	     WSResult := -this._ABSLongIntStringAdd(WS1, WS2)
	   else
	   If (FIsNeg= "1" and SIsNeg= "1" ) ;//Both are negative
	   {
	      if (ABSCompi = 0)  ;//Both are same ABS-size. E.G. -5 - -5 => Result 0
	        return, 0
	      else
	      if (ABSCompi=1)  ;//E.G. -1000 - -20 = -980 => Result negative
	         WSResult := -this._ABSLongIntStringSub(WS1, WS2)
	      else
	      if (ABSCompi=-1) ;//E.G. -20 - -1000 = +980 => Result positive
	         WSResult := this._ABSLongIntStringSub(WS2, WS1)
	   }   
	   else
	   If (FIsNeg = "0" and SIsNeg = "0") ;//Both are positive
	   {
	      if (ABSCompi = 0)  ;//Both are same ABS-size. E.G. 5 - 5 => Result 0
	        return, 0
	      else
	      if (ABSCompi = 1)  ;//E.G. 1000 - 20 = 980 => Result positive
	         WSResult := this._ABSLongIntStringSub(WS1, WS2)
	      else
	      if (ABSCompi=-1) ;//E.G. 20 - 1000 = -980 => Result negative
	         WSResult := -this._ABSLongIntStringSub(WS2, WS1)
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
	      StringMid, value1, FirstLongString, MaxLength + 1 - A_index, 1 
	      StringMid, value2, SecondLongString, MaxLength + 1 - A_index, 1 
	      Sum := Value1 + Value2 + rem
	      Erg := this._Mod(Sum, 10)
	      Rem := this._Div(Sum, 10)
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
	  ABSCompi := this._CompareLongintStrings(WS1, WS2, 0)
	  if (ABSCompi=1)   ;//We do BiggerNum * SmallerNum
	      this._Swap_Values(WS1, WS2)
	  StringLen, Loop1Count, WS1
	  StringLen, Loop2Count, WS2
	  OutLoopCounter=0
	  loop, %Loop1Count% 
	  {
	     OutLoopCounter += 1
	     Help =
	     Rem = 0
	     InLoopCounter=0
	     loop, %loop2Count%
	     {
	        InLoopCounter += 1
	        RightVal := this._StringGetChar(WS2, InLoopCounter, R)
	        LeftVal := this._StringGetChar(WS1, OutLoopCounter, R)
	        MulRes := (LeftVal * RightVal) + rem
	        rem := this._Div(Mulres, 10)
	        Rest := this._Mod(Mulres, 10)
	        Help = %Rest%%Help%
	     }     
	     Help = %rem%%Help%  ;/Not sure if thies right ???
	     ZeroAdd := OutLoopCounter-1
	     loop, %ZeroAdd%
	        Help = %Help%0          
	     this._MakeFitLength(ResultString, Help)
	     ResultString := this._ABSLongIntStringAdd(ResultString, Help)
	  }
	  this._RemoveLeadingZeros(ResultString)
	  If ((FIsNeg = "1") and (SIsNeg = "0")) or ((FIsNeg = "0") and (SIsNeg = "1"))
	    return, -%Resultstring%
	  else
	    return, %Resultstring%
	}
; End:BigInteger-Calculation with AHK ;}
}