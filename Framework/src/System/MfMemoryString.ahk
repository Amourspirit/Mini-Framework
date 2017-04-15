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

/*
	Class MfMemoryString
	Internal class for working dircetly with memory strings
*/
class MfMemoryString extends MfObject
{
	m_Encoding := ""
	m_EncodingName := ""
	m_MemView := ""
	m_CharCount := 0
	m_BytesPerChar := ""
	m_FillBytes := ""
	m_Size := ""
	m_nl := ""
;{ 	Constructor
/*
	Constructor()
		Construct a new instance of the class
	Parameters:
		Size
			The buffer size of the instance
		FillByte
			The byte value to write into memory. Default is 0
		Encoding
			The encoding for the instane.
	Remarks:
		Encoding of Utf-16 requires two bytes per char and needs to be considered for choosing size
*/
	__New(Size, FillByte:=0, Encoding="UTF-16") {
		base.__New()
		this.m_nl := MfEnvironment.Instance.NewLine
		this.m_BytesPerChar := (Encoding = "UTF-16" || Encoding = "CP1600") ? 2 : 1
		StringReplace, _Encoding, Encoding, -, , ALL
		this.m_Encoding := Encoding
		this.m_EncodingName := _Encoding
		this.m_FillBytes := FillByte
		this.m_Size := Size
		this.m_MemView := new MfMemStrView(size, FillByte, this.m_Encoding)
	}
; 	End:Constructor ;}
;{ 	Append
/*
	Method: Append()

	Append()
		Appends a new value to the current instance
	Parameters:
		obj
			The value to append to the instance
			Can be instance of MfMemoryString or MfMemStrView or any object derived from MfObject
	Returns:
		Returns this instance
	Throws:
		Throws MfArgumentException
*/
	Append(obj)	{
		if (IsObject(obj))
		{
			if (MfObject.IsObjInstance(obj, MfMemoryString))
			{
				chars := this.m_MemView.Append(obj.m_MemView)
			}
			else if (MfObject.IsObjInstance(obj, MfString))
			{
				chars := this.m_MemView.AppendString(obj)
			}
			else if (MfObject.IsObjInstance(obj, MfObject))
			{
				chars := this.m_MemView.Append(obj)
			}
			Else
			{
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("NonMfObjectException_General"), "obj")
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}

		}
		else
		{
			chars := this.m_MemView.AppendString(obj)
		}
		this.m_CharCount += chars
		return this
	}
; 	End:Append ;}

	AppendLine() {
		chars := this.m_MemView.AppendString(this.m_nl)
		this.m_CharCount += chars
		return this
	}

	Clear() {
		this.m_CharCount := 0
		this.m_MemView := ""
		this.m_MemView := new MfMemStrView(this.m_Size, this.m_FillBytes, this.m_Encoding)
		return this
	}
	
	
	
	Clone() {
		objMemRW := new MfMemoryString(this.m_BytesPerChar, this.m_FillBytes, this.m_Encoding)
		objMemRW.m_MemView := ""
		objMemRW.m_MemView := this.m_MemView.Clone()
		objMemRW.m_CharCount := this.m_CharCount
		objMemRW.m_Size := objMemRW.m_MemView.Size
		return objMemRW
	}
	
	CompareOrdinal(str) {
		if (str == "")
		{
			return 1
		}
		mStr := this._FromAny(str)
		result := MfMemStrView.CompareOrdinal(this.m_MemView, mStr.m_MemView)
		return result
		
	}
