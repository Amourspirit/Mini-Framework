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

class MfBitConverter extends MfObject
{
;{ Methods
;{ 	CompareUnsignedByteArrays
	CompareUnsignedByteArrays(objA, objB) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(objA, MfByteList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "objA"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(MfObject.IsObjInstance(objB, MfByteList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "objB"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		return MfBitConverter._CompareUnSignedIntegerArraysLe(objA, objB)
	}
; 	End:CompareUnsignedByteArrays ;}
;{ 	CompareSignedByteArrays
	CompareSignedByteArrays(objA, objB)	{
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(objA, MfByteList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "objA"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(MfObject.IsObjInstance(objB, MfByteList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "objB"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(objA.Count = 0)
		{
			return -1
		}
		if(objB.Count = 0)
		{
			return 1
		}
		MostSigbitA := MfBitConverter._GetFirstHexNumber(objA.Item[objA.Count -1])
		MostSigbitInfoA := MfBitConverter.HexBitTable.Item[MostSigbitA]
		
		MostSigbitB := MfBitConverter._GetFirstHexNumber(objB.Item[objB.Count -1])
		MostSigbitInfoB := MfBitConverter.HexBitTable.Item[MostSigbitB]
		if ((MostSigbitInfoA.IsNeg = true) && (MostSigbitInfoB.IsNeg = false))
		{
			return -1
		}
		if ((MostSigbitInfoA.IsNeg = false) && (MostSigbitInfoB.IsNeg = true))
		{
			return 1
		}
		if ((MostSigbitInfoA.IsNeg = false) && (MostSigbitInfoB.IsNeg = false))
		{
			return MfBitConverter._CompareUnSignedIntegerArraysLe(objA, objB)
		}
		if (MostSigbitInfoA.IsNeg = true)
		{
			ObjA := MfBitConverter._FlipBytes(ObjA)
		}
		if (MostSigbitInfoB.IsNeg = true)
		{
			ObjB := MfBitConverter._FlipBytes(ObjB)
		}
		result := MfBitConverter._CompareUnSignedIntegerArraysLe(objA, objB)
		if (result > 0)
		{
			return -1
		}
		if (result < 0)
		{
			return 1
		}
		return result
	}
; 	End:CompareSignedByteArrays ;}
;{ CompareUnsignedNibbleArrays
	CompareUnsignedNibbleArrays(objA, objB) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(objA, MfNibbleList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "objA"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(MfObject.IsObjInstance(objB, MfNibbleList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "objB"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		return MfBitConverter._CompareUnSignedIntegerArraysBe(objA, objB)
	}
; End:CompareUnsignedNibbleArrays ;}
	CompareSignedNibbleArrays(objA, objB)	{
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(objA, MfNibbleList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "objA"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(MfObject.IsObjInstance(objB, MfNibbleList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "objB"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(objA.Count = 0)
		{
			return -1
		}
		if(objB.Count = 0)
		{
			return 1
		}
		HexA := MfBitConverter._GetHexValue(objA.Item[0])
		MostSigbitInfoA :=  MfBitConverter.HexBitTable.Item[HexA]
		
		HexB := MfBitConverter._GetHexValue(objA.Item[0])
		MostSigbitInfoB :=  MfBitConverter.HexBitTable.Item[HexB]
		if ((MostSigbitInfoA.IsNeg = true) && (MostSigbitInfoB.IsNeg = false))
		{
			return -1
		}
		if ((MostSigbitInfoA.IsNeg = false) && (MostSigbitInfoB.IsNeg = true))
		{
			return 1
		}
		if ((MostSigbitInfoA.IsNeg = false) && (MostSigbitInfoB.IsNeg = false))
		{
			return MfBitConverter._CompareUnSignedIntegerArraysBe(objA, objB)
		}
		if (MostSigbitInfoA.IsNeg = true)
		{
			ObjA := MfBitConverter._FlipNibbles(ObjA)
		}
		if (MostSigbitInfoB.IsNeg = true)
		{
			ObjB := MfBitConverter._FlipNibbles(ObjB)
		}
		result := MfBitConverter._CompareUnSignedIntegerArraysBe(objA, objB)
		if (result > 0)
		{
			return -1
		}
		if (result < 0)
		{
			return 1
		}
		return result
	}
;{ GetBytes
	GetBytes(obj) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if (!IsObject(obj))
		{
			IsNeg := False
			if(MfMath._IsStringInt(obj, IsNeg))
			{
				return MfBitConverter._LongIntStringToHexArray(obj, 0)
			}
		}
		ObjCheck := MfConvert._IsNotMfObj(obj)
		if (ObjCheck)
		{
			ObjCheck.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ObjCheck
		}
		wf := A_FormatInteger
		Try
		{
			SetFormat, IntegerFast, d
			if (MfObject.IsObjInstance(obj, MfBool))
			{
				if (obj.Value = true)
				{
					return MfBitConverter._GetBytesInt(1, 8, true)
				}
				return MfBitConverter._GetBytesInt(0, 8, true)
			}
			else if (MfObject.IsObjInstance(obj, MfChar))
			{
				return MfBitConverter._GetBytesInt(obj.CharCode, 16)
			}
			else if (MfObject.IsObjInstance(obj, MfInt16))
			{
				return MfBitConverter._GetBytesInt(obj.Value, 16)
			}
			else if (MfObject.IsObjInstance(obj, MfInteger))
			{
				return MfBitConverter._GetBytesInt(obj.Value, 32)
			}
			else if (MfObject.IsObjInstance(obj, MfInt64))
			{
				return MfBitConverter._GetBytesInt(obj.Value, 64)
			}
			else if (MfObject.IsObjInstance(obj, MfUInt64))
			{
				return MfBitConverter._GetBytesUInt(obj.Value, 64)
			}
			else if (MfObject.IsObjInstance(obj, MfFloat))
			{
				int := MfBitConverter._FloatToInt64(obj.Value)
				return MfBitConverter._GetBytesInt(int, 64)
			}
		}
		Catch e
		{
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		finally
		{
			SetFormat, IntegerFast, %ws%
		}
			

		ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", A_ThisFunc))
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
; End:GetBytes ;}
;{ GetNibbleHigh
	GetNibbleHigh(byte) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		_byte := MfByte.GetValue(byte)
		return MfBitConverter._GetFirstHexNumber(_byte)
	}
; End:GetNibbleHigh ;}
;{ GetNibbleLow
	GetNibbleLow(Byte) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		_byte := MfByte.GetValue(byte)
		return MfBitConverter._GetSecondHexNumber(_byte)
	}
; End:GetNibbleLow ;}
;{ 	BytesAdd
	BytesAdd(BytesA, BytesB) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(BytesA, MfByteList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "BytesA"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(MfObject.IsObjInstance(BytesB, MfByteList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "BytesB"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(BytesA.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "BytesA"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(BytesB.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "BytesB"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		nibA := MfNibbleList.FromByteList(BytesA)
		nibB := MfNibbleList.FromByteList(BytesB)
		nibResult := MfBitConverter.NibbleListAdd(nibA, nibB)
		result := nibResult.ToByteList()
		return result
	}
; 	End:BytesAdd ;}
	BytesMultiply(BytesA, BytesB) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(BytesA, MfByteList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "BytesA"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(MfObject.IsObjInstance(BytesB, MfByteList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "BytesB"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(BytesA.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "BytesA"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(BytesB.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "BytesB"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		nibA := MfNibbleList.FromByteList(BytesA)
		nibB := MfNibbleList.FromByteList(BytesB)
		nibResult := MfBitConverter.NibbleListMultiply(nibA, nibB)
		result := nibResult.ToByteList()
		return result
	}
;{ NibbleListsAdd
	NibbleListAdd(ListA, ListB) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(ListA, MfNibbleList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "ListA"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(MfObject.IsObjInstance(ListB, MfNibbleList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "ListB"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(ListA.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "ListA"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(ListB.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "ListB"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (ListA.Count > ListB.Count)
		{
			return MfBitConverter._NibListsAdd(ListA, ListB)
		}
		return MfBitConverter._NibListsAdd(ListB, ListA)
		
	}
; End:NibbleListsAdd ;}
	NibbleListMultiply(ListA, ListB) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(ListA, MfNibbleList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "ListA"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(MfObject.IsObjInstance(ListB, MfNibbleList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "ListB"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(ListA.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "ListA"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(ListB.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "ListB"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		Compare := MfBitConverter.CompareSignedNibbleArrays(ListA, ListB)
		if (Compare > 0)
		{
			return MfBitConverter._MultiplyNibList(ListA, ListB)
		}
		return MfBitConverter._MultiplyNibList(ListA, ListB)
	}
;{ ToBool
	ToBool(bytes, startIndex = 0, ReturnAsObj = false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(bytes, MfByteList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "bytes"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(bytes.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "bytes"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_startIndex := MfInt64.GetValue(startIndex, 0)
		_ReturnAsObj := MfBool.GetValue(ReturnAsObj, false)
		if ((_startIndex < 0) || (_startIndex > (bytes.Count - 1)))
		{
			ex := new MfArgumentOutOfRangeException("startIndex")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		return bytes.Item[_startIndex] != 0

	}

; End:ToBool ;}
;{ 	ToByte
	ToByte(bytes, startIndex = 0, ReturnAsObj = false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(bytes, MfByteList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "bytes"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(bytes.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "bytes"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_startIndex := MfInt64.GetValue(startIndex, 0)
		_ReturnAsObj := MfBool.GetValue(ReturnAsObj, false)
		if ((_startIndex < 0) || (_startIndex > (bytes.Count - 1)))
		{
			ex := new MfArgumentOutOfRangeException("startIndex")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		retval := "0x"
		b := bytes.Item[_startIndex]
		HexChar1 := MfBitConverter._GetFirstHexNumber(b)
		HexChar2 := MfBitConverter._GetSecondHexNumber(b)
		retval .= HexChar1 . HexChar2
		retval := retval + 0x0
		if (_ReturnAsObj)
		{
			return new MfByte(retval)
		}
		return retval

	}
; 	End:ToByte ;}
;{ ToChar
	ToChar(bytes, startIndex = 0, ReturnAsObj = false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		result := MfBitConverter.ToInt16(bytes, startIndex, false)
		c := new MfChar(result)
		c.CharCode := result
		if (_ReturnAsObj)
		{
			return c
		}
		return c.Value
	}
; End:ToChar ;}
;{ ToInt16
	ToInt16(bytes, startIndex = 0, ReturnAsObj = false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(bytes, MfByteList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "bytes"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(bytes.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "bytes"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_startIndex := MfInt64.GetValue(startIndex, 0)
		_ReturnAsObj := MfBool.GetValue(ReturnAsObj, false)
		if (_startIndex < 0)
		{
			ex := new MfArgumentOutOfRangeException("startIndex")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (_startIndex >= (bytes.Count - 1))
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayPlusOffTooSmall"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}

		bArray := new MfByteList()
		i := 0
		while i < 2
		{
			index := i + _startIndex
			itm := bytes.Item[index]
			bArray.Add(itm)
			i++
		}
		if (MfBitConverter.IsLittleEndian)
		{
			bArray := MfBitConverter._SwapBytes(bArray)
		}
		retval := "0x"
		HexKey := MfBitConverter._GetFirstHexNumber(bArray.Item[0])
		bInfo := MfBitConverter.HexBitTable.Item[HexKey]
		IsNeg := bInfo.IsNeg
		if (IsNeg)
		{
			retval := "-" . retval
			for i, b in bArray
			{
				Hex1 := MfBitConverter._GetFirstHexNumber(b)
				Hex2 := MfBitConverter._GetSecondHexNumber(b)
				bInfo1 := MfBitConverter.HexBitTable.Item[Hex1]
				bInfo2 := MfBitConverter.HexBitTable.Item[Hex2]
				FlipHex := "0x" . bInfo1.HexFlip . bInfo2.HexFlip
				FlipHex := FlipHex + 0x0
				bArray.Item[i] := FlipHex
			}
		}

		for i , b in bArray
		{

			HexChar1 := MfBitConverter._GetFirstHexNumber(b)
			HexChar2 := MfBitConverter._GetSecondHexNumber(b)

			retval .= HexChar1 . HexChar2
		}
		retval := retval + 0x0
		if (IsNeg)
		{
			retval := retval - 0x1
		}
		if (_ReturnAsObj)
		{
			return new MfInt16(retval)
		}
		return retval
	}
; End:ToInt16 ;}
;{ ToInt32
	ToInt32(bytes, startIndex = 0, ReturnAsObj = false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(bytes, MfByteList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "bytes"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(bytes.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "bytes"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_startIndex := MfInt64.GetValue(startIndex, 0)
		_ReturnAsObj := MfBool.GetValue(ReturnAsObj, false)
		iMaxIndex := bytes.Count - 1
		if (_startIndex < 0)
		{
			ex := new MfArgumentOutOfRangeException("startIndex")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (_startIndex >= (bytes.Count - 3))
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayPlusOffTooSmall"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		bArray := new MfByteList()
		i := 0
		while i < 4
		{
			index := i + _startIndex
			itm := bytes.Item[index]
			bArray.Add(itm)
			i++
		}
		if (MfBitConverter.IsLittleEndian)
		{
			bArray := MfBitConverter._SwapBytes(bArray)
		}
		retval := "0x"
		HexKey := MfBitConverter._GetFirstHexNumber(bArray.Item[0])
		bInfo := MfBitConverter.HexBitTable.Item[HexKey]
		IsNeg := bInfo.IsNeg
		if (IsNeg)
		{
			retval := "-" . retval
			for i, b in bArray
			{
				Hex1 := MfBitConverter._GetFirstHexNumber(b)
				Hex2 := MfBitConverter._GetSecondHexNumber(b)
				bInfo1 := MfBitConverter.HexBitTable.Item[Hex1]
				bInfo2 := MfBitConverter.HexBitTable.Item[Hex2]
				FlipHex := "0x" . bInfo1.HexFlip . bInfo2.HexFlip
				FlipHex := FlipHex + 0x0
				bArray.Item[i] := FlipHex
			}
		}

		for i , b in bArray
		{

			HexChar1 := MfBitConverter._GetFirstHexNumber(b)
			HexChar2 := MfBitConverter._GetSecondHexNumber(b)

			retval .= HexChar1 . HexChar2
		}
		retval := retval + 0x0
		if (IsNeg)
		{
			retval := retval - 0x1
		}
		if (_ReturnAsObj)
		{
			return new MfInteger(retval)
		}
		return retval
	}
; End:ToInt32 ;}
;{ ToInt64
	ToInt64(bytes, startIndex = 0, ReturnAsObj = false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(bytes, MfByteList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "bytes"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(bytes.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "bytes"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_startIndex := MfInt64.GetValue(startIndex, 0)
		_ReturnAsObj := MfBool.GetValue(ReturnAsObj, false)
		iMaxIndex := bytes.Count - 1
		if (_startIndex < 0)
		{
			ex := new MfArgumentOutOfRangeException("startIndex")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (_startIndex >= (bytes.Count - 7))
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayPlusOffTooSmall"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		bArray := new MfByteList()
		i := 0
		while i < 8
		{
			index := i + _startIndex
			itm := bytes.Item[index]
			bArray.Add(itm)
			i++
		}
		if (MfBitConverter.IsLittleEndian)
		{
			bArray := MfBitConverter._SwapBytes(bArray)
		}
		retval := "0x"
		HexKey := MfBitConverter._GetFirstHexNumber(bArray.Item[0])
		bInfo := MfBitConverter.HexBitTable.Item[HexKey]
		IsNeg := bInfo.IsNeg
		if (IsNeg)
		{
			retval := "-" . retval
			for i, b in bArray
			{
				Hex1 := MfBitConverter._GetFirstHexNumber(b)
				Hex2 := MfBitConverter._GetSecondHexNumber(b)
				bInfo1 := MfBitConverter.HexBitTable.Item[Hex1]
				bInfo2 := MfBitConverter.HexBitTable.Item[Hex2]
				FlipHex := "0x" . bInfo1.HexFlip . bInfo2.HexFlip
				FlipHex := FlipHex + 0x0
				bArray.Item[i] := FlipHex
			}
		}

		for i , b in bArray
		{

			HexChar1 := MfBitConverter._GetFirstHexNumber(b)
			HexChar2 := MfBitConverter._GetSecondHexNumber(b)

			retval .= HexChar1 . HexChar2
		}
		retval := retval + 0x0
		if (IsNeg)
		{
			retval := retval - 0x1
		}
		if (_ReturnAsObj)
		{
			return new MfInt64(retval)
		}
		return retval
	}
; End:ToInt64 ;}
;{ ToFloat
	ToFloat(bytes, startIndex = 0, ReturnAsObj = false) {
		_ReturnAsObj := MfBool.GetValue(ReturnAsObj, false)
		int := MfBitConverter.ToInt64(bytes, startIndex, false)
		retval := MfBitConverter._Int64ToFloat(int)
		retval += 0.0
		if (_ReturnAsObj)
		{
			return new MfFloat(retval)
		}
		return retval
	}
; End:ToFloat ;}
;{ ToUInt64
	ToUInt64(bytes, startIndex = 0, ReturnAsObj = false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(bytes, MfByteList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "bytes"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(bytes.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "bytes"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_startIndex := MfInt64.GetValue(startIndex, 0)
		_ReturnAsObj := MfBool.GetValue(ReturnAsObj, false)
		iMaxIndex := bytes.Count - 1
		if (_startIndex < 0)
		{
			ex := new MfArgumentOutOfRangeException("startIndex")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (_startIndex >= (bytes.Count - 7))
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayPlusOffTooSmall"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		bArray := new MfByteList()
		i := 0
		while i < 8
		{
			index := i + _startIndex
			itm := bytes.Item[index]
			bArray.Add(itm)
			i++
		}
		if (MfBitConverter.IsLittleEndian)
		{
			;bArray := MfBitConverter._SwapBytes(bArray)
		}
		retval := MfBitConverter._LongHexArrayToLongInt(bArray)
		
		if (_ReturnAsObj)
		{
			return new MfUInt64(retval)
		}
		return retval
	}
; End:ToUInt64 ;}
;{ ToString
	ToString(bytes, returnAsObj = false, startIndex = 0, length="") {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(bytes, MfByteList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "bytes"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_returnAsObj := MfBool.GetValue(returnAsObj, false)
		_startIndex := MfInt64.GetValue(startIndex, 0)
		if (_startIndex < 0)
		{
			ex := new MfArgumentOutOfRangeException("startIndex", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_StartIndex"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (MfNull.IsNull(length)) {
			_length := bytes.Count - _startIndex
		}
		else
		{
			_length := MfInt64.GetValue(length)
		}
		if (_length < 0)
		{
			ex := new MfArgumentOutOfRangeException("length", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_GenericPositive"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}

		if (_startIndex > (bytes.Count - _length))
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayPlusOffTooSmall"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
		retval := ""
		i := _startIndex
		iCount := 0
		while i < _length
		{
			b := bytes.Item[i]
			bit1 := b // 16
			bit2 := Mod(b, 16)
			bitChar1 := MfBitConverter._GetHexValue(bit1)
			bitChar2 := MfBitConverter._GetHexValue(bit2)

			if (iCount > 0)
			{
				retval .= "-" . bitChar1 . bitChar2
			}
			Else
			{
				retval .= bitChar1 . bitChar2
			}
			i++
			iCount++
		}
		
		return _returnAsObj = true?new MfString(retval):retval
	}
; End:ToString ;}
;{ 	Methods
;{ Internal Methods
;{ 	_CompareUnSignedIntegerArraysLe
	_CompareUnSignedIntegerArraysLe(objA, objB) {
		
		if(objA.Count = 0)
		{
			return -1
		}
		if(objB.Count = 0)
		{
			return 1
		}
		x := objA.Count - 1
		y := objB.Count - 1
		
		While objA.Item[x] = 0 && x > -1
		{
			x--
		}
		While objB.Item[y] = 0 && y > -1
		{
			y--
		}
		if (x = 0 && y = 0)
		{
			NumA := objA.Item[x]
			MumB := objB.Item[y]
			if (NumA > MumB)
			{
				return 1
			}
			if (NumA < MumB)
			{
				return -1
			}
			return 0
		}
		
		if (x > y)
		{
			return 1
		}
		if (x < y)
		{
			return -1
		}
		; array non zero index are the same length
		xOffset := x
		yOffset := y
		while yOffset >= 0
		{
			NumA := objA.Item[xOffset]
			MumB := objB.Item[yOffset]
			if (NumA > MumB)
			{
				return 1
			}
			if (NumA < MumB)
			{
				return -1
			}
			xOffset--
			yOffset--
		}
		return 0
	}
; 	End:_CompareUnSignedIntegerArraysLe ;}
;{ _CompareUnSignedIntegerArraysBe
	_CompareUnSignedIntegerArraysBe(objA, objB) {
		
		if(objA.Count = 0)
		{
			return -1
		}
		if(objB.Count = 0)
		{
			return 1
		}
		x := 0
		y := 0
		
		While ((x < objA.Count) && (objA.Item[x] = 0))
		{
			x++
		}
		While ((y < objB.Count) && (objB.Item[y] = 0))
		{
			y++
		}
		if (x = 0 && y = 0)
		{
			NumA := objA.Item[x]
			MumB := objB.Item[y]
			if (NumA > MumB)
			{
				return 1
			}
			if (NumA < MumB)
			{
				return -1
			}
			return 0
		}
		
		xOffset := objA.Count - x
		yOffset := objA.Count - y
		if (xOffset > yOffset)
		{
			return 1
		}
		if (xOffset < yOffset)
		{
			return -1
		}
		; array non zero index are the same length
		xOffset := x
		yOffset := y
		while yOffset < objB.Count
		{
			NumA := objA.Item[xOffset]
			MumB := objB.Item[yOffset]
			if (NumA > MumB)
			{
				return 1
			}
			if (NumA < MumB)
			{
				return -1
			}
			xOffset++
			yOffset++
		}
		return 0
	}
; End:_CompareUnSignedIntegerArraysBe ;}
;{ 	_NibListMultiplyByNib
	_NibListMultiplyByNib(lst, iNib, ShiftAmount=0) {
		ans := new MfNibbleList()
		iCarry := 0
		i := lst.Count - 1
		bZero := true
		while i >= 0
		{
			n := lst.Item[i]
			p := (n * iNib) + iCarry
			R := 0
			iCarry := 0
			if (p > 0)
			{
				bZero := false
				iCarry := MfMath.DivRem(p, 16, R)
			}
			ans.Add(R)
			i--
		}
		if (bZero)
		{
			ans.Clear()
			ans.Add(0)
			return ans
		}
		While (iCarry > 0)
		{
			iCarry := MfMath.DivRem(iCarry, 16, R)
			ans.Add(R)
		}
		x := ans.count -1
		while ans.Item[x] = 0 && x >= 0
		{
			x--
		}
		result := new MfNibbleList()
		i := x
		while i >= 0
		{
			result.Add(ans.Item[i])
			i--
		}
		
		i := 0
		while i < ShiftAmount
		{
			result.Add(0)
			i++
		}
		
		return result
	}
; 	End:_NibListMultiplyByNib ;}
;{ 	_MultiplyNibList
	_MultiplyNibList(lstA, lstB){
		; Order of array is expected to be left to right making lst.Count -1 the MSB
		; in this method LstA.count is excpected to be Greater then or equal to  lstB.Count
		; lstB.Count tells us how many arrays will need to be added together in the end
		; lstA to be Multiplied by lstB
		lst := new MfList()
		
		
		iMaxIndexA := lstA.Count - 1
		iMaxIndexB := lstB.Count - 1
		
		x := 0
		While lstB.Item[x] = 0 && x < lstB.Count
		{
			x++
		}

		if (x >= lstB.Count)
		{
			return lstA
		}
		iStartIndexA := x
		i := iMaxIndexB
		iCount := 0
		jCount := 0
		While i >= iStartIndexA
		{
			n := lstB.Item[i]
			iResult := MfBitConverter._NibListMultiplyByNib(lstA, n, iCount)
			lst.Add(iResult)
			iCount ++
			i--
		}
		lstN := lst.Item[0]
		
		if (lst.Count <= 1)
		{
			return lstN
		}
		ans := new MfNibbleList()
		i := 0
		for i, n in lstN
		{
			ans.Add(n)
		}
		i := 0
		for i, obj in lst
		{
			if (i = 0)
			{
				continue
			}
			lstN := lst.Item[i]
			ans := MfBitConverter.NibbleListAdd(ans, lstN)
			
		}
		return ans
	}
; 	End:_MultiplyNibList ;}
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
;{ _GetFirstHexNumber
	_GetFirstHexNumber(byte) {
		Hex1 := byte // 16
		Hex := MfBitConverter._GetHexValue(Hex1)
		return Hex
	}
; End:_GetFirstHexNumber ;}
;{ _GetSecondHexNumber
	_GetSecondHexNumber(byte) {
		Hex1 := Mod(byte, 16)
		Hex := MfBitConverter._GetHexValue(Hex1)
		return Hex
	}
; End:_GetSecondHexNumber ;}
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
			return MfBitConverter._LongIntStringToHexArray(value, bitCount)
		}
		return MfBitConverter._IntToHexArray(value, bitCount)

	}
	_GetBytesUInt(value, bitCount = 32) {
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
		if (bitCount >= 64)
		{
			; remove any sign
			_val := value . ""
			if (_val ~= "^-[0-9]+$")
			{
				_val := SubStr(_val, 2, (StrLen(_val) -1))
			}
			else if (_val ~= "^\+[0-9]+$")
			{
				_val := SubStr(_val, 2, (StrLen(_val) -1))
			}
			if (!(_val ~= "^[0-9]+$"))
			{
				ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToInteger"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			; will handle negative and positive and convert to Little Endian
			return MfBitConverter._LongIntStringToHexArray(value, bitCount)
		}
		return MfBitConverter._IntToHexArray(Abs(value), bitCount)

	}

;{ _LongHexStringToLongInt
	; takse a MfByteList of hex values and converts to a postive string value of integer
	; in theroy no limit to the number of bytes that can be turned
	; into string integer
	_LongHexArrayToLongInt(lst) {
		; bInfo := MfBitConverter.HexBitTable.Item[lst.Item[0]]
		; IsNeg := bInfo.IsNeg
		bArray := new MfList()
		; remove leading zero's this should speed up long string
		; multiplers later on
		IsleadZero := true
		for i , b in lst
		{
			if ((IsleadZero = true) && (b = 0))
			{
				Continue
			}

			Hex1 := MfBitConverter._GetFirstHexNumber(b)
			Hex2 := MfBitConverter._GetSecondHexNumber(b)
			bInfo1 := MfBitConverter.HexBitTable.Item[Hex1]
			bInfo2 := MfBitConverter.HexBitTable.Item[Hex2]
			IsleadZero = False
			bArray.Add(bInfo1.HexValue)
			bArray.Add(bInfo2.HexValue)
		}

		sResult := "0"
		sCount := "1"
		iLoop := bArray.Count - 1
		iCount := 0
		sPower := "1"
		while iLoop >= 0
		{

			if (iCount > 0)
			{

				; we do not have a power of operater for long string so on each loop Multiply
				; to mimic the power of for hex
				sPower := MfUInt64._LongIntStringMult(sPower, 16)
			}
			b := bArray.Item[iLoop]
			bi := MfBitConverter.HexBitTable.Item[b]
			if (bi.IntValue > 0)
			{
				s := MfUInt64._LongIntStringMult(sPower, bi.IntValue)
				sResult := MfUInt64._LongIntStringAdd(sResult, s)
			}
			iCount++
			iLoop--
		}
		return sResult
	}
; End:_LongHexStringToLongInt ;}
	; takse a MfByteList of hex values and converts to a Negative string value of integer
	; in theroy no limit to the number of bytes that can be turned
	; into negative string integer
	_LongNegHexArrayToLongInt(lst){
		; known to be Negative so flip the Bits

		iMaxIndex := lst.Count - 1
		b := lst.Item[iMaxIndex]
		;lst.Item[iMaxIndex] := b >> 1

		bArray := MfBitConverter._FlipBytes(lst)

		;~ ; when negative Add 1
		IsAdded := MfBitConverter._AddOneToByteList(bArray, false)
		
		sResult := "-"
		sResult .= MfBitConverter._LongHexArrayToLongInt(bArray)
		return sResult
	}
;{ _IntToHexArray
	_IntToHexArray(value, bitCount = 32) {
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
		r := ""
		retval := ""
		
		IsNegative := false
		bArray := new MfByteList()
		ActualBitCount := bitCount // 4
		MaxMinValuCorrect := false
		if (value = 0)
		{
			while (bArray.Count * 2) < ActualBitCount
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
			
			byte := ""
			i := 0
			while i < 2
			{
				if (Result = 0)
				{
					break
				}
				r := Mod(Result, 16)
				Result := Result // 16

				if (r <= 9)
				{
					byte := r . byte
				}
				else if (r = 10)
				{
					byte := "A" . byte
				}
				else if (r = 11)
				{
					byte := "B" . byte
				}
				else if (r = 12)
				{
					byte := "C" . byte
				}
				else if (r = 13)
				{
					byte := "D" . byte
				}
				else if (r = 14)
				{
					byte := "E" . byte
				}
				else
				{
					byte := "F" . byte
				}
				i++
			}
			byte := "0x" . byte
			byte := byte + 0x0
			bArray.Add(byte)
		}
				
		if (IsNegative)
		{
			while (bArray.Count * 2) < ActualBitCount
			{
				bArray.Add(0)
			}
			;bArray := MfBitConverter._ReverseList(bArray)
			; flip all the bits
			bArray := MfBitConverter._FlipBytes(bArray)

			if (MaxMinValuCorrect = False)
			{
				;~ ; when negative Add 1
				IsAdded := MfBitConverter._AddOneToByteList(bArray)
			}
			;bArray := MfBitConverter._SwapBytes(bArray)
		}
		else ; if (IsNegative)
		{
			; add zero's to end of postivie array
			while (bArray.Count * 2) < ActualBitCount
			{
				bArray.Add(0)
			}
			;bArray := MfBitConverter._ReverseList(bArray)
			;bArray := MfBitConverter._SwapBytes(bArray)
			
		}
		return bArray
	}
; End:_IntToHexArray ;}
;{ _FlibBytes
	_FlipBytes(lst) {
		bArray := new MfByteList()
		iMaxIndex := lst.Count - 1
		for i, b in lst
		{

			Hex1 := MfBitConverter._GetFirstHexNumber(b)
			Hex2 := MfBitConverter._GetSecondHexNumber(b)

			bInfo1 := MfBitConverter.HexBitTable.Item[Hex1]
			bInfo2 := MfBitConverter.HexBitTable.Item[Hex2]
			
			strHex := MfString.Format("0x{0}{1}", bInfo1.HexFlip, bInfo2.HexFlip)
			hex := strHex + 0x0
			bArray.Add(hex)
		}
		return bArray
	}
; End:_FlibBytes ;}
	_FlipNibbles(lst) {
		nArray := new MfNibbleList()
		iMaxIndex := lst.Count - 1
		for i, b in lst
		{
			Hex := MfBitConverter._GetHexValue(b)
			bInfo := MfBitConverter.HexBitTable.Item[Hex]
			bInfoFlipped := MfBitConverter.HexBitTable.Item[bInfo.HexFlip]
			
			nArray.Add(bInfoFlipped.IntValue)
		}
		return nArray
	}
;{ _LongIntStringToHexArray
/*
	Method: _LongIntStringToHex()
		Converts Unsigned Integer String of numbers to Hex
	Parameters:
		strN
			String Unsigned Integer Number
	Returns:
		The the representation of strN as MfByteList of hex values in Litte Endian format
*/	
	_LongIntStringToHexArray(strN, bitCount = 32) {
		if ((bitCount > 0) && (Mod(bitCount, 4)))
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Value_Not_Divisable_By", "4"), "bitCount")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		r := ""
		retval := ""
		sResult := strN . ""
		IsNegative := false
		bArray := new MfByteList()
		ActualBitCount := 0
		KnownBitCount := false
		if (bitCount > 0)
		{
			KnownBitCount := true
			ActualBitCount := bitCount // 4
		}
		

		if ((MfString.IsNullOrEmpty(sResult) = true)
			|| (sResult = "0"))
		{
			bArray.Add(0)
			while (bArray.Count * 2) < ActualBitCount
			{
				bArray.Add(0)
			}
			return bArray
		}
		if (sResult ~= "^-[0-9]+$")
		{
			IsNegative := true
			sResult := SubStr(sResult, 2, (StrLen(sResult) -1))
		}
		else if (sResult ~= "^\+[0-9]+$")
		{
			sResult := SubStr(sResult, 2, (StrLen(sResult) -1))
		}
		if (!(sResult ~= "^[0-9]+$"))
		{
			ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToInteger"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		loop
		{
			byte := ""
			i := 0
			while i < 2
			{
				if (sResult = "0")
				{
					break
				}
				sResult := MfBitConverter._LongIntStringDivide(sResult, 16, r)
				r := r + 0 ; convert to integer
				if (r <= 9)
				{
					byte := r . byte
				}
				else if (r = 10)
				{
					byte := "A" . byte
				}
				else if (r = 11)
				{
					byte := "B" . byte
				}
				else if (r = 12)
				{
					byte := "C" . byte
				}
				else if (r = 13)
				{
					byte := "D" . byte
				}
				else if (r = 14)
				{
					byte := "E" . byte
				}
				else
				{
					byte := "F" . byte
				}
				i++
			}
			byte := "0x" . byte
			byte := byte + 0x0
			bArray.Add(byte)

			if (sResult = "0")
			{
				break
			}
		}
		if (KnownBitCount = false)
		{
			; there is know know bit count but sign requires a bit
			bArray.Add(0)
		}
				
		if (IsNegative)
		{
			while (bArray.Count * 2 ) < ActualBitCount
			{
				bArray.Add(0)
			}
			;bArray := MfBitConverter._ReverseList(bArray)
			; flip all the bits
			bArray := MfBitConverter._FlipBytes(bArray)
			
			;~ ; when negative Add 1
			IsAdded := MfBitConverter._AddOneToByteList(bArray)

			
			;bArray := MfBitConverter._SwapBytes(bArray)
		}
		else ; if (IsNegative)
		{
			
			; add zero's to end of postivie array
			while (bArray.Count * 2) < ActualBitCount
			{
				bArray.Add(0)
			}
			;bArray := MfBitConverter._ReverseList(bArray)
			;bArray := MfBitConverter._SwapBytes(bArray)
			
		}
	
		return bArray
	}
; End:_LongIntStringToHexArray ;}
;{ _AddOneToByteList
	_AddOneToByteList(byref bArray, AddToFront = true) {
		
		IsAdded := false
		if ( AddToFront = true)
		{
			i := 0
			While i < bArray.Count
			{
				b := bArray.Item[i]
				if (b = 255)
				{
					bArray.Item[i] := 0
					i++
					continue
				}

				b++
				bArray.Item[i] := b

				IsAdded := true
				break
			}
		}
		else
		{
			i := bArray.Count - 1
			While i >= 0
			{
				b := bArray.Item[i]
				if (b = 255)
				{
					bArray.Item[i] := 0
					i--
					continue
				}

				b++
				bArray.Item[i] := b

				IsAdded := true
				break
			}
		}
		return IsAdded
	}
; End:_AddOneToByteList ;}
;{ _SwapBytes
	_SwapBytes(lst) {
		lstSwap := new MfByteList()

		i := lst.Count - 1
		while i >= 0
		{
			lstSwap.Add(lst.Item[i])
			i--
		}
		return lstSwap
	}
; End:_SwapBytes ;}
;{ _RemoveLeadingZeros
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

; 	End:_LongIntStringDivide ;}
;{ 	_LongIntStringDivide
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
		MfBinaryConverter._RemoveLeadingZeros(q)
		return q
	}
; End:_RemoveLeadingZeros ;}
;{ _ReverseList
	_ReverseList(lst) {
		iCount := lst.Count
		bArray := new MfByteList()
		while iCount > 0
		{
			index := iCount -1
			bArray.Add(lst.Item[index])
			iCount --
		}
		return bArray
	}
; End:_ReverseList ;}
;{ _FloatToInt64
	_FloatToInt64(input) {
		VarSetCapacity(Var, 8, 0)       ; Variable to hold integer
		NumPut(input, Var, 0, "Double" ) ; Input as Float
		retval := NumGet(Var, 0, "Int64") ; Retrieve it as 'Signed Integer 64'
		return retval
	}
; End:_FloatToInt64 ;}
;{ _Int64ToFloat
	_Int64ToFloat(input) {
		VarSetCapacity(Var, 8, 0)       ; Variable to hold integer
		NumPut(input, Var, 0, "Int64" ) ; Input as Float
		retval := NumGet(Var, 0, "Double") ; Retrieve it as 'Signed Integer 64'
		return retval
	}
; End:_Int64ToFloat ;}
;{ 	_NibListsAdd
	_NibListsAdd(lstA, lstB) {
		; lstA.Count is assumed to be greater then or equal to lstB.count
		aLong := Compare > 0
		
		ans := new MfNibbleList()
		iCarry := 0
		i := lstB.Count - 1
		offset := lstA.Count - lstB.Count
		iCount := 0
		while i >= 0
		{
			j := i + offset
			nA := lstA.Item[j]
			nB := lstB.Item[i]
			sum := (nA + nB) + iCarry
			R := 0
			if (sum > 0)
			{
				q := MfMath.DivRem(sum, 16, R)
				iCarry := q
			}
			ans.Add(R)
			i--
			iCount++
		}
		i :=  lstA.Count - 1 - iCount
		While (iCarry > 0)
		{
			R := 0
			if (i >= 0)
			{
				nA := lstA.Item[i]
				sum := nA  + iCarry
				iCarry := 0
				if (sum > 0)
				{
					iCarry := MfMath.DivRem(sum, 16, R)
				}
				i--
				iCount++
			}
			else
			{
				iCarry := MfMath.DivRem(iCarry, 16, R)
			}
			
			ans.Add(R)
		}
		; if there are any remainint elements in lstA add them to ans
		i := lstA.Count - 1 - iCount
		while i >= 0
		{
			ans.Add(lstA.Item[i])
			i--
			iCount++
		}
		
		; create a new list to hold the reverse nibbles
		result := new MfNibbleList()
		i := 0
				
		i := ans.count -1
		while i >= 0
		{
			result.Add(ans.Item[i])
			i--
		}
		return result
		
	}
; 	End:_NibListsAdd ;}
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
				Returns True
		*/
		IsLittleEndian[]
		{
			get {
				return true
			}
			set {
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
				ex.SetProp(A_LineFile, A_LineNumber, "IsLittleEndian")
				Throw ex
			}
		}
	; End:IsLittleEndian ;}
	;{ HexBitTable
		static m_HexBitTable := ""
		/*!
			Property: HexBitTable [get]
				Gets the HexBitTable value associated with the this instance
			Value:
				Var representing the HexBitTable property of the instance
			Remarks:
				Readonly Property
		*/
		HexBitTable[]
		{
			get {
				if (MfBitConverter.m_HexBitTable = "")
				{
					MfBitConverter.m_HexBitTable := new MfHashTable(16)
					MfBitConverter.m_HexBitTable.Add("0", new MfBitConverter.HexBitInfo("0", "F", "0000","1111", 0))
					MfBitConverter.m_HexBitTable.Add("1", new MfBitConverter.HexBitInfo("1", "E", "0001","1000", 1))
					MfBitConverter.m_HexBitTable.Add("2", new MfBitConverter.HexBitInfo("2", "D", "0010","1101", 2))
					MfBitConverter.m_HexBitTable.Add("3", new MfBitConverter.HexBitInfo("3", "C", "0011","1100", 3))
					MfBitConverter.m_HexBitTable.Add("4", new MfBitConverter.HexBitInfo("4", "B", "0100","1011", 4))
					MfBitConverter.m_HexBitTable.Add("5", new MfBitConverter.HexBitInfo("5", "A", "0101","1010", 5))
					MfBitConverter.m_HexBitTable.Add("6", new MfBitConverter.HexBitInfo("6", "9", "0110","1001", 6))
					MfBitConverter.m_HexBitTable.Add("7", new MfBitConverter.HexBitInfo("7", "8", "0111","1000", 7))

					MfBitConverter.m_HexBitTable.Add("8", new MfBitConverter.HexBitInfo("8", "7", "1000","0111", 8, true))
					MfBitConverter.m_HexBitTable.Add("9", new MfBitConverter.HexBitInfo("9", "6", "1001","0110", 9, true))
					MfBitConverter.m_HexBitTable.Add("A", new MfBitConverter.HexBitInfo("A", "5", "1010","0101", 10, true))
					MfBitConverter.m_HexBitTable.Add("B", new MfBitConverter.HexBitInfo("B", "4", "1011","0100", 11, true))
					MfBitConverter.m_HexBitTable.Add("C", new MfBitConverter.HexBitInfo("C", "3", "1100","0011", 12, true))
					MfBitConverter.m_HexBitTable.Add("D", new MfBitConverter.HexBitInfo("D", "2", "1101","0010", 13, true))
					MfBitConverter.m_HexBitTable.Add("E", new MfBitConverter.HexBitInfo("E", "1", "1000","0001", 14, true))
					MfBitConverter.m_HexBitTable.Add("F", new MfBitConverter.HexBitInfo("F", "0", "1111","0000", 15, true))
				}
				return MfBitConverter.m_HexBitTable
			}
			set {
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
				ex.SetProp(A_LineFile, A_LineNumber, "HexBitTable")
				Throw ex
			}
		}
	; End:HexBitTable ;}
; End:Properties ;}
;{ Internal Class HexBitInfo
	class HexBitInfo
	{
		__new(hv, hf, b, bf, int, Neg = false) {
			this.HexValue := hv
			this.HexFlip := hf
			this.Bin := b
			this.BinFlip := bf
			this.IntValue := int
			this.IsNeg := Neg
		}
		HexValue := ""
		HexFlip := ""
		Bin := ""
		BinFlip := ""
		IsNeg := False
		IntValue := 0
	}
; End:Internal Class HexBitInfo ;}
}