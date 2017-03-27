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
	__new(value) {
		if (this.__Class != "MfBigInt")
		{
			throw new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Sealed_Class","MfInt64"))
		}
		base.__new()
		this._FromAnyConstructor(value)
		
	}
;{ 	Methods
	Add(Value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		this._VerifyReadOnly(this, A_LineFile, A_LineNumber, A_ThisFunc)

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
		if (x.IsNegative = false && this.IsNegative = false)
		{
			this.m_bi := MfBigIntHelper.add(this.m_bi, x.m_bi)
			return this
		}
		if (x.IsNegative = true && this.IsNegative = true)
		{
			this.m_bi := MfBigIntHelper.add(this.m_bi, x.m_bi)
			return this
		}
		if (this.IsNegative != x.IsNegative)
		{
			If (MfBigIntHelper.equals(this.m_bi, x.m_bi))
			{
				tmp := new MfBigInt(0)
				this.m_bi := tmp.m_bi
				this.IsNegative := False
				return this
			}
			If (MfBigIntHelper.greater(this.m_bi, x.m_bi))
			{
				this.m_bi := MfBigIntHelper.sub(this.m_bi, x.m_bi)
				this.IsNegative := !x.IsNegative
			}
			else
			{
				this.m_bi := MfBigIntHelper.sub(x.m_bi,this.m_bi)
				this.IsNegative := !this.IsNegative
			}
			return this
		}

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
	; retruns remainder as base 10
	Divide(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		this._VerifyReadOnly(this, A_LineFile, A_LineNumber, A_ThisFunc)

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
		if (MfBigIntHelper.isZero(x.m_bi))
		{
			ex := new MfDivideByZeroException()
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		;q and r must be arrays that are exactly the same Count as x. (Or q can have more).
		q := new MfBigIntHelper.DList(this.m_bi.Count)
		r := new MfBigIntHelper.DList(q.Count)

		; divide_(ByRef x, ByRef y, ByRef q, ByRef r)
		MfBigIntHelper.divide_(this.m_bi, x.m_bi, q, r)
		q := MfBigIntHelper.trim(q, 1)
		this.m_bi := q
		if (this.IsNegative || x.IsNegative)
		{
			this.IsNegative := true
		}
		else
		{
			this.IsNegative := false
		}
		if (this.IsNegative && MfBigIntHelper.isZero(this.m_bi))
		{
			this.IsNegative := false
		}
		MfBigIntHelper.bigInt2str(r, 10)
	}
; 	End:Divide ;}
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
		return MfBigIntHelper.equals(this.m_bi, x.m_bi)
	}
; 	End:Equals ;}
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
		if (MfBigIntHelper.equals(this.m_bi, x.m_bi))
		{
			; MfBigIntHelper.greater returns true if they are equal
			return false
		}
		if (this.IsNegative = true && x.IsNegative = true)
		{
			return MfBigIntHelper.greater(x.m_bi, this.m_bi)
		}
		return MfBigIntHelper.greater(this.m_bi, x.m_bi)

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
		if (MfBigIntHelper.equals(this.m_bi, x.m_bi))
		{
			return true
		}
		if (this.IsNegative = true && x.IsNegative = true)
		{
			return MfBigIntHelper.greater(x.m_bi, this.m_bi)
		}
		return MfBigIntHelper.greater(this.m_bi, x.m_bi)
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
		if (MfBigIntHelper.equals(this.m_bi, x.m_bi))
		{
			; MfBigIntHelper.greater returns true if they are equal
			return false
		}
		if (this.IsNegative = true && x.IsNegative = true)
		{
			return MfBigIntHelper.greater(this.m_bi, x.m_bi)
		}
		return MfBigIntHelper.greater(x.m_bi, this.m_bi)

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
		if (MfBigIntHelper.equals(this.m_bi, x.m_bi))
		{
			return true
		}
		if (this.IsNegative = true && x.IsNegative = true)
		{
			return MfBigIntHelper.greater(this.m_bi, x.m_bi)
		}
		return MfBigIntHelper.greater(x.m_bi, this.m_bi)

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
		if ((x.IsNegative = false && this.IsNegative = false)
			|| (x.IsNegative = true && this.IsNegative = true))
		{
			If (MfBigIntHelper.greater(this.m_bi, x.m_bi))
			{
				bigx := MfBigIntHelper.mult(this.m_bi, x.m_bi)
			}
			Else
			{
				bigx := MfBigIntHelper.mult(x.m_bi, this.m_bi)
			}
			this.m_bi := bigx
			this.IsNegative := False
			return this
		}
		If (MfBigIntHelper.greater(this.m_bi, x.m_bi))
		{
			bigx := MfBigIntHelper.mult(this.m_bi, x.m_bi)
		}
		Else
		{
			bigx := MfBigIntHelper.mult(x.m_bi, this.m_bi)
		}
		this.m_bi := bigx
		this.IsNegative := true
		return this
	}
