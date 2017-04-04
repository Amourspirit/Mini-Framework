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
	m_bigx := ""
;{ Static Properties
	TypeCode[]
	{
		get {
			return 26
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}

; End:Static Properties ;}
;{ Constructor
	__New(args*) {
		if (this.__Class != "MfUInt64")
		{
			throw new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Sealed_Class","MfUInt64"))
		}


		_returnAsObject := false
		_readonly := false

		pArgs := this._ConstructorParams(A_ThisFunc, args*)

		pList := pArgs.ToStringList()
		s := Null
		pIndex := 0
		if (pList.Count > 0)
		{
			varx := pArgs.Item[pIndex]
			if(MfNull.IsNull(varx))
			{
				varx := 0
			}
			bigx := new MFBigInt(varx)
			if (bigx.IsNegative || MfUInt64._IsGreaterThenMax(bigx))
			{
				ex := new MfArgumentOutOfRangeException("varInt"
					, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper"
					,MfUInt64.MinValue, MfUInt64.MaxValue))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			this.m_bigx := bigx
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
							pIndex := p.AddString(arg)							
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
		bigx := new MfBigInt(value)
		bigx.Add(this.m_bigx)
		if (bigx.IsNegative || MfUInt64._IsGreaterThenMax(bigx))
		{
			ex := new MfArgumentOutOfRangeException("varInt"
				, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper"
				,MfUInt64.MinValue, MfUInt64.MaxValue))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		this.m_bigx := bigx

		
		return this
	}
;{ 	CompareTo()			- Overrides	- MfObject
	CompareTo(obj) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfNull.IsNull(value))
		{
			return 1
		}
		bigx := new MfBigInt(obj)
		return this.m_bigx.CompareTo(bigx)
		
	}
; End:CompareTo(c) ;}
;{ ConvertFromInt64
	ConvertFromInt64(value, ReturnAsObject = false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)

		if (MfObject.IsObjInstance(value, MfInt64))
		{
			_value := value
		}
		Else
		{
			_value := new MfInt64(MfInt64.GetValue(value))
		}
		
		_ReturnAsObject := MfBool.GetValue(ReturnAsObject, false)

		nibs := MfNibConverter.GetNibbles(_value)
		uint := MfNibConverter.ToUInt64(nibs, ,true)
		
		if (_ReturnAsObject)
		{
			return uint
		}
		else
		{
			return uint.Value
		}
	}
; End:ConvertFromInt64 ;}
;{ CastToInt64
	CastToInt64(ReturnAsObject = false) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		_ReturnAsObject := MfBool.GetValue(ReturnAsObject, false)
		
		if ((this.GreaterThenOrEqual("0")) && (this.LessThenOrEqual(MfInt64.MaxValue)))
		{
			_val := this.Value + 0
			if (_ReturnAsObject)
			{

				return new MfInt64(_val)
			}
			else
			{
				return _val
			}
		}

		nibs := MfNibConverter.GetNibbles(this)
		int := MfNibConverter.ToInt64(nibs, ,true)
		
		;
		if (_ReturnAsObject)
		{
			return int
		}
		else
		{
			return int.Value
		}
	}
; End:CastToInt64 ;}
;{ CastToInt32
	CastToInt32(ReturnAsObject = false) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		_ReturnAsObject := MfBool.GetValue(ReturnAsObject, false)
		
		if ((this.GreaterThenOrEqual("0")) && (this.LessThenOrEqual(MfInteger.MaxValue)))
		{
			_val := this.Value + 0
			if (_ReturnAsObject)
			{

				return new MfInteger(_val)
			}
			else
			{
				return _val
			}
		}

		nibs := MfNibConverter.GetNibbles(this)
		;IsNeg := (MfNibConverter.IsNegative(nibs)
		int := MfNibConverter.ToInt32(nibs,31 ,true)
		
		
		if (_ReturnAsObject)
		{
			return int
		}
		else
		{
			return int.Value
		}
	}
; End:CastToInt32 ;}
	Clone() {
		uint := new MfUInt64(0)
		uint.m_bigx := this.m_bigx.Clone()
		return uint
	}
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
		if (this._IsZero())
		{
			return this
		}
		bigx := this.m_bigx.Clone()
		xValue := new MfBigInt(value)
		bigx.Divide(xValue)
		if (bigx.IsNegative)
		{
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Arg_ArithmeticExceptionUnder"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (this._IsGreaterThenMax(bigx))
		{
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Arg_ArithmeticExceptionOver"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		this.m_bigx := bigx
		return this

	}
; 	End:Divide ;}
;{ 	Equals()			- Overrides - MfObject
	Equals(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfNull.IsNull(value))
		{
			return false
		}
		bigx := new MfBigInt(value)
		return this.m_bigx.Equals(bigx)
	}
