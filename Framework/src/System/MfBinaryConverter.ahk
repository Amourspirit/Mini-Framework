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

class MfBinaryConverter extends MfObject
{
;{ Methods
;{ 	GetBytes
	GetBits(obj) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		ObjCheck := MfBinaryConverter._IsNotMfObj(obj)
		if (ObjCheck)
		{
			ObjCheck.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ObjCheck
		}
		if (MfObject.IsObjInstance(obj, MfBool))
		{
			if (obj.Value = true)
			{
				return MfBinaryConverter._GetBytesInt(1, 1, true)
			}
			return MfBinaryConverter._GetBytesInt(0, 1, true)
		}
		else if (MfObject.IsObjInstance(obj, MfByte))
		{
			return MfBinaryConverter._GetBytesInt(obj.Value, 8)
		}
		else if (MfObject.IsObjInstance(obj, MfInt16))
		{
			return MfBinaryConverter._GetBytesInt(obj.Value, 16)
		}
		else if (MfObject.IsObjInstance(obj, MfInteger))
		{
			return MfBinaryConverter._GetBytesInt(obj.Value, 32)
		}
		else if (MfObject.IsObjInstance(obj, MfInt64))
		{
			return MfBinaryConverter._GetBytesInt(obj.Value, 64)
		}
		else if (MfObject.IsObjInstance(obj, MfUInt64))
		{
			return MfBinaryConverter._GetBytesUInt(obj.Value, 64)
		}
	}
;{ GetBytes
;{ 	IsNegative
	IsNegative(bits, startIndex = 0, ReturnAsObj = false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(bits, MfBinaryList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "bits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(bits.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "bits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		nCount := 1 ; Number of bits needed for test
		if (bits.Count < nCount)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayTooSmall", "bits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		MaxStartIndex := bits.Count - nCount
		_startIndex := MfInteger.GetValue(startIndex, -1)
		if (_startIndex < 0)
		{
			_startIndex := 0
		}
		_ReturnAsObj := MfBool.GetValue(ReturnAsObj, false)
		if ((_startIndex < 0) || (_startIndex > MaxStartIndex))
		{
			ex := new MfArgumentOutOfRangeException("startIndex")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		retval := bits.Item[_startIndex] = 1
		if (_ReturnAsObj)
		{
			return new MfBool(retval)
		}
		return retval
	}
; 	End:IsNegative ;}
;{ 	ToBool
	ToBool(bits, startIndex = -1, ReturnAsObj = false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(bits, MfBinaryList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "bits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(bits.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "bits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		nCount := 1 ; Number of bits needed for test
		if (bits.Count < nCount)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayTooSmall", "bits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_startIndex := MfInteger.GetValue(startIndex, -1)
		if (_startIndex < 0)
		{
			_startIndex := bits.Count - 1
		}
		_ReturnAsObj := MfBool.GetValue(ReturnAsObj, false)
		if ((_startIndex < 0) || (_startIndex > (bits.Count - 1)))
		{
			ex := new MfArgumentOutOfRangeException("startIndex")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		retval := bits.Item[_startIndex] = 1
		if (_ReturnAsObj)
			return new MfBool(retval)
		return retval

	}
; 	End:ToBool ;}
;{ 	ToByte
	ToByte(bits, startIndex = -1, ReturnAsObj = false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(bits, MfBinaryList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "bits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(bits.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "bits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		nCount := 8 ; Number of bits needed for conversion
		if (bits.Count < nCount)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayTooSmall", "bits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_startIndex := MfInteger.GetValue(startIndex, -1)
		
		MaxStartIndex := bits.Count - nCount
		if (_startIndex < 0)
		{
			_startIndex := MaxStartIndex
		}
		_ReturnAsObj := MfBool.GetValue(ReturnAsObj, false)
		if ((_startIndex < 0) || (_startIndex > MaxStartIndex))
		{
			ex := new MfArgumentOutOfRangeException("startIndex")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		iCount := 0
		i := _startIndex
		strMsb := ""
		strLsb := ""
		While iCount < 4
		{
			strMsb .= bits.Item[i]
			i++
			iCount++
		}
		iCount := 0
		While iCount < 4
		{
			strLsb .= bits.Item[i]
			i++
			iCount++
		}
		mInfo := MfBinaryConverter.ByteTable[strMsb]
		lInfo := MfBinaryConverter.ByteTable[strLsb]
		MSB := mInfo.Int

		LSB := lInfo.Int

		retval := (MSB * 16) + LSB
		if ((retval < MfByte.MinValue) || (retval > MfByte.MaxValue)) {
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_Byte"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (_ReturnAsObj)
		{
			return new MfByte(retval)
		}

		return retval

	}
; 	End:ToByte ;}
;{ ToChar
	ToChar(bits, startIndex = -1, ReturnAsObj = false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		result := MfBinaryConverter.ToInt16(bits, startIndex, false)
		if (result < 0)
		{
			result := Abs(result)
		}
		c := new MfChar()
		c.CharCode := result
		if (_ReturnAsObj)
		{
			return c
		}
		return c.Value
	}
; End:ToChar ;}
;{ ToInt16
	ToInt16(bits, startIndex = -1, ReturnAsObj = false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(bits, MfBinaryList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "bits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(bits.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "bits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		nCount := 16 ; Number of bits needed for conversion
		if (bits.Count < nCount)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayTooSmall", "bits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_startIndex := MfInteger.GetValue(startIndex, -1)
		
		MaxStartIndex := bits.Count -1
		if (_startIndex < 0)
		{
			_startIndex := MaxStartIndex
		}
		_ReturnAsObj := MfBool.GetValue(ReturnAsObj, false)
		if ((_startIndex < 0) || (_startIndex > MaxStartIndex))
		{
			ex := new MfArgumentOutOfRangeException("startIndex")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		IsNeg := MfBinaryConverter.IsNegative(bits, startIndex)

		val := 0
		if (IsNeg)
		{
			_Index := (_startIndex - nCount) + 1
			_IndexEnd := (_Index + nCount) - 1
			subBits := MfBinaryConverter._GetSubList(bits, _Index, _IndexEnd)
			FlipBits := MfBinaryConverter._FlipBits(subBits)
			MfBinaryConverter._AddOneToBitsValue(FlipBits)
			i := FlipBits.Count -1
			iCount := 0
			Num := 1
			while i >= 0
			{
				bit := FlipBits.Item[i]
				if (bit = 1)
				{
					val -= num
				}
				num <<= 1
				i--
				iCount++
			}
			

		}
		Else
		{
			iCount := 0
			i := _startIndex
			Num := 1
			while iCount < nCount
			{
				bit := bits.Item[i]
				if (bit = 1)
				{
					val += num
				}
				Num <<= 1
				iCount++
				i--
			}
		}
		
		if ((val < MfInt16.MinValue) || (val > MfInt16.MaxValue)) {
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_Int16"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (_ReturnAsObj)
		{
			return new MfInt16(val)
		}
		return val
	}
; End:ToInt16 ;}
;{ 	ToInt32
	ToInt32(bits, startIndex = -1, ReturnAsObj = false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(bits, MfBinaryList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "bits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(bits.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "bits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		nCount := 32 ; Number of bits needed for conversion
		if (bits.Count < nCount)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayTooSmall", "bits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_startIndex := MfInteger.GetValue(startIndex, -1)
		
		MaxStartIndex := bits.Count -1
		if (_startIndex < 0)
		{
			_startIndex := MaxStartIndex
		}
		_ReturnAsObj := MfBool.GetValue(ReturnAsObj, false)
		if ((_startIndex < 0) || (_startIndex > MaxStartIndex))
		{
			ex := new MfArgumentOutOfRangeException("startIndex")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		IsNeg := MfBinaryConverter.IsNegative(bits, startIndex)

		val := 0
		if (IsNeg)
		{
			_Index := (_startIndex - nCount) + 1
			_IndexEnd := (_Index + nCount) - 1
			subBits := MfBinaryConverter._GetSubList(bits, _Index, _IndexEnd)
			FlipBits := MfBinaryConverter._FlipBits(subBits)
			MfBinaryConverter._AddOneToBitsValue(FlipBits)
			i := FlipBits.Count -1
			iCount := 0
			Num := 1
			while i >= 0
			{
				bit := FlipBits.Item[i]
				if (bit = 1)
				{
					val -= num
				}
				num <<= 1
				i--
				iCount++
			}
		}
		else
		{
			iCount := 0
			i := _startIndex
			Num := 1
			while iCount < nCount
			{
				bit := bits.Item[i]
				if (bit = 1)
				{
					val += num
				}
				Num <<= 1
				iCount++
				i--
			}
		}
		
		if ((val < MfInteger.MinValue) || (val > MfInteger.MaxValue)) {
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_Int32"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (_ReturnAsObj)
		{
			return new MfInteger(val)
		}
		return val
	}
; 	End:ToInt32 ;}
;{ 	ToInt64
	ToInt64(bits, startIndex = -1, ReturnAsObj = false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(bits, MfBinaryList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "bits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(bits.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "bits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		nCount := 64 ; Number of bits needed for conversion
		if (bits.Count < nCount)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayTooSmall", "bits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_startIndex := MfInteger.GetValue(startIndex, -1)
		
		MaxStartIndex := bits.Count -1
		if (_startIndex < 0)
		{
			_startIndex := MaxStartIndex
		}
		_ReturnAsObj := MfBool.GetValue(ReturnAsObj, false)
		if ((_startIndex < 0) || (_startIndex > MaxStartIndex))
		{
			ex := new MfArgumentOutOfRangeException("startIndex")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		IsNeg := MfBinaryConverter.IsNegative(bits, startIndex)

		val := 0
		if (IsNeg)
		{
			_Index := (_startIndex - nCount) + 1
			_IndexEnd := (_Index + nCount) - 1
			subBits := MfBinaryConverter._GetSubList(bits, _Index, _IndexEnd)
			FlipBits := MfBinaryConverter._FlipBits(subBits)
			MfBinaryConverter._AddOneToBitsValue(FlipBits)
			i := FlipBits.Count -1
			iCount := 0
			Num := 1
			while i >= 0
			{
				bit := FlipBits.Item[i]
				if (bit = 1)
				{
					val -= num
				}
				num <<= 1
				i--
				iCount++
			}
		}
		else
		{
			iCount := 0
			i := _startIndex
			Num := 1
			while iCount < nCount
			{
				bit := bits.Item[i]
				if (bit = 1)
				{
					val += num
				}
				Num <<= 1
				iCount++
				i--
			}
		}
		
		if ((val < MfInt64.MinValue) || (val > MfInt64.MaxValue)) {
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_Int64"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (_ReturnAsObj)
		{
			return new MfInt64(val)
		}
		return val
	}
; 	End:ToInt64 ;}
;{ 	Methods

;{ Internal Methods
	_DecToBin(strDec) {
		lst := new MfBinaryList()
		If (MfString.IsNullOrEmpty(strDec))
		{
			lst.Add(0)
			return lst
		}
		strRev := MfString.Reverse(strDec)
		iCarry := 0
		iCount := 0
		Loop, Parse, strRev
		{

			b := A_LoopField + 0
			iCarry := b + iCarry
			
			While (iCarry > 0)
			{
				R := 0
				sum := iCarry
				iCarry := 0
				if (sum > 0)
				{
					iCarry := MfMath.DivRem(sum, 2, R)
				}
				lst.Add(R)
			}
		}
		return lst
	}
;{ 	_AddOneToBitsValue
	_AddOneToBitsValue(byref lst) {
		iCarry := 1
		i := lst.Count - 1
		while i >= 0
		{
			sum := (lst.Item[i] + 1)
			if (sum > 1)
			{
				lst.Item[i] := 0
			}
			else
			{
				lst.Item[i] := sum
				iCarry := 0
				break
			}
			i--
		}
		if (iCarry = 1)
		{
			lst.Insert(0, 1)
		}
	}
; 	End:_AddOneToBitsValue ;}
	_GetByteInfo(byref bits, startIndex) {
		byte := ""
		i := startIndex
		while iCount < 4
		{
			byte .= bits.Item[i]
			i++
			iCount++
		}
		return MfBinaryConverter.ByteTable[byte]
	}
;{ 	_GetBytesInt
	_GetBytesInt(value, bitCount = 32) {
		If (bitCount < 4 )
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Value_Under", "4"), "bitCount")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (Mod(bitCount, 4))
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Value_Not_Divisable_By", "4"), "bitCount")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (bitCount > 64)
		{
			; will handle negative and positive and convert to Little Endian
			return MfBinaryConverter._LongIntStringToByteArray(value, bitCount)
		}
		return MfBinaryConverter._IntToBinaryList(value, bitCount)

	}
; 	End:_GetBytesInt ;}
;{ 	_LongIntStringToByteArray
	_LongIntStringToByteArray(value, bitCount = 32) {
		throw new MfNotImplementedException("_LongIntStringToByteArray not implemented")
	}
; 	End:_LongIntStringToByteArray ;}
;{ 	_GetSubList
	; returns a subset of a MfBinaryList as a new MfBinaryList instance
	; counts from Right to left so startIndex it from the end
	_GetSubList(lst, startIndex, endIndex=0) {
		_startIndex := MfInteger.GetValue(startIndex, -1)
		_endIndex := MfInteger.GetValue(endIndex, 0)
		if (_startIndex < 1 && _endIndex = 0)
		{
			return lst
		}
		if (_startIndex > _endIndex)
		{
			return lst
		}
		retval := new MfBinaryList()
		i := _startIndex
		while i <= _endIndex
		{
			retval.Add(lst.Item[i])
			i++
		}

		return retval
	}
; 	End:_GetSubList ;}
;{ _FlipBits
	_FlipBits(lst) {
		nArray := new MfBinaryList()
		iMaxIndex := lst.Count - 1
		for i, b in lst
		{
			nArray.Add(b ^ 1)
		}
		return nArray
	}
; End:_FlipBits ;}
	_IntToBinaryList(value, bitCount = 32) {
		If (bitCount < 4 )
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Value_Under", "4"), "bitCount")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (Mod(bitCount, 4))
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Value_Not_Divisable_By", "4"), "bitCount")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
			
		IsNegative := false
		bArray := new MfBinaryList()
		ActualBitCount := bitCount
		MaxMinValuCorrect := false
		if (value = 0)
		{
			while (bArray.Count < ActualBitCount)
			{
				bArray.Add(0)
			}
			return bArray
		}
		if (value < 0)
		{
			IsNegative := true
			; The Absolute value of MfInt64.MinValue is 1 greater then then MfInt64.MaxValue
			; therefore Abs(MfInt64.MinValue) will return the same negative value
			; to get around this add 1 if value = MfInt64.MinValue and subtact if from the bit array
			; this is a one off case and only happens when value is max int min value.
			if (value = MfInt64.MinValue)
			{
				Result := Abs((value + 1))
				MaxMinValuCorrect := true
			}
			else
			{
				Result := Abs(value)
			}
		}
		else
		{
			Result := value
		}
		while Result > 0
		{
			bArray.Add(Result & 0x1)
			Result >>= 1
			i++
		}
		
				
		if (IsNegative)
		{
			while (bArray.Count < ActualBitCount)
			{
				bArray.Add(0)
			}
			bArray := MfBinaryConverter._ReverseList(bArray)
			; flip all the bits
			bArray := MfBinaryConverter._FlipBits(bArray)

			if (MaxMinValuCorrect = False)
			{
				;~ ; when negative Add 1
				IsAdded := MfBinaryConverter._AddOneToBitsValue(bArray, false)
			}
		}
		else ; if (IsNegative)
		{
			; add zero's to end of postivie array
			while (bArray.Count < ActualBitCount)
			{
				bArray.Add(0)
			}
			bArray := MfBinaryConverter._ReverseList(bArray)
		}
		return bArray
	}
;{ _ReverseList
	_ReverseList(lst) {
		iCount := lst.Count
		nArray := new MfBinaryList()
		while iCount > 0
		{
			index := iCount -1
			nArray.Add(lst.Item[index])
			iCount --
		}
		return nArray
	}
; End:_ReverseList ;}
; End:Internal Methods ;}
;{ Properties
;{ IsLittleEndian
		/*!
			Property: IsLittleEndian [get]
				Indicates the byte order ("endianness") in which data is stored in this computer architecture
			Value:
				Var representing the IsLittleEndian property of the instance
			Remarks:
				Readonly Property
				Returns false
		*/
		IsLittleEndian[]
		{
			get {
				return false
			}
			set {
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
				ex.SetProp(A_LineFile, A_LineNumber, "IsLittleEndian")
				Throw ex
			}
		}
	; End:IsLittleEndian ;}
;{ ByteTable
		static m_ByteTable := ""
		/*!
			Property: ByteTable [get]
				Gets the ByteTable value associated with the this instance
			Value:
				Var representing the ByteTable property of the instance
			Remarks:
				Readonly Property
		*/
		ByteTable[key]
		{
			get {
				if (MfBinaryConverter.m_ByteTable = "")
				{
					MfBinaryConverter.m_ByteTable := new MfHashTable(16)
					MfBinaryConverter.m_ByteTable.Add("0000", new MfBinaryConverter.BitInfo("0", "F", "0000","1111", 0, 15))
					MfBinaryConverter.m_ByteTable.Add("0001", new MfBinaryConverter.BitInfo("1", "E", "0001","1110", 1, 14))
					MfBinaryConverter.m_ByteTable.Add("0010", new MfBinaryConverter.BitInfo("2", "D", "0010","1101", 2, 13))
					MfBinaryConverter.m_ByteTable.Add("0011", new MfBinaryConverter.BitInfo("3", "C", "0011","1100", 3, 12))
					MfBinaryConverter.m_ByteTable.Add("0100", new MfBinaryConverter.BitInfo("4", "B", "0100","1011", 4, 11))
					MfBinaryConverter.m_ByteTable.Add("0101", new MfBinaryConverter.BitInfo("5", "A", "0101","1010", 5, 10))
					MfBinaryConverter.m_ByteTable.Add("0110", new MfBinaryConverter.BitInfo("6", "9", "0110","1001", 6, 9))
					MfBinaryConverter.m_ByteTable.Add("0111", new MfBinaryConverter.BitInfo("7", "8", "0111","1000", 7, 8))

					MfBinaryConverter.m_ByteTable.Add("1000", new MfBinaryConverter.BitInfo("8", "7", "1000","0111", 8, 7, true))
					MfBinaryConverter.m_ByteTable.Add("1001", new MfBinaryConverter.BitInfo("9", "6", "1001","0110", 9, 6, true))
					MfBinaryConverter.m_ByteTable.Add("1010", new MfBinaryConverter.BitInfo("A", "5", "1010","0101", 10, 5, true))
					MfBinaryConverter.m_ByteTable.Add("1011", new MfBinaryConverter.BitInfo("B", "4", "1011","0100", 11, 5, true))
					MfBinaryConverter.m_ByteTable.Add("1100", new MfBinaryConverter.BitInfo("C", "3", "1100","0011", 12, 3, true))
					MfBinaryConverter.m_ByteTable.Add("1101", new MfBinaryConverter.BitInfo("D", "2", "1101","0010", 13, 2, true))
					MfBinaryConverter.m_ByteTable.Add("1110", new MfBinaryConverter.BitInfo("E", "1", "1110","0001", 14, 1, true))
					MfBinaryConverter.m_ByteTable.Add("1111", new MfBinaryConverter.BitInfo("F", "0", "1111","0000", 15, 0, true))
				}
				return MfBinaryConverter.m_ByteTable.Item[key]
			}
			set {
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
				ex.SetProp(A_LineFile, A_LineNumber, "HexBitTable")
				Throw ex
			}
		}
	; End:ByteTable ;}
; End:Properties ;}
	;{ Internal Class BitInfo
	class BitInfo
	{
		__new(hv, hf, b, bf, i, iFlip, Neg = false) {
			this.HexValue := hv
			this.HexFlip := hf
			this.Bin := b
			this.BinFlip := bf
			this.Int := i
			this.IntFlip := iFlip
			this.IsNeg := Neg
		}
		HexValue := ""
		HexFlip := ""
		Bin := ""
		BinFlip := ""
		IsNeg := False
		Int := 0
		IntFlip := 0
	}
; End:Internal Class BitInfo ;}
}