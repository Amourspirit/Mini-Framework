;{ 	class DList
; zero based index list that can contain var value of number or string
; adding of objects to this list is not supported
; List is case sensitive
; constructor parame Size determins the default number of element in the list
; constructor param default determinst the defalut value added to the list if Size is > 0
;	default can be null such as ""
class MfListVar extends MfListBase
{
	m_Default := ""
	__new(Size=0, default=0, IgnoreCase=true) {
		if (this.__Class != "MfListVar") {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Sealed_Class","MfListVar"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		base.__new()
		this.m_Default := default ; set in case new default items are added via Item property
		IgnoreCase := MfBool.GetValue(IgnoreCase, false)
		this.m_CaseSensitive := !IgnoreCase
		; test show adding via index is about 26 times faster then using Push
		; test was don by adding 1,000,000 zeros to a list
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
		this.m_isInherited := false
	}
	;{ 	Add()				- Overrides - MfListBase
/*
	Method: Add()
		Overrides MfList.Add()
		This method must be overridden in the derived class
	Add(obj)
		Adds an object to append at the end of the MfList
	Parameters
		obj
			The Object to locate in the MfList
	Returns
		Var containing Integer of the zero-based index at which the obj has been added.
*/
	Add(obj) {
		this.m_Count++
		this.m_InnerList[this.m_Count] := obj
		return this.m_Count
	}
;	End:Add(value) ;}
;{ 	Clone
	Clone() {
		cLst := new MfListVar()
		cLst.Clear()
		cl := cLst.m_InnerList
		ll := this.m_InnerList
		for i, v in ll
		{
			cl[i] := v
		}
		cLst.m_Count := this.Count
		return cLst
	}
; 	End:Clone ;}

;{ 	Contains()			- Overrides - MfListBase
/*!
	Method: Contains()
		Overrides MfListContains()
	Contains(obj)
		Determines whether the MfList contains a specific element.
	Parameters
		obj
			The Object to locate in the MfList
		Returns
			Returns true if the MfList contains the specified value otherwise, false.
	Remarks
		This method performs a linear search; therefore, this method is an O(n) operation, where n is Count.
		This method determines equality by calling MfObject.CompareTo().
*/
	Contains(obj) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		If(IsObject(obj))
		{
			return false
		}
		retval := false
		if (this.Count <= 0)
		{
			return retval
		}
		retval := this.IndexOf(obj, 0) > -1
		return retval
	}
;	End:Contains(obj) ;}
	FromString(s, includeWhiteSpace=true, IgnoreCase=true) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		IgnoreCase := MfBool.GetValue(IgnoreCase, true)
		s := MfString.GetValue(s)
		lst := new MfListVar()
		lstArray := []
		iCount := 0
		if (s = "")
		{
			return lst
		}
		i := 1
		if (includeWhiteSpace)
		{
			Loop, Parse, s
			{
				iCount++
				lstArray[iCount] := A_LoopField
			}
		}
		else
		{
			Loop, Parse, s
			{
				if (A_LoopField == " " || A_LoopField = "`r" || A_LoopField = "`n")
				{
					continue
				}
				iCount++
				lstArray[iCount] := A_LoopField
			}
		}
			
		lst.m_InnerList := lstArray
		lst.m_Count := iCount
		lst.CaseSensitive := !IgnoreCase
		return lst
	}
;{ 	IndexOf()			- Overrides - MfListBase
/*
	Method: IndexOf()
		Overrides MfList.IndexOf()
	IndexOf(obj)
		Searches for the specified Object and returns the zero-based index of the first occurrence within the entire MfList.
	Parameters
		obj
			The object to locate in the List, Objects are not supportd
	Returns
		Returns  index of the first occurrence of value within the entire MfList,
	Remarks
		This method performs a linear search; therefore, this method is an O(n) operation, where n is Count.
		This method determines equality by calling MfObject.CompareTo().
*/
	IndexOf(obj, startIndex=0) {
		startIndex := MfInteger.GetValue(startIndex)
		if (startIndex >= this.Count || startIndex < 0)
		{
			return -1
		}
		i := startIndex
		bFound := false
		If(IsObject(obj))
		{
			return -1
		}
		int := -1
		if (this.Count <= 0) {
			return int
		}
		i++ ; move for one based index
		if (this.m_CaseSensitive = true)
		{
			while (i <= this.Count)
			{
				v := this.m_InnerList[i] ; search inner list for faster searching
				if (obj == v) {
					bFound := true
					i-- ; reset for zero based index
					break
				}
				i++
			}
		}
		else
		{
			while (i <= this.Count)
			{
				v := this.m_InnerList[i] ; search inner list for faster searching
				if (obj = v) {
					bFound := true
					i-- ; reset for zero based index
					break
				}
				i++
			}
		}
		if (bFound = true) {
			int := i
			return int
		}
		return int
	}
;	End:IndexOf() ;}
;{ 	LastIndexOf()			- Overrides - MfListBase
/*
	Method: LastIndexOf()
		Overrides MfListBase.LastIndexOf()
	LastIndexOf(obj)
		Searches for the specified Object and returns the zero-based index of the Last occurrence within the entire MfList.
	Parameters
		obj
			The object to locate in the List, Objects are not supportd
	Returns
		Returns  index of the last occurrence of value within the entire List,
	Remarks
		This method performs a linear search; therefore, this method is an O(n) operation, where n is Count.
		This method determines equality by calling MfObject.CompareTo().
*/
	LastIndexOf(obj, startIndex=0) {
		startIndex := MfInteger.GetValue(startIndex)
		if (startIndex >= this.Count || startIndex < 0)
		{
			return -1
		}
		i := startIndex
		bFound := false
		If(IsObject(obj))
		{
			return -1
		}
		int := -1
		if (this.Count <= 0) {
			return int
		}
		i := this.Count ; one based index
		startIndex++ ; move to one base index
		if (this.m_CaseSensitive = true)
		{
			while (i >= startIndex)
			{
				v := this.m_InnerList[i] ; search inner list for faster searching
				if (obj == v) {
					bFound := true
					i-- ; reset for zero based index
					break
				}
				i--
			}
		}
		else
		{
			while (i >= startIndex)
			{
				v := this.m_InnerList[i] ; search inner list for faster searching
				if (obj = v) {
					bFound := true
					i-- ; reset for zero based index
					break
				}
				i--
			}
		}
		if (bFound = true) {
			int := i
			return int
		}
		return int
	}
;	End:IndexOf() ;}
	ToList() {
		return this._ToList()
	}
	; startIndex and endIndex mimic javascript substring
	ToString(seperator=",", startIndex=0, endIndex="") {
		retval := ""
		maxIndex := this.Count - 1
		IsEndIndex := true
		if (MfString.IsNullOrEmpty(endIndex))
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
		if ((IsEndIndex = false) && (startIndex > maxIndex))
		{
			Return retval
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
			return retval
		}
		if (startIndex > maxIndex)
		{
			return retval
		}
		if (IsEndIndex = true)
		{
			len :=  endIndex - startIndex
		}
		else
		{
			len := maxIndex + 1
		}
		i := startIndex
		iCount := 0
		ll := this.m_InnerList
		while (iCount < len)
		{
			v := ll[i + 1]
			if (i < maxIndex)
			{
				retval .= v . seperator
			}
			else
			{
				retval .= v
			}
			i++
			iCount++
		}
		return retval
	}
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
	SubList(startIndex=0, endIndex="", leftToRight=true) {
		startIndex := MfInteger.GetValue(startIndex, 0)
		endIndex := MfInteger.GetValue(endIndex, "NaN", true)
		leftToRight := MfBool.GetValue(leftToRight, true)
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
		rLst := new MfListVar()
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
			;lst.Add(this.Item[i])
			rl[i] := ll[iCount]
			i++
		}
		
		rLst.m_Count := i - 1
		return rLst
	}
