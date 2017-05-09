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
class MfBinaryList extends MfListBase
{

;{ Constructor
	/*!
		Constructor: ()
			Initializes a new instance of the MfList class.
	*/
	__new(Size=0, default=0) {
		base.__new()
		size := MfInteger.GetValue(size, 0)
		default := MfInteger.GetValue(default, 0)
		If (size < 0)
		{
			ex := new MfArgumentOutOfRangeException("Size")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		If (default < 0 || default > 1)
		{
			ex := new MfArgumentOutOfRangeException("default")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
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
		
		_value := MfByte.GetValue(obj)
		if (_value < 0 || _value > 1)
		{
			ex := new MfArgumentOutOfRangeException("obj"
				, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper" 
				, "0", "1"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		this.m_Count++
		this.m_InnerList[this.m_Count] := _value
		
		return this.m_Count
	}
;	End:Add(value) ;}
;{ 	AddByte
	AddByte(obj) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		
		_value := MfByte.GetValue(obj)
		
		MSB := 0
		LSB := 0

		if (_value > 0) 
		{
			MSB := _Value // 16
			LSB := Mod(_Value, 16)
			LsbHex := MfNibConverter._GetHexValue(LSB)
			MsbHex := MfNibConverter._GetHexValue(MSB)
			LsbInfo := MfNibConverter.HexBitTable[LsbHex]
			MsbInfo := MfNibConverter.HexBitTable[MsbHex]
			strBin := MsbInfo.Bin
			Loop, Parse, strBin
			{
				this.m_Count++
				this.m_InnerList[this.m_Count] := A_LoopField
				
			}
			strBin := LsbInfo.Bin
			Loop, Parse, strBin
			{
				this.m_Count++
				this.m_InnerList[this.m_Count] := A_LoopField
			}
		}
		else
		{
			i := 0
			while i < 8
			{
				this.m_Count++
				this.m_InnerList[this.m_Count] := 0
				i++
			}
		}
		
	}
; 	End:AddByte ;}
;{ 	AddNibble
	AddNibble(obj) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		
		_value := MfByte.GetValue(obj)
		if (_value < 0 || _value > 15)
		{
			ex := new MfArgumentOutOfRangeException("obj"
				, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper" 
				, "0", "15"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		MSB := 0
		LSB := 0

		if (_value > 0) 
		{
			Hex := MfNibConverter._GetHexValue(_value)
			Info := MfNibConverter.HexBitTable[Hex]
			strBin := Info.Bin
			Loop, Parse, strBin
			{
				this.m_Count++
				this.m_InnerList[this.m_Count] := A_LoopField
			}
		}
		else
		{
			i := 0
			while i < 4
			{
				this.m_Count++
				this.m_InnerList[this.m_Count] := 0
				i++
			}
		}
		
	}
; 	End:AddNibble ;}
;{ 	Clone
	Clone() {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		cLst := new MfBinaryList()
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

	FromString(str) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		mStr := MfMemoryString.FromAny(str)
		len := mStr.Length

		lst := new MfBinaryList()

		if (len = 0)
		{
			lst.Add(0)
			lst.Add(0)
			return lst
		}
		ll := lst.m_InnerList
		iCount := 0
		i := 0
		While (i < len)
		{
			ch := mStr.CharCode[i++]
			if (ch = 48)
			{
				iCount++
				ll[iCount] := 0
			}
			else if (ch = 49)
			{
				iCount++
				ll[iCount] := 1
			}
		}
		
		lst.m_Count := iCount
		return lst

	}


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
			While _index >= this.Count
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
		_value := MfByte.GetValue(obj)
		if (_value < 0 || _value > 1)
		{
			ex := new MfArgumentOutOfRangeException("obj"
				, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper" 
				, "0", "1"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		base.Insert(i, _value)
		
	}
;	End:Insert(index, obj) ;}
;{ 	ToString
	ToString(returnAsObj = false, startIndex = 0, length="", Format=0) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		
		_returnAsObj := MfBool.GetValue(returnAsObj, false)
		_Format := MfInteger.GetValue(Format, false)
		_startIndex := MfInteger.GetValue(startIndex, 0)
		if (_startIndex < 0)
		{
			ex := new MfArgumentOutOfRangeException("startIndex", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_StartIndex"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_length := MfInteger.GetValue(length, this.Count - _startIndex)
		
		if (_length < 0)
		{
			ex := new MfArgumentOutOfRangeException("length", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_GenericPositive"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}

		if (_startIndex > (this.Count - _length))
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayPlusOffTooSmall"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (_Format = 1)
		{
			return this._ToByteArrayString(_returnAsObj, _startIndex, _length)
		}
		mStr := new MfMemoryString(_length,,"UTF-8")
		i := _startIndex
		iMaxIndex := _length - 1
		ll := this.m_InnerList
		while i <= iMaxIndex
		{
			n := ll[i + 1]
			if (n = 1)
			{
				mStr.AppendCharCode(49)
			}
			else
			{
				mStr.AppendCharCode(48)
			}
			
			i++
		}
		
		return _returnAsObj = true?new MfString(mStr.ToString()):mStr.ToString()
	}
; 	End:ToString ;}
;{ 		SubList
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
	SubList(startIndex=0, endIndex="", leftToRight=false) {
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
			Return this
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
			len := ((endIndex + 1) - startIndex)
			len := len > 0 ? len: 0
			if (len >= this.m_Count)
			{
				return this.Clone()
			}
		}
		else
		{
			len := maxIndex + 1
		}
		rLst := new MfBinaryList()
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
		
		i := startIndex
		cnt := this.m_Count
		j := 1
		While (j <= len)
		{
			rl[j++] := ll[cnt - i]
			i++
		}
		rLst.m_Count := len
		return rLst

	}
; 		End:SubList ;}
	_ToByteArrayString(returnAsObj, startIndex, length) {
		i := startIndex
		iMaxIndex := length -1
		len := iMaxIndex - startIndex
		mStr := new MfMemoryString(len * 2,, "UTF-8")
		iChunk := 0
		rem := Mod(this.Count, 4)
		iCount := 0
		if (rem > 0)
		{
			offset := (4 - rem)
			k := 0
			While k <= offset
			{
				mStr.Append("0")
				k++
			}
			iCount := offset
			;i += offset
		}
		ll := this.m_InnerList
		iLoopCount := 0
		while i <= iMaxIndex
		{
			if (iLoopCount > 0)
			{
				mStr.Append("-")
			}
			while iCount < 4
			{
				if (i > iMaxIndex)
				{
					break
				}
				n := ll[i + 1]
				if (n = 1)
				{
					mStr.AppendCharCode(49)
				}
				else
				{
					mStr.AppendCharCode(48)
				}
				;mStr.Append(ll[i + 1])
				iCount++
				i++
			}
			iLoopCount++
			iCount := 0
		}
		return returnAsObj = true?new MfString(mStr.ToString()):mStr.ToString()
	}
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
		If (this.Count < 1)
		{
			this.m_Count++
			this.m_InnerList[this.m_Count] := 0
			
			return
		}
		NewCount := this.Count * 2
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
			if (_index >= this.Count)
			{
				if (this.AutoIncrease = true)
				{
					While _index >= this.Count
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
			_index ++ ; increase value for one based array
			return this.m_InnerList[_index]
		}
		set {
			_index := MfInteger.GetValue(Index)
			
			if (_index < 0) {
				ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			if (_index >= this.Count)
			{
				if (this.AutoIncrease = true)
				{
					While _index >= this.Count
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
			_value := MfByte.GetValue(value)
			if (_value < 0 || _value > 1)
			{
				ex := new MfArgumentOutOfRangeException("value"
					, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper" 
					, "0", "1"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			_index ++ ; increase value for one based array
			this.m_InnerList[_index] := _value
			return this.m_InnerList[_index]
		}
	}
;	End:Item[index] ;}
; End:Properties ;}
}
/*!
	End of class
*/