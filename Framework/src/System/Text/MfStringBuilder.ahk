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
	static DefaultCapacity = 16
	m_ChunkChars := 0
	m_ChunkLength := 0
	m_ChunkOffset := 0
	m_ChunkPrevious := ""
	m_MaxCapacity := 0
	static MaxCapacityField := "m_MaxCapacity"
	MaxChunkSize := 16000
	static StringValueField := "m_StringValue"
	static m_BytesPerChar := A_IsUnicode ? 2 : 1
	m_Encoding := ""
	m_Nl := ""
	m_a := ""
;{ 	Constructor
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
		IsInit := false
		if (pArgs.Count = 0)
		{
			this._new()
			IsInit := true
		}
		strP := pArgs.ToString()
		if (IsInit = false && strP = "MfInteger")
		{
			this._newInt(pArgs.Item[0])
			IsInit := true
		}
		else if (IsInit = false && strP = "MfString")
		{
			this._newStr(pArgs.Item[0])
			IsInit := true
		}
		else if (IsInit = false && strP = "MfString,MfInteger")
		{
			this._newStrInt(pArgs.Item[0], pArgs.Item[1])
			IsInit := true
		}
		else if (IsInit = false && strP = "MfInteger,MfInteger")
		{
			this._newIntInt(pArgs.Item[0], pArgs.Item[1])
			IsInit := true
		}
		else if (IsInit = false && strP = "MfString,MfInteger,MfInteger,MfInteger")
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
			this._newSB(pArgs.Item[0])
			IsInit := true
		}
	}
	_new() {
		this._newInt(32)
	}
	_newInt(capacity) {
		this._newStrInt("",capacity)
	}
	_newStr(value) {
		this._newStrInt(value, 32)
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
			capacity := MfMath.Min(32, maxCapacity)
		}
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
		if (MfString.IsNullOrEmpty(value))
		{
			value := new MfString("")
		}
		if (startIndex > value.Length - length)
		{
			ex := new MfArgumentOutOfRangeException("length", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_IndexLength"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		this.m_MaxCapacity := 2147483647
		if (capacity <= 0)
		{
			capacity := 32
		}
		if (capacity < (length * this.m_BytesPerChar))
		{
			capacity := (length + 1) * this.m_BytesPerChar
		}
		;BytesPerChar :=  MfStringBuilder.m_BytesPerChar
		this.m_ChunkChars := new MfMemoryString(capacity,,this.m_Encoding)
		if (length > 0)
		{
			this.m_ChunkChars.Append(MfString.Substring(value, startIndex , length))
		}
		this.m_ChunkLength := length

	}
	_newSB(from) {
		this.m_ChunkLength := from.m_ChunkLength
		this.m_ChunkOffset := from.m_ChunkOffset
		this.m_ChunkChars := from.m_ChunkChars
		this.m_ChunkPrevious := from.m_ChunkPrevious
		this.m_MaxCapacity := from.m_MaxCapacity
	}
	_newIntIntSb(size, maxCapacity, previousBlock) {
		size := MfInteger.GetValue(size)
		maxCapacity := MfInteger.GetValue(maxCapacity)
		this.m_ChunkChars := ""
		this.m_ChunkChars := new MfMemoryString(size,,this.m_Encoding)
		this.m_MaxCapacity := maxCapacity
		this.m_ChunkPrevious := previousBlock
		if (MfNull.IsNull(previousBlock) = false)
		{
			this.m_ChunkOffset := previousBlock.m_ChunkOffset + previousBlock.m_ChunkLength
		}
	}
; 	End:Constructor ;}
;{ Methods
	Append(obj) {
		return this._AppendString(obj)
	}
	AppendLine(value = "") {
		if (MfString.IsNullOrEmpty(value) = false)
		{
			this._AppendString(value)
		}
		return this._AppendString(this.m_Nl)
	}
	_AppendString(value) {
		sLen := 0
		if (MfObject.IsObjInstance(value, MfString))
		{
			sLen := value.Length
		}
		else
		{
			sLen := StrLen(value)
		}
		if (sLen = 0)
		{
			return this
		}
		chunkChars := this.m_ChunkChars
		chunkLength := this.m_ChunkLength
		num := chunkLength + sLen
		if (sLen <= chunkChars.FreeCharCapacity)
		{
			chunkChars.Append(value)
			this.m_ChunkLength := num
		}
		else
		{
			return this._AppendHelper(value, sLen)
		}
		return this
	}

	_AppendHelper(strObj, valueCount) {
		
		num := valueCount + this.m_ChunkLength
		if (num <= this.m_ChunkChars.FreeCharCapacity)
		{
			chunkChars.Append(value)
			this.m_ChunkLength := num
		}
		else
		{
			ms := new MfMemoryString((valueCount + 1) * this.m_BytesPerChar,, this.m_Encoding)
			ms.Append(strObj)
			num2 := this.m_ChunkChars.CharCapacity - this.m_ChunkLength
			if (num2 > 0)
			{
				msSub := ms.SubString(0, num2)
				this.m_ChunkChars.Append(msSub)
				this.m_ChunkLength := this.m_ChunkChars.Length
				msSub := ""
			}
			num3 := valueCount - num2
			this._ExpandByABlock(num3)
			if (num2 > 0)
			{
				msSub := ms.SubString(num2)
				this.m_ChunkChars.Append(msSub)
				msSub := ""
			}
			else
			{
				this.m_ChunkChars.Append(ms)
			}
			this.m_ChunkLength := num3
		}
		return this
	}
	_GetAddress(ByRef Obj) {
		return &Obj
	}
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
		return ms.ToString()
	}
	_sg(ByRef str, length="", encoding="") {
		strA := &str
		result := StrGet(&%strA%, , encoding) . ""
		return result
	}
