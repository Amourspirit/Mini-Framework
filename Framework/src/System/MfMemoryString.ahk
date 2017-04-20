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
 *	Class MfMemoryString
 *
 *	Methods
 *	Append() Appends a new value to the current instance
 *	AppendLine() Appends a new line value into the current instance
 *	Clear() Clears the contents of the buffer removing all text
 *	Clone()	Clones the current instanece into a new stream
 *	CompareOrdinal() Compares obj objects by evaluating the numeric values of the corresponding Char objects in obj.
 *	CompareOrdinalSubString() Compares obj objects by evaluating the numeric values of the corresponding Char objects in obj.
 *	Difference() Gets the Difference between argument obj and argument this instance with an included Max Distance.
 *	EndsWith() Gets a boolean value true or false if this instance ends with obj
 *	Equals() Checks to see if obj is equals this instance
  *	Expand() Expands the current instance of MfMemoryString by AddBytes ammount
 *	FromBase64() Encodes Obj to base64 instance of MfMemoryString
 *	FromByteList() Converts MfByteList into MfMemoryString instance
 *	IndexOf() Gets the zero based position of obj within the currrent instance from start
 *	Insert() Inserts obj into current instance
 *	LastIndexOf() Gets the zero based position of obj within the currrent instance from end
 *	Replace() Replaces instances of oldValue with Instances of newValue
 *	Remove() Removes a number of chars from currrent instance
 *	Reverse() Reverses the contentes of the currrent instance and returne it as a new instance
 *	StartsWith() Gets if current instance starts with obj
 *	SubString() Gets a new instance of MfMemoryString that represents a subset of the current instance chars
 *	ToArray() Gets Byte array of current chars
 *	ToBase64() Reads current instance and returns a new MfMemoryString instance endoced as UTF-8 base64
 *	ToByteList() Creates an MfByteList of bytes from current instance of MfMemoryString
 *	ToString() Retunrs the contents of the current instance as a string var
 *	Trim() Trims TrimChars or whitespace from this instance start and end
 *	TrimBuffer() Trims the internal buffer to the size of the current chars
 *	TrimStart() Trims TrimChars or whitespace from this instance start
 *	TrimStart() Trims TrimChars or whitespace from this instance end
 *	
 *	Properties
 *	Length - Gets the length of the current instance chars
 *	Size - Gets the Size of the current instance in bytes
 * 
 *	Internal class for working dircetly with memory strings
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
			Can be instance of MfMemoryString or any object derived from MfObject
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
;{ 	AppendLine
/*
	Method: AppendLine()

	AppendLine()
		Appends a new line value into the current instance
	Returns:
		Returns this instance after new line is appended
*/
	AppendLine() {
		chars := this.m_MemView.AppendString(this.m_nl)
		this.m_CharCount += chars
		return this
	}
; 	End:AppendLine ;}
/*
	Method: Clear()

	Clear()
		Clears the contents of the buffer removing all text
	Returns:
		Returns this instance after has taken place
*/
;{ 	Clear
	Clear() {
		this.m_CharCount := 0
		this.m_MemView := ""
		this.m_MemView := new MfMemStrView(this.m_Size, this.m_FillBytes, this.m_Encoding)
		return this
	}
; 	End:Clear ;}
;{ 	Clone
/*
	Method: Clone()

	Clone()
		Clones the current instanece into a new stream
	Returns:
		Returns an new instance with itentical contentents
	Remarks:
		Returns result contents are in a new new memory stream
*/
	Clone() {
		objMemRW := new MfMemoryString(this.m_BytesPerChar, this.m_FillBytes, this.m_Encoding)
		objMemRW.m_MemView := ""
		objMemRW.m_MemView := this.m_MemView.Clone()
		objMemRW.m_CharCount := this.m_CharCount
		objMemRW.m_Size := objMemRW.m_MemView.Size
		return objMemRW
	}
; 	End:Clone ;}
;{ 	CompareOrdinal
/*
	Method: CompareOrdinal()

	CompareOrdinal()
		Compares obj objects by evaluating the numeric values of the corresponding Char objects in obj.
	Parameters:
		obj
			The value to append to the instance
			Can be instance of MfMemoryString or MfMemStrView or any object derived from MfObject
		IgnoreCase
			If true comparison must ignore case, then perform an ordinal comparison.
			This technique is equivalent to converting the string to uppercase using the invariant culture
			and then performing an ordinal comparison on the result.
			Default value is false
	Returns:
		An integer that indicates the lexical relationship between the two comparands.
			Less than zero this instance is less than strB.
			Zero this instance and strB are equal.
			Greater than zero this instance is greater than strB.
	Throws:
		Throws MfException if
	Remarks:
		When IgnoreCase is true this method performs a case-sensitive comparison using ordinal sort rules.
		Indicates that the string comparison must use successive Unicode UTF-8 or UTF-16 encoded values of the string
		(code unit by code unit comparison), leading to a fast comparison but one that is culture-insensitive. 
*/
	CompareOrdinal(obj, ignoreCase=false) {
		if (MfNull.IsNull(obj))
		{
			return 1
		}
		mStr := this._FromAny(obj)
		ignoreCase := MfBool.GetValue(ignoreCase, false)
		If (ignoreCase)
		{
			result := MfMemStrView.CompareOrdinalIgnoreCase(this.m_MemView, mStr.m_MemView)
		}
		else
		{
			result := MfMemStrView.CompareOrdinal(this.m_MemView, mStr.m_MemView)
		}
		return result
		
	}
; 	End:CompareOrdinal ;}
;{ 	CompareOrdinalSubString
/*
	Method: CompareOrdinalSubString()

	CompareOrdinalSubString()
		Compares obj objects by evaluating the numeric values of the corresponding Char objects in obj.
	Parameters:
		obj
			The value to append to the instance
			Can be instance of MfMemoryString or MfMemStrView or any object derived from MfObject
		objIndex
			The index in obj to start comparing to this instance
		index
			The index of the current instance to start comparing
		IgnoreCase
			If true comparison must ignore case, then perform an ordinal comparison.
			This technique is equivalent to converting the string to uppercase using the invariant culture
			and then performing an ordinal comparison on the result.
			Default value is false
	Returns:
		Returns 
	Throws:
		Throws MfException if
	Remarks:
		If CompareOrdinalSubString
*/
	CompareOrdinalSubString(obj, objIndex,  index, length=-1, ignoreCase=false) {
		if (MfNull.IsNull(obj))
		{
			return 1
		}
		objIndex := MfInteger.GetValue(objIndex)
		index := MfInteger.GetValue(index)
		length := MfInteger.GetValue(length)
		ignoreCase := MfBool.GetValue(ignoreCase, false)
		mStr := this._FromAny(obj)
		result := MfMemStrView.CompareOrdinalSub(this.m_MemView, index, mStr.m_MemView, objIndex, length, ignoreCase)
		return result
	}
; 	End:CompareOrdinalSubString ;}
;{ 	Difference
	/*
	Method: Difference()
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
			result := MfMemStrView.Diff(this.m_MemView, mStr.m_MemView, maxOffset)
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
;{ 	EndsWith
/*
	Method: EndsWith()

	EndsWith()
		Gets a boolean value true or false if this instance ends with obj
	Parameters:
		obj
			Can be string var or instance of MfMemoryString
		IgnoreCase
			Boolean value. If true case is ignored; Otherwise case is case is not ignored
	Returns:
		Returns true if current instance ends with obj; Otherwise false
*/
	EndsWith(obj, IgnoreCase=true) {
		if (MfNull.IsNull(obj))
		{
			return false
		}
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
;{ 	EndsWith
;{ 	Equals
	/*
	Method: Equals()
		
	Equals()
		Checks to see if obj is equals this instance
	Parameters:
		obj
			Can be string var or instance of MfMemoryString
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
;{ 	Expand
/*
	Method: Expand()

	Expand()
		Expands the current instance of MfMemoryString by AddBytes ammount
	Parameters:
		AddBytes
			The number of bytes to add to the current instance
	Returns:
		Returns current instance
	Throws:
		Throws MfArgumentNullException if Addbytes is null
		Throws MfArgumentException if AddBytes cannot be converted into valid integer or AddBytes is less then 0
*/
	Expand(AddBytes) {
		if (MfNull.IsNull(AddBytes))
		{
			ex := new MfArgumentNullException("AddBytes")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		i := MfInteger.GetValue(AddBytes)
		if (i < 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_NegativeCount"), "AddBytes")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (i = 0)
		{
			return this
		}
		this.m_Size := this.m_MemView.Expand(i)
		return this

	}
; 	End:Expand ;}
;{ 	FromBase64
/*
	Method: FromBase64()

	FromBase64()
		Encodes Obj to base64 instance of MfMemoryString
	Parameters:
		obj
			The value that represents base64
			Can be instance of MfMemoryString or MfMemStrView or any object derived from MfObject
	Returns:
		Returns instance of MfMemoryString with decoded base64 value
	Throws:
		Throws MfInvalidOperationException if not called as a static method
		Throws MfArgumentNullException if obj is null
		Throws MfFormatException if obj does not contain valid base64
	Remarks:
		Static Method
*/
	FromBase64(obj) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfNull.IsNull(obj))
		{
			ex := new MfArgumentNullException("obj")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		mStr := MfMemoryString._FromAnyStatic(obj, "UTF-8") ; base64 string, Use UTF-8
		if (!(mStr.m_Encoding = "UTF-8"))
		{
			; if MfMemoryString instance was passed in not encoded as UTF-8 then
			; call method again to convert to UTF-8
			mStr := MfMemoryString._FromAnyStatic(mStr.ToString(), "UTF-8")
		}
		mv := MfMemStrView.FromBase64(mStr.m_MemView,0, mStr.m_CharCount)

		objMemRW := new MfMemoryString(mv.m_BytesPerChar, mv.m_FillBytes, mv.m_Encoding)
		objMemRW.m_MemView := ""
		objMemRW.m_MemView := mv
		objMemRW.m_CharCount := mv.GetCharCount()
		objMemRW.m_Size := mv.Size
		return objMemRW
	}
; 	End:FromBase64 ;}
;{ 	FromByteList
/*
	Method: FromByteList()

	FromByteList()
		Converts MfByteList into MfMemoryString instance
	Parameters:
		bytes
			instance of MfByteList containing byte values to convert
		encoding
			The encoding type of the bytes such as UTF-16 or UTF-8
			Default value is UTF-16 which means each char is expected to be two bytes
		startIndex
			The starting index in the MfByteList to start the conversion
			Default value is 0
		length
			the length in bytes to convert.
			Default value is -1
			When length is less then 0 then all bytes past startIndex are included
		littleEndian
			Default value is true.
			If true then byte order is considered to be reversed and the bytes are written into
			memory from last byte to first after considering startIndex and length; Oterwise bytes
			are written from start to end.
	Returns:
		Returns instance of MfMemoryString
	Throws:
		Throws MfArgumentException, MfArgumentOutOfRangeException
	Remarks:
		Both startIndex and length operate the same no mater the state of littleEndian.
		Static Method
*/
	FromByteList(bytes, encoding="UTF-16", startIndex=0, length=-1, littleEndian=true) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		startIndex := MfInteger.GetValue(startIndex, 0)
		length := MfInteger.GetValue(length, -1)
		littleEndian := MfBool.GetValue(littleEndian, true)

		mv := MfMemStrView.FromByteList(bytes, encoding, startIndex, length, littleEndian)

		objMemRW := new MfMemoryString(mv.m_BytesPerChar, mv.m_FillBytes, mv.m_Encoding)
		objMemRW.m_MemView := ""
		objMemRW.m_MemView := mv
		objMemRW.m_CharCount := mv.GetCharCount()
		objMemRW.m_Size := mv.Size
		return objMemRW
	}
; 	End:FromByteList ;}
;{ 	IndexOf
/*
	Method: IndexOf()

	IndexOf()
		Gets the zero based position of obj within the currrent instance from start
	Parameters:
		obj
			Can be string var or instance of MfMemoryString
		Offset
			The offset in char count to start looking for obj
			Default value is 0
		Count
			The Number of Chacters to examine.
			Default is -1
			If Count less then 0 then character within startIndex range are examined
		IgnoreCase
			If true then case is ignored: Otherwise case is considered			
	Returns:
		Returns the zero base index of obj within current instance if found; Otherwise -1
	Throws:
		Throws MfArgumentException
	Remarks:
		Case sensitive method
*/
	IndexOf(obj, startIndex=0, Count=-1, IgnoreCase=true) {
		if (MfNull.IsNull(obj))
		{
			return -1
		}
		startIndex := MfInteger.GetValue(startIndex, 0)
		IgnoreCase := MfBool.GetValue(IgnoreCase, true)
		Count := MfInteger.GetValue(Count, -1)
		If (Count = 0)
		{
			return -1
		}
		if (startIndex < 0 || startIndex >= this.m_CharCount)
		{
			return -1
		}

		mStr := this._FromAny(obj)
		if (IgnoreCase && Count <= -1)
		{
			return this.m_MemView.InBuffer(mStr.m_MemView, startIndex)
		}
		return this.m_MemView.IndexOf(mStr.m_MemView, startIndex, Count, IgnoreCase)
	}
; 	End:IndexOf ;}
;{ 	Insert
/*
	Method: Insert()

	Insert()
		Inserts obj into current instance
	Parameters:
		index
			The zero base index to insert obj into current instance
		obj
			Can be string var or instance of MfMemoryString
	Returns:
		Returns 
	Throws:
		Throws MfArgumentNullException, MfArgumentException, MfIndexOutOfRangeException
	Remarks:
		If index greater then or equal to current character count then obj is appended to end of this instance
*/
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
; 	End:Insert ;}
;{ 	LastIndexOf
/*
	Method: LastIndexOf()

	LastIndexOf()
		Gets the zero based position of obj within the currrent instance from end
	Parameters:
		obj
			Can be string var or instance of MfMemoryString
		startIndex
			The offset in char count to start looking for obj
			Default value is 0
			Proceeds from the startIndex to the beginning of the string
		Count
			The Number of Chacters to examine.
			Default is -1
			If Count less then 0 then character within startIndex range are examined
		IgnoreCase
			If true then case is ignored: Otherwise case is considered
	Returns:
		Returns the zero base index of obj within current instance if found; Otherwise -1 
	Throws:
		Throws MfArgumentException
	Remarks:
		Case sensitive method
*/
	LastIndexOf(obj, startIndex=-1, Count=-1, IgnoreCase=true) {
		if (MfNull.IsNull(obj))
		{
			return -1
		}
		startIndex := MfInteger.GetValue(startIndex, -1)
		Count := MfInteger.GetValue(Count, -1)
		If (Count = 0)
		{
			return -1
		}
		if (startIndex >= this.m_CharCount)
		{
			return -1
		}
		mStr := this._FromAny(obj)
		if (IgnoreCase && Count <= -1)
		{
			if (startIndex >= 0)
			{
				startIndex++
			}
			; InbufferRev is faster then LastIndexOf so use it where we can
			return this.m_MemView.InBufferRev(mStr.m_MemView, startIndex)
			
		}
		return this.m_MemView.LastIndexOf(mStr.m_MemView, startIndex, Count, IgnoreCase)
	}
; 	End:LastIndexOf ;}

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
		Throws MfArgumentException
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
;{ 	Remove
/*
	Method: Remove()

	Remove()
		Removes a number of chars from currrent instance
	Parameters:
		index
			The zero base index to insert obj into current instance
		length
			The number of chars to remove from the current instance.
			Default value is 1
	Returns:
		Returns current instance
	Throws:
		Throws MfIndexOutOfRangeException, MfArgumentException
*/
	Remove(index, length=1) {
		index := MfInteger.GetValue(index)
		length := MfInteger.GetValue(length, 1)
		if ((index < 0) || (index >= this.m_CharCount))
		{
			ex := new MfIndexOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_IndexLength"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if ((length < 0) || ((length + index) > this.m_CharCount))
		{
			ex := new MfIndexOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_IndexLength"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		StartPos := index * this.m_BytesPerChar
		_length := length * this.m_BytesPerChar
		this.m_MemView.MoveBytesLeft(StartPos, _length)
		this.m_CharCount := this.m_CharCount - length
		return this
	}
; 	End:Remove ;}
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
		Returns a new instance of MfMemoryString with the chars reversed
	Remarks:
		New line char sequences set in the framework will not be reversed in the return output.
		the default new line chars are 13, 10 when the string is reversed the order will still be 13, 10
		the order and char for new line are read from MfEnviroment.Instance.NewLine
*/
	Reverse(LimitBytes=false) {
		LimitBytes := MfBool.GetValue(LimitBytes, false)
		objRev := new MfMemoryString(this.m_BytesPerChar, this.m_FillBytes, this.m_Encoding)
		objRev.m_MemView := ""
		objRev.m_MemView := this.m_MemView.Reverse(LimitBytes)
		objRev.m_CharCount := this.m_CharCount
		objRev.m_Size := objRev.m_MemView.Size
		return objRev
	}
; 	End:Reverse ;}
	_ResetPos() {
		; add one for line end
		i := (this.m_CharCount + 1) * this.m_BytesPerChar
		this.m_MemView.Pos := i
	}
;{ 	StartsWith
/*
	Method: StartsWith()

	StartsWith()
		Gets if current instance starts with obj
	Parameters:
		obj
			The value to see if current instance starts with
			Can be instance of MfMemoryString or MfMemStrView or any object derived from MfObject
		IgnoreCase
			Boolean value, Default is true. If True Case will be ignored; Otherwise case will be considered
			Default value is true
	Returns:
		Returns True if current instane starts with obj; Otherwise false
	Throws:
		Throws MfArgumentNullException if obj is null
*/
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
; 	End:StartsWith ;}
;{ 	SubString
/*
	Method: SubString()

	SubString()
		Gets a new instance of MfMemoryString that represents a subset of the current instance chars
	Parameters:
		StartIndex
			The zero based index to start the subset from.
		Length
			The length of the subset.
			Default value is -1.
			If value is -1 then all chars from startindex will be included
	Returns:
		Returns 
	Throws:
		Throws MfException if
	Remarks:
		If SubString
*/
	SubString(StartIndex, Length=-1) {
		StartIndex := MfInteger.GetValue(StartIndex, 0)
		Length := MfInteger.GetValue(Length, -1)
		mv := this.m_MemView.SubSet(StartIndex, Length)
		objMemRW := new MfMemoryString(mv.m_BytesPerChar, mv.m_FillBytes, mv.m_Encoding)
		objMemRW.m_MemView := ""
		objMemRW.m_MemView := mv
		objMemRW.m_CharCount := mv.GetCharCount()
		objMemRW.m_Size := mv.Size
		return objMemRW
	}
; 	End:SubString ;}
;{ 	ToArray
/*
	Method: ToArray()

	ToArray()
		Gets Byte array of current chars
	Parameters:
		startIndex
			Optional. The zero based start array to get the bytes for.
			Default is 0
		length
			Optional. the total number of bytes to get.
			Default -1
			Any value less then 0 will result in all char bytes from startIndex to char count
	Returns:
		Returns AutoHotkey one based array of bytes (values from 0 to 255) in Big Endian order
	Throws:
		Throws MfArgumentOutOfRangeException startIndex or length is out of range
*/
	ToArray(startIndex=0, length=-1) {
		startIndex := MfInteger.GetValue(startIndex, 0)
		length := MfInteger.GetValue(length, 0)
		if ((StartIndex < 0) || (StartIndex >= this.m_CharCount))
		{
			ex := new MfArgumentOutOfRangeException("StartIndex", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_IndexString"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (Length < 0)
		{
			Length := (this.m_CharCount - StartIndex)
		}
		if ((Length + StartIndex) > this.m_CharCount)
		{
			ex := new MfArgumentOutOfRangeException("Length", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_IndexString"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		StartIndex := StartIndex * this.m_BytesPerChar
		length := length * this.m_BytesPerChar
		return this.m_MemView.ToArray(startIndex, length, "UChar")
	}
; 	End:ToArray ;}
	;{ 	ToBase64
/*
	Method: ToBase64()

	ToBase64()
		Reads current instance and returns a new MfMemoryString instance endoced as UTF-8 base64
	Parameters:
		addLineBreaks
			Boolean Value, If True a line break will be added to the output every 76 chars;
			Otherwise no line breaks will be added.
	Returns:
		Returns instance of MfMemoryString
	Throws:
		Throws MfException if
	Remarks:
		Return MfMemoryString instance is always encoded as UTF-8
*/
	ToBase64(addLineBreaks=false) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		addLineBreaks := MfBool.GetValue(addLineBreaks, false)
		result := ""
		mv := MfMemStrView.ToBase64(this.m_MemView, 0, this.m_CharCount, addLineBreaks)
		
		objMemRW := new MfMemoryString(mv.m_BytesPerChar, mv.m_FillBytes, mv.m_Encoding)
		objMemRW.m_MemView := ""
		objMemRW.m_MemView := mv
		objMemRW.m_CharCount := mv.GetCharCount()
		objMemRW.m_Size := mv.Size
		return objMemRW
	}
; 	End:ToBase64 ;}
;{ 	ToByteList
/*
	Method: ToByteList()

	ToByteList()
		Creates an MfByteList of bytes from current instance of MfMemoryString
	Parameters:
		startIndex
			The zero based index to start reading current instance chars as bytes
		length
			The length in chars to read from current instance
			Default value is -1
			When value is -1 chars are read from startIndex to current char count
		littleEndian
			Default is true, If True byte order is in Little Endian;
			Otherwise byte order is in Big Endian ( same as ToArray )
	Returns:
		Returns MfByteList
	Throws:
		Throws MfArgumentOutOfRangeException startIndex or length is out of range
*/
	ToByteList(startIndex=0, length=-1, littleEndian=true) {
		startIndex := MfInteger.GetValue(startIndex, 0)
		length := MfInteger.GetValue(length, 0)
		if ((StartIndex < 0) || (StartIndex >= this.m_CharCount))
		{
			ex := new MfArgumentOutOfRangeException("StartIndex", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_IndexString"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (Length < 0)
		{
			Length := (this.m_CharCount - StartIndex)
		}
		if ((Length + StartIndex) > this.m_CharCount)
		{
			ex := new MfArgumentOutOfRangeException("Length", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_IndexString"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		littleEndian := MfBool.GetValue(littleEndian, true)
		StartIndex := StartIndex * this.m_BytesPerChar
		length := length * this.m_BytesPerChar
		return this.m_MemView.ToByteList(startIndex, length, littleEndian)
	}
; 	End:ToByteList ;}

;{ 	_SubString
	; gets substring as string var of current instance
	; see ToString()
	_SubString(StartIndex, Length) {
		if (Length = 0)
		{
			return ""
		}
		if ((StartIndex < 0) || (StartIndex >= this.m_CharCount))
		{
			ex := new MfArgumentOutOfRangeException("StartIndex", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_IndexString"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if ((Length < 0) || ((Length + StartIndex) > this.m_CharCount))
		{
			ex := new MfArgumentOutOfRangeException("Length", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_IndexString"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
				
		_StartIndex := StartIndex * this.m_BytesPerChar
		PI := this.m_MemView.Pos
		this.m_MemView.Seek(_StartIndex)
		methodName := "Read" . this.m_EncodingName
		; Read method will read the proper length no matter the encoding
		len := Length
		retval := this.m_MemView.__Call(methodName, len)
		this.m_MemView.Pos := PI
		return retval
	}
; 	End:_SubString ;}

;{ 	ToString
/*
	Method: ToString()

	ToString()
		Retunrs the contents of the current instance as a string var
	Parameters:
		StartIndex
			The zero based index to start the output string from.
			Default value is 0
		Length
			The length of the output string in chars.
			Default value is -1
			If Length value is -1 this all characters from StartIndex are returned
	Returns:
		Returns String Var
	Throws:
		Throws MfArgumentOutOfRangeException
*/
	ToString(StartIndex=0, Length=-1) {
		StartIndex := MfInteger.GetValue(StartIndex, 0)
		Length := MfInteger.GetValue(Length, -1)
		if (StartIndex != 0)
		{
			if (Length < 0)
			{
				Length := (this.m_CharCount - StartIndex)
			}
			return this._SubString(StartIndex,Length)
		}
		else if (Length < 0)
		{
			Length := this.m_CharCount
		}
		if (Length >= 0)
		{
			return this._SubString(StartIndex,Length)
		}
		return this.m_MemView.ToString()
	}
; 	End:ToString ;}
;{ Trim
/*
	Method: Trim()

	Trim()
		Trims TrimChars or whitespace from this instance start and end
	Parameters:
		trimChars
			Optional string var. The char(s) to trim from this instance.
			If omitted then all unicode whitespace chars are trimed
		IgnoreCase
			Boolean value. Default value is true, If True then case will be ignored; Otherwise
			case will be considered.
			Ignore Case only applies when trimChars has a value
	Returns:
		Returns this instance
*/
	Trim(trimChars="", IgnoreCase=true) {
		If (this.m_CharCount = 0)
		{
			return this
		}
		this.TrimStart(trimChars, IgnoreCase)
		return this.TrimEnd(trimChars, IgnoreCase)
	}
; End:Trim ;}
	;{ 	TrimBuffer
/*
	Method: TrimBuffer()

	TrimBuffer()
		Trims the internal buffer to the size of the current chars
	Returns:
		Returns this instance
	Remarks:
		Trims the buffer down to the size of the current text
*/
	TrimBuffer() {
		this.m_CharCount := this.m_MemView.TrimBufferToPos()
		this.m_Size := this.m_MemView.Size
		return this
	}
; 	End:TrimBuffer ;}
;{ 	TrimStart
/*
	Method: Trim()

	TrimStart()
		Trims TrimChars or whitespace from this instance start
	Parameters:
		trimChars
			Optional string var. The char(s) to trim from this instance.
			If omitted then all unicode whitespace chars are trimed
		IgnoreCase
			Boolean value. Default value is true, If True then case will be ignored; Otherwise
			case will be considered.
			Ignore Case only applies when trimChars has a value
	Returns:
		Returns this instance
*/
	TrimStart(trimChars="", IgnoreCase=true) {
		If (this.m_CharCount = 0)
		{
			return this
		}
		trimChars := MfString.GetValue(trimChars)
		IgnoreCase := MfBool.GetValue(IgnoreCase, true)
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
; 	End:TrimStart ;}
;{ 	TrimEnd
/*
	Method: Trim()

	TrimStart()
		Trims TrimChars or whitespace from this instance end
	Parameters:
		trimChars
			Optional string var. The char(s) to trim from this instance.
			If omitted then all unicode whitespace chars are trimed
		IgnoreCase
			Boolean value. Default value is true, If True then case will be ignored; Otherwise
			case will be considered.
			Ignore Case only applies when trimChars has a value
	Returns:
		Returns this instance
*/
	TrimEnd(trimChars="", IgnoreCase=true) {
		If (this.m_CharCount = 0)
		{
			return this
		}
		trimChars := MfString.GetValue(trimChars)
		IgnoreCase := MfBool.GetValue(IgnoreCase, true)
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
; 	End:TrimEnd ;}
;{ 	_FromAnyStatic
	; static method for converting var or obj into MfMemoryString
	_FromAnyStatic(x, encoding) {

		BytesPerChar := (encoding = "UTF-16" || encoding = "CP1600") ? 2 : 1
		if (IsObject(x))
		{
			if(MfObject.IsObjInstance(x, MfMemoryString))
			{
				if (!(x.m_Encoding = encoding))
				{
					return MfMemoryString._FromAnyStatic(x.ToString(), encoding)
				}
				return x
			}

			else if (MfObject.IsObjInstance(x, MfString))
			{
				len := (x.Length + 1) * BytesPerChar
				retval := new MfMemoryString(len, , encoding)
				retval.Append(x.Value)
				return retval
			}
			else if (MfObject.IsObjInstance(x, MfObject))
			{
				str := x.ToString()
				len := (StrLen(str) + 1) * BytesPerChar
				retval := new MfMemoryString(len, , encoding)
				retval.Append(str)
				return retval
			}
			else if (x.__Class = "MfMemStrView")
			{
				retval := new MfMemoryString(x.m_BytesPerChar, x.m_FillBytes, x.m_Encoding)
				retval.m_MemView := ""
				retval.m_MemView := x
				retval.m_CharCount := (x.Pos - 1) // x.m_BytesPerChar
				retval.m_Size := x.Size
				return this._FromAnyStatic(retval, x.m_Encoding) ; do another _FromAny in case encoding is different
			}
			else
			{
				return new MfMemoryString(BytesPerChar, , encoding)
			}
		}
		if (x = "")
		{
			return new MfMemoryString(BytesPerChar, , encoding)
		}

		len := (StrLen(x) + 1) * BytesPerChar
		retval := new MfMemoryString(len, , encoding)
		retval.Append(x)
		return retval
	}
; 	End:_FromAnyStatic ;}
;{ 	_FromAny
	; instance method for converting var or obj into MfMemoryString
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
				retval := new MfMemoryString(x.m_BytesPerChar, x.m_FillBytes, x.m_Encoding)
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
; 	End:_FromAny ;}
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
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, "Length")
			Throw ex
		}
	}
	;
; End:Length ;}
	;{ Size
		/*!
			Property: Size [get]
				Gets the Size of the current instance in bytes
			Value:
				Var integer
			Remarks:
				Readonly Property
		*/
		Size[]
		{
			get {
				return this.m_MemView.Size
			}
			set {
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
				ex.SetProp(A_LineFile, A_LineNumber, "Size")
				Throw ex
			}
		}
	; End:Size ;}
}

/* Class: MfMemStrView
 *	Methods
 *	Append() Appends obj instance to this instance
 *	AppendString() Appends a string var to current instance
 *	Clone() Clones the current instance and returns a copy
 *	CompareOrdinal() Compares two instance of MfMemStrView as Ordinal
 *	CompareOrdinalIgnoreCase() Compares two instance of MfMemStrView as Ordinal ignoring case
 *	CompareOrdinalSub()	Compares two sub values of instances of MfMemStrView as Ordinal, optionally ignoring case.
 *	Diff() Gets the Difference between argument objA and argument objB argument with an included Max Distance.
 *	EndsWithFromPos() Checks to see if obj ends with the same char as this instance
 *	EqualsSubString() Compares two MfMemStrView objects to see if their subPositions are equal
 *	Equals() Check to see if current instance is equal string as Obj
 *	EqualsString() Check to see if current instance is equal with str
 *	Expand() Expands the current buffer Adding new bytes
 *	FromArray() Creates new isntance of MfMemBlkView from AutoHotkey one based byte array
 *	FromByteList() Converts MfByteList into MfMemStrView instance
 *	FromBase64() Reads buffer and returns UTF-8 or UTF-16 buffer from base64
 *	FromVarAddress() Creates an new instance of MfMemStrView from var or address
 *	GetCharCount() Gets the number of chars currently in this buffer instance
 *	InBuffer() Searches current instance for the first instance of NeedleObj from StartOffset
 *	InBufferRev() Searches current instance for the last instance of NeedleObj from EndOffset
 *	InBuf()	Blazing fast machine-code CASE-SENSITIVE searching in a (binary) buffer for a sequence of bytes,
 *		that may include NULL characters.
 *	InBufRev() Blazing fast machine-code CASE-SENSITIVE searching in a (binary) buffer for a sequence of bytes, 
 *		that may include NULL characters. Reverse look for binary Needle in binary Buffer
 *	IndexOf() Gets the First index of NeedleObj in current instance
 *	Insert() Inserts the contents of obj into current instance
 *	InsertStr()	Inserts the contents of str into current instance
 *	IsWhiteSpace() Check to see if a char number is considered to be whitespace
 *	LastIndexOf() Gets the last index of NeedleObj in current instance
 *	MoveBytesLeft() Moves bytes to the left in the current instance.
 *	Reverse() Reverses the contentes of the currrent instance and returne it as a new instance
 *	ToBase64() Reads instanceof MfMemStrView and returns a new MfMemStrView as base64 equal UTF-8 Encoded
 *	ToString() Gets the value of this instance as string var
 *	TrimBufferToPos() Trims the current size to the current Pos
 *	TrimStart() Trims all whitespace char from start of current instance
 *	TrimStartChars() Trims char(s) from the start of a string
 *	TrimEnd() Trims all whitespace char from end of current instance
 *	TrimStartChars() Trims char(s) from the end of a string
 *	TrimMemoryRight() Overwrites memory bytes with fillbytes for the end of a string, Erases end of a string
 *	StringsAreEqual() Binary comparsion of string in memory
 *	SubSet() Gets a sub set (sub string) of the currrent instance chars
 *	
 *	Internal Class
 *     A MfMemStrView object is used to represent a raw binary data buffer. This class
 *     extends from MfMemBlkView allowing you to directly manipulate its contents.
 */
class MfMemStrView extends MfMemBlkView
{
	m_FillBytes := ""
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
		this.m_FillBytes := FillByte
		ObjSetCapacity(this, "_Buffer", size)
		this.m_BytesPerChar := MfMemStrView.GetBytesPerChar(encoding)
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
;{ 	Clone
/*
	Method: Clone()

	Clone()
		Clones the current instance and returns a copy
	Returns:
		Returns copy of current instance
*/
	Clone() {
		objMemBlk := new MfMemStrView(this.Size, this.m_FillBytes, this.m_Encoding)
		newAddress := objMemBlk[]
		Address := this[]
		DllCall("RtlMoveMemory", UInt,newAddress + 0, UInt,Address + 0, Uint, this.Size)
		objMemBlk.Pos := this.Pos
		return objMemBlk
	}
; 	End:Clone ;}
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
	CompareOrdinalIgnoreCase(ByRef objA, ByRef objB) {
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
;{ 	CompareOrdinalSub
/*
	Method: CompareOrdinalSub()

	CompareOrdinalSub()
		Compares two sub values of instances of MfMemStrView as Ordinal, optionally ignoring case.
	Parameters:
		objA
			The first instance of MfMemStrView to compare
		indexA
			The zero based index location within objA to start comparing.
			Index location is base upon the char count
		objB
			The Second instance of MfMemStrView to compare
		indexB
			The zero based index location within objB to start comparing.
			Index location is base upon the char count
		len
			The length of the string to compare, this is the length of number of characters
			Default value is -1. If default then len is converted to the length of the shortest value after index of objA and objB.
		ignoreCase
			If true case is considered when comparing; Otherwise case is ignored.
			The default is false
	Returns:
		Returns integer of 0 if equal, if objA is greater then objB the positive number is returned; Otherwise negative number
	Throws:
		Throws MfArgumentException
		Throws MfIndexOutOfRangeException
		Throw MfFormatException is encodings are not the same
	Remarks:
		Static Method
*/
	CompareOrdinalSub(byref objA, indexA, byRef objB, indexB, len=-1, ignoreCase=false) {
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

		PIA := objA.Pos
		PIB := objB.Pos
		if (indexA < 0 || indexA > PIA || len > PIA)
		{
			ex := new MfIndexOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_ArrayListInsert"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (indexB < 0 || indexB > PIB || len > PIB)
		{
			ex := new MfIndexOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_ArrayListInsert"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
		objA.Seek(indexA * BytesPerChar)
		objB.Seek(indexB * BytesPerChar)
		
		HasLen := true
		if (len = -1)
		{
			aEnd := PIA - BytesPerChar
			bEnd := PIB - BytesPerChar
			aLen := aEnd - objA.Pos ; aLen may be 1 or two bytes per char
			bLen := bEnd - objB.Pos ; bLen may be 1 or two bytes per char
			HasLen := false
			len := aLen > bLen ? bLen : aLen
		}

		i := len
		;i -= BytesPerChar
		num := -1
		AddressA := objA[] + objA.Pos
		AddressB := objB[] + objB.Pos
		ptrA := AddressA ; first char address
		ptrB := AddressB ; frist char address

		; reset object positions
		objA.Pos := PIA
		objB.Pos := PIB

		While (i >= 5 * BytesPerChar)
		{
			numA := NumGet(ptrA + 0, 0, sType)
			numB := NumGet(ptrB + 0, 0, sType)
			if (numA != numB)
			{
				If (!ignoreCase)
				{
					num := 0
					break
				}
				If (MfMemStrView._IsLatin1(numA) && MfMemStrView._IsLatin1(numB))
				{
					if (MfMemStrView._IsEqualLatin1IgnoreCase(numA, numB) = False)
					{
						num := 0
						break
					}
				}
				else
				{
					char1 := Chr(numA)
					char2 := Chr(numB)
					if (!(char1 = char2))
					{
						num := 0
						break
					}
				}
			}
			numA := NumGet(ptrA + BytesPerChar, 0, sType)
			numB := NumGet(ptrB + BytesPerChar, 0, sType)
			if (numA != numB)
			{
				If (!ignoreCase)
				{
					num := BytesPerChar
					break
				}
				If (MfMemStrView._IsLatin1(numA) && MfMemStrView._IsLatin1(numB))
				{
					if (MfMemStrView._IsEqualLatin1IgnoreCase(numA, numB) = False)
					{
						num := BytesPerChar
						break
					}
				}
				else
				{
					char1 := Chr(numA)
					char2 := Chr(numB)
					if (!(char1 = char2))
					{
						num := BytesPerChar
						break
					}
				}
			}
			numA := NumGet(ptrA + (BytesPerChar * 2), 0, sType)
			numB := NumGet(ptrB + (BytesPerChar * 2), 0, sType)
			if (numA != numB)
			{
				If (!ignoreCase)
				{
					num := BytesPerChar * 2
					break
				}
				If (MfMemStrView._IsLatin1(numA) && MfMemStrView._IsLatin1(numB))
				{
					if (MfMemStrView._IsEqualLatin1IgnoreCase(numA, numB) = False)
					{
						num := BytesPerChar * 2
						break
					}
				}
				else
				{
					char1 := Chr(numA)
					char2 := Chr(numB)
					if (!(char1 = char2))
					{
						num := BytesPerChar * 2
						break
					}
				}
			}
			numA := NumGet(ptrA + (BytesPerChar * 3), 0, sType)
			numB := NumGet(ptrB + (BytesPerChar * 3), 0, sType)
			if (numA != numB)
			{
				If (!ignoreCase)
				{
					num := BytesPerChar * 3
					break
				}
				If (MfMemStrView._IsLatin1(numA) && MfMemStrView._IsLatin1(numB))
				{
					if (MfMemStrView._IsEqualLatin1IgnoreCase(numA, numB) = False)
					{
						num := BytesPerChar * 3
						break
					}
				}
				else
				{
					char1 := Chr(numA)
					char2 := Chr(numB)
					if (!(char1 = char2))
					{
						num := BytesPerChar * 3
						break
					}
				}
			}
			numA := NumGet(ptrA + (BytesPerChar * 4), 0, sType)
			numB := NumGet(ptrB + (BytesPerChar * 4), 0, sType)
			if (numA != numB)
			{
				If (!ignoreCase)
				{
					num := BytesPerChar * 4
					break
				}
				If (MfMemStrView._IsLatin1(numA) && MfMemStrView._IsLatin1(numB))
				{
					if (MfMemStrView._IsEqualLatin1IgnoreCase(numA, numB) = False)
					{
						num := BytesPerChar * 4
						break
					}
				}
				else
				{
					char1 := Chr(numA)
					char2 := Chr(numB)
					if (!(char1 = char2))
					{
						num := BytesPerChar * 4
						break
					}
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
					If (!ignoreCase)
					{
						break
					}
					If (MfMemStrView._IsLatin1(numA) && MfMemStrView._IsLatin1(numB))
					{
						if (MfMemStrView._IsEqualLatin1IgnoreCase(numA, numB) = False)
						{
							break
						}
					}
					else
					{
						char1 := Chr(numA)
						char2 := Chr(numB)
						if (!(char1 = char2))
						{
							break
						}
					}
				}
				ptrA += BytesPerChar
				ptrB += BytesPerChar
				i -= BytesPerChar
			}
			if (i <= 0)
			{
				if (!HasLen)
				{
					return aLen - bLen
				}
				return i
			}
			numA := NumGet(ptrA + 0, 0, sType)
			numB := NumGet(ptrB + 0, 0, sType)
			result := 0
			if (NumA != numB)
			{
				If (!ignoreCase)
				{
					result := numA - numB
				}
				else If (MfMemStrView._IsLatin1(numA) && MfMemStrView._IsLatin1(numB))
				{
					if (MfMemStrView._IsEqualLatin1IgnoreCase(numA, numB) = False)
					{
						result := numA - numB
					}
				}
				else
				{
					char1 := Chr(numA)
					char2 := Chr(numB)
					if (!(char1 = char2))
					{
						result := numA - numB
					}
				}
			}
			if (result != 0)
			{
				return result
			}
			numA := NumGet(ptrA + BytesPerChar, 0, sType)
			numB := NumGet(ptrB + BytesPerChar, 0, sType)
			result := 0
			if (numA != numB)
			{
				If (!ignoreCase)
				{
					result := numA - numB
				}
				else If (MfMemStrView._IsLatin1(numA) && MfMemStrView._IsLatin1(numB))
				{
					if (MfMemStrView._IsEqualLatin1IgnoreCase(numA, numB) = False)
					{
						result := numA - numB
					}
				}
				else
				{
					char1 := Chr(num1)
					char2 := Chr(numB)
					if (!(char1 = char2))
					{
						result := numA - numB
					}
				}
			}
			return result
		}
	}
; 	End:CompareOrdinalSub ;}
;{ 	Diff
/*
	Method: Diff()
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
	Diff(objA, objB, maxOffset=5) {
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
			else If (MfMemStrView._IsLatin1(num1) && MfMemStrView._IsLatin1(num2))
			{
				if (MfMemStrView._IsEqualLatin1IgnoreCase(num1, num2))
				{
					lcs += 0.8
					ni += 1
					mi += 1
					continue
				}
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
				else If (num1 > 0 && MfMemStrView._IsLatin1(num1) && MfMemStrView._IsLatin1(num2))
				{
					if (MfMemStrView._IsEqualLatin1IgnoreCase(num1, num2))
					{
						ni := oi, lcs += 0.8
						break
					}
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
				else If (num2 > 0 && MfMemStrView._IsLatin1(num1) && MfMemStrView._IsLatin1(num2))
				{
					if (MfMemStrView._IsEqualLatin1IgnoreCase(num1, num2))
					{
						mi := pi, lcs += 0.8
						break
					}
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
		objMemBlk := new MfMemStrView((len + 1) * this.m_BytesPerChar, this.m_FillBytes, this.m_Encoding)
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
;{ 	Expand
/*
	Method: Expand()

	Expand()
		Expands the current buffer Adding new bytes
	Parameters:
		AddBytes
			The number of bytes to add the buffer
	Remarks:
		this[] will be a new addresss after expansion
*/
	Expand(AddBytes) {
		
		R := AddBytes + this.Size
		FB := this.m_FillBytes
		nv := 0
		size := this.Size
		sType := "UChar"
		VarSetCapacity(nV, R , FB)
		DllCall("RtlMoveMemory", sType, &nV, sType, this[], sType, Size)
		ObjSetCapacity(this, "_Buffer", 64)
		ObjSetCapacity(this, "_Buffer", 0)
		ObjSetCapacity(this, "_Buffer", R)
		this.__Ptr := ObjGetAddress(this, "_Buffer")
		DllCall("RtlFillMemory", "Ptr", this[], "UPtr", size, "UChar", FB)
		this.Size := this.GetCapacity("_Buffer")
		
		DllCall( "RtlMoveMemory", sType, this[], sType, &nV, sType, Size )
		VarSetCapacity(nV, 0)
		return this.Size
	}
; 	End:Expand ;}
;{ 	FromArray
/*
	Method: FromArray()

	FromArray()
		Creates new isntance of MfMemBlkView from AutoHotkey one based byte array
	Parameters:
		objArray
			The array containing the bytes
		encoding
			The encoding of the byte array.
			Default value is UTF-16
		startIndex
			The zero based index to start read bytes from with the array.
			Default value is zero
		length
			The lengt of byte to read from startIndex forward in the array.
			The default value is -1
			Values less then 0 will read all array bytes from startIndex forward
	Returns:
		Returns MfMemStrView instance
	Throws:
		Throws MfArgumentNullException, MfArgumentOutOfRangeException
*/
	FromArray(byref objArray, encoding="UTF-16", startIndex=0, length=-1) {
		if (MfNull.IsNull(objArray))
		{
			ex := new MfArgumentNullException("ojbArray")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (startIndex < 0)
		{
			ex := new MfArgumentOutOfRangeException("startIndex", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_IndexString"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (length = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "objArray"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		aLength := objArray.Length()
		if (!aLength)
		{
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Arg_ArrayTooSmall"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (length < 0)
		{
			length := (aLength - startIndex) + 1
		}
		if ((startIndex + length) - 1 > aLength)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_IndexLength"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		BytesPerChar := MfMemStrView.GetBytesPerChar(encoding)
		EvenOffset := 0
		if (BytesPerChar = 2)
		{
			; if Even number add on more for even number of bytes
			; even number is because we are zero based
			if (!(length & 1))
			{
				EvenOffset++
			}
		}
		mv := new MfMemStrView(length - 1 + BytesPerChar + EvenOffset, 0, encoding)
		addr := mv[]
		i := 1
		sType := "UChar"
		while (i <= length)
		{
			NumPut(objArray[i], addr + 0, i -1 , sType)
			mv.Pos++
			i++
		}
		if (i > 1)
		{
			mv.Pos--
		}
		if (EvenOffset)
		{
			NumPut(0, addr + 0, i - 1 , sType)
			mv.Pos++
			i++
		}
		; add last byte for null string end
		NumPut(0, addr + 0, i -1 , sType)
		mv.Pos++
		if (BytesPerChar = 2)
		{
			NumPut(0, addr + 0, i , sType)
			mv.Pos++

		}
		return mv
	}
; 	End:FromArray ;}
;{ 	FromByteList
/*
	Method: FromByteList()

	FromByteList()
		Converts MfByteList into MfMemStrView instance
	Parameters:
		bytes
			instance of MfByteList containing byte values to convert
		encoding
			The encoding type of the bytes such as UTF-16 or UTF-8
			Default value is UTF-16 which means each char is expected to be two bytes
		startIndex
			The starting index in the MfByteList to start the conversion
			Default value is 0
		length
			the length in bytes to convert.
			Default value is -1
			When length is less then 0 then all bytes past startIndex are included
		littleEndian
			Default value is true.
			If true then byte order is considered to be reversed and the bytes are written into
			memory from last byte to first after considering startIndex and length; Oterwise bytes
			are written from start to end.
	Returns:
		Returns instance of MfMemStrView
	Throws:
		Throws MfArgumentException, MfArgumentOutOfRangeException
	Remarks:
		Both startIndex and length operate the same no mater the state of littleEndian.
		Static Method
*/
	FromByteList(bytes, encoding="UTF-16", startIndex=0, length=-1, littleEndian=true) {
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
		if(!littleEndian)
		{
			return MfMemStrView.FromArray(bytes.m_InnerList, encoding, startIndex, length)
		}
		if (startIndex < 0)
		{
			ex := new MfArgumentOutOfRangeException("startIndex", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_IndexString"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (length = 0)
		{
			ex := new MfArgumentOutOfRangeException("length", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_IndexString"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		aLength := bytes.Count
		
		if (length < 0)
		{
			length := (aLength - startIndex) + 1
		}
		if ((startIndex + length) -1 > aLength)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_IndexLength"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		BytesPerChar := MfMemStrView.GetBytesPerChar(encoding)
		EvenOffset := 0
		if (BytesPerChar = 2)
		{
			; if Even number add on more for even number of bytes
			; even number is because we are zero based
			if (!(length & 1))
			{
				EvenOffset++
			}
		}
		mv := new MfMemStrView(length - 1 + BytesPerChar + EvenOffset, 0, encoding)
		addr := mv[]
		objArray := bytes.m_InnerList
		i := 1
		j := bytes.Count
		sType := "UChar"
		while (i <= length)
		{
			NumPut(objArray[j], addr + 0, i -1 , sType)
			mv.Pos++
			i++
			j--
		}
		if (i > 1 )
		{
			mv.Pos--
		}
		if (EvenOffset)
		{
			NumPut(0, addr + 0, i - 1 , sType)
			mv.Pos++
			i++
		}
		; add last byte for null string end
		NumPut(0, addr + 0, i - 1 , sType)
		mv.Pos++
		if (BytesPerChar = 2)
		{
			NumPut(0, addr + 0, i , sType)
			mv.Pos++
		}
		
		return mv
	}
; 	End:FromByteList ;}
;{ 	FromBase64
/*
	Method: FromBase64()

	FromBase64()
		Reads buffer and returns UTF-8 or UTF-16 buffer from base64
	Parameters:
		InData
			The buffer to convert from Base64, In Data is expected to be UTF-8
		offset
			The offset in bytes to start the conversion
		length
			The number of bytes to convert
	Returns:
		Returns a MfMemStrView UTF-8 encoded buffer containing basd64 value
	Throws:
		Throws MfArgumentException
	Remarks:
		Static method
*/
	FromBase64(ByRef InData, offset, length) {
		if (InData.__Class != "MfMemStrView")
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_NonMfObjectWithParamName", "InData", "MfMemStrView"), "InData")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}

		BytesPerChar := InData.m_BytesPerChar
		
		inputPtr := InData[] + offset
		inputLength := length
		while (inputLength > 0)
		{
			num := NumGet(inputPtr + 0, inputLength - 1, "UChar")
			if (num != 32 && num != 10 && num != 13 && num != 9)
			{
				break
			}
			inputLength--
		}
		ResultSize := MfMemStrView._FromBase64_ComputeResultLength(inputPtr, inputLength)
		if (ResultSize < 1)
		{
			return new MfMemStrView(1,,"UTF-8")
		}
		
		retval := new MfMemStrView(ResultSize + BytesPerChar,, "UTF-8")
		ptr := retval[]
				
		MfMemStrView._FromBase64_Decode(inputPtr, inputLength, ptr, ResultSize)
		retval.Pos := ResultSize + BytesPerChar
		return retval
	}
; 	End:FromBase64 ;}
;{ 	_FromBase64_ComputeResultLength
	; computes the length of decoded base64
	_FromBase64_ComputeResultLength(inputPtr, inputLength) {
		sType := "UChar"
		ptr := inputPtr + inputLength
		num := inputLength
		num2 := 0
		while (inputPtr < ptr)
		{
			num3 := NumGet(inputPtr + 0, 0, sType)
			inputPtr++
			if (num3 <= 32)
			{
				num--
			}
			else if (num3 = 61)
			{
				num--
				num2++
			}
		}
		if (num2 != 0)
		{
			if (num2 = 1)
			{
				num2 := 2
			}
			else
			{
				if (num2 != 2)
				{
					ex := new MfFormatException(MfEnvironment.Instance.GetResourceString("Format_BadBase64Char"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				num2 := 1
			}
		}
		return num // 4 * 3 + num2
	}
; 	End:_FromBase64_ComputeResultLength ;}
;{ 	_FromBase64_Decode
/*
	Method: _FromBase64_Decode()

	_FromBase64_Decode()
		_FromBase64_Decode description
	Parameters:
		startInputPtr
			The memory address of the base64 input
		inputLength
			The length in bytes of the base64 input
		startDestPtr
			The memory address of the buffer to hold the decoded base64 bytes
		destLength
			The length of the decoded base64 input
	Returns:
		Returns integer
	Throws:
		Throws MfFormatException if non-base64 char is found while decoding or bad char length
	Remarks:
		If _FromBase64_Decode
		Static method
*/
	_FromBase64_Decode(startInputPtr, inputLength, startDestPtr, destLength) {
		sType := "UChar"
		sInType := "UChar"
		ptr := startInputPtr
		ptr2 := startDestPtr
		ptr3 := ptr + inputLength
		ptr4 := ptr2 + destLength
		num := 255
		;strDebug := ""
		while (ptr < ptr3)
		{
			num2 := NumGet(ptr + 0, 0, sInType)
			;OutputDebug % "_FromBase64_Decode: num2 :" . num2
			
			ptr++
			if (num2 >= 65 && num2 - 65 <= 25)
			{
				num2 -= 65
			}
			else if (num2 >= 97 && num2 - 97 <= 25)
			{
				num2 -= 71
			}
			else
			{
				;OutputDebug % "_FromBase64_Decode: Else: num2 :" . num2
				if ((num2 >= 48 && num2 - 48 > 9) || (num2 - 48 < 0))
				{
					if (num2 <= 32)
					{
						if (num2 = 9 || num2 = 10 || num2 = 13 || num2 = 32)
						{
							Continue
						}
						break
					}
					else
					{
						if (num2 = 43)
						{
							num2 := 62
							if (MfMemStrView._FromBase64_DecodeHelper(num, num2, ptr2, ptr4))
							{
								;OutputDebug % strDebug
								return -1
							}
							continue
						}
						else if (num2 = 47)
						{
							num2 := 63
							if (MfMemStrView._FromBase64_DecodeHelper(num, num2, ptr2, ptr4))
							{
								;OutputDebug % strDebug
								return -1
							}
							continue
						}
						else if (num2 = 61)
						{
							if (ptr = ptr3)
							{
								num <<= 6
								if ((num & 2147483648) = 0)
								{
									ex := new MfFormatException(MfEnvironment.Instance.GetResourceString("Format_BadBase64CharArrayLength"))
									ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
									throw ex
								}
								if ((ptr4 - ptr2) < 2)
								{
									return -1
								}
								NumPut(num >> 16, ptr2 + 0, 0, sType)
								ptr2++
								NumPut(num >> 8, ptr2 + 0, 0, sType)
								ptr2++
								num := 255
								break
							}
							else
							{
								while (ptr < ptr3 - 1)
								{
									num3 := NumGet(ptr + 0, 0, sInType)
									if (num3 != 32 && num3 != 10 && num3 != 13 && num3 != 9)
									{
										break
									}
									ptr++
								}
								; 61 is char '='
								if (ptr != ptr3 - 1 || NumGet(ptr + 0, 0, sInType) != 61)
								{
									ex := new MfFormatException(MfEnvironment.Instance.GetResourceString("Format_BadBase64Char"))
									ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
									throw ex
								}
								num <<= 12
								if ((num & 2147483648) = 0)
								{
									ex := new MfFormatException(MfEnvironment.Instance.GetResourceString("Format_BadBase64CharArrayLength"))
									ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
									throw ex
								}
								if ((ptr4 - ptr2) < 1)
								{
									return -1
								}
								NumPut(num >> 16, ptr2 + 0, 0, sType)
								ptr2++
								num := 255
								break
							}
						}
					}
					ex := new MfFormatException(MfEnvironment.Instance.GetResourceString("Format_BadBase64Char"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				num2 -= 4294967292
			}
			if (MfMemStrView._FromBase64_DecodeHelper(num, num2, ptr2, ptr4))
			{
				;OutputDebug % strDebug
				return -1
			}
		}
		;OutputDebug % strDebug
		return ptr2 - startDestPtr
	}
; 	End:_FromBase64_Decode ;}
;{ 	_FromBase64_DecodeHelper
	; helper method for _FromBase64_Decode
	_FromBase64_DecodeHelper(ByRef num, ByRef num2, ByRef ptr2, ptr4) {
		sType :="UChar"
		num := (num << 6 | num2)
		if ((num & 2147483648) != 0)
		{
			if ((ptr4 - ptr2) < 3)
			{
				return true
			}
			
			NumPut(num >> 16, ptr2 + 0, 0, sType)
			NumPut(num >> 8, ptr2 + 0, 1, sType)
			NumPut(num, ptr2 + 0, 2, sType)
			ptr2 += 3
			num = 255
		}
		return false
	}
; 	End:_FromBase64_DecodeHelper ;}
;{ 	FromVarAddress
/*
	Method: FromVarAddress()

	FromVarAddress()
		Creates an new instance of MfMemStrView from var or address
	Parameters:
		VarOrAddr
			The memory address of var pointing to memory or instance of MfMemStrView or instance of MfMemBlkView
		offset
			The memory zero based offset in bytes.
			Default is 0
		length
			The length in bytes
			Default value is "" which will include all the bytes from offset
	Returns:
		Returns MfMemStrView instance
	Throws:
		Throws MfException if
	Remarks:
		If VarOrAddr is MfMemStrView instance both offset and length are still considered. Alos encoding is
		considered to be that smae as VarOrAddr MfMemStrView instance.
		If VarOrAddr is NOT MfMemStrView instance then encoding will be UTF-16 if A_IsUnicode; Otherwise UTF-8
*/
	FromVarAddress(byRef VarOrAddr, offset:=0, length:="") {
		enc := A_IsUnicode ? "UTF-16":"UTF-8"
		FB := 0
		if (IsObject(VarOrAddr) && (VarOrAddr.__Class = "MfMemBlkView" || VarOrAddr.__Class = "MfMemStrView"))
		{
			if (VarOrAddr.__Class = "MfMemStrView")
			{
				if (offset=0 && (length == "" || length = -1))
				{
					return VarOrAddr.Clone()
				}
				if (length == "")
				{
					length := -1
				}
				return VarOrAddr.SubSet(offset, length)
				
			}
			
			objMemBlk := new MfMemStrView(VarOrAddr.Size, FB, enc)
			newAddress := objMemBlk[]
			Address := VarOrAddr[]
			Length := VarOrAddr.Pos
			DllCall("RtlMoveMemory", UInt, newAddress + 0, UInt, Address + 0, UInt, Length)
			objMemBlk.Size := ObjGetCapacity(objMemBlk, "_Buffer")
			objMemBlk.Pos := VarOrAddr.Pos
			return objMemBlk
		}

			bk := new MfMemBlkView(VarOrAddr, offset, length)
			objMemBlk := new MfMemStrView(bk.Size, FB, enc)
			newAddress := objMemBlk[]
			Address := bk[]
			Length := bk.Pos
			DllCall("RtlMoveMemory", UInt, newAddress + 0, UInt, Address + 0, UInt, Length)
			objMemBlk.Size := ObjGetCapacity(objMemBlk, "_Buffer")
			objMemBlk.Pos := bk.Pos
			return objMemBlk
	}
; 	End:FromVarAddress ;}
;{ 	GetBytesPerChar
	GetBytesPerChar(encoding) {
		return (encoding = "UTF-16" || encoding = "CP1200") ? 2 : 1
	}
; 	End:GetBytesPerChar ;}

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
;{ 	InBuffer
/*
	Method: InBuffer()

	InBuffer()
		Searches current instance for the first instance of NeedleObj from StartOffset
	Parameters:
		NeedleObj
			Instanece of MfMemStrView that represents needle in bytes to search for
		StartOffset
			The zero based index offset in bytes to start the search from
	Returns:
		Returns -1 if SearchString is not found; Otherwise zero based index of found position 
	Remarks:
		Wraper method for InBuf
		This method is super fast due to the machine code that performs the search
*/
	InBuffer(ByRef NeedleObj, StartOffset=0) {
		if (NeedleObj.__Class != "MfMemStrView")
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_NonMfObjectWithParamName", "ObjA", "MfMemStrView"), "ObjA")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (!(this.m_Encoding = NeedleObj.m_Encoding))
		{
			ex := new MfFormatException(MfEnvironment.Instance.GetResourceString("Format_Encoding_MisMatch"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
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
; 	End:InBuffer ;}
;{ 	InBufferRev
;{ 	InBufferRev
/*
	Method: InBufferRev()

	InBufferRev()
		Searches current instance for the last instance of NeedleObj from EndOffset
	Parameters:
		NeedleObj
			Instanece of MfMemStrView that represents needle in bytes to search for
		EndOffset
			The zero based maximum hayStack offset to contain Needle's bytes, The is the conut from the 
			right to left of the string to look for the needle in.
			Default value is -1
			If value is -1 then reverse search is started from the first byte
	Returns:
		Returns -1 if SearchString is not found; Otherwise zero based index of found position 
	Remarks:
		Wraper method for InBufRev
		This method is super fast due to the machine code that performs the search
*/
	InBufferRev(ByRef NeedleObj, EndOffset=-1) {
		if (NeedleObj.__Class != "MfMemStrView")
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_NonMfObjectWithParamName", "ObjA", "MfMemStrView"), "ObjA")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (!(this.m_Encoding = NeedleObj.m_Encoding))
		{
			ex := new MfFormatException(MfEnvironment.Instance.GetResourceString("Format_Encoding_MisMatch"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (NeedleObj.Pos = 0)
		{
			return -1
		}
		BytesPerChar := this.m_BytesPerChar
		haystackAddr := this[]
		
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
		haystackSize := this.Pos - BytesPerChar
		result := MfMemStrView.InBufRev(haystackAddr, needleAddr, haystackSize, needleSize, EndOffset)
		if (result > 0)
		{
			result := result // BytesPerChar
		}
		return result
	}
; 	End:InBufferRev ;}
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
			maximum hayStack offset to contain Needle's bytes (-1=whole haystackSize)
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
;{ 	IndexOf
/*
	Method: IndexOf()

	IndexOf()
		Gets the First index of NeedleObj in current instance
	Parameters:
		NeedleObj
			Instance of MfMemStrView that represents the needle byte(s) to search for
		StartIndex
			The index to start the searh for needleObj. Search is preformed from
			StartIndex to the start of the string bytes
			Default value is -1 which search from end of current instance
		Count
			The number of chars to examine from StartIndex location
		IgnoreCase
			If True Case will not be considered; Otherwise case will be considered.
			Default value is true
	Returns:
		Returns the zero based index of NeedleObj if found within current instance; Othwrwise -1
	Throws:
		Throws MfArgumentException
	Remarks:
		Return index is the index with the char count and may not be the same as the byte position
*/
	IndexOf(ByRef NeedleObj, StartIndex=0, Count=-1, IgnoreCase=false) {
		if (NeedleObj.__Class != "MfMemStrView")
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_NonMfObjectWithParamName", "obj", "MfMemStrView"), "obj")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (Count = 0)
		{
			return -1
		}
		BytesPerChar := this.m_BytesPerChar
		
		if ((StartIndex + 1) * BytesPerChar >= this.Pos - BytesPerChar) ; adjust for zero based index
		{
			Return -1
		}
		maxIndex := (this.Pos - (BytesPerChar * 2)) // BytesPerChar ; adjust for zero base index
		if (Count > maxIndex + 1)
		{
			return -1
		}
		if (Count < 0)
		{
			count := maxIndex + 1
		}
		needleSize := (NeedleObj.Pos - BytesPerChar) // BytesPerChar
		if (needleSize > maxIndex)
		{
			return -1
		}

		sType := BytesPerChar = 1? "UChar":"UShort"
		ptr := this[]
		ptrNeedle := NeedleObj[]
		NeedleFirstNum := NumGet(ptrNeedle + 0, 0, sType)
		if (NeedleFirstNum = 0)
		{
			return -1
		}
		NeedleFirtChar := Chr(NeedleFirstNum)
		
		i := StartIndex
		MatchCount := 0
		iCount = 0
		while ( i < maxIndex)
		{
			iCount++
			if (iCount > Count)
			{
				return -1
			}
			Num1 := NumGet(ptr + 0, i * BytesPerChar, sType)
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
							i++
							Continue
						}
					}
					Else
					{
						Char1 := Chr(Num1)
						if (Char1 = NeedleFirtChar)
						{
							MatchCount++
							if (MatchCount = needleSize)
							{
								break
							}
							i++
							continue
						}
					}
				}
				MatchCount := 0
				i++
				continue
			}
			; matchcount is greater then 0
			Num2 := NumGet(ptrNeedle + 0, MatchCount * BytesPerChar, sType)
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
		if (MatchCount > 0)
		{
			return ++i - MatchCount
		}
		Return -1
	}
; 	End:IndexOf ;}
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
	Method: InsertStr()
		
	InsertStr()
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
;{ 	LastIndexOf
/*
	Method: LastIndexOf()

	LastIndexOf()
		Gets the last index of NeedleObj in current instance
	Parameters:
		NeedleObj
			Instance of MfMemStrView that represents the needle byte(s) to search for
		EndIndex
			The index to start the searh for needleObj. Search is preformed from
			EndIndex to the start of the string bytes
			Default value is -1 which search from end of current instance
		Count
			The number of chars to examine from EndIndex location
		IgnoreCase
			If True Case will not be considered; Otherwise case will be considered.
			Default value is true
	Returns:
		Returns the zero based index of NeedleObj if found within current instance; Othwrwise -1
	Throws:
		Throws MfArgumentException
	Remarks:
		Return index is the index with the char count and may not be the same as the byte position
*/
	LastIndexOf(ByRef NeedleObj, EndIndex=-1, Count=-1, IgnoreCase=true) {
		if (NeedleObj.__Class != "MfMemStrView")
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_NonMfObjectWithParamName", "obj", "MfMemStrView"), "obj")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (Count = 0)
		{
			return -1
		}
		BytesPerChar := this.m_BytesPerChar
		if (EndIndex < 0)
		{
			EndIndex := this.Pos - (BytesPerChar * 2) ; adjust for zero base index
		}
		Else
		{
			EndIndex := EndIndex * BytesPerChar
		}
		if (EndIndex > (this.Pos - (BytesPerChar * 2))) ; adjust for zero base index
		{
			Return -1
		}

		maxIndex := EndIndex // BytesPerChar
		if (Count > maxIndex + 1)
		{
			return -1
		}
		needleSize := (NeedleObj.Pos - BytesPerChar) // BytesPerChar
		if (needleSize > maxIndex)
		{
			return -1
		}
		if (Count < 0)
		{
			count := maxIndex + 1
		}

		sType := BytesPerChar = 1? "UChar":"UShort"
		ptr := this[]
		ptrNeedle := NeedleObj[]
		NeedleLastPos := NeedleObj.Pos - BytesPerChar
		NeedleLastNum := NumGet(ptrNeedle + 0, NeedleLastPos - BytesPerChar, sType)
		if (NeedleLastNum = 0)
		{
			return -1
		}
		NeedleLastChar := Chr(NeedleLastNum)
		
		i := maxIndex
		minIndex := 0
		MatchCount := 0
		iCount = 0
		while ( i > minIndex)
		{
			iCount++
			if (iCount > Count)
			{
				return -1
			}
			Num1 := NumGet(ptr + 0, i * BytesPerChar, sType)
			if (MatchCount = 0)
			{
				if (Num1 = NeedleLastNum)
				{
					MatchCount++
					if (MatchCount = needleSize)
					{
						break
					}
					i--
					continue
				}
				if (!IgnoreCase)
				{
					If (MfMemStrView._IsLatin1(Num1) && MfMemStrView._IsLatin1(NeedleLastNum))
					{
						if (MfMemStrView._IsEqualLatin1IgnoreCase(Num1, NeedleLastNum))
						{
							MatchCount++
							if (MatchCount = needleSize)
							{
								break
							}
							i--
							Continue
						}
					}
					Else
					{
						Char1 := Chr(Num1)
						if (Char1 = NeedleLastChar)
						{
							MatchCount++
							if (MatchCount = needleSize)
							{
								break
							}
							i--
							continue
						}
					}
				}
				MatchCount := 0
				i--
				continue
			}
			; matchcount is greater then 0
			Num2 := NumGet(ptrNeedle + 0, ((needleSize - 1) - MatchCount) * BytesPerChar, sType)
			if (Num1 = Num2)
			{
				MatchCount++
				if (MatchCount = needleSize)
				{
					break
				}
				i--
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
						i--
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
						i--
						Continue
					}
				}
			}
			MatchCount := 0
			i--
		}
		if (MatchCount > 0)
		{
			return i
		}
		Return -1
	}
; 	End:LastIndexOf ;}
;{ 	MoveBytesLeft
/*
	Method: MoveBytesLeft()

	MoveBytesLeft()
		Moves bytes to the left in the current instance.
	Parameters:
		startPos
			the Position to start moving left
		Length
			The number of position to move left
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
		rev := new MfMemStrView(LimitBytes?this.Pos + this.m_BytesPerChar: this.Size, this.m_FillBytes, this.m_Encoding)
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

;{ 	ToBase64
/*
	Method: ToBase64()

	ToBase64()
		Reads instanceof MfMemStrView and returns a new MfMemStrView as base64 equal UTF-8 Encoded
	Parameters:
		data
			The MfMemStrView instance to create base64 from
		offset
			Offset in bytes to start the encoding
		addLineBreaks
			If true then line breaks will be inserted into output every 76 chars
	Returns:
		Returns new instance of MfMemStrView with base64 encoded byte values
	Throws:
		Throws MfArgumentException
	Remarks:
		Translated from http://stackoverflow.com/questions/12178495/an-efficient-way-to-base64-encode-a-byte-array
		Static method
*/
	ToBase64(ByRef data, offset, size, addLineBreaks=false) {
		if (data.__Class != "MfMemStrView")
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_NonMfObjectWithParamName", "data", "MfMemStrView"), "data")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}

		strEnc := "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
		base64EncodingTable := new MfMemStrView(StrPut(strEnc,"UTF-8"),,"UTF-8")
		base64EncodingTable.AppendString(strEnc)

		dataBPC := data.m_BytesPerChar
		requiredSize := (4 * ((size + 2) / 3))
		if (addLineBreaks)
		{
			requiredSize += requiredSize + (requiredSize / 38)
		}
		requiredSize := requiredSize * dataBPC
		

		buffer := new MfMemStrView(ceil(requiredSize),,"UTF-8") ; base64 out only makes sense to output as utf-8
		offset := offset * dataBPC
		size := size * dataBPC
		octet_a := ""
		octet_b = ""
		octet_c = ""
		triple = ""
		lineCount := 0
		sizeMod := size - mod(size , 3)
		ptr := data[]
		ptrBuff := buffer[]
		ptr64 := base64EncodingTable[]
		mBufferPos := 0
		while (offset < sizeMod)
		{
			octet_a := NumGet(ptr + 0, Offset++, "UChar")
			octet_b := NumGet(ptr + 0, Offset++, "UChar")
			octet_c := NumGet(ptr + 0, Offset++, "UChar")

			triple := (octet_a << 0x10) + (octet_b << 0x08) + octet_c

			numb64 := NumGet(ptr64 + 0, (triple >> 3 * 6) & 0x3F, "UChar")
			NumPut(numb64, ptrBuff + 0 , mBufferPos++, "UChar")

			numb64 := NumGet(ptr64 + 0, (triple >> 2 * 6) & 0x3F, "UChar")
			NumPut(numb64, ptrBuff + 0 , mBufferPos++, "UChar")

			numb64 := NumGet(ptr64 + 0, (triple >> 1 * 6) & 0x3F, "UChar")
			NumPut(numb64, ptrBuff + 0 , mBufferPos++, "UChar")

			numb64 := NumGet(ptr64 + 0, (triple >> 0 * 6) & 0x3F, "UChar")
			NumPut(numb64, ptrBuff + 0 , mBufferPos++, "UChar")

			 if (addLineBreaks)
			 {
			 	if (++lineCount = 19)
			 	{
			 		NumPut(13, ptrBuff + 0 , mBufferPos++, "UChar")
			 		
			 		NumPut(10, ptrBuff + 0 , mBufferPos++, "UChar")
			 		lineCount := 0
			 	}
			 }
        }
        ; last bytes
		if (sizeMod < size)
    	 {
    	 	octet_a := offset < size ? NumGet(ptr + 0, Offset++, "UChar") : 0
    	 	octet_b := offset < size ? NumGet(ptr + 0, Offset++, "UChar") : 0
    	 	octet_c := 0 ; last character is definitely padded

    	 	triple := (octet_a << 0x10) + (octet_b << 0x08) + octet_c

			numb64 := NumGet(ptr64 + 0, (triple >> 3 * 6) & 0x3F,"UChar")
			NumPut(numb64, ptrBuff + 0 , mBufferPos++, "UChar")

			numb64 := NumGet(ptr64 + 0, (triple >> 2 * 6) & 0x3F,"UChar")
			NumPut(numb64, ptrBuff + 0 , mBufferPos++, "UChar")

			numb64 := NumGet(ptr64 + 0, (triple >> 1 * 6) & 0x3F,"UChar")
			NumPut(numb64, ptrBuff + 0 , mBufferPos++, "UChar")

			numb64 := NumGet(ptr64 + 0, (triple >> 0 * 6) & 0x3F,"UChar")
			NumPut(numb64, ptrBuff + 0 , mBufferPos++, "UChar")

			; add padding '='
			sizeMod := Mod(size , 3)
			; last character is definitely padded
			; for some unknow reason it is needed to set the byte postition at - 2 before -1
			; the last postiion set seems to somehow stop the output from reading anyafter the 
			; last NumPut position
			if (sizeMod = 1)
			{
				NumPut(61, ptrBuff + 0 , mBufferPos - 2, "UChar")

			}
			NumPut(61, ptrBuff + 0 , mBufferPos - 1, "UChar") ; put = sign byte
		}
		buffer.Pos := mBufferPos + buffer.m_BytesPerChar
		return buffer
	}
; 	End:ToBase64 ;}
;{ 	ToString
/*
	Method: ToString()

	ToString()
		Gets the value of this instance as string var
	Returns:
		Returns string var
*/
	ToString() {
		;PI := this.Pos
		methodName := "Read" . this.m_EncodingName
		len := (this.Pos - this.m_BytesPerChar)
		;this.Seek(0, 0)
		ptr := this[]
		retval := StrGet(ptr, len, this.m_Encoding)
		;retval := this.__Call(methodName, len)
		;this.Pos := PI
		return retval
	}
; 	End:ToString ;}

;{ 	TrimBufferToPos
/*
	Method: TrimBufferToPos()

	TrimBufferToPos()
		Trims the current size to the current Pos
	Parameters:
		Param1
	Returns:
		The current CharCount after trim 
	Remarks:
		This[] address will be changed
*/
	TrimBufferToPos() {
		FB := this.m_FillBytes
		size := this.Pos
		nv := 0
		sType := "UChar"
		VarSetCapacity(nV, size , FB)
		DllCall("RtlMoveMemory", sType, &nV, sType, this[], sType, size)
		ObjSetCapacity(this, "_Buffer", 64)
		ObjSetCapacity(this, "_Buffer", 0)
		ObjSetCapacity(this, "_Buffer", size)
		this.__Ptr := ObjGetAddress(this, "_Buffer")
		DllCall("RtlFillMemory", "Ptr", this[], "UPtr", size, "UChar", FB)
		this.Size := this.GetCapacity("_Buffer")
		DllCall("RtlMoveMemory", sType, this[], sType, &nV, sType, size)
		VarSetCapacity(nV, 0)
		return this.GetCharCount()
	}
; 	End:TrimBufferToPos ;}
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
			this.__Call(methodPut,this.m_FillBytes)
		}
		this.Seek(NewPos)
		
	}
; 	End:TrimMemoryRight ;}
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
		BytesPerChar := MfMemStrView.GetBytesPerChar(encoding)
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
					If (MfMemStrView._IsLatin1(num1) && MfMemStrView._IsLatin1(num2))
					{
						if (MfMemStrView._IsEqualLatin1IgnoreCase(num1, num2))
						{
							i += BytesPerChar
							continue
						}
					}
					else
					{
						char1 := Chr(num1)
						char2 := Chr(num2)
						; compare as case in-sensitive
						if (char1 = Char2)
						{
							i += BytesPerChar
							continue
						}
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
;{ 	SubSet
/*
	Method: SubSet()

	SubSet()
		Gets a sub set (sub string) of the currrent instance chars
	Parameters:
		StartIndex
			The start index in chars
		Length
			The length of the subset in chars
	Returns:
		Returns new instance of MfMemStrView
	Throws:
		Throws MfArgumentOutOfRangeException if startIndex or Length is out or range
		Throws MfArgumentException
*/
	SubSet(StartIndex, Length=-1) {
		if (StartIndex < 0)
		{
			ex := new MfArgumentOutOfRangeException("StartIndex", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_IndexString"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (StartIndex > 0)
		{
			StartIndex := StartIndex * this.m_BytesPerChar
		}
		if (Length < 0)
		{
			Length := ((this.Pos - this.m_BytesPerChar) - StartIndex)
		}
		else
		{
			Length := Length * this.m_BytesPerChar
		}
		if (Length <= 0)
		{
			ex := new MfArgumentOutOfRangeException("Length", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_IndexString"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if ((Length < 0) || (StartIndex + Length) > (this.Pos - this.m_BytesPerChar))
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_IndexLength"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		PI := this.Pos
		try
		{
			this.seek(StartIndex)
			;size := (Length - StartIndex) + (this.m_BytesPerChar * 2)

			objMemBlk := new MfMemStrView(Length + this.m_BytesPerChar, this.m_FillBytes, this.m_Encoding)
			newAddress := objMemBlk[]
			Address := this[] + this.Pos
			DllCall("RtlMoveMemory", UInt, newAddress + 0, UInt, Address + 0, Uint, Length)
			objMemBlk.Size := ObjGetCapacity(objMemBlk, "_Buffer")
			objMemBlk.Pos := Length + this.m_BytesPerChar
			return objMemBlk
		}
		catch e
		{
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		finally
		{
			this.Pos := PI
		}
	}
; 	End:SubSet ;}

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

;{ 	_IsEqualLatin1IgnoreCase
	; static method
	; Checkes if char1 and Char2 are equal when case is ignored
	; applies only to Lattin1 chars
	_IsEqualLatin1IgnoreCase(char1, char2) {
		If (Char1 = Char2)
		{
			return true
		}
		if (MfMemStrView._IsAsciiLetter(Char1) && MfMemStrView._IsAsciiLetter(Char2))
		{
			up1 := MfMemStrView._AsciiToUpper(Char1)
			up2 := MfMemStrView._AsciiToUpper(Char2)
			return up1 = up2
		}
		Return false
	}
; 	End:_IsEqualLatin1IgnoreCase ;}
;{ 	_AsciiToUpper
	; statice method
	; Converts ascii lower case char to upper case char
	_AsciiToUpper(cc) {
		if (MfMemStrView._IsAsciiLower(cc))
		{
			return cc - 32
		}
		return cc
	}
; 	End:_AsciiToUpper ;}
;{ 	_AsciiToLower
	; statice method
	; Converts ascii Upper case char to lower case char
	_AsciiToLower(cc) {
		if (MfMemStrView._IsAsciiUpper(cc))
		{
			return cc + 32
		}
		return cc
	}
; 	End:_AsciiToLower ;}
;{ 	_IsAsciiLetter
	; static method
	; check if cc is a ascii letter
	_IsAsciiLetter(cc) {
		IsUpper := MfMemStrView._IsAsciiUpper(cc)
		If (IsUpper)
		{
			return true
		}
		IsLower := MfMemStrView._IsAsciiLower(cc)
		return IsLower
	}
; 	End:_IsAsciiLetter ;}
;{ 	_IsAsciiLower
	; static metohd
	; check to see if cc is a valid ascii lowercase char
	_IsAsciiLower(cc) {
		return ((cc >= 97) && (cc <= 122))
	}
; 	End:_IsAsciiLower ;}
;{ 	_IsAsciiUpper
	; static metohd
	; check to see if cc is a valid ascii uppercase char
	_IsAsciiUpper(cc) {
		return ((cc >= 65) && (cc <= 90))
	}
; 	End:_IsAsciiUpper ;}
;{ 	_IsAscII
	; Static method
	; checks to see if cc is a valid ascii char
	_IsAscII(cc) {
		return cc >=0 && c <= 127
	}
; 	End:_IsAscII ;}
;{ 	_IsLatin1
	; static method
	; checks to see if cc is a valid Latin1 char
	_IsLatin1(cc) {
		return cc >=0 && c <= 255
	}
; 	End:_IsLatin1 ;}
;{ 	_IsSeparatorLatin1
	; static method
	; checks ot see if cc is a Latin1 separator char
	_IsSeparatorLatin1(cc) {
		return ((cc = 32 ) || (cc = 160))
	}
; 	End:_IsSeparatorLatin1 ;}
;{ 	_IsDigitLatin1
	; static method
	; checks ot see if cc is a valid Latin1 digit
	_IsDigitLatin1(cc) {
		retur ((cc >= 48 ) && (cc <= 57))
	}
; 	End:_IsDigitLatin1 ;}

;{ 	__Delete
	; clean up when instance is destroyed
	__Delete() {
		ObjSetCapacity(this, "_Buffer", 0)
	}
; 	End:__Delete ;}	
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
			if (!IsByRef(VarOrAddr))
			{
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Address", "length"),"length")
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			length := VarSetCapacity(VarOrAddr)
		}
		if (IsByRef(VarOrAddr) && ((offset + length) > VarSetCapacity(VarOrAddr)))
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Buffer_Overflow"),"length")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}

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
			if (sizeof[ LTrim(num, "Uu") ])
			{
				mName := "Put" . num . "()"
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", mName), mName)
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
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
;{ 	FromArray
/*
	Method: FromArray()

	FromArray()
		Creates new isntance of MfMemBlkView from AutoHotkey one based byte array
	Parameters:
		objArray
			The array containing the bytes
		startIndex
			The zero based index to start read bytes from with the array.
			Default value is zero
		length
			The lengt of byte to read from startIndex forward in the array.
			The default value is -1
			Values less then 0 will read all array bytes from startIndex forward
	Returns:
		Returns MfMemBlkView instance
	Throws:
		Throws MfArgumentNullException, MfArgumentOutOfRangeException
	Remarks:
		If FromArray
*/
	FromArray(byref objArray, startIndex=0, length=-1, sType="UChar") {
		if (MfNull.IsNull(objArray))
		{
			ex := new MfArgumentNullException("ojbArray")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (startIndex < 0)
		{
			ex := new MfArgumentOutOfRangeException("startIndex", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_IndexString"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (length = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "objArray"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		aLength := objArray.Length()
		if (!aLength)
		{
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Arg_ArrayTooSmall"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (length < 0)
		{
			length := (aLength - startIndex) + 1
		}
		if ((startIndex + length) - 1 > aLength)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_IndexLength"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		; UInt, Int, Int64, Short, UShort, Char, UChar, Double, Float, Ptr or UPtr
		step := 0
		if (sType = "char" || stype = "uchar")
		{
			step := 1
		}
		else if (sType = "short" || stype = "ushort")
		{
			step := 2
		}
		else if (sType = "float" || stype = "int" || stype = "uint")
		{
			step := 4
		}
		else if (sType = "int64" || stype = "uint64" || stype = "Double")
		{
			step := 8
			if (sType = "UInt64")
			{
				sType := "Int64"
			}
		}
		else if (sType = "ptr" || stype = "uptr")
		{
			step := A_PtrSize
		}
		else
		{
			sType := "UChar"
			step := 1
		}

		buff := 0
		mv := new MfMemBlkView(&buff, 0, length)
		addr := mv[]
		i := 1
		j := 0
		while (i <= length)
		{
			NumPut(objArray[i], addr + 0, j , sType)
			mv.Pos += step
			j += step
			i++
		}
		if (i > 1)
		{
			mv.Pos -= step
		}
		return mv
	}
; 	End:FromArray ;}
;{ 	FromByteList
/*
	Method: FromByteList()

	FromByteList()
		Converts MfByteList into MfMemStrView instance
	Parameters:
		bytes
			instance of MfByteList containing byte values to convert
		startIndex
			The starting index in the MfByteList to start the conversion
			Default value is 0
		length
			the length in bytes to convert.
			Default value is -1
			When length is less then 0 then all bytes past startIndex are included
		littleEndian
			Default value is true.
			If true then byte order is considered to be reversed and the bytes are written into
			memory from last byte to first after considering startIndex and length; Oterwise bytes
			are written from start to end.
	Returns:
		Returns instance of MfMemBlkView
	Throws:
		Throws MfArgumentException, MfArgumentOutOfRangeException
	Remarks:
		Both startIndex and length operate the same no mater the state of littleEndian.
		Static Method
*/
	FromByteList(bytes, startIndex=0, length=-1, littleEndian=true) {
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
		if(!littleEndian)
		{
			return MfMemBlkView.FromArray(bytes.m_InnerList, startIndex, length, "UChar")
		}
		if (startIndex < 0)
		{
			ex := new MfArgumentOutOfRangeException("startIndex", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_IndexString"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (length = 0)
		{
			ex := new MfArgumentOutOfRangeException("length", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_IndexString"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		aLength := bytes.Count
		
		if (length < 0)
		{
			length := (aLength - startIndex) + 1
		}
		if ((startIndex + length) -1 > aLength)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_IndexLength"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		buff := 0
		mv := new MfMemBlkView(&buff, 0, length)
		addr := mv[]

		objArray := bytes.m_InnerList
		i := 1
		j := bytes.Count
		sType := "UChar"
		while (i <= length)
		{
			NumPut(objArray[j], addr + 0, i -1 , sType)
			mv.Pos++
			i++
			j--
		}
		if (i > 1 )
		{
			mv.Pos--
		}
		return mv
	}
; 	End:FromByteList ;}
;{ 	ToArray
/*
	Method: ToArray()

	ToArray()
		Creates an array of bytes from current instance of MfMemStrView
	Parameters:
		startIndex
			The zero based index to start reading current instance bytes
		length
			The length in bytes to read from memory
			Default value is -1
			When value is -1 bytes are read from startIndex to current instanec pos
	Returns:
		Returns a one based AutoHotkey array
*/
	ToArray(startIndex=0, length=-1, sType="UChar") {
		if ((StartIndex < 0) || (StartIndex >= this.pos))
		{
			return []
		}
		if (Length = 0)
		{
			return []
		}
		if (Length < 0)
		{
			length := this.Pos - startIndex
		}
		if (Length + startIndex > this.Pos)
		{
			return []
		}
		; UInt, Int, Int64, Short, UShort, Char, UChar, Double, Float, Ptr or UPtr
		step := 0
		if (sType = "char" || stype = "uchar")
		{
			step := 1
		}
		else if (sType = "short" || stype = "ushort")
		{
			step := 2
		}
		else if (sType = "float" || stype = "int" || stype = "uint")
		{
			step := 4
		}
		else if (sType = "int64" || stype = "uint64" || stype = "double")
		{
			step := 8
			if (sType = "UInt64")
			{
				sType := "Int64"
			}
		}
		else if (sType = "ptr" || stype = "uptr")
		{
			step := A_PtrSize
		}
		else
		{
			sType := "UChar"
			step := 1
		}

		ptr := this[]
		a := []
		maxIndex := length - 1
		i := startIndex 
		j := 1

		While (i <= maxIndex)
		{
			a[j] := NumGet(ptr + 0, i, sType)
			i += step
			j++
		}
		return a
	}
; 	End:ToArray ;}
;{ 	ToByteList
/*
	Method: ToByteList()

	ToByteList()
		Creates an MfByteList of bytes from current instance of MfMemStrView
	Parameters:
		startIndex
			The zero based index to start reading current instance bytes
		length
			The length in bytes to read from memory
			Default value is -1
			When value is -1 bytes are read from startIndex to current instance pos
		littleEndian
			Default is true, If True byte order is in Little Endian;
			Otherwise byte order is in Big Endian ( same as ToArray )
	Returns:
		Returns a zero based MfByteList
*/
	ToByteList(startIndex=0, length=-1, littleEndian=true) {
		lst := new MfByteList()
		if (!littleEndian)
		{
			a := this.ToArray(startIndex,length)
			lst._SetInnerList(a, true)
			return lst
		}
		if ((StartIndex < 0) || (StartIndex >= this.pos))
		{
			return lst
		}
		if (Length = 0)
		{
			return lst
		}
		if (Length < 0)
		{
			length := this.Pos - startIndex
		}
		if (Length + startIndex > this.Pos)
		{
			return lst
		}
		ptr := this[]
		a := []
		sType := "UChar"
		
		i := startIndex + length -1
		j := 1
		While (j <= length)
		{
			a[j] := NumGet(ptr + 0, i, sType)
			i--
			j++
		}
		lst._SetInnerList(a, true)
		return lst
	}
; 	End:ToByteList ;}
}