; 	End:Equals ;}
;{ 	GetHashCode()		- Overrides	- MfObject
/*
	Method: GetHashCode()
		Overrides MfObject.GetHashCode()
	
	OutputVar := instance.GetHashCode()
	
	GetHashCode()
		Gets A hash code for the MfUInt64 instance.
	Returns
		A 32-bit signed integer hash code as var.
	Throws
		Throws MfNullReferenceException if object is not an instance.
*/
	GetHashCode() {
		i := this.CastToInt32()
		uint := this.Clone()
		uint.BitShiftRight(32)
		iShift := uint.CastToInt32()
		return i ^ iShift
	}
; End:GetHashCode() ;}
;{ 	GetTypeCode()
/*
	Method: GetTypeCode()
		Get an enumeration value of MfTypeCode the represents MfInt64 Type Code.
	Returns
		And instance of MfEnum.EnumItem with a constant value that represents the type of MfInt64.
*/
	GetTypeCode() {
		return MfTypeCode.Instance.UInt64
	}
; End:GetTypeCode() ;}
;{ 	GetValue()			- Overrides	- MfPrimitive
	GetValue(args*) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		;obj, default=0, AllowAny=false
		i := 0
		for index, arg in args
		{
			i++
		}
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
			_default := MfUint64._GetValue(args[2], false)
			If (_default == "NaN")
			{
				CanThrow := true
			}
			else
			{
				CanThrow := false
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
				_default := MfUint64._GetValue(args[2], false)
				if (_default == "NaN")
				{
					CanThrow := true
				}
				else
				{
					CanThrow := false
				}
			}
		}
		retval := 0
		if (CanThrow = true)
		{
			try
			{
				retval := MfUint64._GetValue(obj)
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
			retval := MfUint64._GetValue(obj, false)
			if (retval == "NaN")
			{
				return _default
			}
			return retval
		}
		return retval
	}