;{ 	_ckNumToString2
	; Gets the string value of stringBuilder current chunk
	_ckNumToString2(byRef sb) {
		return sb.m_ChunkChars.ToString()
	}
; 	End:_ckNumToString2 ;}
	_ckNumToString(Chunk, length) {
		i := 0
		length := length * MfStringBuilder.m_BytesPerChar
		step := MfStringBuilder.m_BytesPerChar
		strType := "UChar"
		if (A_IsUnicode)
		{
			strType := "UShort"
		}
		ChunkA := &Chunk
		retval := ""
		While i < length
		{
			num := NumGet(&Chunk,i, strType)
			retval .= chr(num)
			i += step
		}
		return retval
	}
;{ 	__Delete
	__Delete() {
		this.m_ChunkPrevious := ""
		this.this.m_ChunkChars := ""
	}
; 	End:__Delete ;}
; End:Methods ;}
;{ 	Properties
	;{ Capacity
		m_Capacity := 0
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
				return this.m_Capacity + this.m_ChunkOffset
			}
			set {
				_value := MfInteger.GetValue(value)
				if (_value < 0)
				{
					ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_NegativeCapacity"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				if (_value > this.MaxCapacity)
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
					ms := new MfMemoryString(_value - this.m_ChunkOffset,, this.m_Encoding)
					ms.Append(this.m_ChunkChars)
					this.m_ChunkChars := ""
					this.m_ChunkChars := ms
				}
			}
		}
	; End:Capacity ;}
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
					return this._GetCharFromChunk(stringBuilder.m_ChunkChars, i)
				}
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
					this._SetChar(stringBuilder, i, value)
				}
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
				if (_value > this.MaxCapacity)
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
					this._AppendChar(chr(0), i)
					return
				}
				stringBuilder := this._FindChunkForIndex(_value)
				if (this.Equals(stringBuilder) = false)
				{
					ms := new MfMemoryString(capacity - stringBuilder.m_ChunkOffset,, this.m_Encoding)
					ms.Append(stringBuilder.m_ChunkChars)
					this.m_ChunkChars := ""
					this.m_ChunkChars := ms
					this.m_ChunkPrevious := stringBuilder.m_ChunkPrevious
					this.m_ChunkOffset := stringBuilder.m_ChunkOffset
				}
				this.m_ChunkLength := value - stringBuilder.m_ChunkOffset
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
;{ 	_CopyArray
	; copies source memory array to destionation memory array
	; Params
	;	sourceArray - Memory address of source array
	;	destinationArray - Memory address of dest array
	_CopyArray(ByRef sourceArray, ByRef destinationArray, length, startIndex=0) {
		i := 0
		if(startIndex > 0)
		{
			i := startIndex
			length := length + startIndex
		}
		sourceA := &sourceArray
		destA := &destinationArray
		OutputDebug, % "Dest  Mem: " . destA
		while (i < length)
		{
			num := NumGet(&sourceArray, i, "UChar")
			;NumPut(num, &destinationArray , i, "UChar")
			NumPut(num, this.m_ChunkChars + 0 , i, "UChar")
			i++
		}
		
	}
	_CopyA(ByRef sb, ByRef sourceArray, length, startIndex=0) {
		i := 0
		if(startIndex > 0)
		{
			i := startIndex
			length := length + startIndex
		}
		sourceA := &sourceArray
		destA := sb.m_a + 0
		;OutputDebug, % "Dest  Mem: " . destA
		while (i < length)
		{
			num := NumGet(&sourceArray, i, "UChar")
			;NumPut(num, &destinationArray , i, "UChar")
			NumPut(num, destA + 0 , i, "UChar")
			i++
		}
		
	}
; 	End:_CopyArray ;}
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
		this.m_ChunkChars := new MfMemoryString((num + 1) * this.m_BytesPerChar,, this.m_Encoding)
		
		
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