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
/*!
	Class: MfList
		MfList class exposes methods and properties used for common List and array type operations for strongly typed collections.
	Inherits:
		MfListBase
*/
class MfCharList extends MfListBase
{
	m_Encoding := ""
	m_sType := ""
	m_MaxCharSize := ""
	m_BytesPerChar := ""
	m_FirstNullChar := -1
;{ Constructor
	/*!
		Constructor: ()
			Initializes a new instance of the MfList class.
	*/
	__new(Size=0, Encoding="UTF-16") {
		if (this.__Class != "MfCharList")
		{
			throw new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Sealed_Class","MfStringBuilder"))
		}
		base.__new()
		Encoding := MfString.GetValue(Encoding)
		this.m_Encoding := Encoding
		default := 0
		size := MfInteger.GetValue(size, 0)
		If (size < 0)
		{
			ex := new MfArgumentOutOfRangeException("Size")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		If (default < 0 || default > 255)
		{
			ex := new MfArgumentOutOfRangeException("default")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}

		
		if (Encoding = "UTF-32")
		{
			this.m_BytesPerChar := 4
			this.m_sType := "UInt"
			this.m_MaxCharSize := 0xFFFFFFFF
		}
		else if (Encoding = "UTF-16" || Encoding = "CP1200")
		{
			this.m_BytesPerChar := 2
			this.m_sType := "UShort"
			this.m_MaxCharSize := 0xFFFF
		}
		else
		{
			this.m_BytesPerChar := 1
			this.m_sType := "UChar"
			this.m_MaxCharSize := 0xFF
		}
		if (Size > 0)
		{
			i := 1
			while (i <= size)
			{
				this.m_InnerList[i] := default
				i++
			}
			this.m_Count := i - 1
		}
	}
; End:Constructor ;}
;{ Methods
;{ 	Add()				- Overrides - MfListBase
/*
	Method: Add()
		Overrides MfListBase.Add()
		This method must be overridden in the derived class
	Add(obj)
		Adds an object to append at the end of the MfList
	Parameters
		obj
			The Object to locate in the MfList
	Returns
		Var containing Integer of the zero-based index at which the obj has been added.
	Throws
		Throws MfNullReferenceException if called as a static method.
*/
	Add(obj) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		_value := MfInt64.GetValue(obj)
		if (_value < 0 || _value > this.m_MaxCharSize)
		{
			ex := new MfArgumentOutOfRangeException("obj"
				, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper" 
				, "0", format(":i",this.m_MaxCharSize)))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		return this._Add(_value)
	}
	AddString(str, startIndex=0, length=-1) {
		ms := MfMemoryString.FromAny(str, this.m_Encoding)
		if (ms.Length = 0)
		return
		try
		{
			lst := ms.ToCharList(startIndex,length)
			mlst := lst.m_InnerList
			i := 1
			cnt := lst.m_Count
			while (i <= cnt)
			{
				this._add(mlst[i])
				i++
			}
			return this
		}
		catch e
		{
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
	}
;{ 	_Add
	_Add(int) {
		
		base._Add(int)
		If (this.m_FirstNullChar = -1 && MfMemStrView.IsIgnoreCharLatin1(int))
		{
			this.m_FirstNullChar := this.m_Count - 1
		}
		return this.m_Count - 1
	}
; 	End:_Add ;}
;	End:Add(value) ;}
;{ 	Clone
	Clone() {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		cLst := new MfCharList()
		cLst.Clear()
		bl := cLst.m_InnerList
		ll := this.m_InnerList
		i := 1
		while (i <= this.m_Count)
		{
			bl[i] := ll[i]
			i++
		}
		cLst.m_Count := this.m_Count
		return cLst
	}
; 	End:Clone ;}
;{ CompareTo
	CompareTo(obj, IgnoreCase=true) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		IgnoreCase := MfBool.GetValue(IgnoreCase, true)
		return MfCharList.Compare(this, obj, IgnoreCase)
	}
; End:CompareTo ;}
;{ 	Compare
	Compare(objA, objB, IgnoreCase=true) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfNull.IsNull(objA))
		{
			return -1
		}
		if (MfNull.IsNull(objB))
		{
			return 1
		}
		If (!MfObject.IsObjInstance(objA, MfCharList))
		{
			return - 1
		}
		If (!MfObject.IsObjInstance(objB, MfCharList))
		{
			return 1
		}
		if (objA.Count = 0)
		{
			return -1
		}
		if (objA.Count = 0)
		{
			return 1
		}
		IgnoreCase := MfBool.GetValue(IgnoreCase, true)
		if (IgnoreCase = false)
		{
			return this._CompareIgnoreCase(objA, objB)
		}
		a := objA.m_InnerList
		b := objB.m_InnerList
		numA := a[1]
		numB := b[1]
		comp := numA - numB
		if (comp != 0)
		{
			return comp
		}

		i := objA.m_Count > objB.m_Count ? objB.m_Count : objA.m_Count
		j := 1
		a := objA.m_InnerList
		b := objB.m_InnerList
		num := -1
		While (i >= 5)
		{
			numA := a[j]
			numB := b[j]
			if (numA != numB)
			{
				num := 1
				break
			}
			numA := a[j + 1]
			numB := b[j + 1]
			if (numA != numB)
			{
				num := 2
				break
			}
			numA := a[j + 2]
			numB := b[j + 2]
			if (numA != numB)
			{
				num :=  3
				break
			}
			numA := a[j + 3]
			numB := b[j + 3]
			if (numA != numB)
			{
				num := 4
				break
			}
			numA := a[j + 4]
			numB := b[j + 4]
			if (numA != numB)
			{
				num := 5
				break
			}
			i -=  5
			j += 5
		}
		if (num != -1)
		{
			j := num
			numA := a[j]
			numB := b[j]
			result := numA - numB
			if (result != 0)
			{
				return result
			}
			numA := a[j + 1]
			numB := b[j + 1]
			return numA - numB
		}
		else
		{
			while (i > 0)
			{
				numA := a[j]
				numB := b[j]
				if (numA != numB)
				{
					break
				}
				i--
				j++
			}
			if (i <= 0)
			{
				; if the remaind chars in the obj with the greatet
				; count are all 0 then will ignore in comparsion
				if (objA.m_Count > objB.m_Count)
				{
					while (j <= objA.m_Count)
					{
						if (a[j] != 0)
						{
							return 1
						}
						j++
					}
				}
				else
				{
					while (j <= objB.m_Count)
					{
						if (b[j] != 0)
						{
							return -1
						}
						j++
					}
				}
				return 0
			}
			result := a[j] - b[j]
			if (result != 0)
			{
				return result
			}
			numA := a[j + 1] 
			numB := b[j + 1]
			return numA - numB
		}
	}
; 	End:Compare ;}
	_CompareIgnoreCase(objA, objB) {
		
		if (objA.Count = 0)
		{
			return -1
		}
		if (objA.Count = 0)
		{
			return 1
		}
		a := objA.m_InnerList
		b := objB.m_InnerList
		numA := a[1]
		numB := b[1]
		comp := numA - numB
		if (comp != 0)
		{
			return comp
		}

		i := objA.m_Count > objB.m_Count ? objB.m_Count : objA.m_Count
		j := 1
		a := objA.m_InnerList
		b := objB.m_InnerList
		num := -1
		While (i >= 5)
		{
			numA := a[j]
			numB := b[j]
			if (numA != numB)
			{
				If (MfMemStrView._IsLatin1(numA) && MfMemStrView._IsLatin1(numB))
				{
					if (!MfMemStrView._IsEqualLatin1IgnoreCase(numA, numB))
					{
						num := 1
						break
					}
				}
				else
				{
					chrA := Chr(NumA)
					chrB := Chr(NumB)
					if (!(chrA = chrB))
					{
						num := 1
						break
					}
				}
			}
			numA := a[j + 1]
			numB := b[j + 1]
			if (numA != numB)
			{
				If (MfMemStrView._IsLatin1(numA) && MfMemStrView._IsLatin1(numB))
				{
					if (!MfMemStrView._IsEqualLatin1IgnoreCase(numA, numB))
					{
						num := 2
						break
					}
				}
				else
				{
					chrA := Chr(NumA)
					chrB := Chr(NumB)
					if (!(chrA = chrB))
					{
						num := 2
						break
					}
				}
			}
			numA := a[j + 2]
			numB := b[j + 2]
			if (numA != numB)
			{
				If (MfMemStrView._IsLatin1(numA) && MfMemStrView._IsLatin1(numB))
				{
					if (!MfMemStrView._IsEqualLatin1IgnoreCase(numA, numB))
					{
						num := 3
						break
					}
				}
				else
				{
					chrA := Chr(NumA)
					chrB := Chr(NumB)
					if (!(chrA = chrB))
					{
						num := 3
						break
					}
				}
			}
			numA := a[j + 3]
			numB := b[j + 3]
			if (numA != numB)
			{
				If (MfMemStrView._IsLatin1(numA) && MfMemStrView._IsLatin1(numB))
				{
					if (!MfMemStrView._IsEqualLatin1IgnoreCase(numA, numB))
					{
						num := 4
						break
					}
				}
				else
				{
					chrA := Chr(NumA)
					chrB := Chr(NumB)
					if (!(chrA = chrB))
					{
						num := 4
						break
					}
				}
			}
			numA := a[j + 4]
			numB := b[j + 4]
			if (numA != numB)
			{
				If (MfMemStrView._IsLatin1(numA) && MfMemStrView._IsLatin1(numB))
				{
					if (!MfMemStrView._IsEqualLatin1IgnoreCase(numA, numB))
					{
						num := 5
						break
					}
				}
				else
				{
					chrA := Chr(NumA)
					chrB := Chr(NumB)
					if (!(chrA = chrB))
					{
						num := 5
						break
					}
				}
			}
			i -=  5
			j += 5
		}
		if (num != -1)
		{
			j := num
			numA := a[j]
			numB := b[j]
			If (MfMemStrView._IsLatin1(numA) && MfMemStrView._IsLatin1(numB))
			{
				if (MfMemStrView._IsEqualLatin1IgnoreCase(numA, numB))
				{
					result := 0
				}
				Else
				{
					result := numA - numB
				}
			}
			else
			{
				chrA := Chr(NumA)
				chrB := Chr(NumB)
				if (chrA = chrB)
				{
					result := 0
				}
				else
				{
					result := numA - numB
				}
			}
			if (result != 0)
			{
				return result
			}
			numA := a[j + 1]
			numB := b[j + 1]
			If (MfMemStrView._IsLatin1(numA) && MfMemStrView._IsLatin1(numB))
			{
				if (MfMemStrView._IsEqualLatin1IgnoreCase(numA, numB))
				{
					result := 0
				}
				Else
				{
					result := numA - numB
				}
			}
			else
			{
				chrA := Chr(NumA)
				chrB := Chr(NumB)
				if (chrA = chrB)
				{
					result := 0
				}
				else
				{
					result := numA - numB
				}
			}
			return result
		}
		else
		{
			while (i > 0)
			{
				numA := a[j]
				numB := b[j]
				if (numA != numB)
				{
					If (MfMemStrView._IsLatin1(numA) && MfMemStrView._IsLatin1(numB))
					{
						if (!MfMemStrView._IsEqualLatin1IgnoreCase(numA, numB))
						{
							break
						}
					}
					else
					{
						chrA := Chr(NumA)
						chrB := Chr(NumB)
						if (!(chrA = chrB))
						{
							break
						}
					}
				}
				i--
				j++
			}
			if (i <= 0)
			{
				; if the remaind chars in the obj with the greatet
				; count are all 0 then will ignore in comparsion
				if (objA.m_Count > objB.m_Count)
				{
					while (j <= objA.m_Count)
					{
						if (a[j] != 0)
						{
							return 1
						}
						j++
					}
				}
				else
				{
					while (j <= objB.m_Count)
					{
						if (b[j] != 0)
						{
							return -1
						}
						j++
					}
				}
				return 0
			}
			numA := a[j]
			numB := b[j]
			If (MfMemStrView._IsLatin1(numA) && MfMemStrView._IsLatin1(numB))
			{
				if (!MfMemStrView._IsEqualLatin1IgnoreCase(numA, numB))
				{
					result := numA - numB
				}
			}
			else
			{
				chrA := Chr(NumA)
				chrB := Chr(NumB)
				if (!(chrA = chrB))
				{
					result := numA - numB
				}
			}
			if (result != 0)
			{
				return result
			}
			numA := a[j + 1] 
			numB := b[j + 1]
			If (MfMemStrView._IsLatin1(numA) && MfMemStrView._IsLatin1(numB))
			{
				if (!MfMemStrView._IsEqualLatin1IgnoreCase(numA, numB))
				{
					result := numA - numB
				}
			}
			else
			{
				chrA := Chr(NumA)
				chrB := Chr(NumB)
				if (!(chrA = chrB))
				{
					result := numA - numB
				}
			}
			return result
		}
	}
	Contains(obj, IgnoreCase=true) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		IgnoreCase := MfBool.GetValue(IgnoreCase, true)
		if (this.IndexOf(obj,,IgnoreCase) >= 0)
		{
			return true
		}
		Return false
	}