;{ 	Difference
	/*
	Method: Difference(objA, maxDistance)
		Gets the Difference between argument obj and argument this instance with an included Max Distance.
		obj
			the obj to compare.
		maxDistance
			Integer tells the algorithm to stop if the strings are already too different.
	Returns:
		Returns returns the difference between the strings as a float between 0 and 1.
		0 means strings are identical. 1 means they have nothing in common.
*/
	Difference(obj, maxOffset=5) {
		if (MfNull.IsNull(obj))
		{
			return 1.0
		}
		
		wf := A_FormatFloat
		SetFormat, FloatFast, 0.15
		try
		{
			maxOffset := Abs(MfInteger.GetValue(maxOffset, 5))
			mStr := this._FromAny(obj)
			result := MfMemStrView.Diff(this.m_MemView, mStr.m_MemView, this.m_Encoding, maxOffset)
			return result
		}
		catch e
		{
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		finally
		{
			SetFormat, FloatFast, %wf%
		}
		
	}
; 	End:Difference ;}
;{ 	Equals
	/*
	Method: Equals()
		
	Equals()
		Checks to see if obj is equals this instance
	Parameters:
		obj
			Can be string var or instanc of MfMemoryString
		IgnoreCase
			Boolean value. If true case is ignored; Otherwise case is case is not ignored
	Returns:
		Returns true if obj is equal to this instance, Otherwide false.
	Throws:
		Throws MfArgumentException
*/
	Equals(obj, IgnoreCase=true) {
		IgnoreCase := MfBool.GetValue(IgnoreCase, true)
		mStr := this._FromAny(obj)
		return this.m_MemView.Equals(mStr.m_MemView, IgnoreCase)
	}
; 	End:Equals ;}
	
	IndexOf(obj, Offset=0) {
		if (MfNull.IsNull(obj))
		{
			return -1
		}
		Offset := Abs(MfInteger.GetValue(Offset, 0))
		if (OffSet < 0 || OffSet >= this.m_CharCount)
		{
			return -1
		}

		mStr := this._FromAny(obj)
		return this.m_MemView.InBuffer(mStr.m_MemView, Offset)
	}
	
	LastIndexOf(obj, EndOffset=-1) {
		if (MfNull.IsNull(obj))
		{
			return -1
		}
		EndOffset := MfInteger.GetValue(Offset, -1)
		if (EndOffset >= this.m_CharCount)
		{
			return -1
		}
		mStr := this._FromAny(obj)
		return this.m_MemView.InBufferRev(mStr.m_MemView, EndOffset)
	}
	
	EndsWith(obj, IgnoreCase=true) {
		IgnoreCase := MfBool.GetValue(IgnoreCase, true)
		mStr := this._FromAny(obj)
		if (mStr.m_MemView.Pos = 0)
		{
			return false
		}
		if (mStr.m_MemView.Pos > this.m_MemView.Pos)
		{
			return false
		}
		result := this.m_MemView.EndsWithFromPos(mStr.m_MemView, IgnoreCase)
		
		return result
	}
	
	Insert(index, obj) {
		if (MfNull.IsNull(obj))
		{
			ex := new MfArgumentNullException("obj")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		index := MfInteger.GetValue(index)
		if ((index < 0) || (index > this.m_CharCount))
		{
			ex := new MfIndexOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_IndexLength"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (index = this.m_CharCount)
		{
			return this.Append(obj)
		}
		mStr := this._FromAny(obj)
		try
		{
			cc := this.m_MemView.Insert(index, mStr.m_MemView)
		}
		catch e
		{
			e.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw e
		}
		
		this.m_CharCount := cc
		return this
	}
;{ 	Replace
/*
	Method: Replace()

	Replace()
		Replaces instances of oldValue with Instances of newValue
	Parameters:
		oldValue
			The Value to find and replace
		newValue
			The replacemet value
		startIndex
			the zero based index with this string to start looking for oldValue
		count
			The number of characters to limit the replacemt;
			Or -1 to replace all occurences in the string;
			Or -2 to replace only the first occurence in a string
	Returns:
		Returns the number of replacements made
	Throws:
		Throws MfArgumentNullException
		Throws MfIndexOutOfRangeException
	Remarks:
		If count is -1 then all instances of oldValue are replaced
		If count is -2 only the first instance of oldValue is replaced
		If newValue is empty the oldValue instances will be removed
*/
	Replace(oldValue, newValue, startIndex=0, count=-1) {
		
		if (this.m_CharCount = 0)
		{
			return 0
		}
		if (MfNull.IsNull(newValue))
		{
			ex := new MfArgumentNullException("newValue")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (MfNull.IsNull(oldValue))
		{
			ex := new MfArgumentNullException("oldValue")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		startIndex := MfInteger.GetValue(startIndex)
		if ((startIndex < 0) || (startIndex >= this.m_CharCount))
		{
			ex := new MfIndexOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_IndexLength"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
		count := MfInteger.GetValue(count)

		mStrNew := this._FromAny(newValue)
		mStrOld := this._FromAny(oldValue)

		; -2 represents replacing a single occurence
		if (Count = -2)
		{
			result := this._Replace(mStrOld, mStrNew, startIndex)
			if (result)
			{
				return 1
			}
			return 0
		}
		length := this.m_CharCount
		; -1 represents replacing all counts in the entire string
		if (count = -1)
		{
			count := length
		}

		if (count < 0 || startIndex > length - count)
		{
			return this
		}
		if (count <= 0)
		{
			return this
		}
		if (Count < length && startIndex > length - count)
		{
			return this
		}
		if (oldValue == "")
		{
			return this
		}
		NewLen := mStrNew.m_CharCount
		OldLen := mStrOld.m_CharCount
		fIndex := startIndex
		icount := 0
		loop
		{
			result := this._Replace(mStrOld, mStrNew, fIndex)
			if (result = false || fIndex >= count)
			{
				break
			}
			count -= OldLen
			iCount++
		}
		return iCount
	}
; 	End:Replace ;}
;{ 	_Replace
	; replace a single item
	; returns false if no replacement; Otherwise true
	_Replace(byRef mStrOld, ByRef mStrNew, ByRef startIndex) {
		startIndex := this.IndexOf(mStrOld, startIndex)
		if (startIndex = -1)
		{
			return false
		}
		this.Remove(startIndex, mStrOld.m_CharCount)
		If (mStrNew.m_CharCount > 0)
		{
			this.Insert(startIndex, mStrNew)
		}
		return true
	}
; 	End:_Replace ;}
	Remove(index, length=1) {
		index := MfInteger.GetValue(index)
		length := MfInteger.GetValue(length, 1)
		if ((index < 0) || (index >= this.m_CharCount))
		{
			return
		}
		if ((length < 0) || ((length + index) > this.m_CharCount))
		{
			return
		}
		StartPos := index * this.m_BytesPerChar
		_length := length * this.m_BytesPerChar
		this.m_MemView.MoveBytesLeft(StartPos, _length)
		this.m_CharCount := this.m_CharCount - length
		return this
	}

	Reverse(LimitBytes=false) {
		LimitBytes := MfBool.GetValue(LimitBytes, false)
		objRev := new MfMemoryString(this.m_BytesPerChar, this.m_FillBytes, this.m_Encoding)
		objRev.m_MemView := ""
		objRev.m_MemView := this.m_MemView.Reverse(LimitBytes)
		objRev.m_CharCount := this.m_CharCount
		objRev.m_Size := objRev.m_MemView.Size
		return objRev
	}
	
	_ResetPos() {
		; add one for line end
		i := (this.m_CharCount + 1) * this.m_BytesPerChar
		this.m_MemView.Pos := i
	}
	
	StartsWith(obj, IgnoreCase=true) {
		if (MfNull.IsNull(obj))
		{
			ex := new MfArgumentNullException("obj")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		IgnoreCase := MfBool.GetValue(IgnoreCase, true)
		
		mStr := this._FromAny(obj)
		len := mStr.m_CharCount
		if (len = 0)
		{
			return false
		}
		if (len > this.m_CharCount)
		{
			return false
		}
		; by searching for last index of we can limit the number of chars searched
		; using LasdIndexOf method first is likely the faster method
		; LasdIndexOf search method is extreamly fast as it runs machine code
		result := this.LastIndexOf(mStr, this.m_CharCount - len) = 0
		;result := this.IndexOf(str) = 0
		if (result = false && IgnoreCase = false)
		{
			len := mStr.m_CharCount
			result := MfMemStrView.EqualsSubString(this.m_MemView, 0, mStr.m_MemView, 0, len, IgnoreCase)
			; startStr := this.Substring(0, len)
			; result := startStr = str
		}
		return result
	}
	
	SubString(StartIndex, Length=-1) {
		if ((StartIndex < 0) || (StartIndex >= this.m_CharCount))
		{
			return ""
		}
		if (Length = 0)
		{
			return ""
		}
		if (Length < 0)
		{
			Length := this.m_CharCount + 1
		}
		_StartIndex := StartIndex * this.m_BytesPerChar
		PI := this.m_MemView.Pos
		this.m_MemView.Seek(_StartIndex, 0)
		methodName := "Read" . this.m_EncodingName
		len := Length ; - this.m_MemView.Pos
		retval := this.m_MemView.__Call(methodName, len)
		this.m_MemView.Pos := PI
		return retval
	}
	
	ToString() {
		return this.m_MemView.ToString()
	}
	
	TrimStart(trimChars="", IgnoreCase=true) {
		if (trimChars == "")
		{
			TrimCount := this.m_MemView.TrimStart()
			this.m_CharCount -= TrimCount
			return this
		}
		TrimCount := this.m_MemView.TrimStartChars(trimChars, IgnoreCase)
		this.m_CharCount -= TrimCount
		return this
	}
	
	TrimEnd(trimChars="", IgnoreCase=true) {
		if (trimChars == "")
		{
			TrimCount := this.m_MemView.TrimEnd()
			this.m_CharCount -= TrimCount
			return this
		}
		TrimCount := this.m_MemView.TrimEndChars(trimChars, IgnoreCase)
		this.m_CharCount -= TrimCount
		return this
	}
	Trim(trimChars="", IgnoreCase=true) {
		this.TrimStart(trimChars, IgnoreCase)
		this.TrimEnd(trimChars, IgnoreCase)
	}

	_FromAny(x) {
		if (IsObject(x))
		{
			if(MfObject.IsObjInstance(x, MfMemoryString))
			{
				if (!(x.m_Encoding = this.m_Encoding))
				{
					return this._FromAny(x.ToString())
				}
				return x
			}

			else if (MfObject.IsObjInstance(x, MfString))
			{
				len := (x.Length + 1) * this.m_BytesPerChar
				retval := new MfMemoryString(len, this.m_FillBytes, this.m_Encoding)
				retval.Append(x.Value)
				return retval
			}
			else if (MfObject.IsObjInstance(x, MfObject))
			{
				str := x.ToString()
				len := (StrLen(str) + 1) * this.m_BytesPerChar
				retval := new MfMemoryString(len, this.m_FillBytes, this.m_Encoding)
				retval.Append(str)
				return retval
			}
			else if (x.__Class = "MfMemStrView")
			{
				retval := new MfMemoryString(this.m_BytesPerChar, x.m_FillByte, x.m_Encoding)
				retval.m_MemView := ""
				retval.m_MemView := x
				retval.m_CharCount := (x.Pos - 1) // x.m_BytesPerChar
				retval.m_Size := x.Size
				return this._FromAny(retval) ; do another _FromAny in case encoding is different
			}
			else
			{
				return new MfMemoryString(this.m_BytesPerChar, this.m_FillBytes, this.m_Encoding)
			}
		}
		if (x = "")
		{
			return new MfMemoryString(this.m_BytesPerChar, this.m_FillBytes, this.m_Encoding)
		}

		len := (StrLen(x) + 1) * this.m_BytesPerChar
		retval := new MfMemoryString(len, this.m_FillBytes, this.m_Encoding)
		retval.Append(x)
		return retval
	}
	
;{ Length
	/*!
		Property: Length [get]
			Gets the Length value associated with the this instance
		Value:
			Var representing the Length property of the instance
		Remarks:
			Readonly Property
	*/
	Length[]
	{
		get {
			return this.m_CharCount
		}
		set {
			;~ ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			;~ ex.SetProp(A_LineFile, A_LineNumber, "Length")
			;~ Throw ex
		}
	}
; End:Length ;}
}

/* Class: MfMemStrView
 *	Internal Class
 *     A MfMemStrView object is used to represent a raw binary data buffer. This class
 *     extends from MfMemBlkView allowing you to directly manipulate its contents.
 */
class MfMemStrView extends MfMemBlkView
{
	m_FillByte := ""
	m_Encoding := ""
	m_EncodingName := ""
	m_BytesPerChar := ""
	/* Constructor: __New
	 *     Instantiates an object that represents a memory-block array
	 * Syntax:
	 *     oBuf := new MfMemStrView( size [ , FillByte := 0 ] )
	 * Parameter(s):
	 *     oBuf       [retval] - a MfMemStrView object
	 *     size           [in] - size of the buffer in bytes
	 *     FillByte  [in, opt] - similar to VarSetCapacity's 'FillByte' parameter
	 */
	__New(size, FillByte:=0, encoding="UTF-16") {
		StringReplace, _Encoding, Encoding, -, , ALL
		this.m_Encoding := Encoding
		this.m_EncodingName := _Encoding
		this.m_FillByte := FillByte
		ObjSetCapacity(this, "_Buffer", size)
		this.m_BytesPerChar := (this.m_Encoding = "UTF-16" || this.m_Encoding = "CP1600") ? 2 : 1
		base.__New(ObjGetAddress(this, "_Buffer"),, size)
		
		if (FillByte >= 0 && FillByte <= 255) ; UChar range
			DllCall("RtlFillMemory", "Ptr", this[], "UPtr", size, "UChar", FillByte)
	}
;{ 	Append
/*
	Method: Append()

	Append()
		Appends obj instance to this instance
	Parameters:
		obj
			Instance of MfMemStrView
	Returns:
		Returns the number of chars in this instance
	Throws:
		Throws MfArgumentException
	Remarks:
		see AppendString to append string var
*/
	Append(obj) {

		if (obj.__Class != "MfMemStrView")
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_NonMfObjectWithParamName", "obj", "MfMemStrView"), "obj")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}

		If (obj.Pos <= 1)
		{
			return this.GetCharCount()
		}
		if (!(this.m_Encoding = obj.m_Encoding))
		{
			return this.AppendString(obj.ToString())
		}
		len := obj.Pos

		BufferFree := this.Size - this.Pos

		if (len > BufferFree)
		{
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_General"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (!(obj.m_Encoding = this.m_Encoding))
		{
			; if encodingis different then add by string
			return this.AppendString(obj.ToString())
		}
		PI := this.Pos
		if (PI > 0)
		{
			this.Pos -= this.m_BytesPerChar
		}
		BytesPerChar := this.m_BytesPerChar
		sType := BytesPerChar = 1? "UChar":"UShort"
		i := 0
		thisAddress := this[]
		objAddress := obj[]
		while ( i < obj.Pos)
		{
			num := NumGet(objAddress + 0 ,i, sType)
			NumPut(num, thisAddress + 0, this.Pos, sType)
			this.Pos += BytesPerChar
			i += BytesPerChar
		}
		
		chars := (this.Pos - PI) // BytesPerChar
		return chars
	}
; 	End:Append ;}
;{ AppendString
/*
	Method: AppendString()

	AppendString()
		Appends a string var to current instance
	Parameters:
		s
			Teh string var to append
	Returns:
		Returns the number of chars in this instance
	Remarks:
		see Append to append instance of MfMemStrView
*/
	AppendString(s) {
		len := ""
		if (IsObject(s))
		{
			if (MfObject.IsObjInstance(s, MfString))
			{
				len := s.Length * this.m_BytesPerChar
				str := s.Value
			}
			else if (MfObject.IsObjInstance(s, MfObject))
			{
				str := s.ToString()
				len := StrLen(str) * this.m_BytesPerChar
			}
			else
			{
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("NonMfObjectException_General"), "s")
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		}
		else
		{
			str := s
			len := StrLen(str) * this.m_BytesPerChar
		}

		BufferFree := this.Size - this.Pos

		
		if (len > BufferFree)
		{
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_General"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		;this.m_MemView.Seek()
		if (this.Pos > 0)
		{
			; remove line terminator befor addign new text
			this.Pos -= this.m_BytesPerChar
		}
		methodName := "Write" . this.m_EncodingName
		chars := this.__Call(methodName,s)
		chars := chars > 0 ? chars - 1 : chars
		return chars
	}
; End:AppendString ;}
;{ 	ToString
/*
	Method: ToString()

	ToString()
		Gets the value of this instance as string var
	Returns:
		Returns string var
*/
	ToString() {
		PI := this.Pos
		methodName := "Read" . this.m_EncodingName
		len := (this.Pos - this.m_BytesPerChar)
		this.Seek(0, 0)
		retval := this.__Call(methodName, len)
		this.Pos := PI
		return retval
	}
; 	End:ToString ;}
;{ 	CompareOrdinal
/*
	Method: CompareOrdinal()

	CompareOrdinal()
		Compares two instance of MfMemStrView as Ordinal
	Parameters:
		objA
			The first instance of MfMemStrView to compare
		objB
			The Second instance of MfMemStrView to compare
	Returns:
		Returns integer of 0 if equal, if objA is greater then objB the positive number is returned; Otherwise negative number
	Throws:
		Throws MfArgumentException
		Throw MfFormatException is encodings are not the same
	Remarks:
		Static Method
*/
	CompareOrdinal(objA, objB) {
		if (ObjA.__Class != "MfMemStrView")
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_NonMfObjectWithParamName", "ObjA", "MfMemStrView"), "ObjA")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (ObjB.__Class != "MfMemStrView")
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_NonMfObjectWithParamName", "ObjB", "MfMemStrView"), "ObjB")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (!(objA.m_Encoding = objB.m_Encoding))
		{
			ex := new MfFormatException(MfEnvironment.Instance.GetResourceString("Format_Encoding_MisMatch"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (objA == "")
		{
			return -1
		}
		if (objB == "")
		{
			return 1
		}
		BytesPerChar := objA.m_BytesPerChar
		sType := BytesPerChar = 1? "UChar":"UShort"
		ptrA := objA[] ; first char address
		ptrB := objB[] ; frist char address
		numA := NumGet(ptrA + 0, 0, sType)
		numB := NumGet(ptrB + 0, 0, sType)
		comp := numA - numB
		if (comp != 0)
		{
			return comp
		}
		return MfMemStrView._CompareOrdinalHelper(objA, objB)
	}
; 	End:CompareOrdinal ;}
;{ 	CompareIgnoreCase
;{ 	CompareOrdinalIgnoreCase
/*
	Method: CompareOrdinalIgnoreCase()

	CompareOrdinalIgnoreCase()
		Compares two instance of MfMemStrView as Ordinal ignoring case
	Parameters:
		objA
			The first instance of MfMemStrView to compare
		objB
			The Second instance of MfMemStrView to compare
	Returns:
		Returns integer of 0 if equal, if objA is greater then objB the positive number is returned; Otherwise negative number
	Throws:
		Throws MfArgumentException
		Throw MfFormatException is encodings are not the same
	Remarks:
		Static Method
*/
	CompareOrdinalIgnoreCase(objA, objB) {
		if (ObjA.__Class != "MfMemStrView")
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_NonMfObjectWithParamName", "ObjA", "MfMemStrView"), "ObjA")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (ObjB.__Class != "MfMemStrView")
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_NonMfObjectWithParamName", "ObjB", "MfMemStrView"), "ObjB")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (!(objA.m_Encoding = objB.m_Encoding))
		{
			ex := new MfFormatException(MfEnvironment.Instance.GetResourceString("Format_Encoding_MisMatch"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		BytesPerChar := objA.m_BytesPerChar
		sType := BytesPerChar = 1? "UChar":"UShort"
		i := objA.Pos > objB.Pos ? objB.Pos : objA.Pos
		i -= BytesPerChar
		num := -1
		AddressA := objA[]
		AddressB := objB[]
		ptrA := objA[] ; first char address
		ptrB := objB[] ; frist char address
		While (i >= 5 * BytesPerChar)
		{
			numA := NumGet(ptrA + 0, 0, sType)
			numB := NumGet(ptrB + 0, 0, sType)
			if (numA != numB)
			{
				chrA := Chr(NumA)
				chrB := Chr(NumB)
				if (!(chrA = chrB))
				{
					num := 0
					break
				}
			}
			numA := NumGet(ptrA + BytesPerChar, 0, sType)
			numB := NumGet(ptrB + BytesPerChar, 0, sType)
			if (numA != numB)
			{
				chrA := Chr(NumA)
				chrB := Chr(NumB)
				if (!(chrA = chrB))
				{
					num := BytesPerChar
					break
				}
			}
			numA := NumGet(ptrA + (BytesPerChar * 2), 0, sType)
			numB := NumGet(ptrB + (BytesPerChar * 2), 0, sType)
			if (numA != numB)
			{
				chrA := Chr(NumA)
				chrB := Chr(NumB)
				if (!(chrA = chrB))
				{
					num := BytesPerChar * 2
					break
				}
			}
			numA := NumGet(ptrA + (BytesPerChar * 3), 0, sType)
			numB := NumGet(ptrB + (BytesPerChar * 3), 0, sType)
			if (numA != numB)
			{
				chrA := Chr(NumA)
				chrB := Chr(NumB)
				if (!(chrA = chrB))
				{
					num := BytesPerChar * 2
					break
				}
			}
			numA := NumGet(ptrA + (BytesPerChar * 4), 0, sType)
			numB := NumGet(ptrB + (BytesPerChar * 4), 0, sType)
			if (numA != numB)
			{
				chrA := Chr(NumA)
				chrB := Chr(NumB)
				if (!(chrA = chrB))
				{
					num := BytesPerChar * 4
					break
				}
			}
			ptrA += BytesPerChar * 5
			ptrB += BytesPerChar * 5
			i -= BytesPerChar * 5
		}
		if (num != -1)
		{
			ptrA += num
			ptrB += num
			numA := NumGet(ptrA + 0, 0, sType)
			numB := NumGet(ptrB + 0, 0, sType)
			result := numA - numB
			if (result != 0)
			{
				return result
			}
			numA := NumGet(ptrA + BytesPerChar, 0, sType)
			numB := NumGet(ptrB + BytesPerChar, 0, sType)
			return numA - numB
		}
		else
		{
			while (i > 0)
			{
				numA := NumGet(ptrA + 0, 0, sType)
				numB := NumGet(ptrB + 0, 0, sType)
				if (numA != numB)
				{
					chrA := Chr(NumA)
					chrB := Chr(NumB)
					if (!(chrA = chrB))
					{
						break
					}
				}
				ptrA += BytesPerChar
				ptrB += BytesPerChar
				i -= BytesPerChar
			}
			if (i <= 0)
			{
				return objA.Pos - objB.Pos
			}
			numA := NumGet(ptrA + 0, 0, sType)
			numB := NumGet(ptrB + 0, 0, sType)
			result := 0
			if (numA != numB)
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
			numA := NumGet(ptrA + BytesPerChar, 0, sType)
			numB := NumGet(ptrB + BytesPerChar, 0, sType)
			if (numA != numB)
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
; 	End:CompareIgnoreCase ;}
;{ 	GetCharCount
/*
	Method: GetCharCount()

	GetCharCount()
		Gets the number of chars currently in this buffer instance
	Returns:
		Returns the Count actual count of chars
	Remarks:
		If this.Pos <= Bytes Per Char then 0 is returned
		The numberof bytes in the buffer are ignore and
		return result is based on number of chars an not bytes
*/
	GetCharCount() {
		if (this.Pos <= this.m_BytesPerChar)
		{
			return 0
		}
		return (this.Pos - this.m_BytesPerChar) // this.m_BytesPerChar
	}
; 	End:GetCharCount ;}
;{ 	Reverse
/*
	Method: Reverse()

	Reverse()
		Reverses the contentes of the currrent instance and returne it as a new instance
	Parameters:
		LimitBytes
			If True then the return instance will have its size limited to the number of chars in the current instaned;
			Otherwise the size will be the same size as the current instance
	Returns:
		Returns a new instance with the chars reversed
	Remarks:
		New line char sequences set in the framework will not be reversed in the return output.
		the default new line chars are 13, 10 when the string is reversed the order will still be 13, 10
		the order and char for new line are read from MfEnviroment.Instance.NewLine
*/
	Reverse(LimitBytes=false) {
		rev := new MfMemStrView(LimitBytes?this.Pos + this.m_BytesPerChar: this.Size, this.m_FillByte, this.m_Encoding)
		If (this.Pos < 1)
		{
			return rev
		}
		
		;nlChars := MfEnvironment.Instance.GetResourceStringBySection("NewLine", "SYSTEM")
		; capture the new line char(s) so we can add them to the reverse string in the same order
		nl := MfEnvironment.Instance.NewLine
		i := 1
		arrNl := []
		NewLineCount := StrLen(nl)
		i := 1
		While (i <= NewLineCount)
		{
			; fill array so we can enter value in reverse later
			arrNl[i] := 0
			i++
		}
		i := NewLineCount
		Loop, Parse, nl
		{
			; fill the arrry with the reverse of the new line chars
			arrNl[i] := asc(A_LoopField)
			i--
		}
		LastNewChar := arrNl[1]
		
		BytesPerChar := this.m_BytesPerChar
		i := this.Pos - BytesPerChar
		j := 0
		
		sType := BytesPerChar = 1? "UChar":"UShort"
		thisAddress := this[]
		revAddress := rev[]
		LastChar := NumGet(thisAddress + 0, i , sType)
		i -= BytesPerChar
		While (i >= 0)
		{
			num := NumGet(thisAddress + 0, i , sType)
			if ((num = LastNewChar) && (NewLineCount > 1) && (i - (BytesPerChar * NewLineCount)  > 0))
			{
				; do not reverse new line chars which is 13,10 by default
				k := 2 ; already have amatch on the first
				FoundNewLine := true
				While k <= NewLineCount
				{
					numNext := NumGet(thisAddress + 0, i - (BytesPerChar * (k - 1)), sType) ; get the next char number for k
					; check the next char number against the revers array to see if it matches the next char in new line
					if (numNext != arrNl[k])
					{
						; no match, this byte sequence is not in the same order as new line chars sequence so will
						; ignore here and add as regular byte
						FoundNewLine := false
						break
					}
					k++
				}
				if (FoundNewLine)
				{
					; new line byte sequence has been found so add a new line sequence of bytes to the reverse
					; from the new line array captured above
					; the array value are in reverse so count down to add into reverse output
					k := NewLineCount
					while (k >= 1)
					{
						NumPut(arrNl[k], revAddress + 0, j, sType)
						j += BytesPerChar
						i -= BytesPerChar
						k--
					}
					continue
				}
			}
			NumPut(num, revAddress + 0, j, sType)
			i -= BytesPerChar
			j += BytesPerChar
		}
		NumPut(LastChar, revAddress + 0, j, sType)
		rev.Pos := this.Pos
		return rev
	}
; 	End:Reverse ;}
;{ 	_CompareOrdinalHelper
	; compare two instances of MfMemStrView and returns ordinal value comparsion
	_CompareOrdinalHelper(objA, objB) {
		BytesPerChar := objA.m_BytesPerChar
		sType := BytesPerChar = 1? "UChar":"UShort"
		i := objA.Pos > objB.Pos ? objB.Pos : objA.Pos
		i -= BytesPerChar
		num := -1
		AddressA := objA[]
		AddressB := objB[]
		ptrA := objA[] ; first char address
		ptrB := objB[] ; frist char address
		While (i >= 5 * BytesPerChar)
		{
			numA := NumGet(ptrA + 0, 0, sType)
			numB := NumGet(ptrB + 0, 0, sType)
			if (numA != numB)
			{
				num := 0
				break
			}
			numA := NumGet(ptrA + BytesPerChar, 0, sType)
			numB := NumGet(ptrB + BytesPerChar, 0, sType)
			if (numA != numB)
			{
				num := BytesPerChar
				break
			}
			numA := NumGet(ptrA + (BytesPerChar * 2), 0, sType)
			numB := NumGet(ptrB + (BytesPerChar * 2), 0, sType)
			if (numA != numB)
			{
				num := BytesPerChar * 2
				break
			}
			numA := NumGet(ptrA + (BytesPerChar * 3), 0, sType)
			numB := NumGet(ptrB + (BytesPerChar * 3), 0, sType)
			if (numA != numB)
			{
				num := BytesPerChar * 3
				break
			}
			numA := NumGet(ptrA + (BytesPerChar * 4), 0, sType)
			numB := NumGet(ptrB + (BytesPerChar * 4), 0, sType)
			if (numA != numB)
			{
				num := BytesPerChar * 4
				break
			}
			ptrA += BytesPerChar * 5
			ptrB += BytesPerChar * 5
			i -= BytesPerChar * 5
		}
		if (num != -1)
		{
			ptrA += num
			ptrB += num
			numA := NumGet(ptrA + 0, 0, sType)
			numB := NumGet(ptrB + 0, 0, sType)
			result := numA - numB
			if (result != 0)
			{
				return result
			}
			numA := NumGet(ptrA + BytesPerChar, 0, sType)
			numB := NumGet(ptrB + BytesPerChar, 0, sType)
			return numA - numB
		}
		else
		{
			while (i > 0)
			{
				numA := NumGet(ptrA + 0, 0, sType)
				numB := NumGet(ptrB + 0, 0, sType)
				if (numA != numB)
				{
					break
				}
				ptrA += BytesPerChar
				ptrB += BytesPerChar
				i -= BytesPerChar
			}
			if (i <= 0)
			{
				return objA.Pos - objB.Pos
			}
			result := NumGet(ptrA + 0, 0, sType) - NumGet(ptrB + 0, 0, sType)
			if (result != 0)
			{
				return result
			}
			numA := NumGet(ptrA + BytesPerChar, 0, sType)
			numB := NumGet(ptrB + BytesPerChar, 0, sType)
			return numA - numB
		}
	}
; 	End:_CompareOrdinalHelper ;}
;{ 	Clone
/*
	Method: Clone()

	Clone()
		Clones the current instance and returns a copy
	Returns:
		Returns copy of current instance
*/
	Clone() {
		objMemBlk := new MfMemStrView(this.Size, this.m_FillByte, this.m_Encoding)
		newAddress := objMemBlk[]
		Address := this[]
		DllCall("RtlMoveMemory", UInt,newAddress + 0, UInt,Address + 0, Uint, this.Size)
		objMemBlk.Pos := this.Pos
		return objMemBlk
	}
; 	End:Clone ;}
;{ 	Diff
/*
	Method: Diff(objA, objA, maxDistance)
		Gets the Difference between argument objA and argument objB argument with an included Max Distance.
		objA
			the frist MfMemStrView to compare.
		objB
			the second MfMemStrView to compare.
		maxDistance
			Integer tells the algorithm to stop if the strings are already too different.
	Returns:
		Returns returns the difference between the strings as a float between 0 and 1.
		0 means strings are identical. 1 means they have nothing in common.
*/
	Diff(objA, objB, encoding, maxOffset=5) {
		if (ObjA.__Class != "MfMemStrView")
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_NonMfObjectWithParamName", "ObjA", "MfMemStrView"), "ObjA")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (ObjB.__Class != "MfMemStrView")
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_NonMfObjectWithParamName", "ObjB", "MfMemStrView"), "ObjB")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (!(objA.m_Encoding = objB.m_Encoding))
		{
			ex := new MfFormatException(MfEnvironment.Instance.GetResourceString("Format_Encoding_MisMatch"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		BytesPerChar := objA.m_BytesPerChar
		
		if (objA.Pos <= 1 || objB.Pos <= 1)
		{
			return (objA.Pos = objB.Pos ? 0/1 : 1/1)
		}
		lenA := objA.Pos
		lenA -= BytesPerChar
		lenB := objB.Pos
		lenB -= BytesPerChar
		lcs := 0
		ni := 1
		mi := 1
		n0 := (lenA // BytesPerChar)
		m0 := (lenB // BytesPerChar)
		if (objA.Equals(objB, encoding, false))
		{
			result := objA.Equals(ojbB, encoding)
			retval := result = true? (0/1) : (0.2/n0)
			return retval
		}
		
		sType := BytesPerChar = 1? "UChar":"UShort"
		ptrA := objA[] ; first char address
		ptrB := objB[] ; frist char address
		
		i := 0
		
		while ((ni <= n0) && (mi <= m0))
		{
			num1 := NumGet(ptrA + 0, ((ni - 1) * BytesPerChar), sType)
			num2 := NumGet(ptrB + 0, ((mi - 1) * BytesPerChar), sType)
			if (num1 = num2)
			{
				lcs += 1
				ni += 1
				mi += 1
				continue
			}
			else
			{
				char1 := Chr(num1)
				char2 := Chr(num2)
				if (char1 = char2)
				{
					lcs += 0.8
					ni += 1
					mi += 1
					continue
				}
			}
			Loop, % maxOffset
			{
				oi := ni + A_Index, pi := mi + A_Index
				num1 := oi <= n0 ? NumGet(ptrA + 0, ((oi - 1) * BytesPerChar), sType) : 0
				num2 := mi <= m0 ? NumGet(ptrB + 0, ((mi - 1) * BytesPerChar), sType) : 0
				if ((num1 > 0 ) && (num1 = num2))
				{
					;ni := oi, lcs += (num1 = num2 ? 1 : 0.8)
					ni := oi, lcs += 1
					break
				}
				else if (num1 > 0)
				{
					char1 := Chr(num1)
					char2 := Chr(num2)
					if ((char1 = char2))
					{
						;ni := oi, lcs += (char1 = char1 ? 1 : 0.8)
						ni := oi, lcs += 0.8
						break
					}
				}
					
				num1 := ni <= n0 ? NumGet(ptrA + 0, ((ni - 1) * BytesPerChar), sType) : 0
				num2 := pi <= m0 ? NumGet(ptrB + 0, ((pi - 1) * BytesPerChar), sType) : 0
				if ((num2 > 0) && (num1 = num2))
				{
					mi := pi, lcs += 1
					break
				}
				else if (num2 > 0)
				{
					char1 := Chr(num1)
					char2 := Chr(num2)
					if (char1 = char2)
					{
						mi := pi, lcs += 0.8
						break
					}
				}
			}
			ni += 1
			mi += 1
		}
		
		return ((n0 + m0)/2 - lcs) / (n0 > m0 ? n0 : m0)
	}
; 	End:Diff ;}
;{ 	EndsWithFromPos
/*
	Method: EndsWithFromPos()

	EndsWithFromPos()
		Checks to see if obj ends with the same char as this instance
	Parameters:
		obj
			the obj instance to compare to this instance
		IgnoreCase
			If True case is ignored; Otherwise case is compared
	Returns:
		Returns true if this instance ends with the same chars as obj
	Remarks:
		Obj.Pos must not be bigger then this instance or false will be returned
*/
	EndsWithFromPos(Obj, IgnoreCase=true) {
		if (Obj.Pos = 0 || this.Pos = 0)
		{
			return false
		}
		if (Obj.Pos > this.Pos)
		{
			return false
		}
		PI := this.Pos
		this.Pos := this.Pos - Obj.Pos
		
		BytesPerChar := this.m_BytesPerChar
		; move address to this plus this position
		Address1 := this[] + this.Pos
		len := (Obj.Pos - BytesPerChar) // BytesPerChar
		Address2 := Obj[]
		retval := MfMemStrView.StringsAreEqual(Address1, len, Address2, len, this.m_Encoding, IgnoreCase)
		this.Pos := PI ; reset this pos to originl location
		return retval
	}
; 	End:EndsWithFromPos ;}
;{ 	EqualsSubString
/*
	Method: EqualsSubString()

	EqualsSubString()
		Compares two MfMemStrView objects to see if their subPositions are equal
	Parameters:
		ObjA
			The first MfMemStrView to compare
		ObjAStartIndex
			The zero base start index of ObjA to compare, this is char index and not base on bytes ber char
		ObjA
			The second MfMemStrView to compare
		ObjAStartIndex
			The zero base start index of ObjB to compare, this is char index and not base on bytes ber char
		Len
			The Length to Compare
		IgnoreCase
			Boolean value indicating if case to to be ignored
	Returns:
		Boolean var of True if Sub-Positions are equal; Otherwise false 
	Throws:
		Throws MfArgumentException
		Throws MfFormatException if encodings for both objects do not match
	Remarks:
		static method
*/
	EqualsSubString(ByRef ObjA, ObjAStartIndex, ByRef ObjB, ObjbStartIndex, Len, IgnoreCase=true) {
		if (ObjA.__Class != "MfMemStrView")
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_NonMfObjectWithParamName", "ObjA", "MfMemStrView"), "ObjA")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (ObjB.__Class != "MfMemStrView")
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_NonMfObjectWithParamName", "ObjB", "MfMemStrView"), "ObjB")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (!(objA.m_Encoding = objB.m_Encoding))
		{
			ex := new MfFormatException(MfEnvironment.Instance.GetResourceString("Format_Encoding_MisMatch"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		ObjAStartIndex := MfInteger.GetValue(ObjAStartIndex)
		Len := MfInteger.GetValue(Len)
		
		ObjbStartIndex := MfInteger.GetValue(ObjbStartIndex)
				

		IgnoreCase := MfBool.GetValue(IgnoreCase, true)
		If (objA.Size <= (ObjAStartPos + Len))
		{
			return false
		}
		If (ObjB.Size <= (ObjAStartIndex + Len))
		{
			return false
		}
		PIA := objA.Pos
		PIB := objB.Pos
		BytesPerChar := objA.m_BytesPerChar
		try
		{
			objA.Seek(ObjAStartIndex * BytesPerChar)
			objB.Seek(ObjbStartIndex * BytesPerChar)
			AddressA := objA[] + objA.Pos
			AddressB := objB[] + objB.Pos
			retval := MfMemStrView.StringsAreEqual(AddressA, Len, AddressB, Len, objA.m_Encoding, IgnoreCase)
			return retval
		}
		catch e
		{
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		Finally
		{
			objA.Pos := PIA
			objB.Pos := PIB
		}
	}
; 	End:EqualsSubString ;}
;{ 	Equals
/*
	Method: Equals()

	Equals()
		Check to see if current instance is equal string as Obj
	Parameters:
		Obj
			Instance of MfMemStrView to compare to current instance
		IgnoreCase
			Boolean value indicating if case should be ignored when comparing
	Returns:
		Boolean var true if equal; Otherwise false 
	Throws:
		Throws MfArgumentException
	Remarks:
		See EqualsString for comparsion of String var
*/
	Equals(Obj, IgnoreCase=true) {
		if (Obj.__Class != "MfMemStrView")
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_NonMfObjectWithParamName", "Obj", "MfMemStrView"), "Obj")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (Obj.Pos = 0 && this.Pos = 0)
		{
			return true
		}
		if (Obj.Pos <> this.Pos)
		{
			return false
		}
		
		BytesPerChar := this.m_BytesPerChar
		Address1 := this[]
		len1 := (this.Pos - BytesPerChar) // BytesPerChar
		Address2 := Obj[]
		len2 := (Obj.Pos - BytesPerChar) // BytesPerChar
		retval := MfMemStrView.StringsAreEqual(Address1, len1, Address2, len2, this.m_Encoding, IgnoreCase)
		return retval
	}
; 	End:Equals ;}
;{ 	EqualsString
/*
	Method: EqualsString()

	EqualsString()
		Check to see if current instance is equal with str
	Parameters:
		str
			Var strgin to compare to current instance
		IgnoreCase
			Boolean value indicating if case should be ignored when comparing
	Returns:
		Boolean var true if equal; Otherwise false 
	Remarks:
		See Equals for comparsion of MfMemStrView obj
*/
	EqualsString(str, IgnoreCase=true) {
		len := StrLen(str)
		objMemBlk := new MfMemStrView((len + 1) * this.m_BytesPerChar, this.m_FillByte, this.m_Encoding)
		methodName := "Write" . this.m_EncodingName
		chars := objMemBlk.__Call(methodName, str)
		if (objMemBlk.Pos <> this.Pos)
		{
			return false
		}
		retval := this.Equals(objMemBlk, IgnoreCase)
		return retval
	}
; 	End:EqualsString ;}
;{ StringsAreEqual
/*
	Method: StringsAreEqual()

	StringsAreEqual()
		Binary comparsion of string in memory
	Parameters:
		FirstStrAddr
			The memory address of the frist string to compare
		FirstStrLen
			The length of the frist string to compare
		SecondStrAddr
			The memory address of the secnod string to compare
		SecondStrLen
			The length of the frist string to compare
		encoding
			The encoding of the string in memory
		IgnoreCase
			Boolean value indicating if case should be ignored
	Returns:
		Boolean true if string are equal, Otherwise False 
	Remarks:
		Because Memory addresses and length are being compared this method could alus be used to to compare
		substring of memory strings. See EqualsSubString as an example
		Static Method
*/
	StringsAreEqual(FirstStrAddr, FirstStrLen, SecondStrAddr,SecondStrLen, encoding, IgnoreCase=true) {
		if (FirstStrAddr = SecondStrAddr)
		{
			return true
		}
		If (FirstStrLen <> SecondStrLen)
		{
			Return false
		}
		retval := true
		BytesPerChar := (encoding = "UTF-16" || encoding = "CP1600") ? 2 : 1
		sType := BytesPerChar = 1? "UChar":"UShort"
		i := 0
		len := FirstStrLen * BytesPerChar
		if (IgnoreCase)
		{
			while (i < len)
			{
				num1 := NumGet(FirstStrAddr + 0, i, sType)
				num2:= NumGet(SecondStrAddr + 0, i, sType)
				if (num1 != num2)
				{
					retval := false
					break
				}
				i += BytesPerChar
			}
		}
		else
		{
			while (i < len)
			{
				num1 := NumGet(FirstStrAddr + 0, i, sType)
				num2:= NumGet(SecondStrAddr + 0, i, sType)
				if (num1 != num2)
				{
					char1 := Chr(num1)
					char2 := Chr(num2)
					; compare as case in-sensitive
					if (char1 = Char2)
					{
						i += BytesPerChar
						continue
					}
					retval := false
					break
				}
				i += BytesPerChar
			}

		}
		Return retval
	}
; End:StringsAreEqual ;}
	/*
	Returns -1 if SearchString is not found; Otherwise zero based index of found position
	*/
	InBuffer(ByRef NeedleObj, StartOffset=0) {
		;NeedleStr := "over"
		;haystack := "the quick brown fox jumped over the lazy dog which is funny"
		if (NeedleObj.Pos = 0)
		{
			return -1
		}
		haystackAddr := this[]
		BytesPerChar := this.m_BytesPerChar
		StartOffset := StartOffset * BytesPerChar
			
		needleAddr := NeedleObj[]
		needleSize := (NeedleObj.Pos - BytesPerChar)
		haystackSize := this.Pos
		result := MfMemStrView.InBuf(haystackAddr, needleAddr, this.Pos, needleSize, StartOffset)
		if (result > 0)
		{
			result := result // BytesPerChar
		}
		return result
	}
	
	InBufferRev(ByRef NeedleObj, EndOffset=-1) {
		;NeedleStr := "over"
		;haystack := "the quick brown fox jumped over the lazy dog which is funny"
		if (NeedleObj.Pos = 0)
		{
			return -1
		}
		haystackAddr := this[]
		BytesPerChar := this.m_BytesPerChar
		if (EndOffset > 0)
		{
			EndOffset := EndOffset * BytesPerChar
		}
		else
		{
			EndOffset := -1 ; ensure set not less then -1
		}
		
		needleAddr := NeedleObj[]
		needleSize := (NeedleObj.Pos - BytesPerChar)
		haystackSize := this.Pos
		result := MfMemStrView.InBufRev(haystackAddr, needleAddr, this.Pos, needleSize, EndOffset)
		if (result > 0)
		{
			result := result // BytesPerChar
		}
		return result
	}
	
;{ 	InBuf
/*
	Method: InBuf()

	InBuf()
		Blazing fast machine-code CASE-SENSITIVE searching in a (binary) buffer for a sequence of bytes,
		that may include NULL characters.
	Parameters:
		haystackAddr
			The memory address of the string to search
		needleAddr
			The Memory address of the string that is to be searched for in haystack
		haystackSize
			The size of the haystack in bytes
		needleSize
			The size of the needle in bytes
		StartOffset
			The zero based index offset value to begin the searh in haystack
	Returns:
		Returns zero based index of position of 'sought' inside 'haystack' or -1 if not found. 
	Remarks:
		See https://autohotkey.com/board/topic/23627-machine-code-binary-buffer-searching-regardless-of-null/
		Credit for this method goes to wOxxOm
		See InBuffer for wraper function
		Static Method
*/
	InBuf(haystackAddr, needleAddr, haystackSize, needleSize, StartOffset=0) {
		Static fun
		IfEqual,fun,
		{
			h=
			( LTrim join
				5589E583EC0C53515256579C8B5D1483FB000F8EC20000008B4D108B451829C129D9410F8E
				B10000008B7D0801C78B750C31C0FCAC4B742A4B742D4B74364B74144B753F93AD93F2AE0F
				858B000000391F75F4EB754EADF2AE757F3947FF75F7EB68F2AE7574EB628A26F2AE756C38
				2775F8EB569366AD93F2AE755E66391F75F7EB474E43AD8975FC89DAC1EB02895DF483E203
				8955F887DF87D187FB87CAF2AE75373947FF75F789FB89CA83C7038B75FC8B4DF485C97404
				F3A775DE8B4DF885C97404F3A675D389DF4F89F82B45089D5F5E5A595BC9C2140031C0F7D0EBF0
		  )
		  VarSetCapacity(fun,StrLen(h)//2)
		  Loop % StrLen(h)//2
			 NumPut("0x" . SubStr(h,2*A_Index-1,2), fun, A_Index-1, "Char")
	   }
	   Return DllCall(&fun
		  , "uint",haystackAddr, "uint",needleAddr
		  , "uint",haystackSize, "uint",needleSize
		  , "uint",StartOffset)
	}
; 	End:InBuf ;}
;{ 	InBufRev
/*
	Method: InBufRev()

	InBufRev()
		Blazing fast machine-code CASE-SENSITIVE searching in a (binary) buffer for a sequence of bytes,
		that may include NULL characters. Reverse look for binary Needle in binary Buffer
	Parameters:
		haystackAddr
			The memory address of the string to search
		needleAddr
			The Memory address of the string that is to be searched for in haystack
		haystackSize
			The size of the haystack in bytes
		needleSize
			The size of the needle in bytes
		StartOffsetOfLastNeedleByte
			The zero based index offset value to begin the searh from the end of haystack
	Returns:
		Returns zero based index of position of 'sought' inside 'haystack' or -1 if not found. 
	Remarks:
		See https://autohotkey.com/board/topic/23627-machine-code-binary-buffer-searching-regardless-of-null/
		Credit for this method goes to wOxxOm
		See InBufferRev for wraper function
		Static Method
*/
	InBufRev(haystackAddr, needleAddr, haystackSize, needleSize, StartOffsetOfLastNeedleByte=-1) {   
		Static fun
		IfEqual,fun,
		{
		h=
		( LTrim join
			5589E583EC0C53515256579C8B5D1483FB000F8EDE0000008B4510488B4D1883F9FF0F44
			C839C80F4CC829D989CF410F8EC1000000037D088B750C83E000FCAC4B74224B742A4B74
			354B74434B754E93AD93FDF2AE0F859B000000395F0275F3E981000000FDF2AE0F858800
			0000EB76FD8A26F2AE757F38670275F7EB689366AD93FDF2AE756F66395F0275F6EB574E
			ADFDF2AE756039470175F7EB494E43AD8975FC89DAC1EB02895DF483E2038955F887DF87
			D1FD87FB87CAF2AE753839470175F7FC89FB89CA83C7058B75FC8B4DF485C97404F3A775
			DC8B4DF885C97404F3A675D189DF4789F82B45089D5F5E5A595BC9C2140031C0F7D0EBF0
		)
		VarSetCapacity(fun,StrLen(h)//2)
		Loop % StrLen(h)//2
		NumPut("0x" . SubStr(h,2*A_Index-1,2), fun, A_Index-1, "Char")
		}
		return DllCall(&fun
			, "uint",haystackAddr, "uint",needleAddr
			, "uint",haystackSize, "uint",needleSize
			, "uint",StartOffsetOfLastNeedleByte)
	}
; 	End:InBufRev ;}
;{ 	IsWhiteSpace
/*
	Method: IsWhiteSpace()

	IsWhiteSpace()
		Check to see if a char number is considered to be whitespace
	Parameters:
		cc
			The char number to check
	Returns:
		Returns boolean true if cc is whitespace char; Otherwise false
	Remarks:
		Char numbers are base on unicode
*/
	IsWhiteSpace(cc) {
		; from unicode database
		retval := ((cc >= 9 && cc <= 13) || (cc = 32) || (cc = 133) || (cc = 160) || (cc = 5760) || (cc >= 8192 && cc <= 8202)
			|| (cc = 8232) || (cc = 8233) || (cc = 8239) || (cc = 8287) || (cc = 12288))
		return retval
	}
; 	End:IsWhiteSpace ;}
;{ 	TrimStart
/*
	Method: TrimStart()

	TrimStart()
		Trims all whitespace char from start of current instance
	Returns:
		Returns the count of the number of chars trimed from the start
*/
	TrimStart() {
		
		BytesPerChar := this.m_BytesPerChar
		sType := BytesPerChar = 1? "UChar":"UShort"
		len := this.Pos
		Address := this[]
		i := 0
		while (i < len)
		{
			num := NumGet(Address + 0, i, sType)
			if (MfMemStrView.IsWhiteSpace(num) = false)
			{
				break
			}
			i += BytesPerChar
		}
		if (i = 0)
		{
			return 0
		}
		length := this.Pos - i
		
		this.MoveBytesLeft(0, i)
		result := i // BytesPerChar
		return result
	}
; 	End:TrimStart ;}
;{ 	TrimStartChars
/*
	Method: TrimStartChars()

	TrimStartChars()
		Trims char(s) from the start of a string
	Parameters:
		strChars
			A string var containing one or more chars to trim from the start of current instance
		IgnoreCase
			If true case is ignored for trim chars; Otherwise case is observed
	Returns:
		Returns the count of the number of chars trimed from the start
*/
	TrimStartChars(strChars, IgnoreCase=true) {
		if (strChars == "")
		{
			return 0
		}
		chars := MfMemStrView._GetCharArray(strChars, IgnoreCase)
		
		BytesPerChar := this.m_BytesPerChar
		sType := BytesPerChar = 1? "UChar":"UShort"
		len := this.Pos
		Address := this[]
		i := 0
		while (i < len)
		{
			num := NumGet(Address + 0, i, sType)
			if (!MfMemStrView._indexOfArr(chars, num))
			{
				break
			}
			i += BytesPerChar
		}
		if (i = 0)
		{
			return 0
		}
		length := this.Pos - i
		
		this.MoveBytesLeft(0, i)
		result := i // BytesPerChar
		return result
	}
; 	End:TrimStartChars ;}
;{ 	TrimEnd
/*
	Method: TrimEnd()

	TrimEnd()
		Trims all whitespace char from end of current instance
	Returns:
		Returns the count of the number of chars trimed from the end
*/
	TrimEnd() {
		BytesPerChar := this.m_BytesPerChar
		sType := BytesPerChar = 1? "UChar":"UShort"
		PI := this.Pos
		Address := this[]
		i := PI - (BytesPerChar * 2) ; minus 1 for zero based
		if ( i < 0)
		{
			return 0
		}
		iCount := 0
		while (i >= 0)
		{
			num := NumGet(Address + 0, i, sType)
			if (MfMemStrView.IsWhiteSpace(num) = false)
			{
				break
			}
			i -= BytesPerChar
			iCount ++
		}
		if (iCount = 0)
		{
			return 0
		}
		
		this.TrimMemoryRight(iCount)
		result := iCount	
		return result
	}
; 	End:TrimEnd ;}
;{ 	TrimEndChars
/*
	Method: TrimStartChars()

	TrimStartChars()
		Trims char(s) from the end of a string
	Parameters:
		strChars
			A string var containing one or more chars to trim from the end of current instance
		IgnoreCase
			If true case is ignored for trim chars; Otherwise case is observed
	Returns:
		Returns the count of the number of chars trimed from the end
*/
	TrimEndChars(strChars, IgnoreCase=true) {
		if (strChars == "")
		{
			return 0
		}
		chars := MfMemStrView._GetCharArray(strChars, IgnoreCase)
		
		BytesPerChar := this.m_BytesPerChar
		sType := BytesPerChar = 1? "UChar":"UShort"
		PI := this.Pos
		Address := this[]
		i := PI - (BytesPerChar * 2) ; minus 1 for zero based
		if ( i < 0)
		{
			return 0
		}
		iCount := 0
		while (i >= 0)
		{
			num := NumGet(Address + 0, i, sType)
			if (!MfMemStrView._indexOfArr(chars, num))
			{
				break
			}
			i -= BytesPerChar
			iCount ++
		}
		if (iCount = 0)
		{
			return 0
		}
		this.TrimMemoryRight(iCount)
		result := iCount	
		return result
	}
; 	End:TrimEndChars ;}
;{ 	TrimMemoryRight
/*
	Method: TrimMemoryRight()

	TrimMemoryRight()
		Overwrites memory bytes with fillbytes for the end of a string, Erases end of a string
	Parameters:
		Length
			The number of chars to erase from the end this instance
*/
	TrimMemoryRight(Length) {
		BytesPerChar := this.m_BytesPerChar
		PI := this.Pos
		NewPos := this.Pos - (Length * BytesPerChar)
		this.Seek(NewPos - BytesPerChar)
		strType := BytesPerChar = 1?"UChar":"UShort"
		methodPut := "Put" . strType
		while (this.Pos < PI)
		{
			this.__Call(methodPut,this.m_FillByte)
		}
		this.Seek(NewPos)
		
	}
; 	End:TrimMemoryRight ;}
;{ 	_GetCharArray
/*
	Method: _GetCharArray()

	_GetCharArray()
		Builds a one base array from strChars adding each character only once as a char number
	Parameters:
		strChars
			The source string to build array from
		IgnoreCase
			Boolean value indicating if case should be ignored
	Returns:
		Returns one based array of chars numbers representing the chars in strChars
	Remarks:
		if IgnoreCase is false then each char in strChars will be added as upper case and lower case if the char
		has a corresponding case
*/
	_GetCharArray(strChars, IgnoreCase=true) {
		
		tc := []
		i := 1
		Loop, Parse, strChars
		{
			if (IgnoreCase = true)
			{
				char := Asc(A_LoopField)
				if (MfMemStrView._indexOfArr(tc, char))
				{
					continue
				}

				tc[i] := char
				i++
			}
			else
			{
				StringLower, LC, A_LoopField
				char := Asc(LC)
				if (MfMemStrView._indexOfArr(tc, char))
				{
					continue
				}
				tc[i] := char
				i++
				; some chars are the same upper and lower case
				StringUpper, UC, A_LoopField
				charU := Asc(UC)
				if (CharU != char)
				{
					tc[i] := CharU
					i++
				}
			}
		}
		return tc
	}
; 	End:_GetCharArray ;}
;{ 	_indexOfArr
	/*
	Method: _indexOfArr()

	_indexOfArr()
		Search a one based array to see if contains var value
	Parameters:
		Arr
			Array to search
		var
			Value to search for
		fromIndex
			The one based index to start searching from. Defauult is 1
	Returns:
		Returns the index in the array if var is found otherwise false
*/
	_indexOfArr(ByRef Arr, var, fromIndex:=1) {
		for index, value in Arr {
			if (index < fromIndex)
				Continue
			else if (value = var)
				return index
		}
		return false
	}
; 	End:_indexOfArr ;}
;{ 	Insert
/*
	Method: Insert()
		
	Insert()
		Inserts the contents of obj into current instance
	Parameters:
		startPos
			The zero based index to start the insertion
		obj
			The MfMemStrView instance to insert into this instance
	Returns:
		Returns the number of char of this instance after insert
	Throws:
		Throws MfArgumentException
	Remarks:
		see InsertStr to insert as string var
*/
	Insert(startPos, ByRef obj) {
		; StartPos is the Position to start inserting text
		if (obj.__Class != "MfMemStrView")
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_NonMfObjectWithParamName", "obj", "MfMemStrView"), "obj")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		BytesPerChar := this.m_BytesPerChar
		If (obj.Pos <= BytesPerChar)
		{
			return this.GetCharCount()
		}
		If (!(this.m_Encoding = obj.m_Encoding))
		{
			return this.InsertStr(startPos, obj.ToString())
		}

		PI := this.Pos ; this will be the end the current chars
		
		startPos := startPos * BytesPerChar
		sType := BytesPerChar = 1? "UChar":"UShort"
		;this.Seek(StrPut(str, enc) * BytesPerChar, 1)
		iLen := obj.Pos - BytesPerChar

		if ( (PI + ILen) > this.Size)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Capacity"), "obj")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
		; copy the remainder of the string to a new address and then append it back later
		this.Seek(startPos) ; Move to the start Pos

		sourcePtr := this[] + this.Pos ; get the start pos Address
		ChunkLen := PI - this.Pos

		; copy the from the insertion point to the end into a temp memory address
		tmp := ""
		VarSetCapacity(tmp,ChunkLen + 10)
		DllCall("RtlMoveMemory", sType, &tmp, sType, sourcePtr + 0, sType, ChunkLen)
		result := ErrorLevel
		tmpC := VarSetCapacity(tmp, -1)

		objAddress := obj[]
		; copy the obj bytes into the current location of this address
		DllCall("RtlMoveMemory", sType, sourcePtr + 0, sType, objAddress + 0, sType, iLen)
		; move this position to the location the insert ended Plus one position
		this.Pos += iLen ; + BytesPerChar
						
		; copy the temp memory values back to the end of this memory space
		; Move the Position back one char to overwrite line end from write method
		;this.Pos -= BytesPerChar
		sourcePtr := this[] + this.Pos ; get the start pos Address
		; Write the tmp memory into this
		DllCall("RtlMoveMemory", sType, sourcePtr + 0, sType, &tmp, sType, ChunkLen)
		this.Pos += ChunkLen
		;this.Pos += BytesPerChar ; move forward to end again

		; clear tmp memory
		VarSetCapacity(tmp, 0)
		tmp := ""
		return this.GetCharCount()
	}
; 	End:Insert ;}
;{ 	InsertStr
/*
	Method: Insert()
		
	Insert()
		Inserts the contents of str into current instance
	Parameters:
		startPos
			The zero based index to start the insertion
		obj
			The string var to insert into this instance
	Returns:
		Returns the number of char of this instance after insert
	Remarks:
		see Insert to insert as MfMemStrView instance
*/
	InsertStr(startPos, str) {
		; StartPos is the Position to start inserting text
		
		strLength := StrLen(str)
		If (strLength = 0)
		{
			return this.GetCharCount()
		}
		
		iLen := strLength * BytesPerChar
		
		PI := this.Pos ; this will be the end the current chars
		BytesPerChar := this.m_BytesPerChar
		encodingN := this.m_EncodingName
		startPos := startPos * BytesPerChar
		
		sType := BytesPerChar = 1? "UChar":"UShort"
		;this.Seek(StrPut(str, enc) * BytesPerChar, 1)
		iLen := StrLen(str) * BytesPerChar
		if ( (PI + ILen) > this.Size)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Capacity"), "str")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
		; copy the remainder of the string to a new address and then append it back later
		this.Seek(startPos) ; Move to the start Pos
		sourcePtr := this[] + this.Pos ; get the start pos Address
		ChunkLen := PI - this.Pos
		tmp := ""
		VarSetCapacity(tmp,ChunkLen + 10)
		DllCall("RtlMoveMemory", sType, &tmp, sType,sourcePtr + 0, sType,ChunkLen)
		result := ErrorLevel
		tmpC := VarSetCapacity(tmp,-1)
		
		methodName := "Write" . encodingN
		; Write the new strign into memory at current Pos
		chars := this.__Call(methodName,str)
		
		; Move the Position back one char to overwrite line end from write method
		this.Pos -= BytesPerChar
		sourcePtr := this[] + this.Pos ; get the start pos Address
		; Write the tmp memory into this
		DllCall("RtlMoveMemory", sType ,sourcePtr + 0, sType, &tmp, sType, ChunkLen)
		this.Pos += ChunkLen
		;this.Pos += BytesPerChar ; move forward to end again
				
		; clear tmp memory
		VarSetCapacity(tmp, 0)
		tmp := ""
		return this.GetCharCount()
	}
; 	End:InsertStr ;}
;{ 	MoveBytesLeft
/*
	Method: MoveBytesLeft()

	MoveBytesLeft()
		Moves bytes to the left
	Parameters:
		startPos
			the Position to start moving left
		Length
			The number of position to move left
	Returns:
		Returns 
	Throws:
		Throws MfException if
	Remarks:
		If MoveBytesLeft
*/
	MoveBytesLeft(startPos, Length) {
		; will be moving chunk start position to end to Dest Position which is left of start
		
		PI := this.Pos ; this will be the end the current chars
		this.Seek(startPos) ; Move to the start Pos
		sourcePtr := this[] + this.Pos ; get the start pos Address
		ChunkLen := PI - this.Pos
		destPtr := sourcePtr + Length
		BytesPerChar := this.m_BytesPerChar
		sType := BytesPerChar = 1? "UChar":"UShort"
		
		;DllCall("RtlMoveMemory","UInt",sourcePtr + 0,"UInt",destPtr + 0,"UInt",ChunkLen)
		DllCall("RtlMoveMemory", sType, sourcePtr + 0, sType, destPtr + 0, sType ,ChunkLen)
		this.Seek(PI - Length)
	}
; 	End:MoveBytesLeft ;}
	__Delete() {
		ObjSetCapacity(this, "_Buffer", 0)
	}
	
}

/* Class: MfMemBlkView
 *     Provides an interface for reading data from and writing it to a buffer or
 *     memory address. API is similar to that of AutoHotkey's File object.
 */
class MfMemBlkView
{
	/* Constructor: __New
	 *     Instantiates an object that respresents a view into a buffer.
	 * Syntax:
	 *     oView := new MfMemBlkView( ByRef VarOrAddress [ , offset := 0, length ] )
	 * Parameter(s):
	 *     oView             [retval] - a MfMemBlkView object
	 *     VarOrAddress   [in, ByRef] - variable(initialized by VarSetCapacity)
	 *                                  or a memory address
	 *     offset           [in, opt] - an offset, in bytes, which is added to
	 *                                  'VarOrAddress' for the new view object
	 *                                  to reference. Defaults to 0 if omitted.
	 *     length           [in, opt] - length of the view, in bytes. This parameter
	 *                                  is required when 'VarOrAddress' is a memory
	 *                                  address, else, an exception is thrown.
	 * Remarks:
	 *     An exception is thrown if the 'offset' and 'length' result in the
	 *     specified view extending past the end of the buffer.
	 */
	__New(ByRef VarOrAddr, offset:=0, length:="") {
		this.__Ptr := (IsByRef(VarOrAddr) ? &VarOrAddr : VarOrAddr) + offset
				
		if (length == "")
		{
			if !IsByRef(VarOrAddr)
				throw Exception("Parameter 'length' must be specified when passing an address", -1, VarOrAddr)
			length := VarSetCapacity(VarOrAddr)
		}
		if IsByRef(VarOrAddr) && ((offset + length) > VarSetCapacity(VarOrAddr))
			throw Exception("Trying to create view that extends past the buffer", -1, offset + length)

		this.Size := (this[] + length) - this[]
		this.Pos := 0
		
	}
	/* Property: Size
	 *     Size of the view in bytes. This property is read-only
	 * Syntax:
	 *     size := oView.Size
	 */

	/* Property: Pos
	 *     The current position of the view pointer, where 0 is the beginning of
	 *     the view
	 * Syntax:
	 *     pos := oView.Pos
	 */
	__Get(key:="", args*) {
		if !key || (key > 0 && key <= this.Size)
			return this.__Ptr + Round(key)
	}
	
	__Call(name, args*)	{
		if (name = "Put" || name = "Get")
			name .= "UPtr"
		else if (name = "Read" || name = "Write")
			name .= "CP0"

		if (name ~= "i)^((Put|Get)(U?(Char|Short|Int|Ptr)|Double|Float|Int64)|(Read|Write)(UTF(8|16)|CP\d+))$")
		{
			static ObjPush := Func(A_AhkVersion<"2" ? "ObjInsert" : "ObjPush")

			n := InStr("RW", SubStr(name, 1, 1)) ? InStr(name, "r") : 0
			%ObjPush%(args, SubStr(name, 4 + n)) ; num type OR encoding
			return this[n ? "_Str" : "_Num"](SubStr(name, 1, 3 + n), args*)
		}
	}
	/* Method: Put[NumType]
	 *     Store a number in binary format and advances the view pointer
	 * Syntax:
	 *     oView.PutNumType( num [ , offset ] )
	 * Parameter(s):
	 *     NumType          - One of the following specified directly as part of
	 *                        the method name: UInt, Int, Int64, Short, UShort,
	 *                        Char, UChar, Double, Float, UPtr or Ptr. Defaults
	 *                        to 'UPtr' if omitted.
	 *     num         [in] - a number
	 *     offset [in, opt] - the offset, in bytes, from the view's start point.
	 *                        If omitted, 'num' is written at the current position
	 *                        of the view pointer.
	 */

	/* Method: Get[NumType]
	 *     Reads a number from the view and advances the view pointer
	 * Syntax:
	 *     num := oView.GetNumType()
	 * Parameter(s):
	 *     num     [retval] - a number
	 *     NumType          - same as that of .PutNumType()
	 *     offset [in, opt] - the offset, in bytes, from the view's start point.
	 *                        If omitted, 'num' is read from the current position
	 *                        of the view pointer.
	 */
	_Num(action, args*)	{
		static sizeof := { "Char":1, "Short":2, "Int":4, "Float":4, "Double":8, "Int64":8, "Ptr":A_PtrSize }
		static ObjRemoveAt := Func(A_AhkVersion<"2" ? "ObjRemove" : "ObjRemoveAt")
		
		; Process args
		if (action = "Put")
		{
			num := %ObjRemoveAt%(args, 1)
			if sizeof[ LTrim(num, "Uu") ]
				throw Exception("Too few parameters passed to method", -1, "Put" . num . "()")
		}
		ptr := this[]
		at   := ObjHasKey(args, 1) && ((args[1]+0) != "") ? %ObjRemoveAt%(args, 1) : ptr + this.Pos
		type := ObjHasKey(args, 1) && sizeof[LTrim(args[1], "Uu")] ? args[1] : "UPtr"
		
		if (at != (ptr + this.Pos)) && (at >= 0 && at < this.Size) ; offset
			at += ptr

		if (action = "Put")
			return (n := NumPut(num, at + 0, type), this.Pos := n-ptr, n) ; rightmost for v2.0-a

		this.Seek(sizeof[ LTrim(type, "Uu") ], 1)
		return NumGet(at + 0, type)
	}
	/* Method: Write[Encoding]
	 *     Copies a string into the view and advances the view pointer
	 * Syntax:
	 *     chars := oView.WriteEncoding( str [ , length ] )
	 * Parameter(s):
	 *     Encoding           - source/target encoding in the following format:
	 *                          'CPnnn' or 'UTFn' specified directly as part of
	 *                          the method name. Defaults to 'CP0' if omitted.
	 *     chars     [retval] - the number of characters written
	 *     str           [in] - a string
	 *     length   [in, opt] - Similar to StrPut()'s 'Length' parameter.
	 */

	/* Method: Read[Encoding]
	 *     Copies a string from the view and advances the view pointer
	 * Syntax:
	 *     str := oView.ReadEncoding( [ length ] )
	 * Parameter(s):
	 *     Encoding           - same as that of .Write[Encoding]()
	 *     str       [retval] - the requested string after performing any necessary
	 *                          conversion
	 *     length   [in, opt] - Similar to StrGet()'s 'Length' parameter.
	 */
	_Str(action, args*)	{
		enc := "CP0" ; default encoding
		for i, arg in args
		{
			if (arg ~= "i)^UTF-?(8|16)|CP\d+$")
			{
				if InStr(enc := arg, "UTF")
					args[i] := enc := "UTF-" . Abs(SubStr(enc, 4)) ; normalizes if it contains a dash
				break
			}
		}
		static ObjRemoveAt := Func(A_AhkVersion<"2" ? "ObjRemove" : "ObjRemoveAt")
		addr := this[] + this.Pos
		str := action="Read" ? StrGet(addr, args*) : %ObjRemoveAt%(args, 1)

		BytesPerChar := (enc = "UTF-16" || enc = "CP1600") ? 2 : 1
		this.Seek(StrPut(str, enc) * BytesPerChar, 1)

		return action="Read" ? str : StrPut(str, addr, args*)
	}
	/* Method: RawRead
	 *     Copies raw binary data from the the view into the specified buffer
	 *     or memory address. Data is read from the current position of the view
	 *     pointer.
	 * Syntax:
	 *     BytesRead := oView.RawRead( ByRef VarOrAddress, bytes )
	 * Parameter(s):
	 *     BytesRead         [retval] - number of bytes that were read
	 *     VarOrAddress   [in, ByRef] - variable or memory address to which the
	 *                                  data will be copied
	 *     bytes                 [in] - maximum number of bytes to read
	 */
	RawRead(ByRef dest, bytes) {
		if ((this.Pos + bytes) > this.Size) ; exceeds view's capacity
			bytes := this.Size - this.Pos
		if IsByRef(dest) && (!VarSetCapacity(dest) || (VarSetCapacity(dest) < bytes))
		{
			if (bytes < (A_IsUnicode ? 6 : 3)) ; minimum allowed is 3 TCHARS
				VarSetCapacity(dest, 128), VarSetCapacity(dest, 0) ; force ALLOC_MALLOC method
			VarSetCapacity(dest, bytes, 0) ; initialize or adjust if capacity is 0 or < bytes
		}
		DllCall("RtlMoveMemory", "Ptr", IsByRef(dest) ? &dest : dest, "Ptr", this[] + this.Pos, "UPtr", bytes)
		return bytes
	}
	/* Method: RawWrite
	 *     Write raw binary data into the view. Data is written at the current
	 *     position of the view pointer.
	 * Syntax:
	 *     BytesWritten := oView.RawWrite( ByRef VarOrAddress, bytes )
	 * Parameter(s):
	 *     BytesWritten      [retval] - number of bytes that were written
	 *     VarOrAddress   [in, ByRef] - variable containing the data or the
	 *                                  address of the data in memory
	 *     bytes                 [in] - maximum number of bytes to write
	 */
	RawWrite(ByRef src, bytes) {
		if ((this.Pos + bytes) > this.Size)
			bytes := this.Size - this.Pos
		DllCall("RtlMoveMemory", "Ptr", this[] + this.Pos, "Ptr", IsByRef(src) ? &src : src, "UPtr", bytes)
		return bytes
	}
	/* Method: Seek
	 *     Moves the view pointer
	 * Syntax:
	 *     oView.Seek( distance [ , origin := 0 ] )
	 * Parameter(s):
	 *     distance      [in] - distance to move, in bytes.
	 *     origin   [in, opt] - starting point for the view pointer move. Must
	 *                          be one of the following:
	 *                              0 - beginning of the view
	 *                              1 - current position of the pointer
	 *                              2 - end of the view, 'distance' should usually
	 *                                  be negative
	 *                          If ommitted, 'origin' defaults to 2 if 'distance'
	 *                          is negative and 0 otherwise.
	 */
	Seek(distance, origin:=0) {
		if (distance < 0 && origin != 2)
			origin := 2
		start := origin == 0 ? this[]              ; start
		      :  origin == 1 ? this[] + this.Pos   ; current
		      :  origin == 2 ? this[] + this.Size  ; end
		      :  0
		return start ? this.Pos := start + distance - this[] : 0
	}
}