; 		End:SubList ;}
;{ 	Properties
	;{ CaseSensitive
		m_CaseSensitive := true
		/*!
			Property: CaseSensitive [get/set]
				Gets or sets the CaseSensitive value associated with the this instance
			Value:
				Var representing the CaseSensitive property of the instance
		*/
		CaseSensitive[]
		{
			get {
				return this.m_CaseSensitive
			}
			set {
				this.m_CaseSensitive := MfBool.GetValue(value, true)
				return this.m_CaseSensitive
			}
		}
	; End:CaseSensitive ;}
;{	Item[index]
/*
	Property: Item [get\set]
		Overrides MfList.Item
		Gets or sets the element at the specified index.
		Will auto increase if index is less then Count -1
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
		Throws MfArgumentOutOfRangeException if index is less than zero
*/
	Item[index]
	{
		get {
			_index := MfInteger.GetValue(Index)
			if (_index < 0 || _index >= this.Count) {
				return ""
			}
			_index ++ ; increase value for one based array
			return this.m_InnerList[_index]
		}
		set {
			_index :=  MfInteger.GetValue(Index)
			if (_index >= this.Count) {
				ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			if (_index >= this.Count) {
				i := this.Count - 1
				while (i <= _index)
				{
					this.Add(this.m_Default)
					i++
				}
			}
			_index ++ ; increase value for one based array
			this.m_InnerList[_index] := value
			return this.m_InnerList[_index]
		}
	}
;	End:Item[index] ;}
;{ 	Properties
}

; 	End:class DList ;}