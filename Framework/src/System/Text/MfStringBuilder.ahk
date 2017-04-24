;{ License
/* This file is part of Mini-Framework For AutoHotkey.
 * 
 * Mini-Framework is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 2 of the License.m_ChunkOffset := ""
 m_ChunkPrevious := ""
 m_MaxCapacity := 0
 static MaxCapacityField = "m_MaxCapacity"
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
Class MfText
{
	static StringBuilder := MfStringBuilder
}
	
class MfStringBuilder extends MfObject
{
	static CapacityField := "Capacity"
	static DefaultCapacity := 16
	m_ChunkChars := 0
	m_ChunkLength := 0
	m_ChunkOffset := 0
	m_ChunkPrevious := ""
	m_MaxCapacity := 0
	static MaxCapacityField := "m_MaxCapacity"
	MaxChunkSize := 8000
	static StringValueField := "m_StringValue"
	static m_BytesPerChar := A_IsUnicode ? 2 : 1
	m_Encoding := ""
	m_Nl := ""
	m_HasNullChar := false
;{ 	Constructor
	; Capacity is the length in chars
	__new(args*) {
		if (this.__Class != "MfStringBuilder")
		{
			throw new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Sealed_Class","MfStringBuilder"))
		}
		; cp1252
		base.__new()
		this.m_isInherited := false
		this.m_Encoding := A_IsUnicode ? "UTF-16" : "cp1252"
		this.m_Nl := MfEnvironment.Instance.NewLine
		
		
		
		pArgs := this._ConstructorParams(A_ThisFunc, args*)
		strP := ""
		IsInit := false
		if (pArgs.Count = 0)
		{
			this._new()
			IsInit := true
		}
		else
		{
			strP := pArgs.ToString()
		}
		
		if (IsInit = false && strP = "MfInteger") ; Capacity
		{
			this._newInt(pArgs.Item[0])
			IsInit := true
		}
		else if (IsInit = false && strP = "MfString") ; string
		{
			this._newStr(pArgs.Item[0])
			IsInit := true
		}
		else if (IsInit = false && strP = "MfString,MfInteger") ; string, Capacity
		{
			this._newStrInt(pArgs.Item[0], pArgs.Item[1])
			IsInit := true
		}
		else if (IsInit = false && strP = "MfInteger,MfInteger") ; Capacity, Max Capacity
		{
			this._newIntInt(pArgs.Item[0], pArgs.Item[1])
			IsInit := true
		}
		else if (IsInit = false && strP = "MfString,MfInteger,MfInteger,MfInteger") ; string, index, length, capacity
		{
			this._newStrIntIntInt(pArgs.Item[0], pArgs.Item[1], pArgs.Item[2], pArgs.Item[3])
			IsInit := true
		}
		
		if (IsInit = false && pArgs.Data.Contains("_internalsb") = false)
		{
			e := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", A_ThisFunc))
			e.SetProp(A_LineFile, A_LineNumber, MethodName)
			throw e
		}
		else if (IsInit = false && strP = "MfStringBuilder")
		{
			; internal constructor base
			this._newSB(pArgs.Item[0])
			IsInit := true
		}
	}

	_new() {
		this._newInt(MfStringBuilder.DefaultCapacity)
	}
	_newInt(capacity) {
		
		this._newStrInt("",capacity)
	}
	_newStr(value) {
		this._newStrInt(value, MfStringBuilder.DefaultCapacity)
	}
	_newStrInt(value, capacity) {
		if (MfObject.IsObjInstance(value, MfString) = false)
		{
			value := new MfString(value)
		}
		this._newStrIntIntInt(value, 0, value.Length, capacity)
	}
	_newIntInt(capacity, maxCapacity) {
		capacity := MfInteger.GetValue(capacity)
		maxCapacity := MfInteger.GetValue(maxCapacity)
		if (capacity > maxCapacity)
		{
			ex := new MfArgumentOutOfRangeException("capacity", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Capacity"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (maxCapacity < 1)
		{
			ex := new ArgumentOutOfRangeException("maxCapacity", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_SmallMaxCapacity"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (capacity < 0)
		{
			ex := new MfArgumentOutOfRangeException("capacity", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_MustBePositive","capacity"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (capacity = 0)
		{
			capacity := MfMath.Min(MfStringBuilder.DefaultCapacity, maxCapacity)
		}
		capacity := MfStringBuilder._GetCapacity(capacity)
		this.m_MaxCapacity := maxCapacity
		this.m_ChunkChars := new MfMemoryString(capacity,,this.m_Encoding)
	}
	
	_newStrIntIntInt(value, startIndex, length, capacity) {
		startIndex := MfInteger.GetValue(startIndex)
		length := MfInteger.GetValue(length)
		capacity := MfInteger.GetValue(capacity)
		if (capacity < 0)
		{
			ex := new MfArgumentOutOfRangeException("capacity", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_MustBePositive","capacity"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (length < 0)
		{
			ex := new MfArgumentOutOfRangeException("Length", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_MustBeNonNegNum","length"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (startIndex < 0)
		{
			ex := new MfArgumentOutOfRangeException("startIndex", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_StartIndex"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		ms := MfMemoryString.FromAny(value, this.m_Encoding)
		
		if (startIndex > ms.Length - length)
		{
			ex := new MfArgumentOutOfRangeException("length", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_IndexLength"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		this.m_MaxCapacity := 2147483647
		BytesPerChar := MfStringBuilder.m_BytesPerChar
		if (capacity <= 0)
		{
			capacity :=  MfStringBuilder.DefaultCapacity
		}
		if (capacity < length)
		{
			capacity := length
		}
		capacity := MfStringBuilder._GetCapacity(capacity)
		;BytesPerChar :=  MfStringBuilder.m_BytesPerChar
		this.m_ChunkChars := new MfMemoryString(capacity,,this.m_Encoding)
		if (length > 0)
		{
			this.m_ChunkChars.Append(ms.Substring(startIndex, length))
		}
		this.m_ChunkLength := length
		ms := ""

	}
	_newSB(from) {
		this.m_ChunkLength := from.m_ChunkLength
		this.m_ChunkOffset := from.m_ChunkOffset
		this.m_ChunkChars := from.m_ChunkChars
		this.m_ChunkPrevious := from.m_ChunkPrevious
		this.m_MaxCapacity := from.m_MaxCapacity
		this.m_HasNullChar := from.m_HasNullChar
	}
	_newIntIntSb(size, maxCapacity, previousBlock) {
		size := MfInteger.GetValue(size)
		maxCapacity := MfInteger.GetValue(maxCapacity)
		this.m_ChunkChars := ""
		this.m_ChunkChars := new MfMemoryString(MfStringBuilder._GetCapacity(size),,this.m_Encoding)
		this.m_MaxCapacity := maxCapacity
		this.m_ChunkPrevious := previousBlock
		if (MfNull.IsNull(previousBlock) = false)
		{
			this.m_ChunkOffset := previousBlock.m_ChunkOffset + previousBlock.m_ChunkLength
			this.m_HasNullChar := previousBlock.m_HasNullChar
		}
	}
; 	End:Constructor ;}
;{ Methods
	Append(obj) {
		return this._AppendString(obj)
	}

	AppendFormatted(str, args*) {
		_str := MfString.GetValue(str)
		fStr := MfString.Format(_str, args*)
		this._AppendString(fStr)
	}

	AppendLine(obj = "") {
		if (MfNull.IsNull(obj) = false)
		{
			this._AppendString(obj)
		}
		return this._AppendString(this.m_Nl)
	}
	Clear() {
		this.Length := 0
		return this
	}
	_AppendString(obj) {
		ms := MfMemoryString.FromAny(obj, this.m_Encoding)
		sLen := ms.m_CharCount
		if (sLen = 0)
		{
			return this
		}
		chunkChars := this.m_ChunkChars
		chunkLength := this.m_ChunkLength
		num := chunkLength + sLen
		if (sLen <= chunkChars.FreeCharCapacity)
		{
			chunkChars.Append(ms)
			this.m_ChunkLength := num
		}
		else
		{
			return this._AppendHelper(ms, sLen)
		}
		return this
	}
;{ 	_AppendHelper
	; msObj is MfMemoryString instance
	_AppendHelper(msObj, valueCount) {
		
		num := valueCount + this.m_ChunkLength
		if (num <= this.m_ChunkChars.FreeCharCapacity)
		{
			chunkChars.Append(msObj)
			this.m_ChunkLength := num
		}
		else
		{
			num2 := this.m_ChunkChars.CharCapacity - this.m_ChunkLength
			if (num2 > 0)
			{
				if (msObj.m_CharCount > num2)
				{
					msSub := msObj.SubString(0, num2)
					this.m_ChunkChars.Append(msSub)
					msSub := ""
				}
				else
				{
					this.m_ChunkChars.Append(msObj)
				}
				this.m_ChunkLength := this.m_ChunkChars.m_CharCount
			}
			num3 := valueCount - num2
			this._ExpandByABlock(num3)
			if (num3 > 0)
			{
				if (num2 <= 0)
				{
					this.m_ChunkChars.Append(msObj)
				}
				else
				{
					msSub := msObj.SubString(num2)
					this.m_ChunkChars.Append(msSub)
					msSub := ""
				}
			}
			else
			{
				this.m_ChunkChars.Append(msObj)
			}
			this.m_ChunkLength := this.m_ChunkChars.m_CharCount
		}
		return this
	}
; 	End:_AppendHelper ;}
	_GetAddress(ByRef Obj) {
		return &Obj
	}
;{ 	_getCapacity
	; get the size needed for a MfMemoryString from Capacity
	; Capacity is considered to be the Char Count
	; MfMemoryString needs to be the size of the string + 1
	_GetCapacity(Capacity) {
		BytesPerChar := MfStringBuilder.m_BytesPerChar
		;retval := (Capacity + BytesPerChar) * BytesPerChar
		retval := (Capacity + 1) * BytesPerChar
		;retval := (Capacity) * BytesPerChar
		return retval
	}
; 	End:_getCapacity ;}
;{ 	_AppendChar
	_AppendChar(value, repeatCount=1)	{
		if (repeatCount < 0)
		{
			ex := new MfArgumentOutOfRangeException("repeatCount", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_NegativeCount"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (repeatCount = 0)
		{
			return this
		}
		num := this.m_ChunkLength
		charCode := 0
		if (MfObject.IsObjInstance(value, MfObject))
		{
			charCode := Asc(value.ToString())
		}
		else
		{
			charCode := Asc(value . "")
		}
		return this._AppendCharCode(charCode, repeatCount)
	}

; 	End:_AppendChar ;}
	_AppendCharCode(charCode, repeatCount=1)	{
		if (repeatCount < 0)
		{
			ex := new MfArgumentOutOfRangeException("repeatCount", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_NegativeCount"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (repeatCount = 0)
		{
			return this
		}
		num := this.m_ChunkLength
		
		If (MfMemStrView.IsIgnoreCharLatin1(charCode))
		{
			; set a flag to note that this instance may have one or more null chars
			; this will be checked in the ToString() method to allow displaying of
			; text ignoring null chars (unicode 0)
			this.m_HasNullChar := true
		}
		while (repeatCount > 0)
		{
			if (num < this.m_ChunkChars.FreeCharCapacity)
			{
				;this._SetCharFromChunk(this.m_ChunkChars, num, value)
				this.m_ChunkChars.AppendCharCode(charCode)
				num++
				repeatCount--
			}
			else
			{
				this.m_ChunkLength := num
				this._ExpandByABlock(repeatCount)
				num := 0
			}
		}
		this.m_ChunkLength := num
		return this
	}
;{ 	_InsertStrInt
	; Inserts one or more copies of a specified string into this instance at the specified character position.
	_InsertStrInt(index, obj, count) {
		value := MfMemoryString.FromAny(obj, this.m_Encoding)
		if (count < 0)
		{
			ex := new MfArgumentOutOfRangeException("count", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_NeedNonNegNum"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		length := this.Length
		if (index > length)
		{
			ex := new MfArgumentOutOfRangeException("index", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (value.Length = 0 || count = 0)
		{
			return this
		}
		num := value.Length * count
		if (num > (long)(this.MaxCapacity - this.Length))
		{
			ex := new MfOutOfMemoryException()
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		stringBuilder := ""
		num2 := 0
		this._MakeRoom(index, num, stringBuilder, num2, false)

	}
; 	End:_InsertStrInt ;}
;{ 	_ReplaceInPlaceAtChunk
	; chunk StringBuilder
	; indexInChunk Integer
	; value MfMemoryString
	; count integer
	_ReplaceInPlaceAtChunk(ByRef chunk, ByRef indexInChunk, value, count) {
		if (count != 0)
		{
			loop
			{
				num := MfMath.Min(chunk.m_ChunkLength - indexInChunk, count)
				StringBuilder.ThreadSafeCopy(value, chunk.m_ChunkChars, indexInChunk, num)
				indexInChunk += num
				if (indexInChunk >= chunk.m_ChunkLength)
				{
					chunk = this.Next(chunk);
					indexInChunk := 0
				}
				count -= num
				if (count = 0)
				{
					break
				}
				value += num
			}
		}
	}
; 	End:_ReplaceInPlaceAtChunk ;}
;{ 	Equals
	Equals(sb) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfNull.IsNull(sb))
		{
			return false
		}
		if(MfObject.IsObjInstance(sb, MfStringBuilder) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_IncorrectObjType", "sb", "StringBuilder"), "sb")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
		if (this.Capacity != sb.Capacity || this.MaxCapacity != sb.MaxCapacity || this.Length != sb.Length)
		{
			return false
		}
		if (MfObject.ReferenceEquals(this, sb))
		{
			return true
		}
		stringBuilder := this
		i := stringBuilder.m_ChunkLength
		stringBuilder2 := sb
		j := stringBuilder2.m_ChunkLength
		ContinueOutLoop := false
		while (true)
		{
			ContinueOutLoop := false
			i--
			j--
			while (i < 0)
			{
				stringBuilder := stringBuilder.m_ChunkPrevious
				if (MfNull.IsNull(stringBuilder) = false)
				{
					i := stringBuilder.m_ChunkLength + i
				}
				else
				{
					ContinueOutLoop := false
					while (j < 0)
					{
						stringBuilder2 := stringBuilder2.m_ChunkPrevious
						if (MfNull.IsNull(stringBuilder2))
						{
							break
						}
						j := stringBuilder2.m_ChunkLength + j
					}
					if (i < 0)
					{
						return j < 0
					}
					if (j < 0)
					{
						return false
					}
					c1 := stringBuilder.m_ChunkChars.Byte[i]
					c2 := stringBuilder2.m_ChunkChars.Byte[j]
					if (c1 != c2)
					{
						return false
					}
					ContinueOutLoop := true
					break
				}
			}
			if (ContinueOutLoop = true)
			{
				continue
			}
			while (j < 0)
			{
				stringBuilder2 := stringBuilder2.m_ChunkPrevious
				if (MfNull.IsNull(stringBuilder2))
				{
					break
				}
				j := stringBuilder2.m_ChunkLength + j
			}
			if (i < 0)
			{
				return j < 0
			}
			if (j < 0)
			{
				return false
			}
			c1 := stringBuilder.m_ChunkChars.Byte[i]
			c2 := stringBuilder2.m_ChunkChars.Byte[j]
			if (c1 != c2)
			{
				return false
			}
		}
		return j < 0
	}
; 	End:Equals ;}
;{ 	Is
	Is(ObjType) {
		typeName := MfType.TypeOfName(ObjType)
		if (typeName = "MfText.StringBuilder")
		{
			return true
		}
		return base.Is(ObjType)
	}
; 	End:Is ;}
	ToString() {
		if (this.Length = 0)
		{
			return ""
		}
		stringBuilder := this
		OutOfRange := true
		;~ iLen := 0 ; (this.Length + 1) * this.m_BytesPerChar
		;~ sb := this
		;~ while (MfNull.IsNull(sb) = False)
		;~ {
			;~ iLen += (sb.m_ChunkChars.Length + this.m_BytesPerChar) * this.m_BytesPerChar
			;~ sb := sb.m_ChunkPrevious
		;~ }
		iLen := (this.Length + 1) * this.m_BytesPerChar
		ms := new MfMemoryString(iLen,, this.m_Encoding)
		stringBuilder := this
		loop
		{
			if (stringBuilder.m_ChunkLength > 0)
			{
				chunkChars := stringBuilder.m_ChunkChars
				chunkOffset := stringBuilder.m_ChunkOffset
				chunkLength := stringBuilder.m_ChunkLength
				if (chunkLength + chunkOffset > ms.CharCapacity || chunkLength > chunkChars.Length)
				{
					break
				}
				ms.OverWrite(stringBuilder.m_ChunkChars, chunkOffset, chunkLength)
			}
			stringBuilder := stringBuilder.m_ChunkPrevious
			if (MfNull.IsNull(stringBuilder))
			{
				OutOfRange := false
				break
			}
		}
		if (OutOfRange)
		{
			ms := ""
			ex := new MfArgumentOutOfRangeException("chunkLength", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
		ms.m_MemView.Pos := iLen
		ms.m_CharCount := this.Length
		; if flag has been set that this instance contains null char ( unicode 0 ) values
		; in the string then we will get a new MfMemoryString that ignores all null chars
		; to output the text
		; If we did not get this new MfMemoryString instance then the text output would stop
		; at the first null char encountered in the string.
		; Null value can be added into the current instance by extending the length or by adding 0 value char to
		; add char method such as this._AppendCharCode(0, 1)
		if (this.m_HasNullChar = true)
		{
			ms2 := ms.GetStringIgnoreNull()
			return ms2.ToString()
		}
		return ms.ToString()
	}
;{ 	_MakeRoom
/*
	_MakeRoom()
		Makes room insde of string builder
	Parameters:
		index
			Integer Index
		count
			Integer Count
		chunk
			MfString Builder Instance ( out )
		indexInChunk
			Integer ( out )
		doneMoveFollowingChars
			Boolean value
*/
	_MakeRoom(index, count, byRef chunk, ByRef indexInChunk, doneMoveFollowingChars) {
		if (count + this.Length > this.m_MaxCapacity)
		{
			ex := new MfArgumentOutOfRangeException("requiredLength", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_SmallCapacity"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		chunk := this
		while (chunk.m_ChunkOffset > index)
		{
			chunk.m_ChunkOffset += count
			chunk := chunk.m_ChunkPrevious
		}
		indexInChunk := index - chunk.m_ChunkOffset
		if (!doneMoveFollowingChars && chunk.m_ChunkLength <= (MfStringBuilder.DefaultCapacity * 2) && chunk.m_ChunkChars.CharCapacity - chunk.m_ChunkLength >= count)
		{
			i := chunk.m_ChunkLength
			while (i > indexInChunk)
			{
				; move bytes to the right by count amount
				i--
				chunk.m_ChunkChars.Byte[i + count] := chunk.m_ChunkChars.Byte[i]
			}
			chunk.m_ChunkLength += count
			; advance the pos to match the number count moved
			chunk.m_ChunkChars.Pos += count
			return
		}
		stringBuilder := new MfStringBuilder(MfMath.Max(count, MfStringBuilder.DefaultCapacity), chunk.m_MaxCapacity, chunk.m_ChunkPrevious)
		stringBuilder.m_ChunkLength := count
		num := MfMath.Min(count, indexInChunk)
		BytesPerChar := MfStringBuilder.m_BytesPerChar
		if (num > 0)
		{
			stringBuilder.m_ChunkChars.Append(chunk.m_ChunkChars.SubString(0, num))
			num2 := indexInChunk - num
			if (num2 >= 0)
			{
				; move any remaining bytes not copied int stringBuilder left
				len := num2
				chunk.m_ChunkChars.MoveCharsLeft(0, len)
				
				if (chunk.m_ChunkChars.FreeCapacity > 0)
				{
					; set the next char past m_MemView.Pos to 0 for good measure
					i := 1
					While (i <= BytesPerChar)
					{
						chunk.m_ChunkChars.Byte[chunk.m_ChunkChars.m_MemView.Pos - i] := 0
						i++
					}
				}
				indexInChunk := num2
			}
		}
		chunk.m_ChunkPrevious := stringBuilder
		chunk.m_ChunkOffset += count
		if (num < count)
		{
			chunk := stringBuilder
			indexInChunk := num
		}
	}
; 	End:_MakeRoom ;}
	_sg(ByRef str, length="", encoding="") {
		strA := &str
		result := StrGet(&%strA%, , encoding) . ""
		return result
	}
;{ 	__Delete
	__Delete() {
		this.m_ChunkPrevious := ""
		this.m_ChunkChars := ""
	}
; 	End:__Delete ;}
; End:Methods ;}
;{ 	Properties
	;{ Capacity
		/*!
			Property: Capacity [get/set]
				Gets or sets the maximum number of characters that can be contained in the memory allocated by the current instance.
			Value:
				Var representing the Capacity property of the instance
			Returns:
				The maximum number of characters that can be contained in the memory allocated by the current instance
		*/
		Capacity[]
		{
			get {
				return this.m_ChunkChars.CharCapacity + this.m_ChunkOffset
			}
			set {
				_value := MfInteger.GetValue(value)
				if (_value < 0)
				{
					ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_NegativeCapacity"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				if (_value > this.m_MaxCapacity)
				{
					ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Capacity"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				if (_value < this.Length)
				{
					ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_SmallCapacity"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				if (this.Capacity != _value)
				{
					; this will expand the current chunk to add the new expanded Capacity
					v := _value - this.m_ChunkOffset
					v := MfStringBuilder._GetCapacity(v)
					
					ms := new MfMemoryString(v,, this.m_Encoding)
					ms.Append(this.m_ChunkChars)
					this.m_ChunkChars := ""
					this.m_ChunkChars := ms
				}
			}
		}
	; End:Capacity ;}
	;{ MaxCapacity
		/*!
			Property: MaxCapacity [get]
				Gets the MaxCapacity value associated with the this instance
			Value:
				Var representing the MaxCapacity property of the instance
			Remarks:
				Readonly Property
		*/
		MaxCapacity[]
		{
			get {
				return this.m_MaxCapacity
			}
			set {
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
				ex.SetProp(A_LineFile, A_LineNumber, "MaxCapacity")
				Throw ex
			}
		}
	; End:MaxCapacity ;}
	;{ Item
		/*!
			Property: Item [get/set]
				Gets or sets the Item value associated with the this instance
			Value:
				Var representing the Item property of the instance
		*/
		Item[index]
		{
			get {
				;return this.m_Item
				stringBuilder := this
				_index := MfInteger.GetValue(index)
				i := 0
				loop
				{
					i := _index - stringBuilder.m_ChunkOffset
					if (i >= 0)
					{
						break
					}
					stringBuilder := stringBuilder.m_ChunkPrevious
					if (MfNull.IsNull(stringBuilder))
					{
						ex := new MfIndexOutOfRangeException()
						ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
						throw ex
					}
					if (i >= stringBuilder.m_ChunkLength)
					{
						ex := new MfIndexOutOfRangeException()
						ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
						throw ex
					}
				}
				return this._GetCharFromChunk(stringBuilder.m_ChunkChars, i)
			}
			set {
				;this.m_Item := value
				;return this.m_Item
				stringBuilder := this
				_index := MfInteger.GetValue(index)
				i := 0
				Loop
				{
					i := _index - stringBuilder.m_ChunkOffset
					if (i >= 0)
					{
						break
					}
					stringBuilder := stringBuilder.m_ChunkPrevious
					if (MfNull.IsNull(stringBuilder))
					{
						ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
						ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
						throw ex
					}
					if (i >= stringBuilder.m_ChunkLength)
					{
						ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
						ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
						throw ex
					}
					;this._SetCharFromChunk(stringBuilder.m_ChunkChars, i, value)
				}
				this._SetChar(stringBuilder, i, value)
			}
		}
	; End:Item ;}
	;{ Length
		/*!
			Property: Length [get/set]
				Gets or sets the Length value associated with the this instance
			Value:
				Var representing the Length property of the instance
		*/
		Length[]
		{
			get {
				return this.m_ChunkOffset + this.m_ChunkLength
			}
			set {
				_value := MfInteger.GetValue(value)
				if (_value < 0)
				{
					ex := new MfArgumentOutOfRangeException("value", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_NegativeLength"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				if (_value > this.m_MaxCapacity)
				{
					ex := new MfArgumentOutOfRangeException("value", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_SmallCapacity"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				capacity := this.Capacity
				if (_value = 0 && MfNull.IsNull(this.m_ChunkPrevious))
				{
					this.m_ChunkLength := 0
					this.m_ChunkOffset := 0
					return
				}
				i := _value - this.Length
				if (i > 0)
				{
					this._AppendCharCode(0, i)
					return
				}
				BytesPerChar := MfStringBuilder.m_BytesPerChar
				stringBuilder := this._FindChunkForIndex(_value)
				if (this.Equals(stringBuilder) = false)
				{
					ms := new MfMemoryString(MfStringBuilder._GetCapacity(capacity - stringBuilder.m_ChunkOffset),, this.m_Encoding)
					ms.Append(stringBuilder.m_ChunkChars)
					this.m_ChunkChars := ""
					this.m_ChunkChars := ms
					this.m_ChunkPrevious := ""
					this.m_ChunkPrevious := stringBuilder.m_ChunkPrevious
					this.m_ChunkOffset := stringBuilder.m_ChunkOffset
				}
				
				this.m_ChunkLength := value - stringBuilder.m_ChunkOffset
				if (this.m_ChunkChars.m_MemView.Size > (this.m_ChunkLength * BytesPerChar))
				{
					this.m_ChunkChars.m_MemView.Pos := (this.m_ChunkLength + 1) * BytesPerChar
					this.m_ChunkChars.m_CharCount := this.m_ChunkLength
				}
				else
				{
					this.m_ChunkChars.m_MemView.Pos := this.m_ChunkChars.m_MemView.Size
					this.m_ChunkLength := this.m_ChunkChars.m_MemView.Size // BytesPerChar
					this.m_ChunkChars.m_CharCount := this.m_ChunkLength
				}
				if (this.m_ChunkChars.FreeCapacity > 0)
				{
					; set the next char past m_MemView.Pos to 0 for good measure
					i := 1
					While (i <= BytesPerChar)
					{
						this.m_ChunkChars.Byte[this.m_ChunkChars.m_MemView.Pos - i] := 0
						i++
					}
				}
			}
		}
	; End:Length ;}
; 	End:Properties ;}
;{ 	Internal Methods
	_SetCharFromChunk(byref chunk, index, value) {
		chunk.Char[index] := value
	}
	_SetChar(ByRef sb, index, value) {
		sb.m_ChunkChars.Char[index] := value
		
	}
	
	_GetCharFromChunk(byref chunk, index) {
		; chunk is instance of MfMemoryString
		return chunk.Char[index]
	}
	_GetCharCodeFromChunk(byref chunk, index) {
		return chunk.CharCode[index]
	}
;{ 	_ExpandByABlock
	_ExpandByABlock(minBlockCharCount) {
		if (minBlockCharCount + this.Length > this.m_MaxCapacity)
		{
			ex := new MfArgumentOutOfRangeException("requiredLength", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_SmallCapacity"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
		num := MfMath.Max(minBlockCharCount, MfMath.Min(this.Length, 16000))
		params := new MfParams()
		params.Data.Add("_internalsb", true)
		params.Add(this)

		this.m_ChunkPrevious := new MfStringBuilder(params)
		this.m_ChunkOffset += this.m_ChunkLength
		this.m_ChunkLength := 0
		if (this.m_ChunkOffset + num < num)
		{
			this.m_ChunkChars := null
			ex := new MfOutOfMemoryException()
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		this.m_ChunkChars := new MfMemoryString( MfStringBuilder._GetCapacity(num),, this.m_Encoding)
		
		
	}
; 	End:_ExpandByABlock ;}
;{ _FindChunkForIndex
	_FindChunkForIndex(index) {
		stringBuilder := this
		while (stringBuilder.m_ChunkOffset > index)
		{
			stringBuilder := stringBuilder.m_ChunkPrevious
		}
		return stringBuilder
	}
; End:_FindChunkForIndex ;}

;{ _ConstructorParams
	_ConstructorParams(MethodName, args*) {

		p := Null
		cnt := MfParams.GetArgCount(args*)

	
		if ((cnt > 0) && MfObject.IsObjInstance(args[1], MfParams))
		{
			p := args[1] ; arg 1 is a MfParams object so we will use it
			; can be up to five parameters
			; Two parameters is not a possibility
			if (p.Count > 4)
			{
				e := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", MethodName))
				e.SetProp(A_LineFile, A_LineNumber, MethodName)
				throw e
			}
		}
		else
		{

			p := new MfParams()
			p.AllowEmptyString := false ; no strings for parameters in this case
			p.AllowOnlyAhkObj := false ; needed to allow for undefined to be added
			p.AllowEmptyValue := true ; all empty/null params will be added as undefined

			;p.AddInteger(0)
			;return p
			
			; can be up to five parameters
			; Two parameters is not a possibility
			if (cnt > 4)
			{
				e := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", MethodName))
				e.SetProp(A_LineFile, A_LineNumber, MethodName)
				throw e
			}
			
			i := 1
			while i <= cnt
			{
				arg := args[i]
				try
				{
					if (IsObject(arg))
					{
						p.Add(arg)
					} 
					else
					{
						if (cnt = 1 && i = 1)
						{
							; can be int or string, can alos be MfStringBuilder but that is taken care of by object
							; if int then capacity
							result := MfInteger.GetValue(arg, "NaN", true)
							if (result == "NaN")
							{
								p.AddString(arg)
							}
							else
							{
								p.AddInteger(result)
							}
						}
						if (cnt = 2)
						{
							if (i = 1)
							{
								result := MfInteger.GetValue(arg, "NaN", true)
								if (result == "NaN")
								{
									p.AddString(arg)
								}
								else
								{
									p.AddInteger(result)
								}
							}
						}
						if (i = 2)
						{
							; param 2 is always an int when not an MfObject
							result := new MfInteger(arg)
							p.Add(result)

						}
						if (i = 3)
						{
							; param 3 is always an int when not an MfObject
							result := new MfInteger(arg)
							p.Add(result)

						}
					}
				}
				catch e
				{
					ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Error_on_nth", i), e)
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				i++
			}
			
		}
		;return new MfParams()
		return p
	}
; End:_ConstructorParams ;}
; 	End:Internal Methods ;}
}