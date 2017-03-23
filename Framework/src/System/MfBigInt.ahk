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
class MfBigInt extends MfObject
{

;{ 	Constructor
	__new(args*) {
		base.__new()
		; params: len, sign or instance of MfBigInt
		cnt := MfParams.GetArgCount(args*)
		if (cnt > 2)
		{
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", A_ThisFunc))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		i := 0
		x := ""
		need_init := false
		if (cnt = 0)
		{
			this.m_Sign := true
			this.m_Length := 1
			this.m_Digits := new MfList()
			need_init := true
		}
		else if (cnt = 1)
		{
			obj := args[1]
			if (MfObject.IsObjInstance(obj, MfBigInt))
			{
				x := obj.Clone()
			}
			else
			{
				x := MfBigInt.bigint_from_any(args[1])
			}
			this.m_Sign := x.Sign
			this.m_Length := x.Length
			this.m_Digits := x.m_Digits
			need_init := false
		}
		else
		{
			this.m_Length := MfInteger.GetValue(args[1], 1)
			this.m_Sign := MfBool.MfBool.GetValue(args[2], true)
			this.m_Digits := new MfList()
			need_init := true
		}
		if (need_init)
		{
			i := 0
			while i < this.m_Length
			{
				this.m_Digits.Add(0)
				i++
			}
		}
	}
; 	End:Constructor ;}
;{ Clone
	Clone() {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		x := new BigInt(this.Length, this.Sign)
		i := 0
		while (i < this.Length)
		{
			x.Digits[i] := this.Digits[i]
			i++
		}
		return x
	}
; End:Clone ;}
;{ 	FromAny
	FromAny(x) {
		if (IsObject(x))
		{
			if(MfObject.IsObjInstance(x, MfBigInt))
			{
				return x
			}
			else if (MfObject.IsObjInstance(x, MfObject))
			{
				x := x.ToString()
			}
			else
			{
				return new MfBigInt(1, true)
			}
		}
		num := MfInt64.GetValue(x,"NaN", true)
		if (num == "NaN")
		{
			return MfBigInt._FromStringBase(num)
		}
		if((-2147483647 <= num) && (num <= 2147483647))
		{
			return MfBigInt._fromInt(num)
		}
		wf := Mfunc.SetFormat(MfSetFormatNumberType.Instance.IntegerFast, "D")
		try
		{
			num := num . ""
			return MfBigInt._FromStringBase(num)
		}
		catch e
		{
			throw e
		}
		finally
		{
			Mfunc.SetFormat(MfSetFormatNumberType.Instance.IntegerFast, wf)
		}
		return new MfBigInt(1, true)

	}
; 	End:FromAny ;}
;{ 	Add
	Add(x, y) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		x := MfBigInt.FromAny(x)
		y := MfBigInt.FromAny(y)
		return MfBigInt._add(x, y, true)
	}
; 	End:Add ;}
	Compare(x, y) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfNull.IsNull(y))
		{
			return 1
		}
		if (MfNull.IsNull(x))
		{
			return -1
		}
		if (MfObject.IsObjInstance(y, MfBigInt) = false)
		{
			return 1
		}
		if (MfObject.IsObjInstance(x, MfBigInt) = false)
		{
			return -1
		}
		if (MfObject.ReferenceEquals(x, y))
		{
			return 0
		}
		xlen := x.Length
		if (x.Sign != y.Sign)
		{
			if (x.Sign)
			{
				return 1
			}
			return -1
		}
		if (xLen < y.Length)
		{
			return (x.Sign) ? -1 : 1
		}
		if (xlen > y.Length)
		{
			return (x.Sign) ? 1 : -1
		}
		xlen--
		while(xlen >= 0 && (x.Digits[xlen] = y.Digits[xlen]))
		{
			xlen--
		}
		if (xlen = -1)
		{
			return 0
		}
		if (x.Digits[xlen] > y.Digits[xlen])
		{
			return (x.sign ? 1 : -1)
		}
		return (x.sign ? -1 : 1)
	}