;{ 	GetEnumerator()
/*
		Method: GetEnumerator()
			GetEnumerator() Gets an enumerator
		Remarks:
			Returns an enumerator that iterates through a collection.  
		Returns:
			Returns an enumerator that iterates through a collection.
		Throws:
			Throws MfNotImplementedException if _NewEnum() Method has not been overridden in derived class.
*/
	GetCharEnumerator() {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		return new MfCharList.CharEnumerator(this)
	}
; End:GetEnumerator() ;}
	IndexOf(obj, StartIndex=0, Count=-1, IgnoreCase=true) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		StartIndex := MfInteger.GetValue(StartIndex, 0)
		Count := MfInteger.GetValue(Count, -1)
		IgnoreCase := MfBool.GetValue(IgnoreCase, true)
		if (StartIndex < 0 || StartIndex >= this.m_Count)
		{
			ex := new MfArgumentOutOfRangeException("StartIndex",MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (Count = 0)
		{
			return -1
		}
		if (Count < 0)
		{
			count := this.m_Count - StartIndex
		}
		if (Count - StartIndex > this.m_Count)
		{
			ex := new MfArgumentOutOfRangeException("Count",MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_IndexLength"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (IsObject(obj))
		{
			if (!MfObject.IsObjInstance(obj, MfObject))
			{
				return -1
			}
			If (MfObject.IsObjInstance(obj, MfCharList))
			{
				if(obj.m_Count = 0)
				{
					return -1
				}
				return this._indexOfLst(obj, StartIndex, Count)
			}
			T := obj.GetType()
			if (t.IsIntegerNumber)
			{
				return this._indexOf(obj.Value, StartIndex, Count,IgnoreCase)
			}
			if (T.IsString)
			{
				if (obj.Length = 0)
				{
					Return -1
				}
				if (obj.Length = 1)
				{
					num := Asc(obj.Value)
					return this._indexOf(num, StartIndex, Count,IgnoreCase)
				}
				lst := new MfCharList(0, this.m_Encoding)
				lst.AddString(obj.Value)
				return this._indexOfLst(lst, StartIndex, Count,IgnoreCase)
			}
			if (T.IsChar)
			{
				return this._indexOf(obj.CharCode, StartIndex, Count,IgnoreCase)
			}
			if (T.IsUInt64)
			{
				if (obj.LessThenOrEqual(this.m_MaxCharSize))
				{
					num := obj.Value + 0
					return this._indexOf(num, StartIndex, Count,IgnoreCase)
				}
				return -1
			}
			if (T.IsBigInt)
			{
				if (obj.GreaterThenOrEqual(0) && obj.LessThenOrEqual(this.m_MaxCharSize))
				{
					num := obj.Value + 0
					return this._indexOf(num, StartIndex, Count, IgnoreCase)
				}
				return -1
			}
		}
		else
		{
			if (Mfunc.IsInteger(obj))
			{
				if (obj < 0 || obj > this.m_MaxCharSize)
				{
					return -1
				}
				; integer values from 0 to 9 for var will be treated as string and not integer
				; this is because it is not likely that a user would search for values between 0 and 9 as char code
				; to search for charcode from 0 to 9 user muset input as supported MfObject such as MfChar
				; or Mfbyte or MfInteger
				If (obj <= 0 && obj <= 9)
				{
					num := Chr(obj)
					return this._indexOf(num, StartIndex, Count, IgnoreCase)
				}
				return this._indexOf(obj, StartIndex, Count, IgnoreCase)
			}
			len := StrLen(obj)
			if (len = 0)
			{
				return - 1
			}
			if (len = 1)
			{
				num := Asc(obj)
				return this._indexOf(num, StartIndex, Count, IgnoreCase)
			}
			lst := new MfCharList(0, this.m_Encoding)
			lst.AddString(obj)
			return this._indexOfLst(lst, StartIndex, Count, IgnoreCase)
		}
		return -1
	}

	_indexOf(num, StartIndex=0, Count=-1, IgnoreCase=true) {
		if (Count = 0)
		{
			return -1
		}
		if (Count < 0)
		{
			count := this.m_Count - StartIndex
		}
		if (num < 0 || num > this.m_MaxCharSize)
		{
			return -1
		}
		if (this.m_Count = 0)
		{
			return -1
		}
		a := this.m_InnerList
		i := StartIndex + 1
		cnt := MfMath.Min(StartIndex + count, this.m_Count)
		NeedleFirtChar := ""
		if (!IgnoreCase)
		{
			NeedleFirtChar := Chr(num)
		}
		if (IgnoreCase)
		{
			while (i <= cnt)
			{
				n := a[i]
				if (n = num)
				{
					return i - 1
				}
				i++
			}
		}
		else
		{
			while (i <= cnt)
			{
				n := a[i]
				if (n = num)
				{
					return i - 1
				}
				If (MfMemStrView._IsLatin1(n))
				{
					if (MfMemStrView._IsEqualLatin1IgnoreCase(n, num))
					{
						return i - 1
					}
					
				}
				else
				{
					C := Chr(n)
					if (c = NeedleFirtChar)
					{
						return i - 1
					}
				}
				i++
			}
		}
		return -1
	}

	_indexOfLst(obj, StartIndex=0, Count=-1, IgnoreCase=true) {
		if (Count = 0)
		{
			return -1
		}
		if (Count < 0)
		{
			count := this.m_Count - StartIndex
		}
		if (obj.m_Count = 0)
		{
			return -1
		}
		if (this.m_Count = 0)
		{
			return -1
		}
		needleSize := obj.m_Count
		a := this.m_InnerList
		b := obj.m_InnerList
		NeedleFirstNum := b[1]
		if (NeedleFirstNum = 0)
		{
			return -1
		}
		NeedleFirtChar := ""
		if (!IgnoreCase)
		{
			NeedleFirtChar := Chr(b[1])
		}
		
				
		i := StartIndex + 1
		MatchCount := 0
		iCount = 0
		maxCount := MfMath.Min(StartIndex + count, this.m_Count)
		while ( i <= maxCount)
		{
			; iCount++
			; if (iCount > maxCount)
			; {
			; 	return -1
			; }
			Num1 := a[i]
			if (MatchCount = 0)
			{
				if (Num1 = NeedleFirstNum)
				{
					MatchCount++
					if (MatchCount = needleSize)
					{
						break
					}
					i++
					continue
				}
				if (!IgnoreCase)
				{
					If (MfMemStrView._IsLatin1(Num1) && MfMemStrView._IsLatin1(NeedleFirstNum))
					{
						if (MfMemStrView._IsEqualLatin1IgnoreCase(Num1, NeedleFirstNum))
						{
							MatchCount++
							if (MatchCount = needleSize)
							{
								break
							}
						}
					}
					else
					{
						Char1 := Chr(Num1)
						if (Char1 = NeedleFirtChar)
						{
							MatchCount++
							if (MatchCount = needleSize)
							{
								break
							}
						}
					}
					i++
					continue
				}
				MatchCount := 0
				i++
				continue
			}
			; matchcount is greater then 0
			Num2 := b[MatchCount + 1]
			if (Num1 = Num2)
			{
				MatchCount++
				if (MatchCount = needleSize)
				{
					break
				}
				i++
				continue
			}
			if (!IgnoreCase)
			{
				If (MfMemStrView._IsLatin1(Num1) && MfMemStrView._IsLatin1(Num2))
				{
					if (MfMemStrView._IsEqualLatin1IgnoreCase(Num1, Num2))
					{
						MatchCount++
						if (MatchCount = needleSize)
						{
							break
						}
						i++
						Continue
					}
				}
				else
				{
					Char1 := Chr(Num1)
					Char2 := Chr(Num2)
					if (Char1 = Char2)
					{
						MatchCount++
						if (MatchCount = needleSize)
						{
							break
						}
						i++
						Continue
					}
				}
			}
			MatchCount := 0
			i++
		}
		if (MatchCount = needleSize)
		{
			return i - MatchCount
		}
		Return -1
	}

;{ Equals
	Equals(obj) {
		if (MfNull.IsNull(obj))
		{
			return false
		}
		If (!MfObject.IsObjInstance(obj, MfCharList))
		{
			return false
		}
		if (this.m_Count = 0 && obj.m_Count = 0)
		{
			return true
		}
		i := this.m_Count > obj.m_Count ? obj.m_Count : this.m_Count
		if (i = 0)
		{
			return false
		}
		a := this.m_InnerList
		b := obj.m_InnerList
		j := 1
		while (i > 0)
		{
			numA := a[j]
			numB := b[j]
			if (numA != NumB)
			{
				return false
			}
			i--
			j++
		}
		if (this.m_Count > obj.m_Count)
		{
			while (j <= this.m_Count)
			{
				if (a[j] != 0)
				{
					return false
				}
				j++
			}
		}
		else
		{
			while (j <= obj.m_Count)
			{
				if (b[j] != 0)
				{
					return false
				}
				j++
			}
		}
		return true

	}
; End:Equals ;}
;{ 	Insert()			- Overrides - MfListBase
/*!
	Method: Insert()
		Overrides MfListBase.Insert()
	Insert(index, obj)
		Inserts an element into the MfList at the specified index.
	Parameters
		index
			The zero-based index at which value should be inserted.
		obj
			The object to insert.
	Throws
		Throws MfNullReferenceException if called as a static method.
		Throws MfArgumentOutOfRangeException if index is less than zero.-or index is greater than MfList.Count
		Throws MfArgumentException if index is not a valid Integer object or valid var Integer.
		Throws MfNotSupportedException if MfList is read-only or Fixed size.
	Remarks
		If index is equal to Count, value is added to the end of MfGenericList.
		In MfList the elements that follow the insertion point move down to accommodate the new element.
		This method is an O(n) operation, where n is Count.
*/
	Insert(index, obj) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		_index := MfInteger.GetValue(index)
		if (this.AutoIncrease = true)
		{
			If (_index >= this.m_Count)
			{
				this.m_FirstNullChar := this.m_Count
			}
			
			While (_index >= this.m_Count)
			{
				this._AutoIncrease()
			}
		}
		if ((_index < 0) || (_index > this.Count))
		{
			ex := new MfArgumentOutOfRangeException("index", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_value := MfInt64.GetValue(obj)
		if (_value < 0 || _value > this.m_MaxCharSize)
		{
			ex := new MfArgumentOutOfRangeException("obj"
				, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper" 
				, "0", format(":i",this.m_MaxCharSize)))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		If (_index = this.m_Count)
		{
			this._Add(_value)
			return
		}
		i := _index + 1 ; step up to one based index for AutoHotkey array
		this.m_InnerList.InsertAt(i, _value)
		this.m_Count++
		If (this.m_FirstNullChar = -1 && MfMemStrView.IsIgnoreCharLatin1(_value))
		{
			this.m_FirstNullChar := this.m_Count - 1
		}
	}
;	End:Insert(index, obj) ;}
	Remove(obj,StartIndex=0, Count=-1, ignoreCase=true, RemoveAll=false) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		StartIndex := MfInteger.GetValue(StartIndex, 0)
		Count := MfInteger.GetValue(Count, -1)
		IgnoreCase := MfBool.GetValue(IgnoreCase, true)
		RemoveAll := MfBool.GetValue(RemoveAll, false)
		if (StartIndex < 0 || StartIndex >= this.m_Count)
		{
			ex := new MfArgumentOutOfRangeException("StartIndex",MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (Count = 0)
		{
			return
		}
		if (Count < 0)
		{
			count := this.m_Count - StartIndex
		}
		if (Count - StartIndex > this.m_Count)
		{
			ex := new MfArgumentOutOfRangeException("Count",MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_IndexLength"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (MfNull.IsNull(obj))
		{
			ex := new MfArgumentNullException("obj")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		;return this._Remove(obj, StartIndex, Count, ignoreCase)
		a := this._GetValueLengthType(obj)
		if (a[3] = -1)
		{
			return
		}
		if (RemoveAll = fasle)
		{
			idx := this._RemoveHelper(a,StartIndex, Count, ignoreCase)
			return
		}
		else
		{
			rep := this._GetReplaceIndexs(a, StartIndex, Count, ignoreCase)
			if (rep.m_Count = 0)
			{
				return
			}
			rlst := rep.m_InnerList
			i := rep.m_Count
			len := a[2]
			; remove the index in reverse order to avoid remove incorrect chars
			while (i >= 1)
			{
				this._RemoveAt(rlst[i], len)
				i--
			}
		}
		
	}

	_GetReplaceIndexs(a, startIndex, count, IgnoreCase) {
		replacements := new MfListVar()
		If (startIndex >= count)
		{
			return replacements
		}
		if (a[3] = -1)
		{
			return -1
		}
		searchLen := a[2]
		st := a[3]
		if (searchLen = 0)
		{
			return replacements
		}
		if (st = "s" || st = "l")
		{
			lst := ""
			if (st = "s")
			{
				lst := new MfCharList(0, this.m_Encoding)
				lst.AddString(a[1])
			}
			else
			{
				lst := a[1]
			}
			idx := startIndex
			while (idx >= 0)
			{
				idx := this._indexOfLst(lst, idx, Count, IgnoreCase)
				if (idx >= 0)
				{
					replacements.Add(idx)
					idx += searchLen
					if (idx >= Count)
					{
						break
					}
				}
				else
				{
					break
				}

			}
		}
		if (st = "i")
		{
			j := a[1]

			idx := startIndex
			while (idx >= 0)
			{
				idx := this._indexOf(j, idx, Count, IgnoreCase)
				if (idx >= 0)
				{
					replacements.Add(idx)
					idx ++
					if (idx >= Count)
					{
						break
					}
				}
				else
				{
					break
				}
			}
		}
		return replacements
	}

	_RemoveHelper(a, StartIndex, Count, ignoreCase) {
		if (a[3] = -1)
		{
			return -1
		}
		obj := a[1]
		len := a[2]
		st := a[3]
		if (st = "i")
		{
			idx := this._indexOf(obj, StartIndex, Count, IgnoreCase)
			if (idx >= 0)
			{
				this._RemoveAt(idx, 1)
				return idx
			}
			return -1
		}
		if (st = "s")
		{
			lst := new MfCharList(0, this.m_Encoding)
			lst.AddString(obj)
			idx := this._indexOfLst(lst, StartIndex, Count, IgnoreCase)
			if (idx >= 0)
			{
				this._RemoveAt(idx, len)
				return idx
			}
			return -1
		}
		if (st = "l")
		{
			idx := this._indexOfLst(obj, StartIndex, Count, IgnoreCase)
			if (idx >= 0)
			{
				this._RemoveAt(idx, len)
				return idx
			}
			return -1
		}

	}

;{ 	_GetValueLengthType
	; gets an array of three values with information about the type
	; if not a valud type then array contains three -1 values
	; Returns Array
	;	Array[1] := the obj or obj value
	;	Array[2] := the length of the object as 1 or more
	;	Array[3] := the type of object
	;		l for List
	;		i for integer
	;		s for string
	_GetValueLengthType(obj) {
		result := []
		result[1] := -1
		result[2] := -1
		result[3] := -1
		if (IsObject(obj))
		{
			if (!MfObject.IsObjInstance(obj, MfObject))
			{
				return result
			}
			If (MfObject.IsObjInstance(obj, MfCharList))
			{
				if(obj.m_Count = 0)
				{
					return result
				}
				result[1] := obj
				result[2] := obj.m_Count
				result[3] := "l"
				return result
			}
			T := obj.GetType()
			if (t.IsIntegerNumber)
			{
				result[1] := obj.Value
				result[2] := 1
				result[3] := "i"
				return result
			}
			if (T.IsString)
			{
				if (obj.Length = 0)
				{
					return result
				}
				if (obj.Length = 1)
				{
					num := Asc(obj.Value)
					result[1] := num
					result[2] := 1
					result[3] := "i"
					return result
				}
				result[1] := obj.Value
				result[2] := obj.Length
				result[3] := "s"
				return result
			}
			if (T.IsChar)
			{
				result[1] := obj.CharCode
				result[2] := 1
				result[3] := "i"
				return result
			}
			if (T.IsUInt64)
			{
				if (obj.LessThenOrEqual(this.m_MaxCharSize))
				{
					num := obj.Value + 0
					result[1] := num
					result[2] := 1
					result[3] := "i"
					return result
				}
				return result
			}
			if (T.IsBigInt)
			{
				if (obj.GreaterThenOrEqual(0) && obj.LessThenOrEqual(this.m_MaxCharSize))
				{
					num := obj.Value + 0
					result[1] := num
					result[2] := 1
					result[3] := "i"
					return result
				}
				return result
			}
		}
		else
		{
			if (Mfunc.IsInteger(obj))
			{
				if (obj < 0 || obj > this.m_MaxCharSize)
				{
					return -1
				}
				; integer values from 0 to 9 for var will be treated as string and not integer
				; this is because it is not likely that a user would search for values between 0 and 9 as char code
				; to search for charcode from 0 to 9 user muset input as supported MfObject such as MfChar
				; or Mfbyte or MfInteger
				If (obj <= 0 && obj <= 9)
				{
					num := Chr(obj)
					result[1] := num
					result[2] := 1
					result[3] := "i"
					return result
				}
				result[1] := obj
				result[2] := 1
				result[3] := "i"
				return result
			}
			len := StrLen(obj)
			if (len = 0)
			{
				return result
			}
			if (len = 1)
			{
				num := Asc(obj)
				result[1] := num
				result[2] := 1
				result[3] := "i"
				return result
			}
			result[1] := obj
			result[2] := StrLen(obj)
			result[3] := "s"
			return result
		}
		return result
	}
; 	End:_GetValueLengthType ;}
	
	_Remove(obj, StartIndex=0, Count=-1, ignoreCase=true) {
		
		
		
		if (IsObject(obj))
		{
			if (!MfObject.IsObjInstance(obj, MfObject))
			{
				return
			}
			If (MfObject.IsObjInstance(obj, MfCharList))
			{
				if(obj.m_Count = 0)
				{
					return
				}
				idx := this._indexOfLst(obj, StartIndex, Count, IgnoreCase)
				if (idx >= 0)
				{
					this._RemoveAt(idx, obj.m_Count)
					return obj
				}
			}
			T := obj.GetType()
			if (t.IsIntegerNumber)
			{
				idx := this._indexOf(obj.Value, StartIndex, Count, IgnoreCase)
				if (idx >= 0)
				{
					this._RemoveAt(idx, 1)
					return obj
				}
			}
			if (T.IsString)
			{
				if (obj.Length = 0)
				{
					Return
				}
				if (obj.Length = 1)
				{
					num := Asc(obj.Value)
					idx := this._indexOf(num, StartIndex, Count, IgnoreCase)
					if (idx >= 0)
					{
						this._RemoveAt(idx, 1)
						return obj
					}
					return
				}
				lst := new MfCharList(0, this.m_Encoding)
				lst.AddString(obj.Value)
				idx := this._indexOfLst(lst, StartIndex, Count, IgnoreCase)
				if (idx >= 0)
				{
					this._RemoveAt(idx, obj.Length)
					return obj
				}
				return
			}
			if (T.IsChar)
			{
				idx := this._indexOf(obj.CharCode, StartIndex, Count, IgnoreCase)
				if (idx >= 0)
				{
					this._RemoveAt(idx, 1)
					return obj
				}
				return
			}
			if (T.IsUInt64)
			{
				if (obj.LessThenOrEqual(this.m_MaxCharSize))
				{
					num := obj.Value + 0
					idx := this._indexOf(num, StartIndex, Count, IgnoreCase)
					if (idx >= 0)
					{
						this._RemoveAt(idx, 1)
						return obj
					}
				}
				return
			}
			if (T.IsBigInt)
			{
				if (obj.GreaterThenOrEqual(0) && obj.LessThenOrEqual(this.m_MaxCharSize))
				{
					num := obj.Value + 0
					idx := this._indexOf(num, StartIndex, Count, IgnoreCase)
					if (idx >= 0)
					{
						this._RemoveAt(idx, 1)
						return obj
					}
					return
				}
				return
			}
		}
		else
		{
			if (Mfunc.IsInteger(obj))
			{
				if (obj < 0 || obj > this.m_MaxCharSize)
				{
					return -1
				}
				; integer values from 0 to 9 for var will be treated as string and not integer
				; this is because it is not likely that a user would search for values between 0 and 9 as char code
				; to search for charcode from 0 to 9 user muset input as supported MfObject such as MfChar
				; or Mfbyte or MfInteger
				If (obj <= 0 && obj <= 9)
				{
					num := Chr(obj)
					idx := this._indexOf(num, StartIndex, Count, IgnoreCase)
					if (idx >= 0)
					{
						this._RemoveAt(idx, 1)
						return obj
					}
					return
				}
				idx := this._indexOf(obj, StartIndex, Count, IgnoreCase)
				if (idx >= 0)
				{
					this._RemoveAt(idx, 1)
					return obj
				}
				return
			}
			len := StrLen(obj)
			if (len = 0)
			{
				return
			}
			if (len = 1)
			{
				num := Asc(obj)
				idx := this._indexOf(num, StartIndex, Count, IgnoreCase)
				if (idx >= 0)
				{
					this._RemoveAt(idx, 1)
					return obj
				}
			}
			lst := new MfCharList(0, this.m_Encoding)
			lst.AddString(obj)
			idx := this._indexOfLst(lst, StartIndex, Count, IgnoreCase)
			if (idx >= 0)
			{
				this._RemoveAt(idx, lst.m_Count)
				return obj
			}
			return
		}
		return
	}
	_RemoveAt(index, length) {
		if (index + length > this.m_Count)
		{
			ex := new MfArgumentOutOfRangeException("Count",MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_IndexLength"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}

		a := this.m_InnerList
		i := index + length
		while (i > index)
		{
			a.RemoveAt(i)
			i--
		}
		this.m_Count -= length
	}
	_FromSubList(startIndex, endIndex="") {
		lst := this.SubList(startIndex, endIndex)
		this.m_InnerList := ""
		this.m_InnerList := lst.m_InnerList
		this.m_Count := lst.m_Count

	}
;{ 	ToString
	ToString(returnAsObj = false, startIndex = 0, length="") {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		
		_returnAsObj := MfBool.GetValue(returnAsObj, false)
		_startIndex := MfInt64.GetValue(startIndex, 0)
		if (_startIndex < 0)
		{
			ex := new MfArgumentOutOfRangeException("startIndex", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_StartIndex"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_length := MfInteger.GetValue(length, this.m_Count - _startIndex)
		
		if (_length < 0)
		{
			ex := new MfArgumentOutOfRangeException("length", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_GenericPositive"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}

		if (_startIndex > (this.m_Count - _length))
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayPlusOffTooSmall"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
		retval := ""
		mv := MfMemStrView.FromCharList(this,_startIndex, _length)
		if (this.m_FirstNullChar >= 0 && this.m_FirstNullChar < this.m_Count - 1)
		{
			retval := mv.GetStringIgnoreNull().ToString()
		}
		else
		{
			retval := mv.ToString()
		}
		
		return _returnAsObj = true?new MfString(retval):retval
	}
; 	End:ToString ;}
;{ 	SubList
	; The SubList() method extracts the elements from list, between two specified indices, and returns the a new list.
	; This method extracts the element in a list between "startIndex" and "endIndex", not including "endIndex" itself.
	; If "startIndex" is greater than "endIndex", this method will swap the two arguments, meaning lst.SubList(1, 4) == lst.SubList(4, 1).
	; If either "startIndex" or "endIndex" is less than 0, it is treated as if it were 0.
	; startIndex and endIndex mimic javascript substring
	; Params
	;	startIndex
	;		The position where to start the extraction. First element is at index 0
	;	endIndex
	;		The position (up to, but not including) where to end the extraction. If omitted, it extracts the rest of the list
	SubList(startIndex=0, endIndex="") {
		leftToRight := false
		startIndex := MfInteger.GetValue(startIndex, 0)
		endIndex := MfInteger.GetValue(endIndex, "NaN", true)
		leftToRight := MfBool.GetValue(leftToRight, false)
		maxIndex := this.Count - 1
		
		IsEndIndex := true
		if (endIndex == "NaN")
		{
			IsEndIndex := False
		}
		If (IsEndIndex = true && endIndex < 0)
		{
			endIndex := 0
		}
		if (startIndex < 0)
		{
			startIndex := 0
		}
		if ((IsEndIndex = false) && (startIndex = 0))
		{
			Return this.Clone()
		}
		if ((IsEndIndex = false) && (startIndex > maxIndex))
		{
			Return this.Clone()
		}
		if ((IsEndIndex = true) && (startIndex > endIndex))
		{
			; swap values
			tmp := startIndex
			startIndex := endIndex
			endIndex := tmp
		}
		if ((IsEndIndex = true) && (endIndex = startIndex))
		{
			return this.Clone()
		}
		if (startIndex > maxIndex)
		{
			return this.Clone()
		}
		if (IsEndIndex = true)
		{
			len :=  endIndex - startIndex
			if ((len + 1) >= this.Count)
			{
				return this.Clone()
			}
		}
		else
		{
			len := maxIndex
		}
		rLst := new MfCharList()
		rl := rLst.m_InnerList
		ll := this.m_InnerList
		if (leftToRight)
		{
			i := startIndex + 1 ; Move to one base index
			len++ ; move for one based index
			while (i <= len)
			{
				rl[i] := ll[i]
				i++
			}
			rLst.m_Count := i - 1
			return rLst
		}
		i := 1
		iCount := 0
		if (IsEndIndex = true)
		{
			While ((iCount + len) < (this.Count - 1))
			{
				iCount++
			}
		}
		else
		{
			While ((iCount + (len - startIndex)) < (this.Count - 1))
			{
				iCount++
			}
		}
		while iCount < this.m_Count
		{
			iCount++
			rl[i] := ll[iCount]
			i++
			
		}
		
		rLst.m_Count := i - 1
		return rLst
	}
; 	End:SubList ;}
	_AutoIncrease()
	{
		if (this.IsFixedSize) {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_FixedSize"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (this.IsReadOnly) {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_List"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		If (this.m_Count < 1)
		{
			this.m_Count++
			this.m_InnerList[this.m_Count] := 0
			
			return
		}
		NewCount := this.m_Count * 2
		while this.m_Count < NewCount
		{
			this.m_Count++
			this.m_InnerList[this.m_Count] := 0
		}
	}
; End:Methods ;}
;{ Properties
	m_AutoIncrease := false
;{	AutoIncrease[]
/*
	Property: AutoIncrease [get]
		Gets a value indicating the list should Auto-Increase in size when Limit is reached
	Value:
		Var Bool
	Remarks"
		Gets/Sets if the List will auto increase when limit is reached.
*/
	AutoIncrease[]
	{
		get {
			return this.m_AutoIncrease
		}
		set {
			this.m_AutoIncrease := MfBool.GetValue(Value)
		}
	}
;	End:AutoIncrease[] ;}
/*
	Property: Char [get\set]
		Gets or sets the char element at the specified index.
	Parameters:
		index
			The zero-based index of the element to get or set.
		value
			the value of the item at the specified index
	Gets:
		Gets element at the specified index.
	Sets:
		Sets the char element at the specified index
	Throws:
		Throws MfArgumentOutOfRangeException if index is less than zero or index is equal to or greater than Count
		Throws MfArgumentException if index is not a valid MfInteger instance or valid var containing Integer
*/
	Char[index]
	{
		get {
			_index := MfInteger.GetValue(Index)
			if (_index < 0) {
				ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			if (_index >= this.m_Count)
			{
				if (this.AutoIncrease = true)
				{
					While _index >= this.m_Count
					{
						this._AutoIncrease()
					}
				}
				else
				{
					ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
			}
			_index++ ; increase value for one based array
			return Chr(this.m_InnerList[_index])
		}
		set {
			_index := MfInteger.GetValue(Index)
			
			if (_index < 0) {
				ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			if (_index >= this.m_Count)
			{
				if (this.AutoIncrease = true)
				{
					While _index >= this.m_Count
					{
						this._AutoIncrease()
					}
				}
				else
				{
					ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
			}
			_value := MfString.GetValue(value)
			_index++ ; increase value for one based array
			num := Asc(_value)
			this.m_InnerList[_index] := num
			If (this.m_FirstNullChar = -1 && MfMemStrView.IsIgnoreCharLatin1(num))
			{
				this.m_FirstNullChar := _index - 1
			}
			return this.m_InnerList[_index]
		}
	}
;{	Item[index]
/*
	Property: Item [get\set]
		Overrides MfListBase.Item
		Gets or sets the element at the specified index.
	Parameters:
		index
			The zero-based index of the element to get or set.
		value
			the value of the item at the specified index
	Gets:
		Gets element at the specified index.
	Sets:
		Sets the element at the specified index
	Throws:
		Throws MfArgumentOutOfRangeException if index is less than zero or index is equal to or greater than Count
		Throws MfArgumentException if index is not a valid MfInteger instance or valid var containing Integer
*/
	Item[index]
	{
		get {
			_index := MfInteger.GetValue(Index)
			if (_index < 0) {
				ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			if (_index >= this.m_Count)
			{
				if (this.AutoIncrease = true)
				{
					While _index >= this.m_Count
					{
						this._AutoIncrease()
					}
				}
				else
				{
					ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
			}
			_index++ ; increase value for one based array
			return this.m_InnerList[_index]
		}
		set {
			_index := MfInteger.GetValue(Index)
			
			if (_index < 0) {
				ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			if (_index >= this.m_Count)
			{
				if (this.AutoIncrease = true)
				{
					While _index >= this.m_Count
					{
						this._AutoIncrease()
					}
				}
				else
				{
					ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
			}
			_value := MfInt64.GetValue(value)
			if (_value < 0 || _value > this.m_MaxCharSize)
			{
				ex := new MfArgumentOutOfRangeException("value"
					, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper" 
					, "0", format(":i",this.m_MaxCharSize)))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			_index++ ; increase value for one based array
			this.m_InnerList[_index] := _value
			If (this.m_FirstNullChar = -1 && MfMemStrView.IsIgnoreCharLatin1(_value))
			{
				this.m_FirstNullChar := _index - 1
			}
			return this.m_InnerList[_index]
		}
	}
;	End:Item[index] ;}
; End:Properties ;}
;{ 		internal class CharEnumerator
	; can also enum itself
	; Example:
	;	enum := CharList.GetGetCharEnumerator()
	; 	For i, v in enum
	;	{
	;		MsgBox % v
	;	}
	; Example:
	;	enum := CharList.GetGetCharEnumerator()
	;	While (enum.Next(i, v))
	;	{
	;		MsgBox % v
	;	}
	class CharEnumerator
	{
		m_Parent := ""
		m_KeyEnum := ""
		m_index := 0
		m_count := 0
		m_InnerList := ""
		__new(ByRef ParentClass) {
			this.m_Parent := ParentClass
			this.m_count := this.m_Parent.Count
			this.m_InnerList := this.m_Parent.m_InnerList
		}

		Next(ByRef key, ByRef value)
		{
		
			if (this.m_index < this.m_count) {
				key := this.m_index
				value := Chr(this.m_InnerList[key + 1])
			}
			this.m_index++
			if (this.m_index > (this.m_count)) {
				return false
			} else {
				return true
			}
		}
		;{ 		_NewEnum
		/*
			Method: _NewEnum()
				Overrides MfEnumerableBase._NewEnum()
			_NewEnum()
				Returns a new enumerator to enumerate this object's key-value pairs.
				This method is usually not called directly, but by the for-loop or by GetEnumerator()
		*/
			_NewEnum() {
				return new MfCharList.CharEnumerator(this.m_Parent)
			}
		; 		End:_NewEnum ;}
	}
; 		End:class CharEnumerator ;}
}
/*!
	End of class
*/