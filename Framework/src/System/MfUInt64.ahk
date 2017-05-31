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
			if(MfNull.IsNull(varx) || varx == Undefined)
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

		return this._ReturnUInt64(this)
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
;{ 	Clone
	Clone() {
		uint := new MfUInt64(0)
		uint.m_bigx := this.m_bigx.Clone()
		return uint
	}
; 	End:Clone ;}
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
		i := MfCast.ToInt32(this, false)
		uint := this.Clone()
		uint.BitShiftRight(32)
		iShift := MfCast.ToInt32(uint, false)
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
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToUInt64"), e)
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
			if (MfObject.IsObjInstance(obj, MfUInt64))
			{
				return obj.Value
			}
			T := new MfType(obj)
			if (T.IsIntegerNumber)
			{
				if (obj.LessThen(0))
				{
					if (!CanThrow)
					{
						return "NaN"
					}
					ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("NullReferenceException_Object_Param", "obj"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				return obj.Value
			}
			else if (t.IsFloat)
			{
				return MfUint64._GetValueFromVar(obj.Value, CanThrow)
			}
			else
			{
				if (!CanThrow)
				{
					return "NaN"
				}
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("NullReferenceException_Object_Param", "obj"))
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
		; in most cases MfInt64 can likely handele the getvalue and it is faster
		result := MfInt64.GetValue(varInt, "NaN", true)
		if (result != "NaN")
		{
			if (result >= 0)
			{
				return result
			}
			if (!CanThrow)
			{
				return "NaN"
			}
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Arg_ArithmeticExceptionUnder"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
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
		if (bigx._IsZero())
		{
			; if zero then error must have occured
			; 0 values would have been handled already by MfInt64.GetValue above
			if (!CanThrow)
			{
				return "NaN"
			}
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Arg_ArithmeticException"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (bigx.GreaterThen(MfUInt64.MaxValue))
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
		return this._ReturnUInt64(this)

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
		objParams := MfInt16._intParseParams(A_ThisFunc, args*)
		cnt := objParams.Count
		retval := MfNull.Null
		try {
			strP := objParams.ToString()
		
			if (strP = "MfString" || strP = "MfChar")
			{
				strV := objParams.Item[0].Value
				ns := 7 ; integer
				retval := MfUInt64._Parse(strV, ns, MfNumberFormatInfo.CurrentInfo, A_ThisFunc)
			}
			else if (cnt = 2)
			{
				str := objParams.Item[0]
				if (!MfObject.IsObjInstance(str, MfString))
				{
					ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", A_ThisFunc))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				obj := objParams.Item[1]
				if (MfObject.IsObjInstance(obj, MfFormatProvider))
				{
					ns := 7 ; integer
					retval := MfUInt64._Parse(str.Value, ns, MfNumberFormatInfo.GetInstance(obj), A_ThisFunc)
				}
				else if (MfObject.IsObjInstance(obj, MfNumberStyles))
				{
					retval := MfUInt64._Parse(str.Value, obj.Value, MfNumberFormatInfo.CurrentInfo, A_ThisFunc)
				}
				else
				{
					ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", A_ThisFunc))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
			}
			else if (cnt = 3)
			{
				str := objParams.Item[0]
				ns := objParams.Item[1]
				fInfo := objParams.Item[2]
				if ((!MfObject.IsObjInstance(str, MfString))
					|| (!MfObject.IsObjInstance(ns, MfNumberStyles))
					|| (!MfObject.IsObjInstance(fInfo, MfFormatProvider)))
				{
					ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", A_ThisFunc))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				retval := MfUInt64._Parse(str.Value, ns.Value, MfNumberFormatInfo.GetInstance(fInfo), A_ThisFunc)
			}
			else if (strP = "MfUInt64")
			{
				retval := objParams.Item[0].Value
			}
		} catch e {
			if (MfObject.IsObjInstance(e, MFFormatException))
			{
				e.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw e
			}
			else if (MfObject.IsObjInstance(e, MfOverflowException))
			{
				e.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw e
			}
			else if (MfObject.IsObjInstance(e, MfException))
			{
				if (e.Source = A_ThisFunc)
				{
					throw e
				}
			}
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
		if (!MfNull.IsNull(retval))
		{
			x := MfBigInt.Parse(retval, 10)
			ui := new MfUInt64(0, true)
			ui.m_bigx := x
			return ui
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
		return this._ReturnUInt64(this)
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
		return this._ReturnUInt64(this)
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
		return this._ReturnUInt64(this)
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
		return this._ReturnUInt64(this)
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
		return this._ReturnUInt64(this)
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
		return this.m_bigx.ToString(10)
	}
;  End:ToString() ;}
;{ 	TryParse()
	TryParse(byref result, args*) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		objParams := MfInt16._intParseParams(A_ThisFunc, args*)
		cnt := objParams.Count
		retval := false
		
		strP := objParams.ToString()
		num := 0
		if (strP = "MfString" || strP = "MfChar")
		{
			strV := objParams.Item[0].Value
			ns := 7 ; integer
			retval := MfUInt64._TryParse(strV, ns, MfNumberFormatInfo.CurrentInfo, num)
		}
		else if (cnt = 2)
		{
			str := objParams.Item[0]
			if (!MfObject.IsObjInstance(str, MfString))
			{
				return false
			}
			obj := objParams.Item[1]
			if (MfObject.IsObjInstance(obj, MfNumberStyles))
			{
				retval := MfUInt64._TryParse(str.Value, obj.Value, MfNumberFormatInfo.CurrentInfo, num)
			}
			else
			{
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", A_ThisFunc))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		}
		else if (cnt = 3)
		{
			str := objParams.Item[0]
			ns := objParams.Item[1]
			fInfo := objParams.Item[2]
			if ((!MfObject.IsObjInstance(str, MfString))
				|| (!MfObject.IsObjInstance(ns, MfNumberStyles))
				|| (!MfObject.IsObjInstance(fInfo, MfFormatProvider)))
			{
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", A_ThisFunc))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			retval := MfUInt64._TryParse(str.Value, ns.Value, MfNumberFormatInfo.GetInstance(fInfo), num)
		}
		else if (strP = "MfUInt64")
		{
			num := objParams.Item[0].Value
			retval := true
		}
		if (retval)
		{
			if (IsObject(result))
			{
				x := MfBigInt.Parse(num, 10)
				if (!MfObject.IsObjInstance(result, MfUInt64))
				{
					result := new MfUInt64(0, true)
				}
				result.m_bigx := x
				;int.Value := num
			}
			else
			{
				result := num
			}
		}
		return retval
	}
; End:TryParse() ;}

; End:Methods ;}
;{ Internal Methods
; Sealed Class Following methods cannot be overriden ; Do Not document for this class
; VerifyIsInstance([ClassName, LineFile, LineNumber, Source])
; VerifyIsNotInstance([MethodName, LineFile, LineNumber, Source])
; Sealed Class Following methods cannot be overriden
; VerifyReadOnly()
;{ MfObject Attribute Overrides - methods not used from MfObject - Do Not document for this class
;{	AddAttribute()
/*
	Method: AddAttribute()
	AddAttribute(attrib)
		Overrides MfObject.AddAttribute Sealed Class will never have attribute
	Parameters:
		attrib
			The object instance derived from MfAttribute to add.
	Throws:
		Throws MfNotSupportedException
*/
	AddAttribute(attrib) {
		ex := new MfNotSupportedException()
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex		
	}
;	End:AddAttribute() ;}
;{	GetAttribute()
/*
	Method: GetAttribute()

	OutputVar := instance.GetAttribute(index)

	GetAttribute(index)
		Overrides MfObject.GetAttribute Sealed Class will never have attribute
	Parameters:
		index
			the zero-based index. Can be MfInteger or var containing Integer number.
	Throws:
		Throws MfNotSupportedException
*/
	GetAttribute(index) {
		ex := new MfNotSupportedException()
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
;	End:GetAttribute() ;}
;	GetAttributes ;}
/*
	Method: GetAttributes()

	OutputVar := instance.GetAttributes()

	GetAttributes()
		Overrides MfObject.GetAttributes Sealed Class will never have attribute
	Throws:
		Throws MfNotSupportedException
*/
	GetAttributes()	{
		ex := new MfNotSupportedException()
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
;	End:GetAttributes ;}
;{	GetIndexOfAttribute()
/*
	GetIndexOfAttribute(attrib)
		Overrides MfObject.GetIndexOfAttribute. Sealed Class will never have attribute
	Parameters:
		attrib
			The object instance derived from MfAttribute.
	Throws:
		Throws MfNotSupportedException
*/
	GetIndexOfAttribute(attrib) {
		ex := new MfNotSupportedException()
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
;	End:GetIndexOfAttribute() ;}
;{	HasAttribute()
/*
	HasAttribute(attrib)
		Overrides MfObject.HasAttribute. Sealed Class will never have attribute
	Parameters:
		attrib
			The object instance derived from MfAttribute.
	Throws:
		Throws MfNotSupportedException
*/
	HasAttribute(attrib) {
		ex := new MfNotSupportedException()
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
;	End:HasAttribute() ;}
; End:MfObject Attribute Overrides ;}
;{ 	_Parse
/*
	Method: _Parse()

	_Parse()
		Parses s string into an integer
	Parameters:
		s
			String to parse
		style
			MfNumberStyles number
		info
			instance of MfFormatProvider
	Returns:
		Returns var integer
	Throws:
		Throws MfOverflowException if return value is out of range
	Remarks:
		Static method
		Private method
*/
	_Parse(s, style, info, methodName) {
		try
		{
			MfNumberFormatInfo.ValidateParseStyleInteger(style)	
		}
		catch e
		{
			e.SetProp(A_LineFile, A_LineNumber, methodName)
			throw e
		}
		num := 0
		try
		{
			num := MfNumber.ParseUInt64(s, style, info)
			return num
		}
		catch e
		{
			if (MfObject.IsObjInstance(e, MfOverflowException))
			{
				ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_Int32"), e)
				ex.SetProp(A_LineFile, A_LineNumber, methodName)
				throw ex
			}
			throw e
		}
	}
; 	End:_Parse ;}
;{ 	_TryParse
/*
	Method: _Parse()

	_TryParse()
		Parses string and read value into integer
	Parameters:
		s
			String to parse
		style
			MfNumberStyles number
		info
			instance of MfFormatProvider
		Out
			The result of the parse
	Returns:
		Returns boolean if true if number was parsed; Otherwise false
	Throws:
		Throws MfArgumentException style is not correct for integer
	Remarks:
		Static method
*/
	_TryParse(s, style, info, ByRef Out) {
		try
		{
			MfNumberFormatInfo.ValidateParseStyleInteger(style)	
		}
		catch e
		{
			e.SetProp(A_LineFile, A_LineNumber, methodName)
			throw e
		}
		num := 0
		result := MfNumber.TryParseUInt64(s, style, info, num)
		if (result)
		{
			out := num
			return true
		}
		return false
	}
; 	End:_TryParse ;}
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
		Value = "18446744073709551615" (0xFFFFFFFFFFFFFFFF) hex
*/
	MaxValue[]
	{
		get {
			return "18446744073709551615"   ;  0xFFFFFFFFFFFFFFFF
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