; End:GetValue() ;}	
;{ 	_GetValue
	_GetValue(obj, CanThrow=true) {
		retval := 0
		if (IsObject(obj)) {
			T := new MfType(obj)
			if (T.IsIntegerNumber)
			{
				return := MfUint64._GetValueFromVar(obj.Value, CanThrow)
				
			}
			else if (t.IsFloat)
			{
				return := MfUint64._GetValueFromVar(obj.Value, CanThrow)
			}
			else
			{
				if (!CanThrow)
				{
					return "NaN"
				}
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("NullReferenceException_Object_Param", "int"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		} else {
			retval := MfUint64._GetValueFromVar(obj, CanThrow)
		}
		return retval
	}
; 	End:_GetValue ;}
; 	End:_GetValue ;}
;{ 	_GetValueFromVar
	_GetValueFromVar(varInt, CanThrow=true) {
		dotIndex := InStr(varInt, ".") - 1
		if (dotIndex > 0)
		{
			varInt := SubStr(varInt, 1, dotIndex) ; drop decimal portion
		}
		bigx := MfBigInt.Parse(varInt)

		if (bigx.IsNegative)
		{
			if (!CanThrow)
			{
				return "NaN"
			}
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Arg_ArithmeticExceptionUnder"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (bigx.GreaterThen(Uint64Max))
		{
			if (!CanThrow)
			{
				return "NaN"
			}
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Arg_ArithmeticExceptionOver"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		return bigx.Value
	}
; 	End:_GetValueFromVar ;}
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
		
		try
		{
			bigx := new MfBigInt(value)
			return this.m_bigx.GreaterThenOrEqual(bigx)
		}
		Catch e
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_InvalidCastException"), "value", e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
	}
; 	End:GreaterThenOrEqual ;}
;{ 	LessThen
	LessThen(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		retval := false
		if (MfNull.IsNull(value)) {
			return retval
		}
		
		try
		{
			bigx := new MfBigInt(value)
			return this.m_bigx.LessThen(bigx)
		}
		Catch e
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_InvalidCastException"), "value", e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
	}
; 	End:LessThen ;}
;{ 	LessThenOrEqual
	LessThenOrEqual(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		retval := false
		if (MfNull.IsNull(value)) {
			return retval
		}
		
		try
		{
			bigx := new MfBigInt(value)
			return this.m_bigx.LessThenOrEqual(bigx)
		}
		Catch e
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_InvalidCastException"), "value", e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
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
		if (this._IsZero())
		{
			return this
		}
		bigx := new MfBigInt(value)
		if(bigx._IsOne(false) = true)
		{
			return this
		}
		if (bigx._IsZero())
		{
			this.m_bigx := bigx
			return this
		}
		bigx.Multiply(this.m_bigx)
		if (bigx.IsNegative)
		{
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Arg_ArithmeticExceptionUnder"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (this._IsGreaterThenMax(bigx))
		{
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Arg_ArithmeticExceptionOver"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		this.m_bigx := bigx
		return this

	}
; 	End:Multiply ;}
;{ 	Parse()
	;parse UMfUint from string
	; Parmas,
	;	value - string to parse or MfUInt64 or MfInt64 instance or MfChar instance or 
	;	ReturnAsObject
	;	Base - the Base to convert string from, only applied if value is string
	Parse(args*) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)

		pArgs := MfUInt64._ParaseParams(A_ThisFunc, args*)

		pList := pArgs.ToStringList()

		returnAsObject := false
		base := -2
		strP := ""
		s := ""
		pIndex := 0
		retval := Null
		if (pList.Count > 0)
		{
			strP := pList.Item[pIndex].Value
			
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
			if (strP = "MfInt64")
			{
				base := pArgs.Item[pIndex].Value
				if (base < 1 || base > 95)
				{
					base := -2
				}
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

	
		try {
			if (strP = "MfUInt64")
			{
				retval := pArgs.Item[0]
				base := 10
			}
			else if (strP = "MfChar")
			{
				c := pArgs.Item[0]
				if (MfChar.IsDigit(c)) {
					retval := MfInt64.GetValue(MfCharUnicodeInfo.GetDecimalDigitValue(c))

				}
				base := -2
			}
			else if (strP = "MfString")
			{
				strV := pArgs.Item[0].Value
				retval := MfString.GetValue(strV)
			}
			else if (strP = "MfInt64")
			{
				retval := pArgs.Item[0].Value
				base := -2
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
			if (base > 0)
			{
				bigx := MfBigInt.Parse(retval, base)
			}
			else
			{
				bigx := new MfBigInt(retval)
			}
			
			if (bigx.IsNegative)
			{
				ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Arg_ArithmeticExceptionUnder"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			if (bigx.GreaterThen(MfBigMathInt.Uint64Max))
			{
				ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Arg_ArithmeticExceptionOver"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}


			if (returnAsObject)
			{
				
				return new MfUInt64(bigx)
			}
			else
			{
				return MfBigMathInt.BigInt2str(bigx, 10)
				
			}
			
		}
		ex := new MfFormatException(MfEnvironment.Instance.GetResourceString("Format_InvalidString"))
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
; End:Parse() ;}
;{ _ParaseParams
	_ParaseParams(MethodName, args*) {
		; Params - Value, .ReturnAsObject, Base,
		p := Null
		cnt := MfParams.GetArgCount(args*)

	
		if ((cnt > 0) && MfObject.IsObjInstance(args[1], MfParams))
		{
			p := args[1] ; arg 1 is a MfParams object so we will use it
			; can be up to five parameters
			; Two parameters is not a possibility
			if (p.Count = 0 || p.Count > 3)
			{
				e := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", MethodName))
				e.SetProp(A_LineFile, A_LineNumber, MethodName)
				throw e
			}
		}
		else
		{

			p := new MfParams()
			p.AllowEmptyString := true ; can be strings for parameters in this case
			p.AllowOnlyAhkObj := false ; needed to allow for undefined to be added
			p.AllowEmptyValue := true ; all empty/null params will be added as undefined

			;p.AddInteger(0)
			;return p
			
			; can be up to five parameters
			; Two parameters is not a possibility
			if (cnt = 0 || cnt > 3)
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
						if (i = 2) ; ReturnAsObject
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
						else if (i = 3) ; base
						{
							; convert to MfInt64 for  easy parsing of parameter
							if (MfObject.IsObjInstance(arg, MfInt64))
							{
								p.add(arg)
							}
							else
							{
								int := new MfInt64(MfInt64.GetValue(arg, 10))
								p.Add(int)
							}
						}
						else
						{
							p.Add(arg)
						}
					} 
					else
					{
						if (i = 1) ; uint64
						{
							pIndex := p.AddString(arg)							
						}
						else if (i = 2) ; ReturnAsObject
						{
							if (MfNull.IsNull(arg))
							{
								pIndex := p.Add(new MfBool(true))
							}
							else
							{
								pIndex := p.AddBool(arg)
							}
						}
						else ; all params past 2 are integer
						{
							int := new MfInt64(MfInt64.GetValue(arg, 10))
							pIndex := p.Add(int)
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
; End:_ParaseParams ;}
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
		
		if (this._IsZero())
		{
			return this
		}
		_bits := MfBinaryConverter.GetBits(Value)
		if (_bits.Count > 64)
		{
			_bits := MfBinaryConverter.Trim(_bits)
		}
		
		if (_bits.Count > 64)
		{
			ex := new MfArgumentOutOfRangeException("Value")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		localBits := MfBinaryConverter.GetBits(this)
		rBits := MfBinaryConverter.BitAnd(localBits, _bits)

		uint := MfBinaryConverter.ToUInt64(rBits)
		this.m_bigx := uint.m_bigx
		Return this
	}
; End:BitAnd ;}
;{ BitNot
	BitNot() {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		this.VerifyReadOnly(this, A_LineFile, A_LineNumber, A_ThisFunc)
		
		if (this._IsZero())
		{
			return this
		}
		
		localBits := MfBinaryConverter.GetBits(this)
		rBits := MfBinaryConverter.BitNot(localBits)

		uint := MfBinaryConverter.ToUInt64(rBits)
		this.m_bigx := uint.m_bigx
		Return this
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
		
		if (this._IsZero())
		{
			return this
		}
		_bits := MfBinaryConverter.GetBits(Value)
		if (_bits.Count > 64)
		{
			_bits := MfBinaryConverter.Trim(_bits)
		}
		
		if (_bits.Count > 64)
		{
			ex := new MfArgumentOutOfRangeException("Value")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		localBits := MfBinaryConverter.GetBits(this)
		rBits := MfBinaryConverter.BitOr(localBits, _bits)

		uint := MfBinaryConverter.ToUInt64(rBits)
		this.m_bigx := uint.m_bigx
		Return this
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
		
		if (this._IsZero())
		{
			return this
		}
		_bits := MfBinaryConverter.GetBits(Value)
		if (_bits.Count > 64)
		{
			_bits := MfBinaryConverter.Trim(_bits)
		}
		
		if (_bits.Count > 64)
		{
			ex := new MfArgumentOutOfRangeException("Value")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		localBits := MfBinaryConverter.GetBits(this)
		rBits := MfBinaryConverter.BitXor(localBits, _bits)

		uint := MfBinaryConverter.ToUInt64(rBits)
		this.m_bigx := uint.m_bigx
		Return this
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
		_value := 0
		try
		{
			_value :=  MfInteger.GetValue(value)
		}
		catch e
		{
			ex := new MfArithmeticException(MfEnvironment.Instance.GetResourceString("Arg_InvalidCastException"), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}

		if (_value = 0)
		{
			return this
		}
		
		if (this._IsZero())
		{
			return this
		}
		if (_value < 0)
		{
			_value := Abs(_value)
			r := mod(_value, 64)
			_value := 64 - r
		}

		if (_value >= 64)
		{
			_value := Mod(_value, 64)
		}
		if (_value < 0)
		{
			return this
		}
		
		localBits := MfBinaryConverter.GetBits(this)
		rBits := MfBinaryConverter.BitShiftLeftUnSigned(localBits, _value, true, true)

		uint := MfBinaryConverter.ToUInt64(rBits)
		this.m_bigx := uint.m_bigx
		Return this
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
		_value := 0
		try
		{
			_value :=  MfInteger.GetValue(value)
		}
		catch e
		{
			ex := new MfArithmeticException(MfEnvironment.Instance.GetResourceString("Arg_InvalidCastException"), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}

		if (_value = 0)
		{
			return this
		}
		
		if (this._IsZero())
		{
			return this
		}
		if (_value < 0)
		{
			_value := Abs(_value)
			r := mod(_value, 64)
			_value := 64 - r
		}
		if (_value >= 64)
		{
			_value := Mod(_value, 64)
		}
		if (_value < 0)
		{
			return this
		}
		this.m_bigx.BitShiftRight(_value)
		return this
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
		bigx := new MfBigInt(value)
		tx := this.m_bigx.Clone()
		tx.Subtract(bigx)
		if (tx.IsNegative || MfUInt64._IsGreaterThenMax(tx))
		{
			ex := new MfArgumentOutOfRangeException("varInt"
				, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper"
				,MfUInt64.MinValue, MfUInt64.MaxValue))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		this.m_bigx := tx
		return this
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
	ToString(base=10) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		return this.m_bigx.ToString(base)
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
		pArgs := MfUInt64._TryParaseParams(A_ThisFunc, args*)
		; pArgs can only be 1 or 2 args
		p := new MfParams()
		p.Add(pArgs.Item[0])
		p.AddBool(true) ; return as Object
		if (pArgs.Count > 1)
		{
			p.Add(pArgs.Item[1]) ; base
		}

		retval := false
		try {
			iVal := MfUInt64.Parse(p)
			if (_isObj = true)
			{
				int.m_bigx := iVal.m_bigx
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
;{ 	_TryParaseParams
	_TryParaseParams(MethodName, args*) {
		; Params - Value, Base
		p := Null
		cnt := MfParams.GetArgCount(args*)

	
		if ((cnt > 0) && MfObject.IsObjInstance(args[1], MfParams))
		{
			p := args[1] ; arg 1 is a MfParams object so we will use it
			; can be up to five parameters
			; Two parameters is not a possibility
			if (p.Count = 0 || p.Count > 2)
			{
				e := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", MethodName))
				e.SetProp(A_LineFile, A_LineNumber, MethodName)
				throw e
			}
		}
		else
		{

			p := new MfParams()
			p.AllowEmptyString := true ; can be strings for parameters in this case
			p.AllowOnlyAhkObj := false ; needed to allow for undefined to be added
			p.AllowEmptyValue := true ; all empty/null params will be added as undefined

			;p.AddInteger(0)
			;return p
			
			; can be up to five parameters
			; Two parameters is not a possibility
			if (cnt = 0 || cnt > 2)
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
						if (i = 3) ; base
						{
							; convert to MfInt64 for  easy parsing of parameter
							if (MfObject.IsObjInstance(arg, MfInt64))
							{
								p.add(arg)
							}
							else
							{
								int := new MfInt64(MfInt64.GetValue(arg, 10))
								p.Add(int)
							}
						}
						else
						{
							p.Add(arg)
						}
					} 
					else
					{
						if (i = 1) ; uint64
						{
							pIndex := p.AddString(arg)							
						}
						else ; all params past 1 are integer
						{
							int := new MfInt64(MfInt64.GetValue(arg, 10))
							pIndex := p.Add(int)
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
; 	End:_TryParaseParams ;}
; End:Methods ;}
;{ Internal Methods
;{ 	_GetValue
	_IsGreaterThenMax(value) {
		bigx := new MfBigInt(value)
		return bigx.GreaterThen(MfBigMathInt.Uint64Max)
	}
	_IsZero() {
		return MfBigMathInt.IsZero(this.m_bigx.m_bi)
	}
	; internal method
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
;{	Value
/*
	Property: Value [get/set]
		Overrides MfPrimitive.Value
		Gets or sets the value associated with the this instance of MfUInt64
	Value:
		Value is a integer and can be var or any type that matches MfType.IsIntegerNumber.
	Sets:
		Set the Value of the instance. Can  be var or any type that matches MfType.IsIntegerNumber. 
	Gets:
		Gets integer Value as var with a value no less then MinValue and no greater than MaxValue.
	Throws
		Throws MfNotSupportedException on set if Readonly is true.
		Throws MfArgumentOutOfRangeException if value is less then MinValue or greater then MaxValue
		Throws MfArgumentException for other errors.
*/
	Value[]
	{
		get {
			return this.m_bigx.Value
		}
		set {
			this.VerifyReadOnly(this, A_LineFile, A_LineNumber, A_ThisFunc)
			x := MfUInt64.Parse(value, true)
			this.m_bigx := x.m_bigx
		}
	}
;	End:Value ;}
; End:Properties ;}
;{ BigInteger-Calculation with AHK
;	https://autohotkey.com/board/topic/3474-biginteger-calculation-with-ahk/

	
; End:BigInteger-Calculation with AHK ;}
}