; 	End:Multiply ;}
;{ 	Power
	; Raise Value to the power of
	Power(value, byRef R) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		this._VerifyReadOnly(this, A_LineFile, A_LineNumber, A_ThisFunc)


		throw new MfNotImplementedException()


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
		bigR := new MfBigIntHelper.DList(this.m_bi.Count)
		result := MfBigIntHelper.powMod(this.m_bi, x.m_bi, bigR)
		bigR := MfBigIntHelper.trim(bigR, 1)
		result :=  MfBigIntHelper.trim(result, 1)
		this.m_bi := result
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
			If (MfBigIntHelper.equals(this.m_bi, x.m_bi))
			{
				tmp := new MfBigInt(0)
				this.m_bi := tmp.m_bi
				this.IsNegative := False
				return this
			}
			If (MfBigIntHelper.greater(this.m_bi, x.m_bi))
			{
				this.m_bi := MfBigIntHelper.sub(this.m_bi, x.m_bi)
			}
			else
			{
				this.m_bi := MfBigIntHelper.sub(x.m_bi,this.m_bi)
				this.IsNegative := true
			}

			return this
		}
		if (x.IsNegative = true && this.IsNegative = true)
		{
			If (MfBigIntHelper.equals(this.m_bi, x.m_bi))
			{
				tmp := new MfBigInt(0)
				this.m_bi := tmp.m_bi
				this.IsNegative := False
				return
			}
			If (MfBigIntHelper.greater(this.m_bi, x.m_bi))
			{
				this.m_bi := MfBigIntHelper.sub(this.m_bi, x.m_bi)
			}
			else
			{
				this.m_bi := MfBigIntHelper.sub(x.m_bi,this.m_bi)
				this.IsNegative := false
			}

			return this
		}
		if (this.IsNegative != x.IsNegative)
		{
			If (MfBigIntHelper.greater(this.m_bi, x.m_bi))
			{
				this.m_bi := MfBigIntHelper.add(this.m_bi, x.m_bi)
				this.IsNegative := !x.IsNegative
			}
			else
			{
				this.m_bi := MfBigIntHelper.add(x.m_bi,this.m_bi)
				this.IsNegative := !x.IsNegative
			}
			return this
		}
	}
; End:Subtract ;}
;{ 	Clone
	Clone() {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		retval := new MfBigInt(0)
		retval.m_bi := this.m_bi.Clone()
		retval.m_IsNegative := this.m_IsNegative
		return retval
	}
; 	End:Clone ;}
;{ 	Parse
	Parse(str, base="") {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfObject.IsObjInstance(str,  MfBigIntHelper.DList))
		{
			retval := new MfBigInt(0)
			retval.m_bi := str.Clone()
			return retval
		}
		_str := MfString.GetValue(str)
		strLst := MfBigIntHelper.DList.FromString(_str, false) ; ignore whitespace
		
		if (strLst.Count = 0)
		{
			return new MfBigInt(0)
		}
		sign := true
		i := 0
		if (strLst.Item[0] = "-")
		{
			i++
			sign := false
		}
		if (strLst.Item[0] = "+")
		{
			i++
		}
		if (i >= strLst.Count)
		{
			return new MfBigInt(0)
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
			while (strLst.Item[i] = "0")
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
		bigX := MfBigIntHelper.str2bigInt(strLst.ToString("", i), base, len, len)
		bigX := MfBigIntHelper.trim(bigX, 1)
		retval := new MfBigInt(0)
		retval.m_bi := bigX
		retval.m_IsNegative := !sign
		return retval
	}
; 	End:Parse ;}
;{ 	ToString
	ToString(base=10) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		s := ""
		if (this.m_IsNegative)
		{
			s := "-"
		}
		s .= MfBigIntHelper.bigInt2str(this.m_bi, base)
		return s
	}
