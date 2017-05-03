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
class MfNumber extends MfObject
{
;{ 	MfNumber.NumberBuffer Class
	class NumberBuffer
	{
		static NumberBufferBytes := 12 + ((MfNumber.NumberMaxDigits + 1) * A_IsUnicode ? 2 : 1) + A_PtrSize
		digits := "" ; instance of MfMemoryString
		precision := 0
		scale := 0
		sign := false
		baseAddress := ""

		__new(BufferLen) {
			; stackBuffer is the memory addres to array of bytes created via VarSetCapacity
			BytesPerChar := A_IsUnicode ? 2 : 1
			
			
			BufferLen := BufferLen * BytesPerChar
			this.digits := new MfMemoryString(BufferLen)
			this.baseAddress := this.digits.BufferPtr
			this.precision := 0
			this.scale := 0
			this.sign := false
		}
		
	}
; 	End:MfNumber.NumberBuffer Class ;}

	static Int32Precision := 10
	static Int64Precision := 19
	static NumberMaxDigits := 50
	static UInt32Precision := 10
	static UInt64Precision := 20

	IsWhite(ch) {
		return ch = 32 || (ch >= 9 && ch <= 13)
	}
;{ 	MatchChars
	; returns index of mached char +1 within mStr or ""
	MatchChars(mStr, StartIndex, byRef str) {
		len := StrLen(str)
		if (len = 0)
		{
			return ""
		}
		ms := new MfMemoryString(len,,,&str)
		
		ch2 := ms.CharCode[0]
		if (ch2 = 0)
		{
			return ""
		}
		if (len > mStr.Length)
		{
			return ""
		}
		i := 0
		j := StartIndex
		; ptr := mStr.BufferPtr
		; ptrStr := ms.BufferPtr
		; mStrBpc := mStr.BytesPerChar
		; msBpc := ms.BytesPerChar
		While (i < len)
		{
			ch := mStr.CharCode[j]
			ch2 := ms.CharCode[i]
			if (ch != ch2 && (ch2 != 160 || ch != 32))
			{
				return ""
			}
			i++
			j++
			; ptr += mStrBpc
			; ptrStr += msBpc
		}
		return j
	}
; 	End:MatchChars ;}
; 	End:ParseInt32 ;}
	ParseInt32(s, style, info) {
		numberBufferBytes := MfNumber.NumberBuffer.NumberBufferBytes
		number := new MfNumber.NumberBuffer(numberBufferBytes)
		i := 0
		MfNumber.StringToNumber(s, style, ByRef number, info, false)
		if ((style & 512) != 0)
		{
			; style & MfNumberStyles.AllowHexSpecifier
			if (!MfNumber.HexNumberToInt32(ByRef number, ByRef i))
			{
				ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_Int32"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}	
		}
		else
		{
			if (!MfNumber.NumberToInt32(ByRef number, ByRef i))
			{
				ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_Int32"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		}
	}
; 	End:ParseInt32 ;}
	HexNumberToInt32(ByRef number, ByRef value) {
		passedValue := 0
		returnValue := MfNumber.HexNumberToUInt32(number, passedValue)
		; passedValue need to convert this value to int32. it is now Uint32
		VarSetCapacity( Var, 16, 0) ; Variable to hold integer
		NumPut(passedValue , Var, 0, "UInt") ; Input as 'Unsigned Integer'
		value := NumGet(Var, 0,"Int")	; Retrieve it as 'Signed Integer'
		VarSetCapacity( Var, 0) 
		return value
	}
;{ 	HexNumberToUInt32
	HexNumberToUInt32(ByRef number, ByRef value) {
		i := number.scale
		if (i > MfNumber.UInt32Precision || i < number.precision)
		{
			 return false
		}
		nd := number.digits
		p := 0
		ch := nd.CharCode[0]
		n := 0
		while (--i >= 0)
		{
			if (n > (0xFFFFFFFF // 16))
			{
				return False
			}
			n *= 16
			if (ch != 0)
			{
				newN := n
				if (ch != 0)
				{
					if (ch >= 48 && ch <= 57)
					{
						newN += (ch - 48)
					}
					else
					{
						if (ch >= 65 && ch <= 70)
						{
							newN += ((ch - 65) + 10)
						}
						else if (ch >= 97 && ch <= 102)
						{
							newN += ((ch - 97) + 10)
						}
					}
					p++
				}
				; Detect an overflow here...
				 if (newN < n)
				 {
				 	return false
				 }
				 n := newN
			}
		}
		 value := n
		 return true
	}
; 	End:HexNumberToUInt32 ;}
;{ 	NumberToInt32
	NumberToInt32(ByRef number, ByRef value) {
		i := number.scale
		if (i > MfNumber.Int32Precision || i < number.precision)
		{
			return false
		}
		p := 0
		nd := number.digits
		ch := nd.CharCode[p]
		n := 0
		while (--i >= 0)
		{
			if (n > (0x7FFFFFFF / 10))
			{
				return false
			}
			n *= 10
			if (ch != 0)
			{
				n += nd.CharCode[p++] - 48
			}
		}
		if (number.sign)
		{
			n := -n
			if (n > 0)
			{
				return false
			}
		}
		else
		{
			if (n < 0)
			{
				return false
			}
		}
		value := n
		return true
	}
; 	End:NumberToInt32 ;}
;{ 	StringToNumber
	StringToNumber(str, options, ByRef number, info, parseDecimal) {
		if (MfString.IsNullOrEmpty(str))
		{
			ex := new MfArgumentNullException("str")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		mStr := MfMemoryString.FromAny(str)
		len := mStr.Length
		if (!MfNumber.ParseNumber(mStr, len, options, number, "", info , parseDecimal) 
			|| (len < str.Length && !MfNumber.TrailingZeros(mStr, (p - stringPointer))))
		{
			ex := new MfFormatException(MfEnvironment.Instance.GetResourceString("Format_InvalidString"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
	}
; 	End:StringToNumber ;}
;{ 	TrailingZeros
	; return boolean
	TrailingZeros(mStr, index) {
		; For compatability, we need to allow trailing zeros at the end of a number string
		i := index
		len := mStr.Length
		while (i < len)
		{
			ch := mStr.CharCode[i]
			if (ch != 0)
			{
				return false
			}
			i++
		}
		return true
	}
; 	End:TrailingZeros ;}
;{ 	ParseNumber
	ParseNumber(mStr, ByRef strLen, options, ByRef number, sb, numfmt, parseDecimal) {
		static StateSign := 0x0001
		static StateParens := 0x0002
		static StateDigits := 0x0004
		static StateNonZero := 0x0008
		static StateDecimal := 0x0010
		static StateCurrency := 0x0020

		
		number.scale := 0
		number.sign := false

		decSep := ""			; decimal separator from NumberFormatInfo.
		groupSep := "" 			; group separator from NumberFormatInfo.
		currSymbol := "" 		; currency symbol from NumberFormatInfo.

		; The alternative currency symbol used in ANSI codepage, that can not roundtrip between ANSI and Unicode.
		; Currently, only ja-JP and ko-KR has non-null values (which is U+005c, backslash)
		ansicurrSymbol := "" 	; currency symbol from NumberFormatInfo.
		altdecSep := "" 		; decimal separator from NumberFormatInfo as a decimal
		altgroupSep := ""	 	; group separator from NumberFormatInfo as a decimal

		parsingCurrency := false
		if ((options & 256) != 0)
		{
			; options & MfNumberStyles.Instance.AllowCurrencySymbol
			currSymbol := numfmt.CurrencySymbol
			if (numfmt.ansiCurrencySymbol != "")
			{
				ansicurrSymbol := numfmt.ansiCurrencySymbol
			}
			; The idea here is to match the currency separators and on failure match the number separators to keep the perf of VB's IsNumeric fast.
			; The values of decSep are setup to use the correct relevant separator (currency in the if part and decimal in the else part).
			altdecSep := numfmt.NumberDecimalSeparator
			altgroupSep := numfmt.NumberGroupSeparator
			decSep := numfmt.CurrencyDecimalSeparator
			groupSep := numfmt.CurrencyGroupSeparator
			parsingCurrency := true
		}
		else
		{
			decSep := numfmt.NumberDecimalSeparator
			groupSep := numfmt.NumberGroupSeparator
		}
		state := 0
		signflag := false
		bigNumber := !MfNull.IsNull(sb)
		bigNumberHex := (bigNumber && ((options & 512) != 0))
		maxParseDigits := bigNumber ? MfInteger.MaxValue : MfNumber.NumberMaxDigits

		p := 0
		ch := ch := mStr.CharCode[0]
		next := ""
		len := mStr.Length + 1 ; add one to allow for null terminator
		i := 0
		While (i < len)
		{
			
			; Eat whitespace unless we've found a sign which isn't followed by a currency symbol.
			; "-Kr 1231.47" is legal but "- 1231.47" is not.
			if (MfNumber.IsWhite(ch) && ((options & 1) != 0) 
				&& (((state & StateSign) = 0) || (((state & StateSign) != 0) && (((state & StateCurrency) != 0)
					|| numfmt.numberNegativePattern = 2))))
			{
				; Do nothing here. We will increase i at the end of the loop.
			}
			else if ((signflag := (((options & 4) != 0) && ((state & StateSign) == 0))) && ((next := MfNumber.MatchChars(mStr, p, numfmt.positiveSign)) != ""))
			{
				state |= StateSign
				p := next - 1
			}
			else if (signflag && (next := MfNumber.MatchChars(mStr,p, numfmt.negativeSign)) != "")
			{
				state |= StateSign
				number.sign := true
				p := next - 1
			}
			else if (ch = 40 && ((options & 16) != 0) && ((state & StateSign) = 0))
			{
				; ascii 40 = (
				state |= StateSign | StateParens
				number.sign := true
			}
			else if ((currSymbol != "" && (next := MfNumber.MatchChars(mStr, p, currSymbol)) != "") || (ansicurrSymbol != "" 
				&& (next := MfNumber.MatchChars(mStr, p, ansicurrSymbol)) != ""))
			{
				state |= StateCurrency
				currSymbol := ""
				ansicurrSymbol := ""
				; We already found the currency symbol. There should not be more currency symbols. Set
				; currSymbol to NULL so that we won't search it again in the later code path.
				p := next - 1
			}
			else
			{
				break
			}
			i++
			ch := mStr.CharCode[p]
		}
		digCount := 0
		digEnd := 0
		While (i < len)
		{
			if ((ch >= 48 && ch <= 57) || (((options & 512) != 0) && ((ch >= 97 && ch <= 102) || (ch >= 65 && ch <= 70))))
			{
				; if char is 0 to 9 or ((option MfNumberStyles.Instance.AllowHexSpecifier ) and ((ch = a to f) or (ch = A to F))
				state |= StateDigits
				if (ch != 48 || (state & StateNonZero) != 0 || bigNumberHex)
				{
					if (digCount < maxParseDigits)
					{
						if (bigNumber)
						{
							 sb.Append(ch)
						}
						else
						{
							number.digits.CharCode[digCount++] := ch

						}
						if (ch != 48 || parseDecimal)
						{
							digEnd := digCount
						}
						if ((state & StateDecimal) = 0)
						{
							number.scale++
						}
						state |= StateNonZero
					}

				}
				else if ((state & StateDecimal) != 0)
				{
					number.scale--
				}
			}
			else if (((options & 32) != 0) && ((state & StateDecimal) = 0) && ((next := MfNumber.MatchChars(MfStr, p, decSep)) != "" || ((parsingCurrency) && (state & StateCurrency) = 0) && (next := MfNumber.MatchChars(MfStr, p, altdecSep)) != ""))
			{
				; options & NumberStyles.AllowDecimalPoint
				state |= StateDecimal
				p := next - 1
			}
			else if (((options & 64) != 0) && ((state & StateDigits) != 0) && ((state & StateDecimal) = 0) && ((next := MfNumber.MatchChars(mStr, p, groupSep)) != "" || ((parsingCurrency) && (state & StateCurrency) = 0) && (next := MfNumber.MatchChars(mStr, p, altgroupSep)) != ""))
			{
				; options & NumberStyles.AllowThousands
				p := next - 1
			}
			else
			{
				break
			}
			i++
			ch := mStr.CharCode[i]
		}
		negExp := false
		number.precision := digEnd
		if (bigNumber)
		{
			sb._AppendCharCode(0)
		}
		else
		{
			number.digits.CharCode[digEnd] := 0
		}
		if ((state & StateDigits) != 0)
		{
			if ((ch = 69 || ch = 101) && ((options & 128) != 0))
			{
				; ch = E or ch = e , options & NumberStyles.AllowExponent
				temp := p
				i++
				ch := mStr.CharCode[i]
				if ((next := MfNumber.MatchChars(mStr, p, numfmt.positiveSign)) != "")
				{
					p := next
					ch := mStr.CharCode[p]
				}
				else if ((next := MfNumber.MatchChars(mStr, p, numfmt.negativeSign)) != "")
				{
					p := next
					ch := mStr.CharCode[p]
					negExp := true
				}
				if (ch >= 48 && ch <= 57) ; ch 0 to 9
				{
					exp := 0
					loop
					{
						exp := (exp * 10) + (ch - 48) ; ch - 48 gets actual digit 0 to 9
						p++
						ch := mStr.CharCode[p]
						if (exp > 1000)
						{
							exp := 9999
							while (ch >= 48 && ch <= 57)
							{
								p++
								ch := mStr.CharCode[p]
							}
						}
						if (ch < 48 || ch > 57)
						{
							break
						}
					}
					if (negExp)
					{
						exp := -exp
					}
					number.scale += exp
				}
				else
				{
					p := temp
					ch := mStr.CharCode[p]
				}
			}
			loop
			{
				if (MfNumber.IsWhite(ch) && ((options & 2) != 0))
				{
					; options & NumberStyles.AllowTrailingWhite
				}
				else if ((signflag := (((options & 8) != 0) && ((state & StateSign) = 0))) && (next := MfNumber.MatchChars(MStr, p, numfmt.positiveSign)) != "")
				{
					; options & NumberStyles.AllowTrailingSign
					 state |= StateSign
					 p := next - 1
				}
				else if (signflag && (next := MfNumber.MatchChars(mStr, p, numfmt.negativeSign)) != "") 
				{
					state |= StateSign
					number.sign := true
					p := next - 1
				}
				else if (ch = 41 && ((state & StateParens) != 0))
				{
					; ch = ')'
					intSP := new MfInteger(StateParens)
					state &= MfBinaryConverter.NumberComplement(intSp).Value
				}
				else if ((currSymbol != "" && (next := MfNumber.MatchChars(mStr, p, currSymbol)) != "") || (ansicurrSymbol != "" && (next := MfNumber.MatchChars(mStr, p, ansicurrSymbol)) != ""))
				{
					currSymbol := ""
					ansicurrSymbol := ""
					p := next - 1
				}
				else
				{
					break
				}
				ch := mStr.CharCode[p]
			}
			if ((state & StateParens) = 0)
			{
				if ((state & StateNonZero) = 0)
				{
					if (!parseDecimal)
					{
						number.scale := 0
					}
					if ((state & StateDecimal) = 0)
					{
						number.sign := false
					}
				}
				strLen := p
				return true
			}
		}
		strLen := p
		return false
	}
; 	End:ParseNumber ;}
}