;{ 	Divide
	Divide(x, y) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		x := MfBigInt.FromAny(x)
		y := MfBigInt.FromAny(y)
		return MfBigInt._Divide(x, y, false)
	}
; 	End:Divide ;}
;{ 	Mod
	Mod(x, y) {
		x := MfBigInt.FromAny(x)
		y := MfBigInt.FromAny(y)
		return MfBigInt._Divide(x, y, true)
	}
; 	End:Mod ;}
;{ 	Multiply
	Multiply(x, y) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		i := 0
		j := 0
		z := ""

		x := MfBigInt.FromAny(x)
		y := MfBigInt.FromAny(y)

		j := x.Length + y.Length + 1
		z := new MfBigInt(j, x.Sign = y.Sign)
		yLen := y.Length

		while (z.Count < j)
		{
			z.m_Digits.Add(0)
		}

		i := 0
		While (i < x.Length)
		{
			dd := x.Digits[i]
			if (dd = 0)
			{
				i++
				Continue
			}
			n := 0
			j := 0
			while (j < ylen)
			{
				ee := n + y.Digits[j]
				n := z.Digits[i + j] + ee
				if (ee > 0)
				{
					z.Digits[i + j] := (n & 0xffff)
				}
				n := MfBigInt._ShiftRightUnsigned(n, 16)
				;n >>= 16
				j++
			}
			if (n > 0)
			{
				z.Digits[i + j] := n
			}
			i++
		}
		MfBigInt._norm(z)
		return z
	}
; 	End:Multiply ;}
;{ 	Subtract
	Subtract(x, y) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		x := MfBigInt.FromAny(x)
		y := MfBigInt.FromAny(y)
		return MfBigInt._subtract(x, y, false)
	}
; 	End:Subtract ;}
	ToString(base=10) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		base := MfInteger.GetValue(base, 10)
		Return this._ToStringBase(10)
	}