; 	End:ToString ;}
; 	End:Methods ;}
;{ 	Internal methods
	_ComplementTwo() {
		; x := this.m_bi.Clone()
		; x2 := MfBigIntHelper.mult(x, x2)

		; xC := MfBigIntHelper.sub(x, x2)
		; xC := MfBigIntHelper.addInt(xC, -1)
		; retval := new MfBigInt(0)
		; retval.m_bi := xC
		; return retval

		
		hex := MfBigIntHelper.bigInt2str(this.m_bi, 16)
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
			else if (MfObject.IsObjInstance(x, MfBigIntHelper.DList))
			{
				retval := new MfBigInt(0)
				retval.m_bi := x.Clone()
				return retval
			}
			else if (MfObject.IsObjInstance(x, MfObject))
			{
				x := MfBigInt.Parse(x)
			}
			else
			{
				return new MfBigInt(0)
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
		wf := Mfunc.SetFormat(MfSetFormatNumberType.Instance.IntegerFast, "D")
		try
		{
			num := num . ""
			return MfBigInt.Parse(num)
		}
		catch e
		{
			throw e
		}
		finally
		{
			Mfunc.SetFormat(MfSetFormatNumberType.Instance.IntegerFast, wf)
		}
		return new MfBigInt(0)
	}
; 	End:_FromAny ;}
;{ 	_FromAnyConstructor
	; Internal Instance method used by constructor
	_FromAnyConstructor(x) {
		if (IsObject(x))
		{
			if(MfObject.IsObjInstance(x, MfBigInt))
			{
				this.m_bi := x.m_bi.Clone()
				this.m_IsNegative := x.IsNegative
			}
			else if (MfObject.IsObjInstance(x, MfBigIntHelper.DList))
			{
				this.m_bi := x.Clone()
			}
			else if (MfObject.IsObjInstance(x, MfObject))
			{
				x := MfBigInt.Parse(x)
				this.m_bi := x.m_bi.Clone()
				this.m_IsNegative := x.IsNegative
			}
			else
			{
				this.m_bi := new MfBigIntHelper.DList(3)
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
			this.m_bi := new MfBigIntHelper.DList(3)
			Return
		}
		if((num >= -2147483647) && (num <= 2147483647))
		{
			x := MfBigInt._fromInt(num)
			this.m_bi := x.m_bi.Clone()
			this.m_IsNegative := x.IsNegative
			return
		}
		wf := Mfunc.SetFormat(MfSetFormatNumberType.Instance.IntegerFast, "D")
		try
		{
			num := num . ""
			x := MfBigInt.Parse(num)
			this.m_bi := x.m_bi.Clone()
			this.m_IsNegative := x.IsNegative
			return

		}
		catch e
		{
			throw e
		}
		finally
		{
			Mfunc.SetFormat(MfSetFormatNumberType.Instance.IntegerFast, wf)
		}
		this.m_bi := new MfBigIntHelper.DList(3)
		Return
	}
; 	End:_FromAnyConstructor ;}
;{ 	_fromInt
	_fromInt(n) {
		retval := new MfBigInt(0)
		if (n < 0)
		{
			retval.IsNegative := true
			n := -n
		}
		Else
		{
			retval.IsNegative := false
		}

		retval.m_bi := MfBigIntHelper.int2bigInt(n, 31, 4)
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
		strLst := MfBigIntHelper.DList.FromString(str, false) ; ignore whitespace
		i := 0

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
			return this.Tostring()
		}
		set {
			this._FromAnyConstructor(value)
		}
	}
; End:Value ;}
; End:Properties ;}
}