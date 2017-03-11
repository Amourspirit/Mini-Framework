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
;{ 	Methods
;{ Internal Methods
	_GetBytesInt(value, bitCount = 32, PadLeft = false) {
		; int64 and UInt64 are identical as binary
		aValue := Abs(value)
		bArray := new MfList()
		SubBitCount := bitCount - 1
		if (value < 0)
		{
			i := Abs(value)
			; add pos neg bit
			while i
			{
				r:= (1 & i) = 1?0:1 ; flip bits
				i >>= 1
				bArray.Add(r)
				; if we have hit max count return
				; this will add all the bits from left to right up to the max of SubBitCount
				if (bArray.Count >= SubBitCount)
				{
					break
				}
			}
			; add 1
			; list is already reversed so add to start of list
			IsAdded := false
			for index, bit in bArray
			{
				if (IsAdded = false)
				{
					if (bit = 1)
					{
						bArray.Item[index] := 0
					}
					else
					{
						IsAdded := true
						bArray.Item[index] := 1
						Break
					}
				}
			}
			if (IsAdded = False)
			{
				bArray.Add(1)
			}
			iCount := bArray.Count
			iMax := SubBitCount
			While (iCount < iMax)
			{
				; add any missing flipped bits
				bArray.Add(1)
				iCount++
			}

			; array is reversed so add 1 for negative to end of array
			if (iCount < bitCount)
			{
				bArray.Add(1) ; first bit position
			}
			
		}
		else
		{
			i := value
			while i
			{
				r:= 1 & i
				i >>= 1
				bArray.Add(r)
				; if we have hit max count return
				; this will add all the bits from left to right up to the max of SubBitCount
				if (bArray.Count >= SubBitCount)
				{
					break
				}
			}
			if ((PadLeft = true) && (bArray.Count < bitCount))
			{
				while bArray.Count < bitCount
				{
					bArray.Add(0)
				}
			}
			if (bArray.Count = 0)
			{
				bArray.Add(0)
			}
		}

		bA := MfBinaryConverter._ReverseBinList(bArray)
		return bA
	}

	_GetBytesUInt(value, bitCount = 32, PadLeft = false) {
		; int64 and UInt64 are identical as binary
		; for UInt greater than 32 bit need to work out as string as 
		; AutoHotkey only supports 32 bit UInt
		if (bitCount > 32)
		{
			bArray := MfBinaryConverter._LongIntStringToBinArray(Value)
			if (bArray.Count > bitCount)
			{
				; If The bits returned are greater then the bitCount
				; then will only include bits from left to right up the
				; value of bitCount
				rArray := MfBinaryConverter._ReverseBinList(bArray)
				bArray := new MfList()
				index := rArray.Count - 1
				Loop
				{
					bArray.Add(rArray.Item[index])
					index--
					if (bArray.Count = bitCount)
					{
						break
					}
				}
			}
			if ((PadLeft = true) && (bArray.Count < bitCount))
			{
				while bArray.Count < bitCount
				{
					bArray.Insert(0, 0)
				}
			}
			if (bArray.Count = 0)
			{
				bArray.Add(0)
			}
			return bArray
		}
		bArray := new MfList()
		i := value
		while i
		{
			r:= 1 & i
			i >>= 1
			bArray.Add(r)
			; if we have hit max count return
			; this will add all the bits from left to right up to the max of bitCount
			if (bArray.Count >= bitCount)
			{
				break
			}
		}
		if ((PadLeft = true) && (bArray.Count < bitCount))
		{
			while bArray.Count < bitCount
			{
				bArray.Add(0)
			}
		}
		if (bArray.Count = 0)
		{
			bArray.Add(0)
		}
		bA := MfBinaryConverter._ReverseBinList(bArray)
		return bA
	}

;{ 	_LongIntStringToBinArray
	; convert uInt string into MfList of Bits
	; in theory no limit to length or size of number but number must be positive
	_LongIntStringToBinArray(strN) {
		r := ""
		sResult := strN . ""
		bArray := new MfList()
		if ((MfString.IsNullOrEmpty(sResult) = true)
			|| (sResult = "0"))
		{
			bArray.Add(0)
			return bArray
		}
		Loop 
		{
			sResult := MfBinaryConverter._LongIntStringDivide(sResult, 2, r)
			r := r + 0 ; convert to integer
			bArray.Add(r)
			if (sResult = "0")
			{
				break
			}
		}
		return bArray
	}
; 	End:_LongIntStringToBinArray ;}

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

	_ReverseBinList(lst) {
		iCount := lst.Count
		bArray := new MfList()
		while iCount > 0
		{
			index := iCount -1
			bArray.Add(lst.Item[index])
			iCount --
		}
		return bArray
	}
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
}