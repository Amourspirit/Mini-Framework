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
Class MfBigInt extends MfObject
{
	m_bi := ""
	;{ Static Properties
	TypeCode[]
	{
		get {
			return 27
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}

; End:Static Properties ;}
;{ 	Constructor
	__new(args*) {
		; Parameters all optional, Value=0, ReturnAsObject=false, ReadOnly=false
		if (this.__Class != "MfBigInt")
		{
			throw new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Sealed_Class","MfInt64"))
		}
		base.__new()
		
		_readonly := false
		pArgs := this._ConstructorParams(A_ThisFunc, args*)
		pList := pArgs.ToStringList()
		pIndex := 0
		if (pList.Count > 0)
		{
			this._FromAnyConstructor(pArgs.Item[pIndex])
		}
		else
		{
			this.m_bi := new MfListVar(3)
		}
		if (pList.Count > 1)
		{
			pIndex++
			s := pList.Item[pIndex].Value
			if (s = "MfBool")
			{
				this.m_ReturnAsObject := pArgs.Item[pIndex].Value
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
				this.m_ReadOnly := pArgs.Item[pIndex].Value
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
		
		
		this.m_isInherited := False
		
	}
; 	End:Constructor ;}
;{ 	_ConstructorParams
	_ConstructorParams(MethodName, args*) {

		p := Null
		cnt := MfParams.GetArgCount(args*)

	
		if ((cnt > 0) && MfObject.IsObjInstance(args[1], MfParams))
		{
			p := args[1] ; arg 1 is a MfParams object so we will use it
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

			
			; can be up to five parameters
			; Two parameters is not a possibility
			if (cnt > 3)
			{
				e := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", MethodName))
				e.SetProp(A_LineFile, A_LineNumber, MethodName)
				throw e
			}
			
			i := 1
			while (i <= cnt)
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
						else if (i = 1) ; bigInt any kind, add as string
						{

							p.AddString(arg)
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
		return p
	}
; 	End:_ConstructorParams ;}
;{ 	Methods
	Add(Value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		this._VerifyReadOnly(this, A_LineFile, A_LineNumber, A_ThisFunc)

		if (MfNull.IsNull(value)) {
			ex := new MfArgumentNullException("value")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		this._ClearCache()
		x := ""
		try
		{
			x := MfBigInt._FromAny(value)
		}
		Catch e
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_InvalidCastException"), "value", e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (x.IsNegative = false && this.IsNegative = false)
		{
			this.m_bi := MfBigMathInt.add(this.m_bi, x.m_bi)
			return this._ReturnBigInt()
		}
		if (x.IsNegative = true && this.IsNegative = true)
		{
			this.m_bi := MfBigMathInt.add(this.m_bi, x.m_bi)
			return this._ReturnBigInt()
		}
		if (this.IsNegative != x.IsNegative)
		{
			If (MfBigMathInt.Equals(this.m_bi, x.m_bi))
			{
				tmp := new MfBigInt(new MfInteger(0))
				this.m_bi := tmp.m_bi
				this.IsNegative := False
				return this._ReturnBigInt()
			}
			If (MfBigMathInt.Greater(this.m_bi, x.m_bi))
			{
				this.m_bi := MfBigMathInt.Sub(this.m_bi, x.m_bi)
				this.IsNegative := !x.IsNegative
			}
			else
			{
				this.m_bi := MfBigMathInt.Sub(x.m_bi,this.m_bi)
				this.IsNegative := !this.IsNegative
			}
			return this._ReturnBigInt()
		}
		return this._ReturnBigInt()
	}
	BitShiftLeft(Value) {
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
			return
		}
		if(this._IsZero())
		{
			return
		}
		if (_value < 0)
		{
			this._SetZero()
			return
		}
		this._ClearCache()
		; Get how many positins may be needed for the shift
		n := (_value // MfBigMathInt.bpe) + 1
		; add new positions to the list
		this.m_bi := MfBigMathInt.Trim(this.m_bi, n)
		; do the shifting
		MfBigMathInt.leftShift_(this.m_bi, _value)
		; trim inner list back down
		this.m_bi := MfBigMathInt.Trim(this.m_bi, 1)
		if(this._IsZero())
		{
			this.IsNegitive := false
		}
	}
	BitShiftRight(Value) {
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
			return
		}
		if(this._IsZero())
		{
			return
		}
		if (_value < 0)
		{
			this._SetZero()
			return
		}
		this._ClearCache()
		
		; If (_value >= this.BitSize)
		; {
		; 	this._SetZero()
		; 	return
		; }
		MfBigMathInt.rightShift_(this.m_bi, _value)
		; trim inner list back down
		this.m_bi := MfBigMathInt.Trim(this.m_bi, 1)
		if (this.IsNegative)
		{
			this.m_bi := MfBigMathInt.Add(this.m_bi, MfBigMathInt.one)
		}
		this.m_bi := MfBigMathInt.Trim(this.m_bi, 1)
		if(this._IsZero())
		{
			this.IsNegative := false
		}
	}
	_SetZero() {
		this._ClearCache()
		this.m_bi := new MfListVar(2, 0)
		this.IsNegative := false
	}
	_ClearCache() {
		this.strValue := ""
		this.m_BitSize := ""
	}
;{ 	CompareTo
	CompareTo(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)

		if (MfNull.IsNull(value)) {
			ex := new MfArgumentNullException("value")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		x := ""
		try
		{
			x := MfBigInt._FromAny(value)
		}
		Catch e
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_InvalidCastException"), "value", e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (this.Equals(x))
		{
			return 0
		}
		if (this.GreaterThen(x))
		{
			return 1
		}
		return -1
	}
; 	End:CompareTo ;}
;{ 	Divide
	; retruns remainder as base MfBigInt
	Divide(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		this._VerifyReadOnly(this, A_LineFile, A_LineNumber, A_ThisFunc)

		if (MfNull.IsNull(value)) {
			ex := new MfArgumentNullException("value")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
				
		this._ClearCache()
		r := new MfBigInt()
		q := MfBigInt.DivRem(this, value, r)
		this.m_bi := q.m_bi
		this.IsNegative := q.IsNegative
		return r

	}
; 	End:Divide ;}
	DivRem(dividend, divisor, byref remainder) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfNull.IsNull(dividend))
		{
			ex := new MfArgumentNullException("dividend")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (MfNull.IsNull(divisor))
		{
			ex := new MfArgumentNullException("divisor")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		x := ""
		y := ""
		try
		{
			x := MfBigInt._FromAny(dividend)
		}
		catch e
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToBigInt"), "dividend")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		try
		{
			y := MfBigInt._FromAny(divisor)
		}
		catch e
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToBigInt"), "divisor")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (MfBigMathInt.IsZero(y.m_bi))
		{
			ex := new MfDivideByZeroException()
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		IsObj := false
		If (IsObject(remainder))
		{
			If (MfObject.IsObjInstance(remainder, MfBigInt) = false)
			{
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_IncorrectObjType_Generic"), "remainder")
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			IsObj := true
		}
		
		q := new MfBigInt()
		r := new MfBigInt()


		if (MfBigMathInt.IsZero(x.m_bi))
		{
			; all return value will be zero
			if (IsObj)
			{
				remainder.m_bi := r.m_bi
				remainder.IsNegative := false
			}
			else
			{
				remiander := r.Value
			}
			return q ; return 0 value
		}

		; q and r must have arrays that are exactly the same Count as x. (Or q can have more).
		r.m_bi := new MfListVar(x.m_bi.Count, 0)
		q.m_bi := r.m_bi.Clone()
		; m_bi will always be positive so negative values have to be re-assigned
		MfBigMathInt.divide_(x.m_bi, y.m_bi, q.m_bi, r.m_bi)
		q.m_bi := MfBigMathInt.Trim(q.m_bi , 1)
		r.m_bi := MfBigMathInt.Trim(r.m_bi , 1)
		
		rNeg := false
		qNeg := false
		if (x.IsNegative && !y.IsNegative)
		{
			rNeg := true
			qNeg := true
		}
		else if (!x.IsNegative && y.IsNegative)
		{
			rNeg := false
			qNeg := true
		}
		else if (x.IsNegative || y.IsNegative)
		{
			rNeg := true
			qNeg := false
		}
		
		if (qNeg && MfBigMathInt.IsZero(q.m_bi))
		{
			qNeg := false
		}
		if (rNeg && MfBigMathInt.IsZero(r.m_bi))
		{
			rNeg := false
		}
				
		
		if (IsObj)
		{
			remainder.m_bi := r.m_bi.Clone()
			remainder.IsNegative := rNeg
		}
		else
		{
			r.IsNegative := rNeg
			remiander := r.Value
		}
		q.IsNegative := qNeg
		return q
	}
;{ 	Equals
	Equals(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)

		if (MfNull.IsNull(value)) {
			ex := new MfArgumentNullException("value")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		x := ""
		try
		{
			x := MfBigInt._FromAny(value)
		}
		Catch e
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_InvalidCastException"), "value", e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (x.IsNegative = true && this.IsNegative = true)
		{
			return false
		}
		return MfBigMathInt.Equals(this.m_bi, x.m_bi)
	}
; 	End:Equals ;}
;{ 	GetTypeCode()
/*
	Method: GetTypeCode()
		Get an enumeration value of MfTypeCode the represents MfInt64 Type Code.
	Returns
		And instance of MfEnum.EnumItem with a constant value that represents the type of MfInt64.
*/
	GetTypeCode() {
		return MfTypeCode.Instance.MfBigInt
	}
; End:GetTypeCode() ;}
;{ 	GreaterThen
	GreaterThen(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)

		if (MfNull.IsNull(value)) {
			ex := new MfArgumentNullException("value")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		x := ""
		try
		{
			x := MfBigInt._FromAny(value)
		}
		Catch e
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_InvalidCastException"), "value", e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}

		if (this.IsNegative = true && x.IsNegative = false)
		{
			return false
		}
		if (this.IsNegative = false && x.IsNegative = true)
		{
			return true
		}
		if (this.IsNegative = true && x.IsNegative = true)
		{
			return MfBigMathInt.Greater(x.m_bi, this.m_bi)
		}
		return MfBigMathInt.Greater(this.m_bi, x.m_bi)

	}
; 	End:GreaterThen ;}
	GreaterThenOrEqual(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)

		if (MfNull.IsNull(value)) {
			ex := new MfArgumentNullException("value")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		x := ""
		try
		{
			x := MfBigInt._FromAny(value)
		}
		Catch e
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_InvalidCastException"), "value", e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}

		if (this.IsNegative = true && x.IsNegative = false)
		{
			return false
		}
		if (this.IsNegative = false && x.IsNegative = true)
		{
			return true
		}
		if (MfBigMathInt.Equals(this.m_bi, x.m_bi))
		{
			return true
		}
		if (this.IsNegative = true && x.IsNegative = true)
		{
			return MfBigMathInt.Greater(x.m_bi, this.m_bi)
		}
		return MfBigMathInt.Greater(this.m_bi, x.m_bi)
	}
;{ 	LessThen
	LessThen(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)

		if (MfNull.IsNull(value)) {
			ex := new MfArgumentNullException("value")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		x := ""
		try
		{
			x := MfBigInt._FromAny(value)
		}
		Catch e
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_InvalidCastException"), "value", e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}

		if (this.IsNegative = true && x.IsNegative = false)
		{
			return true
		}
		if (this.IsNegative = false && x.IsNegative = true)
		{
			return false
		}
		if (this.IsNegative = true && x.IsNegative = true)
		{
			return MfBigMathInt.Greater(this.m_bi, x.m_bi)
		}
		return MfBigMathInt.Greater(x.m_bi, this.m_bi)

	}
; 	End:LessThen ;}
;{ 	LessThenOrEqual
	LessThenOrEqual(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)

		if (MfNull.IsNull(value)) {
			ex := new MfArgumentNullException("value")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		x := ""
		try
		{
			x := MfBigInt._FromAny(value)
		}
		Catch e
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_InvalidCastException"), "value", e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}

		if (this.IsNegative = true && x.IsNegative = false)
		{
			return true
		}
		if (this.IsNegative = false && x.IsNegative = true)
		{
			return false
		}
		if (MfBigMathInt.Equals(this.m_bi, x.m_bi))
		{
			return true
		}
		if (this.IsNegative = true && x.IsNegative = true)
		{
			return MfBigMathInt.Greater(this.m_bi, x.m_bi)
		}
		return MfBigMathInt.Greater(x.m_bi, this.m_bi)

	}
; 	End:LessThenOrEqual ;}
;{ 	Multiply
	Multiply(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		this._VerifyReadOnly(this, A_LineFile, A_LineNumber, A_ThisFunc)

		if (MfNull.IsNull(value)) {
			ex := new MfArgumentNullException("value")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(this._IsZero())
		{
			return this._ReturnBigInt()
		}
		
		this._ClearCache()
		x := ""
		try
		{
			x := MfBigInt._FromAny(value)
		}
		Catch e
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_InvalidCastException"), "value", e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(this._IsOne(true))
		{
			if (this.IsNegative)
			{
				x.IsNegative := !x.IsNegative
			}
			this.m_bi := x.m_bi.Clone()
			this.IsNegative := x.IsNegative
			return this._ReturnBigInt()
		}
		if(x._IsOne(true))
		{
			if (x.IsNegative)
			{
				this.IsNegative := !this.IsNegative
			}
			return this._ReturnBigInt()
		}

		if ((x.IsNegative = false && this.IsNegative = false)
			|| (x.IsNegative = true && this.IsNegative = true))
		{
			If (MfBigMathInt.Greater(this.m_bi, x.m_bi))
			{
				bigx := MfBigMathInt.Mult(this.m_bi, x.m_bi)
			}
			Else
			{
				bigx := MfBigMathInt.Mult(x.m_bi, this.m_bi)
			}
			this.m_bi := bigx
			this.IsNegative := False
			return this._ReturnBigInt()
		}
		If (MfBigMathInt.greater(this.m_bi, x.m_bi))
		{
			bigx := MfBigMathInt.Mult(this.m_bi, x.m_bi)
		}
		Else
		{
			bigx := MfBigMathInt.Mult(x.m_bi, this.m_bi)
		}
		this.m_bi := bigx
		this.IsNegative := true
		return this._ReturnBigInt()
	}
; 	End:Multiply ;}
;{ 	Power
	; Raise Value to the power of
	Power(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		this._VerifyReadOnly(this, A_LineFile, A_LineNumber, A_ThisFunc)

		
		if (MfNull.IsNull(value)) {
			ex := new MfArgumentNullException("value")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(this._IsZero())
		{
			return this._ReturnBigInt()
		}
		if(this._IsOne(true))
		{
			if (this.IsNegative)
			{
				this.IsNegative := False
			}
			return this._ReturnBigInt()
		}
		
		exp := MfInt64.GetValue(value)

		if (exp < 0)
		{
			exp := Abs(exp)
		}
		if (exp = 1)
		{
			return this._ReturnBigInt()
		}
		if (exp = 0)
		{
			this.Value := 1
			return this._ReturnBigInt()
		}
		this._ClearCache()	
		bigX := this.m_bi.Clone()

		i := 1
		while (i < exp)
		{
			this.Multiply(bigX)
			i++
		}
		return this._ReturnBigInt()
	}
; 	End:Power ;}
;{ Subtract
	Subtract(Value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		this._VerifyReadOnly(this, A_LineFile, A_LineNumber, A_ThisFunc)

		if (MfNull.IsNull(value)) {
			ex := new MfArgumentNullException("value")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		this._ClearCache()
		x := ""
		try
		{
			x := MfBigInt._FromAny(value)
		}
		Catch e
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_InvalidCastException"), "value", e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (x.IsNegative = false && this.IsNegative = false)
		{
			If (MfBigMathInt.Equals(this.m_bi, x.m_bi))
			{
				tmp := new MfBigInt(new MfInteger(0))
				this.m_bi := tmp.m_bi
				this.IsNegative := False
				return this._ReturnBigInt()
			}
			If (MfBigMathInt.Greater(this.m_bi, x.m_bi))
			{
				this.m_bi := MfBigMathInt.Sub(this.m_bi, x.m_bi)
			}
			else
			{
				this.m_bi := MfBigMathInt.Sub(x.m_bi,this.m_bi)
				this.IsNegative := true
			}

			return this._ReturnBigInt()
		}
		if (x.IsNegative = true && this.IsNegative = true)
		{
			If (MfBigMathInt.equals(this.m_bi, x.m_bi))
			{
				tmp := new MfBigInt(new MfInteger(0))
				this.m_bi := tmp.m_bi
				this.IsNegative := False
				return this._ReturnBigInt()
			}
			If (MfBigMathInt.Greater(this.m_bi, x.m_bi))
			{
				this.m_bi := MfBigMathInt.Sub(this.m_bi, x.m_bi)
			}
			else
			{
				this.m_bi := MfBigMathInt.Sub(x.m_bi,this.m_bi)
				this.IsNegative := false
			}

			return this._ReturnBigInt()
		}
		if (this.IsNegative != x.IsNegative)
		{
			If (MfBigMathInt.Greater(this.m_bi, x.m_bi))
			{
				this.m_bi := MfBigMathInt.Add(this.m_bi, x.m_bi)
				this.IsNegative := !x.IsNegative
			}
			else
			{
				this.m_bi := MfBigMathInt.Add(x.m_bi,this.m_bi)
				this.IsNegative := !x.IsNegative
			}
			return this._ReturnBigInt()
		}
		return this._ReturnBigInt()
	}
; End:Subtract ;}
;{ 	Clone
	Clone() {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		retval := new MfBigInt(new MfInteger(0))
		retval.m_bi := this.m_bi.Clone()
		retval.m_IsNegative := this.m_IsNegative
		return retval
	}
; 	End:Clone ;}
;{ 	Parse
	Parse(str, base="") {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfObject.IsObjInstance(str,  MfListVar))
		{
			retval := new MfBigInt(new MfInteger(0))
			retval.m_bi := str.Clone()
			retval.m_bi := MfBigMathInt.Trim(retval.m_bi, 1)
			return retval
		}
		_str := MfString.GetValue(str)
		strLst := MfListVar.FromString(_str, false) ; ignore whitespace
		ll := strLst.m_InnerList
		if (strLst.Count = 0)
		{
			return new MfBigInt(new MfInteger(0))
		}
		sign := false
		IsNeg := false
		i := 0
		if (strLst.Item[0] = "-")
		{
			i++
			sign := true
			IsNeg := true
		}
		if (strLst.Item[0] = "+")
		{
			sign := true
			i++
		}
		if (i >= strLst.Count)
		{
			return new MfBigInt(new MfInteger(0))
		}
		if (MfNull.IsNull(base))
		{
			base := -2
		}
		else
		{
			base := MfInt16.GetValue(base, -2)
		}
		if (base = -2)
		{
			cnt := (strLst.Count - (i + 2))
			if ((cnt >= 2) && strLst.Item[i] = "0")
			{
				c := strLst.Item[i + 1]
				if (c = "x")
				{
					base = 16
				}
				else if (c = "b")
				{
					base := 2
				}
				else
				{
					base = 8
				}
			}
			else
			{
				base := 10
			}
		}
		if (base = 8)
		{
			while (strLst.Item[i] = "0")
			{
				i++
			}
			len := 3 * ((strLst.Count + 1) - i)
		}
		else
		{
			if (base = 16 && strLst.Item[i] = "0" && strLst.Item[i+1] = "x")
			{
				i += 2
			}
			if (base = 2 && strLst.Item[i] = "0" && strLst.Item[i+1] = "b")
			{
				i += 2
			}
			If ((base = 2 ) && sign = false && (strLst.Item[i] = "1"))
			{
				bits := MfBinaryList.FromString(strLst.ToString("", i))
				c2bits := MfBinaryConverter.ToComplement2(bits)
				strLst.m_InnerList := c2Bits.m_InnerList
				ll := strLst.m_InnerList
				i := 0
				; only advance for sign if binary in not in the format of 1000000000000....
				j := i + 2 ; move to one base index
				While j <= strLst.Count
				{
					If (ll[j] = 1)
					{
						i++ ; advance for sign
						break
					}
					j++
				}
				IsNeg := true
			}
			
			while (ll[i + 1] = "0")
			{
				i++
			}
			if (i = strLst.Count)
			{
				i--
			}
			len := 4 * ((strLst.Count + 1) - i)
		}
		len := (len >> 4) + 1
		bigX := MfBigMathInt.Str2bigInt(strLst.ToString("", i), base, len, len)
		bigX := MfBigMathInt.Trim(bigX, 1)
		retval := new MfBigInt(new MfInteger(0))
		retval.m_bi := bigX
		retval.m_IsNegative := IsNeg
		return retval
	}
; 	End:Parse ;}
;{ 	ToString
	ToString(base=10) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		base := MfByte.GetValue(base, 10)
		if (base > 95)
		{
			; max base is 95 so revert to 10 if greater
			base := 10
		}
		s := ""
		if (this.m_IsNegative)
		{
			s := "-"
		}
		s .= MfBigMathInt.BigInt2str(this.m_bi, base)
		return s
	}
; 	End:ToString ;}
; 	End:Methods ;}
;{ 	Internal methods
;{ _ReturnUInt64
	_ReturnBigInt() {
		if (this.m_ReturnAsObject)
		{
			return this
		}
		return this.Value
	}
; End:_ReturnUInt64 ;}
	_IsZero() {
		return MfBigMathInt.IsZero(this.m_bi)
	}
	_IsOne(IgnoreSign=false) {
		If (IgnoreSign = false && this.IsNegative = true)
		{
			return false
		}
		return MfBigMathInt.Equals(this.m_bi, MfBigMathInt.one)
	}
	_IsNegOne() {
		If (this.IsNegative = true)
		{
			return this._IsOne(true)
		}
		return false
	}
	_ComplementTwo() {
		; x := this.m_bi.Clone()
		; x2 := MfBigMathInt.mult(x, x2)

		; xC := MfBigMathInt.sub(x, x2)
		; xC := MfBigMathInt.addInt(xC, -1)
		; retval := new MfBigInt(0)
		; retval.m_bi := xC
		; return retval

		
		hex := MfBigMathInt.bigInt2str(this.m_bi, 16)
		len := StrLen(hex)
		
		bitcount := (len & 1?len + 1:len) * 4
		nib := MfNibConverter._HexStringToNibList(hex, bitcount)
		nibFlip := MfNibConverter.ToComplement16(nib)
		hexFlipped := "0x" . nibFlip.ToString()
		retval := MfBigInt.Parse(hexFlipped)
		return retval
	}
;{ 	_FromAny
	; static method
	_FromAny(x) {
		if (IsObject(x))
		{
			if(MfObject.IsObjInstance(x, MfBigInt))
			{
				return x
			}

			else if (MfObject.IsObjInstance(x, MfListVar))
			{

				retval := new MfBigInt(new MfInteger(0))
				retval.m_bi := MfBigMathInt.Trim(x, 1)
				return retval
			}
			else if (MfObject.IsObjInstance(x, MfUInt64))
			{
				retval := new MfBigInt(x)
				return retval
			}
			else if (MfObject.IsObjInstance(x, MfObject))
			{
				x := MfBigInt.Parse(x)
			}
			else
			{
				return new MfBigInt(new MfInteger(0))
			}
		}
		num := MfInt64.GetValue(x,"NaN", true)
		if (num == "NaN")
		{
			return MfBigInt.Parse(x)
		}
		if((num >= -2147483647) && (num <= 2147483647))
		{
			return MfBigInt._fromInt(num)
		}
		num := format("{:i}", num)
		return MfBigInt.Parse(num)
	}
; 	End:_FromAny ;}
;{ 	_FromAnyConstructor
	; Internal Instance method used by constructor
	_FromAnyConstructor(x) {
		this._ClearCache()
		if (IsObject(x))
		{
			if(MfObject.IsObjInstance(x, MfBigInt))
			{
				this.m_bi := x.m_bi.Clone()
				this.m_bi := MfBigMathInt.Trim(this.m_bi, 1)
				this.m_IsNegative := x.IsNegative
			}
			else if (MfObject.IsObjInstance(x, MfListVar))
			{
				this.m_bi := x.Clone()
				this.m_bi := MfBigMathInt.Trim(this.m_bi, 1)
			}
			else if (MfObject.IsObjInstance(x, MfInteger))
			{
				; adding as MfInteger is necessary so methods like parse can create a new instance
				; of MfbigInt without going into a recursion loop using vars, as you can see below
				; unknow objects attempt to use parse to create a new instance
				varx := x.Value
				IsNeg := false
				if (varx < 0)
				{
					IsNeg := true
					varx := Abs(varx)
				}
				this.m_bi := MfBigMathInt.Str2bigInt(format("{:i}",varx), 10, 2, 2)
				this.m_bi := MfBigMathInt.Trim(this.m_bi, 1)
				this.m_IsNegative := IsNeg
			}
			else if (MfObject.IsObjInstance(x, MfUInt64))
			{
				xClone := x.m_bigx.Clone()
				this.m_bi := xClone.m_bi
				this.m_bi := MfBigMathInt.Trim(this.m_bi, 1)
				this.m_IsNegative := false
			}
			else if (MfObject.IsObjInstance(x, "StringBuilder"))
			{
				return this._FromAnyConstructor(x.ToString())
			}
			else if (MfObject.IsObjInstance(x, MfObject))
			{
				x := MfBigInt.Parse(x)
				this.m_bi := x.m_bi.Clone()
				this.m_IsNegative := x.IsNegative
			}
			else
			{
				this.m_bi := new MfListVar(3)
			}
			return
		}
		
		num := MfInt64.GetValue(x,"NaN", true)
		if (num == "NaN")
		{
			x := MfBigInt.Parse(x)
			this.m_bi := x.m_bi.Clone()
			this.m_IsNegative := x.IsNegative
			return
		}
		if (num = 0)
		{
			this.m_bi := new MfListVar(2)
			Return
		}
		if((num >= -2147483647) && (num <= 2147483647))
		{
			x := MfBigInt._fromInt(num)
			this.m_bi := x.m_bi.Clone()
			this.m_IsNegative := x.IsNegative
			return
		}
		num := format("{:i}", num)
		x := MfBigInt.Parse(num)
		this.m_bi := x.m_bi.Clone()
		this.m_IsNegative := x.IsNegative
		return
	}
; 	End:_FromAnyConstructor ;}
;{ 	_fromInt
	_fromInt(n) {
		retval := new MfBigInt(new MfInteger(0))
		if (n < 0)
		{
			retval.IsNegative := true
			n := -n
		}
		Else
		{
			retval.IsNegative := false
		}

		retval.m_bi := MfBigMathInt.Int2bigInt(n, 31, 4)
		retval.m_bi := MfBigMathInt.Trim(retval.m_bi, 1)
		return retval
	}
; 	End:_fromInt ;}
	_FromStringBase(str, base="") {
		if (MfString.IsNullOrEmpty(str))
		{
			this._fromInt(0)
			return
		}
		this.m_IsNegative := false
		strLst := MfListVar.FromString(str, false) ; ignore whitespace
		i := 0
		throw new MfNotImplementedException()
	}
;{ 	_VerifyReadOnly
	_VerifyReadOnly(args*) {
		; args: [ClassName, LineFile, LineNumber, Source]
		if (this.ReadOnly)
		{
			p := this._VerifyReadOnlyParams(args*)
			ClassName := this.__Class
			LineFile := A_LineFile
			LineNumber := A_LineNumber
			Source := A_ThisFunc

			mfgP := p.ToStringList()
			for i, str in mfgP
			{
				if (i = 0) ; classname
				{
					if (str.Value = "MfString")
					{
						ClassName := p.Item[i].Value
					}
					else if (str.Value != Undefined)
					{
						ClassName := MfType.TypeOfName(p.Item[i])
					}
					
				}
				else if ((i = 1) && (str.Value = "MfString")) ; LineFile
				{
					LineFile := p.Item[i].Value
				}
				else if ((i = 2) && (str.Value = "MfInteger")) ; LineNumber
				{
					LineNumber := p.Item[i].Value
				}
				else if (i = 3) ; source
				{
					if (str.Value = "MfString")
					{
						Source := p.Item[i].Value
					}
					else if (str.Value != Undefined)
					{
						Source := p.Item[i]
					}
				}
			}

			if (MfString.IsNullOrEmpty(ClassName))
			{
				msg := MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Instance")
			}
			Else
			{
				msg := MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Instance_Class", ClassName)
			}

			ex := new MfNotSupportedException(msg)
			ex.SetProp(LineFile, LineNumber, Source)
			throw ex
		}
		return true
	}
; 	End:_VerifyReadOnly ;}
;{ _VerifyReadOnlyParams
	_VerifyReadOnlyParams(args*) {
		; args: [MethodName, LineFile, LineNumber, Source]
		p := Null
		cnt := MfParams.GetArgCount(args*)
		if (MfObject.IsObjInstance(args[1], MfParams))
		{
			p := args[1] ; arg 1 is a MfParams object so we will use it
			if (p.Count > 4)
			{
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", A_ThisFunc))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		}
		else
		{
			p := new MfParams()
			p.AllowEmptyString := true ; allow empty strings to be compared
			p.AllowOnlyAhkObj := false
			p.AllowEmptyValue := true ; all empty/null params will be added as undefined
			
			if (cnt > 4)
			{
				e := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", A_ThisFunc))
				e.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
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
					} 
					else
					{
						if ((i = 3) && (MfNull.IsNull(arg) = false)) ; Integer A_LineNumber
						{
							p.AddInteger(arg)
						}
						else
						{
							pIndex := p.Add(arg)
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
		return p
	}
; End:_VerifyReadOnlyParams ;}
;{ _ErrorCheckParameter
/*
		Method: _ErrorCheckParameter(index, pArgs[, AllowUndefined = true])
			_ErrorCheckParameter() Chekes to see if the Item of pArgs at the given index is undefined or otherwise
		Parameters:
			index - The index with pArgs to use
			pArgs - The instance of MfParams that contains the Parameters
			AllowUndefined - If True then pArg Item at index can be undefined otherwse will an error will be thrown
		Returns:
			Returns MfArgumentException if item at index in pArgs does not pass set conditions. Otherwise False
		Remarks
			This method is intended to be use internally only and accessed in derived classes such as MfString,
			MfByte, MfInteger, MfInt64, MfChar
*/
	_ErrorCheckParameter(index, pArgs, AllowUndefined = true) {
		ThrowErr := False
		if((!IsObject(pArgs.Item[index]))
			&& (pArgs.Item[index] = Undefined))
		{
			if (AllowUndefined = true)
			{
				return ThrowErr
			}
			ThrowErr := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Error_on_nth", (index + 1)))
			ThrowErr.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			return ThrowErr
		}
		
		ThrowErr := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Error_on_nth", (index + 1)))
		ThrowErr.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		return ThrowErr
	}
; End:_ErrorCheckParameter ;}
; 	End:Internal methods ;}
;{ Properties
	;{ BitSize
		m_BitSize := ""
		/*!
			Property: BitSize [get]
				Gets the BitSize value associated with the this instance
			Value:
				Var representing the BitSize property of the instance
			Remarks:
				Readonly Property
		*/
		BitSize[]
		{
			get {
				if (this.m_BitSize = "")
				{
					this.m_BitSize := MfBigMathInt.BitSize(this.m_bi)
				}
				return this.m_BitSize
			}
			set {
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
				ex.SetProp(A_LineFile, A_LineNumber, "BitSize")
				Throw ex
			}
		}
	; End:BitSize ;}
;{ InnerList
	/*!
		Property: InnerList [get]
			Gets the InnerList value associated with the this instance
		Value:
			Var representing the InnerList property of the instance
		Remarks:
			Readonly Property
	*/
	InnerList[]
	{
		get {
			return this.m_bi
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, "InnerList")
			Throw ex
		}
	}
; End:InnerList ;}
;{ IsNegative
	m_IsNegative := false
	/*!
		Property: IsNegative [get/set]
			Gets or sets the IsNegative value associated with the this instance
		Value:
			Var representing the IsNegative property of the instance
	*/
	IsNegative[]
	{
		get {
			return this.m_IsNegative
		}
		set {
			this.m_IsNegative := MfBool.GetValue(value, false)
			this._ClearCache()
			return this.m_IsNegative
		}
	}
; End:IsNegative ;}
;{	ReadOnly
	m_ReadOnly := false
/*
	Property: Readonly [get]
		Gets the if the derived class will allow the underlying value to be altered after the constructor has been called.
	Value:
		Boolean representing true or false.
	Gets:
		Gets a boolean value indicating if the derived class will allow the underlying value to be altered after the constructor has been called.
	Remarks:
		Read-only property
		Default value is false. This property only be set in the constructor of the derive class.
*/
	ReadOnly[]
	{
		get {
			return this.m_ReadOnly
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
;	End:ReadOnly ;}
;{ ReturnAsObject
	m_ReturnAsObject := false
	/*!
		Property: ReturnAsObject [get/set]
			Gets or sets the ReturnAsObject value associated with the this instance
		Value:
			Var representing the ReturnAsObject property of the instance
	*/
	ReturnAsObject[]
	{
		get {
			return this.m_ReturnAsObject
		}
		set {
			this.m_ReturnAsObject := MfBool.GetValue(value)
			return this.m_ReturnAsObject
		}
	}
; End:ReturnAsObject ;}
	strValue := ""
;{ Value
	/*!
		Property: Value [get/set]
			Gets or sets the Value value associated with the this instance
		Value:
			Var representing the Value property of the instance
	*/
	Value[]
	{
		get {
			if (this.strValue = "")
			{
				this.strValue := this.ToString()
			}
			return this.strValue
		}
		set {
			this._FromAnyConstructor(value)
		}
	}
; End:Value ;}
; End:Properties ;}
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
}