;{ Methods

; End:Methods ;}
;{ Internal Methods
;{ 	_add
	_add(x, y, sign) {
		num := 0
		len := 0
		sign := (sign = y.Sign)
		if (x.sign != sign)
		{
			if (sign)
			{
				return MfBigInt._subInternal(y, x)
			}
			return MfBigInt._subInternal(x, y)
		}
		if (x.Length > y.Length)
		{
			len := x.Length + 1
			z := x
			x := y
			y := z
		}
		else
		{
			len := y.Length + 1
		}
		z := new MfBigInt(len, sign)

		len := x.Length
		i := 0
		num := 0
		while (i < len)
		{
			num += x.Digits[i] + y.Digits[i]
			z.Digits[i] := (num & 0xfff)
			num := MfBigInt._ShiftRightUnsigned(num, 16)
			;num >>= 16
			i++
		}
		len := y.Length
		while (num != 0 && i < len)
		{
			num += y.Digits[i]
			z.Digits[i] := (num & 0xffff)
			Num := MfBigInt._ShiftRightUnsigned(num, 16)
			;num >>= 16
			i++
		}
		while (i < len)
		{
			z.Digits[i] := y.Digits[i]
			i++
		}
		z.Digits[i] := (num & 0xffff)
		MfBigInt._norm(z)
		return z
	}
; 	End:_add ;}
;{ 	_Divide
	_Divide(x, y, modulo=false) {
		modulo := MfBool.GetValue(modulo, false)
		nx := x.Length
		ny := y.Length
		if ((ny = 0) && (y.Digits[0] = 0))
		{
			if(modulo)
			{
				MfBigInt._norm(x)
				return x
			}
			return new MfBigInt(1, true)
		}
		if (ny = 1)
		{
			dd := y.Digits[0]
			z := z.Clone()
			t2 := 0
			i := nx
			while (i > 0)
			{
				t2 := t2 * 65536 + z.Digits[i]
				z.Digtis[i] := (t2 / dd) & 0xffff
				t2 := Mod(t2, dd)
				i--
			}
			z.Sign := (x.Sign = y.Sign)
			if (modulo)
			{
				if (x.Sign = false)
				{
					t2 = -t2
				}
				if (x.Sign != y.Sign)
				{
					t2 := t2 + y.Digits[0] * (y.Sign ? 1 : -1)
				}
				return MfBigInt._fromInt(t2)
			}
			MfBigInt._norm(z)
			return z
		}
		z := new MfBitInt(nx = ny ? nx + 2 : nx + 1, x.Sign = y.Sign)
		if (nx = ny)
		{
			z.Digits[nx + 1] := 0
		}
		While (y.Digits[ny - 1] = 0)
		{
			ny--
		}
		if ((dd = ((65536 / (y.Digits[ny-1]+1)) & 0xffff)) != 1)
		{
			yy := y.Clone()
			j := 0
			num := 0
			while (j < ny)
			{
				num += y.Digits[j] * dd
				yy.Digits[j] :=  num & 0xffff
				num >>= 16
				j++
			}
			j := 0
			num := 0
			y.m_Digits := yy.m_Digits
			j := 0
			num := 0
			while (j < nx)
			{
				num += x.Digits[j] * dd
				z.Digits[j] := num & 0xffff
				num >>= 16
				j++
			}
			z.Digits[j] := num & 0xffff
		}
		else
		{
			z.Digits[0] := 0
			j := nx
			j--
			while (j >= 0)
			{
				z.Digits[j] := x.Digits[j]
				j--
			}
		}
		j := nx = ny?nx+1:nx
		while (j >= ny)
		{
			if (z.Digits[j] = y.Digits[ny - 1])
			{
				q = 65535
			}
			else
			{
				q = ((z.Digits[j] * 65536 + z.Digits[j-1]) / y.Digits[ny - 1]) & 0xffff
			}
			if (q != 0)
			{
				i := 0
				num := 0
				t2 := 0
				while (i < ny)
				{
					t2 += y.Digits[i] * q
					ee := num - (t2 & 0xffff)
					num := z.Digits[j - ny + i] + ee
					if (ee != 0)
					{
						z.Digits[j - ny + i] := num & 0xffff
					}
					num >>= 16
					t2 := MfBigInt._ShiftRightUnsigned(t2, 16)
					;t2 >>= 16
					i++
				}
				num += z.Digits[j - ny + i] - t2 ;  borrow from high digit; don't update
				while (num != 0)
				{
					; "add back" required
					i := 0
					num := 0
					q--
					while (i < ny)
					{
						ee := num + y.Digits[i]
						num := z.Digits[j - ny + i] + ee
						if (ee != 0)
						{
							z.Digits[j - ny + i] := num & 0xffff
						}
						num >>= 16
						i++
					}
					num--
				}
			}
			z.Digits[j] := q
			j--
		}
		if (modulo)
		{
			; just normalize remainder
			mod := z.clone()
			if (dd)
			{
				t2 := 0
				i := ny
				i--
				while (i >= 0)
				{
					t2 := (t2 * 65536) + mod.Digits[i]
					mod.Digits[i] := (t2 / dd) & 0xffff
					t2 := Mod(t2, dd)
					i--
				}
			}
			mod.Length := ny
			mod.Sign := x.Sign
			if (x.Sign != y.Sign)
			{
				return MfBigInt._add(mod, y, true)
			}
			MfBigInt._norm(mod)
			return mod
		}
		div := z.Clone()
		j := (nx = ny ? nx + 2: nx+1) - ny
		i := 0
		while (i < j)
		{
			div.Digits[i] := div.Digits[i + ny]
			i++
		}
		div.Length := i
		MfBigInt._norm(div)
		return div
	}
; 	End:_Divide ;}
;{ 	_subtract
	_subtract(x, y) {
		z := 0
		i := 0
		num := 0
		zds := ""
		i := x.Length
		if (x.Length < y.Length)
		{
			; swap x and y
			z := x
			x := y
			y := z
		}
		else if (x.Length = y.Length)
		{
			while (i > 0)
			{
				i--
				if (x.Digits[i] > y.Digits[i])
				{
					break
				}
				if (x.Digits[i] < y.Digits[i])
				{
					z := x
					x := y
					y := z
					break
				}
			}
		}

		z := new MfBigInt(x.Length, (z = 0) ? true : false)
		
		i := 0
		num := 0
		while (i < y.Length)
		{
			num += x.Digits[i] - y.Digits[i]
			z.Digits[i] := (num & 0xffff)
			num := MfBigInt._ShiftRightUnsigned(num, 16)
			;num >>= 16
			i++
		}
		while ((num != 0) && (i < x.Length))
		{
			num += x.Digits[i]
			z.Digits := (num & 0xffff)
			num := MfBigInt._ShiftRightUnsigned(num, 16)
			;num >>= 16
		}

		while (i < x.Length)
		{
			z.Digits[i] := x.Digits[i]
			i++
		}
		MfBigInt._norm(z)
		return
	}
; 	End:_subtract ;}
;{ 	_norm
	_norm(byRef x){
		len := x.Length

		while (x.Digits[len - 1] = 0)
		{
			len--
		}
		len++
		x.m_Length := len
	}
; 	End:_norm ;}
;{ 	_from_int
	_fromInt(n) {
		sign := False
		big := ""
		i := 0

		if(n < 0)
		{
			n := -n
			sign := false
		} 
		else
		{
			sign := true
		}

		n &= 0x7fffffff

		if(n <= 0xffff)
		{
			big := new MfBigInt(1, 1)
			big.Digits[0] := n
		}
		else
		{
			big := new MfBigInt(2, 1)
			big.Digits[0] := (n & 0xffff)
			big.Digits[1] := ((n >> 16) & 0xffff)
		}
		return big
	}
; 	End:_from_int ;}
;{ 	_FromStringBase
	_FromStringBase(str, base="") {
		if (MfString.IsNullOrEmpty(str))
		{
			return "0"
		}
		sign := true
		strLst := new MfList()
		c := ""
		len := 0
		blen := 1
		num := 0
		i := 0
		Loop, Parse, str
		{
			strLst.Add(A_LoopField)
		}
		
		if (strLst.Item[i] = "+")
		{
			i++
		}
		else if (strLst.Item[i] = "-")
		{
			i++
			sign := false
		}
		if (i >= strLst.Count)
		{
			return "0"
		}
		if (base = "")
		{
			if (strLst.Item[i] = "0")
			{
				c := strLst.Item[i + 1]
				if (c = "x")
				{
					base := 16
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
		z := new MfBigInt(len, sign)

		
		loop
		{
			if (i >= strLst.Count)
			{
				break
			}
			c := strLst.Item[i]
			i++
			if (c = "0")
			{
				c := 0
			}
			else if (c = "1")
			{
				c := 1
			}
			else if (c = "2")
			{
				c := 2
			}
			else if (c = "3")
			{
				c := 3
			}
			else if (c = "4")
			{
				c := 4
			}
			else if (c = "5")
			{
				c := 5
			}
			else if (c = "6")
			{
				c := 6
			}
			else if (c = "7")
			{
				c := 7
			}
			else if (c = "8")
			{
				c := 8
			}
			else if (c = "9")
			{
				c := 9
			}
			else if (c = "a")
			{
				c := 10
			}
			else if (c = "b")
			{
				c := 11
			}
			else if (c = "c")
			{
				c := 12
			}
			else if (c = "d")
			{
				c := 13
			}
			else if (c = "e")
			{
				c := 14
			}
			else if (c = "f")
			{
				c := 15
			}
			else
			{
				c := base
			}
			if (c >= base)
			{
				break
			}
			j := 0
			num := c
			loop
			{
				while (j < blen)
				{
					num += z.Digits[j] * base
					z.Digits[j] := (num & 0xffff)
					num := MfBigInt._ShiftRightUnsigned(num, 16)
					;num >>= 16
					j++
				}
				if (num)
				{
					blen++
					continue
				}
				break
			}
		}
		MfBigInt._norm(z)
		return z
	}
;{ _FromStringBase


	_ToStringBase(base) {
		i := this.Length
		x := i - 1
		
		j := 0
		hBase := 0
		t := ""
		ds := ""
		c := ""
		if (i = 0)
		{
			return "0"
		}
		if (i = 1 && this.Digits[0] = 0)
		{
			return "0"
		}
		if (base = 16)
		{
			j := Floor((2 * 8 * i) / 4) + 2
        	hbase = 0x10000
		}
		else if (base = 8)
		{
			j = (2 * 8 * i) + 2
        	hbase = 010000
		}
		else if (base = 8)
		{
			j = (2 * 8 * i) + 2
			hbase = 010000
		}
		else if (base = 2)
		{
			j = (2 * 8 * i) + 2
			hbase = 020
		}
		else
		{
			j := Floor((2 * 8 * i * 241) / 800) + 2
			hbase = 10000
		}
		t := this.Clone()
		s := ""
		while (i && j)
		{
			k := i - 1
			num := 0
			k--
			While (k >= 0)
			{
				num := (num << 16) + t.Digits[k]
				If (num < 0)
				{
					num += 4294967296
				}
				tmp := num // hbase
				t.Digits[k] := tmp
				num := Mod(num, hbase)
				k--
			}

			if (t.Digits[i-1] = 0)
			{
				i--
			}
			k := 3
			while (k >= 0)
			{
				c := Mod(num, base)
				chrValue := MfNibConverter._GetHexValue(c)
				s := chrValue . s
				j--
				num := num // base
				if ( i = 0 && num = 0)
				{
					break
				}
				k--
			}
		}
		MfBigInt._RemoveLeadingZeros(s)
		if (sign)
		{
			s := "-" . s
		}
		return s

	}
;{ _GetHexValue
	_GetHexValue(i)	{
		iChar := 0
		if (i < 10)
		{
			iChar := i + 48
		}
		else
		{
			iChar := (i - 10) + 65
		}
		return Chr(iChar)
	}
; End:_GetHexValue ;}
;{ 	_RemoveLeadingZeros
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
; 	End:_RemoveLeadingZeros ;}
	_uminus(x) {
		z := x.Clone()
		z.Sign := !z.Sign
		MfBigInt._norm(z)
		return z
	}
;{ 	_ShiftRightUnsigned
	; shifts value by shiftCount to the right as unsigned
	; in javascript this would be >>> (Zero-fill right shift)
	_ShiftRightUnsigned(value, shiftCount) {
		int := new MfInteger(value)
		bits := MfBinaryConverter.GetBits(int)
		ShiftedBits := MfBinaryConverter.ShiftRightUnsigned(bits, shiftCount)
		return MfBinaryConverter.ToInt32(ShiftedBits)
	}
; 	End:_ShiftRightUnsigned ;}
; End:Internal Methods ;}
;{ Properties
;{ Digits
		m_Digits := ""
	/*!
		Property: Digits [get]
			Gets the Digits value associated with the this instance
		Value:
			Var representing the Digits property of the instance
		Remarks:
			Readonly Property
	*/
	Digits[index]
	{
		get {
			_index := MfInteger.GetValue(index)
			return this.m_Digits.Item[_index]
		}
		set {
			_index := MfInteger.GetValue(index)
			_value := MfInteger.GetValue(value)
			this.m_Digits.Item[_index] := _value
		}
	}
; End:Digits ;}
;{ Sign
	m_Sign := true
	/*!
		Property: Sign [get/set]
			Gets or sets the Sign value associated with the this instance
		Value:
			Var representing the Sign property of the instance
	*/
	Sign[]
	{
		get {
			return this.m_Sign
		}
		set {
			this.m_Sign := MfBool.GetValue(value)
			return this.m_Sign
		}
	}
; End:Sign ;}
;{ Length
	m_Length := 0
	/*!
		Property: Length [get/set]
			Gets or sets the Length value associated with the this instance
		Value:
			Var representing the Length property of the instance
	*/
	Length[]
	{
		get {
			return this.m_Length
		}
		set {
			this.m_Length := MfInteger.GetValue(value)
			return this.m_Length
		}
	}
; End:Length ;}
; End:Properties ;}
}