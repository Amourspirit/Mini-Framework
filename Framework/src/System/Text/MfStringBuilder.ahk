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
class MfStringBuilder extends MfObject
{
	static DefaultCapacity := 16
	m_ChunkChars := 0
	m_ChunkLength := 0
	m_ChunkOffset := 0
	m_ChunkPrevious := ""
	m_MaxCapacity := 0
	MaxChunkSize := 8000
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
		else if (IsInit = false && strP = "MfInteger,MfInteger") ; Capacity, Max Capacity or size, maxCapacity, previousBlock
		{
			if (pArgs.Data.Contains("_nullSb"))
			{
				if (pArgs.Data.Contains("_InternalOnly") && pArgs.Data.Item["_InternalOnly"] = true)
				{
					this._newIntIntSb(pArgs.Item[0], pArgs.Item[1])
					IsInit := true
				}
			}
			else
			{
				this._newIntInt(pArgs.Item[0], pArgs.Item[1])
				IsInit := true
			}
		}
		else if (IsInit = false && strP = "MfInteger,MfInteger,MfStringBuilder") ; size, maxCapacity, previousBlock
		{
			if (pArgs.Data.Contains("_InternalOnly") && pArgs.Data["_InternalOnly"] = true)
			{
				this._newIntIntSb(pArgs.Item[0], pArgs.Item[1], pArgs.Item[2])
				IsInit := true
			}
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
; 	End:Constructor ;}
;{ Methods
;{ 	Append
	; append object, var, char, charcode or MfCharList or MfObject x number of times
	Append(args*) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		cnt := MfParams.GetArgCount(args*)
		; by checking for single item via cout it is much faster then loading from _AppendParams and then processing
		; most usage if Append will be appending a single itemd such as a string or var.
		if (cnt = 1)
		{
			obj := args[1]
			if (MfObject.IsObjInstance(obj, MfCharList))
			{
				this._AppendCharList(obj, 0, obj.Count)
				return this
			}
			; can handel null values
			return this._AppendString(obj)
		}

		pArgs := this._AppendParams(A_ThisFunc, args*)
		pList := pArgs.ToStringList()

		if (cnt = 2)
		{
			; only valid choice is MfChar and Repeat count
			if (pList.Item[0].Value = "MfChar")
			{
				num :=  MfInt64.GetValue(pArgs.Item[1])
				cc := pArgs.Item[0].Charcode
				this._AppendCharCode(cc, num)
			}
		}
		if (cnt = 3)
		{
			; MfCharList, StartIndex, Count
			; MfString, StartIndex, Count
			s := pList.Item[0].Value
			If (s = "MfCharList")
			{
				obj := pArgs.Item[0]
				StartIndex := MfInt64.GetValue(pArgs.Item[1])
				Count := MfInt64.GetValue(pArgs.Item[2])
				this._AppendCharList(obj, StartIndex, Count)
				return this
			}
			else if (s = "MfString")
			{
				obj := pArgs.Item[0]
				StartIndex := MfInt64.GetValue(pArgs.Item[1])
				Count := MfInt64.GetValue(pArgs.Item[2])
				ms := MfMemoryString.FromAny(obj, this.m_Encoding)
				if (Count > ms.Length - startIndex)
				{
					ex := new MfArgumentOutOfRangeException("count", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				this._AppendString(ms.SubString(StartIndex,Count))
				return this
			}
		}
		e := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", A_ThisFunc))
		e.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw e
	}
; 	End:Append ;}
;{ 	AppendString
	AppendString(str) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		this._AppendString(str)
		return this
	}
; 	End:AppendString ;}
;{ 	AppendFormatted
	; append a formatted string See MfString.Format()
	AppendFormatted(str, args*) {
		_str := MfString.GetValue(str)
		fStr := MfString.Format(_str, args*)
		this._AppendString(fStr)
	}
; 	End:AppendFormatted ;}
;{ 	AppendLine
	; append object, var, char, charcode or MfCharList or MfObject followed by a new line
	; or just append a new line
	AppendLine(obj = "") {
		if (MfNull.IsNull(obj) = false)
		{
			this._AppendString(obj)
		}
		return this._AppendString(this.m_Nl)
	}
; 	End:AppendLine ;}
;{ 	Clear
	Clear() {
		this.Length := 0
		return this
	}
; 	End:Clear ;}
;{ 	CompareTo - Overrides MfObject CompareTo
	; Compares current instance to obj instance
	CompareTo(obj) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfNull.IsNull(obj))
		{
			return 1
		}
		if(MfObject.IsObjInstance(obj, MfStringBuilder) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_IncorrectObjType", "obj", "StringBuilder"), "obj")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (MfObject.ReferenceEquals(this, obj))
		{
			return 0
		}
		thisMs := this._ToMemoryString()
		ObjMs := obj._ToMemoryString()
		return thisMs.CompareOrdinal(objMs, false)
	}
; 	End:CompareTo ;}
;{ 	CopyTo
	; Copy chars of current instance to destination
	; destination is instance of MfCharList
	CopyTo(sourceIndex, destination, destinationIndex, count) {
			sourceIndex := MfInteger.GetValue(sourceIndex)
			destinationIndex := MfInteger.GetValue(destinationIndex)
			count := MfInteger.GetValue(count)

			if (MfNull.IsNull(destination))
			{
				ex := new MfArgumentNullException("destination")
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			if (!MfObject.IsObjInstance(destination, MfCharList))
			{
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("NullReferenceException_Object_Param", "destination"), "destination")
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}

			if (destinationIndex < 0)
			{
				ex := new MfArgumentOutOfRangeException("destinationIndex", mfEnvironment.Instance.GetResourceString("Arg_NegativeArgCount"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			if (sourceIndex < 0)
			{
				ex := new MFArgumentOutOfRangeException("sourceIndex", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_StartIndex"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}

			if (count < 0)
			{
				ex := new MFArgumentOutOfRangeException("count", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_StartIndex"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}

			if (sourceIndex > this.Length)
			{
				ex := new MfArgumentOutOfRangeException("sourceIndex", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}

			if (sourceIndex > this.Length - count)
			{
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_LongerThanSrcString"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}

			chunk := this
			sourceEndIndex := sourceIndex + count
			curDestIndex := destinationIndex + count
			while (count > 0)
			{
				chunkEndIndex := sourceEndIndex - chunk.m_ChunkOffset
				if (chunkEndIndex >= 0)
				{
					if (chunkEndIndex > chunk.m_ChunkLength)
					{
						chunkEndIndex := chunk.m_ChunkLength
					}

					chunkCount := count
					chunkStartIndex := chunkEndIndex - count
					if (chunkStartIndex < 0)
					{
						chunkCount += chunkStartIndex
						chunkStartIndex := 0
					}
					curDestIndex -= chunkCount
					count -= chunkCount
					MfMemoryString.CopyToCharList(chunk.m_ChunkChars, chunkStartIndex, destination, curDestIndex, chunkCount)
				}
				chunk := chunk.m_ChunkPrevious
			}
		}
; 	End:CopyTo ;}

;{ 	EnsureCapacity
	; ensure current instance has internal capacity specified by Parameter capacity
	EnsureCapacity(capacity) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		capacity := MfInteger.GetValue(capacity)
		if (capacity < 0)
		{
			ex := new new MfArgumentOutOfRangeException("capacity", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_NegativeCapacity"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (this.Capacity < capacity)
		{
			this.Capacity := capacity
		}
		return this.Capacity
	}
; 	End:EnsureCapacity ;}
;{ 	Insert
/*
	Method: Insert()

	Insert()
		Inserts a obj into this instance at the specified character position.
	Parameters:
		index
			The position in this instance where insertion begins. 
		obj
			The MfObject based object or var to insert
		Count
			Optional value. If included the obj will be inserted at the index Count times.
	Returns:
		Returns A reference to this instance after the insert operation has completed. 
	Throws:
		Throws MfArgumentException if index is not a valid integer
		Throws MfArgumentOutOfRangeException if index is out of range
		Throws MfException if error compleating the insert
*/
	Insert(args*) {
		pArgs := this._InsertParams(A_ThisFunc, args*)
		pList := pArgs.ToStringList()
		cnt := pArgs.Count
		if (pArgs.Count < 2)
		{
			e := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", A_ThisFunc))
			e.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw e
		}
		index := 0
		try
		{
			index := MfInteger.GetValue(pArgs.Item[0])
		}
		catch e
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToInteger"), "index")
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
		if (cnt = 2)
		{
			; only valid choice is MfChar and Repeat count
			if (pList.Item[1].Value = "MfCharList")
			{
				try
				{
					this._InsertObjInt(index, pArgs.Item[1].ToString(), 1)
					return this
				}
				catch e
				{
					ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
			}
			else
			{
				try
				{
					this._InsertObjInt(index, pArgs.Item[1], 1)
					return this
				}
				catch e
				{
					ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
			}
		}
		if (cnt = 3)
		{
			count := 0
			try
			{
				count := MfInteger.GetValue(pArgs.Item[2])
				return this
			}
			catch e
			{
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToInteger"), "count")
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			
			try
			{
				this._InsertObjInt(index, pArgs.Item[1], count)
				return this
			}
			catch e
			{
				ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		}
		else if (cnt = 4)
		{
			; index, MfCharList, startIndex, CharCount
			if (pList.Item[1].Value = "MfCharList")
			{
				lst := pArgs.Item[1]
				startIndex := 0
				try
				{
					startIndex := MfInteger.GetValue(pArgs.Item[2])
				}
				catch e
				{
					ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToInteger"), "startIndex")
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				CharCount := 0
				try
				{
					CharCount := MfInteger.GetValue(pArgs.Item[3])
				}
				catch e
				{
					ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToInteger"), "CharCount")
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				if (lst.Count = 0)
				{
					if (startIndex = 0 && charCount = 0)
					{
						return this
					}
					ex := new MfArgumentNullException("value"fEnvironment.Instance.GetResourceString("ArgumentNull_String"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				if (startIndex < 0)
				{
					ex := new MfArgumentOutOfRangeException("startIndex", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_StartIndex"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				if (startIndex > lst.Count - charCount)
				{
					ex := new MfArgumentOutOfRangeException("startIndex", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_StartIndex"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				if (charCount > 0)
				{
					this._InsertObjInt(index, lst.ToString(false, startIndex, charCount), 1)
				}
				return this
			}
		}
		e := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", A_ThisFunc))
		e.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw e
	}
; 	End:Insert ;}
;{ 	Replace
	; Replace oldValue with newValue in the currrent instance
	Replace(oldValue, newValue, startIndex=0, count=-1) {
		startIndex := MfInteger.GetValue(startIndex, 1)
		count := MfInteger.GetValue(count, -1)
		currentLength := this.Length
		
		
		if ((startIndex < 0) || (startIndex > currentLength))
		{
			ex := new MfArgumentOutOfRangeException("startIndex", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (count < 0)
		{
			count := currentLength
		}
		
		if (count < 0 || startIndex > currentLength - count)
		{
			ex := new MfArgumentOutOfRangeException("count", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (MfNull.IsNull(oldValue))
		{
			ex := new MfArgumentNullException("oldValue")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		MsOldVal := MfMemoryString.FromAny(oldValue, this.m_Encoding)
		if (MsOldVal.Length = 0)
		{
			ex := new  MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_EmptyName"), "oldValue")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		MsNewVal := MfMemoryString.FromAny(newValue, this.m_Encoding)
		deltaLength := MsNewVal.Length - MsOldVal.Length

		; this._Replace(MsOldVal, MsNewVal, startIndex, Count)
		; return this

		; uainf the method of of mergin and replacing was 30 time faster
		; on a string with 4200 chars with a initial buffer of 3000 chars.
		; the MsMemoryString is much faster with find and replace
		; mostly because it does not have to work on multible chunks
		; and consider peices here and there.
		; Also the case insenstive MfMemoryString method uses a special
		; fast machine code method to find the index of the old value.
		; When the newValue and oldValue length are the same the replacements
		; are even faster as the replacement is done by just overwriting the bytes
		; and not mem copy method are used to move and copy bytes to rebuild the string.
		; Due to the speed advantages it is worth merging the smaller chunks together
		; into one chunk and then using MfMemoryString to replace.
		if (this.m_ChunkOffset > 0 && this.Length < this.MaxChunkSize)
		{
			if (deltaLength = 0)
			{
				this._Merge()
			}
			else
			{
				this._Merge(MfMath.Min(this.Length + MfStringBuilder.DefaultCapacity, this.MaxChunkSize - this.Length))
			}
			
		}

		sIndex := startIndex
		if (this.m_ChunkOffset = 0)
		{
			Indexes := this._GetReplaceIndexsForChunk(this, MsOldVal, sIndex, count)
			ReplacedAll := false
			iCount := count
			i := Indexes.Count
			lst := Indexes.m_InnerList
			iLen := MsOldVal.Length
			while (i >= 1)
			{
				indexValue := lst[i]
				If (indexValue > count)
				{
					i--
					Continue
				}
				if (this.m_ChunkChars.FreeCharCapacity > deltaLength)
				{
					this.m_ChunkChars.ReplaceAtIndex(indexValue, iLen, MsNewVal)
					this.m_ChunkLength := this.m_ChunkChars.Length
				}
				else
				{
					ReplacedAll := false
					break
				}
				iCount := indexValue
				i--
			}
			if (i = 0)
			{
				ReplacedAll = true
			}
			
			; if all the space avaailable in this chunk is used and we
			; are not yet at the max chunk size then add an chunk and
			; call this method again recursivly to mearge chunks and 
			; start replacing again
			; The reason to call recursion here is that the MsMemoryString
			; operates much faster then the MfStringBuilder replace does
			; so for string under the length of MaxChunkSize we can
			; use MsMemoryString repalce method
			if (ReplacedAll = false && this.Length < this.MaxChunkSize)
			{
				this._ExpandByABlock(MfStringBuilder.DefaultCapacity)
				this.Replace(MsOldVal, MsNewVal, sIndex, iCount)
			}
			if (ReplacedAll = false && iCount > 0)
			{
				this._Replace(MsOldVal, MsNewVal, sIndex,  iCount)
			}
		}
		else
		{
			this._Replace(MsOldVal, MsNewVal, sIndex, Count)
		}

		return this
	}
; 	End:Replace ;}
;{ 	Remove
	; Remove a section of chars from current instance
	Remove(startIndex, length) {
		try
		{
			startIndex := MfInteger.GetValue(startIndex)
		}
		catch e
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToInteger"), "startIndex")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		try
		{
			length := MfInteger.GetValue(length)
		}
		catch e
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToInteger"), "length")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (length < 0)
		{
			ex := new MFArgumentOutOfRangeException("length", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_NegativeLength"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (startIndex < 0)
		{
			ex := new MFArgumentOutOfRangeException("length", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_StartIndex"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (length > this.Length - startIndex)
		{
			ex := new MFArgumentOutOfRangeException("index", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (this.Length = length && startIndex = 0)
		{
			this.Length := 0
			return this
		}
		if (length > 0)
		{
			stringBuilder := ""
			num := 0
			this._Remove(startIndex, length, stringBuilder, num)
		}
		return this
	}
; 	End:Remove ;}

;{ 	Equals
	; compare this instance to another instance of MfStringBulder to see if they are equal
	Equals(sb) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfNull.IsNull(sb))
		{
			return false
		}
		if(MfObject.IsObjInstance(sb, MfStringBuilder) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_IncorrectObjType", "sb", "thisChunk"), "sb")
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
		; if this instance and sb instance both have one chununk the compare as MemoryString
		if (this.m_ChunkOffset = 0 && sb.m_ChunkOffset = 0)
		{
			return this.m_ChunkChars.Equals(sb.m_ChunkChars)
		}
		thisChunk := this
		i := thisChunk.m_ChunkLength
		sbChunk := sb
		j := sbChunk.m_ChunkLength
		ContinueOutLoop := false
		while (true)
		{
			ContinueOutLoop := false
			i--
			j--
			while (i < 0)
			{
				thisChunk := thisChunk.m_ChunkPrevious
				if (MfNull.IsNull(thisChunk) = false)
				{
					i := thisChunk.m_ChunkLength + i
				}
				else
				{
					ContinueOutLoop := false
					while (j < 0)
					{
						sbChunk := sbChunk.m_ChunkPrevious
						if (MfNull.IsNull(sbChunk))
						{
							break
						}
						j := sbChunk.m_ChunkLength + j
					}
					if (i < 0)
					{
						return j < 0
					}
					if (j < 0)
					{
						return false
					}
					c1 := thisChunk.m_ChunkChars.CharCode[i]
					c2 := sbChunk.m_ChunkChars.CharCode[j]
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
				sbChunk := sbChunk.m_ChunkPrevious
				if (MfNull.IsNull(sbChunk))
				{
					break
				}
				j := sbChunk.m_ChunkLength + j
			}
			if (i < 0)
			{
				return j < 0
			}
			if (j < 0)
			{
				return false
			}
			c1 := thisChunk.m_ChunkChars.CharCode[i]
			c2 := sbChunk.m_ChunkChars.CharCode[j]
			if (c1 != c2)
			{
				return false
			}
		}
		return j < 0
	}
; 	End:Equals ;}
;{ 	Is - Overrides MfObject
	Is(ObjType) {
		typeName := MfType.TypeOfName(ObjType)
		if (typeName = "MfText.StringBuilder")
		{
			return true
		}
		if (typeName = "StringBuilder")
		{
			return true
		}
		return base.Is(ObjType)
	}
; 	End:Is ;}
;{ 	ToString - Overrides MfObject
	ToString(AsStringObj:=false, startIndex:=0, length:=-1) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		
		currentLength := this.Length
		if (currentLength = 0)
		{
			return ""
		}
		startIndex := MfInteger.GetValue(startIndex, 0)
		length := MfInteger.GetValue(length, -1)
		AsStringObj := MfBool.GetValue(AsStringObj, false)
		
		if (length < 0)
		{
			length := currentLength
		}
		if (startIndex < 0)
		{
			ex := new MfArgumentOutOfRangeException("startIndex", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_StartIndex"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (startIndex > currentLength)
		{
			ex := new MfArgumentOutOfRangeException("startIndex", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_StartIndexLargerThanLength"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (startIndex > (currentLength - length))
		{
			ex := new MfArgumentOutOfRangeException("length", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_IndexLength"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		DoSub := false
		if (startIndex > 0 || length < currentLength)
		{
			DoSub := true
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
		ms := ""

		HasOtherchunk := false
		if (MfNull.IsNull(this.m_ChunkPrevious))
		{
			ms := this.m_ChunkChars
		}
		else
		{
			HasOtherchunk := true
			iLen := (currentLength + 1)
			ms := new MfMemoryString(iLen,, this.m_Encoding)
		}
		if (HasOtherchunk)
		{
			stringBuilder := this
			loop
			{
				if (stringBuilder.m_ChunkLength > 0)
				{
					chunkChars := stringBuilder.m_ChunkChars
					chunkOffset := stringBuilder.m_ChunkOffset
					chunkLength := stringBuilder.m_ChunkLength
					;OutputDebug % chunkChars.ToString()
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
			ms.m_MemView.Pos := (currentLength + 1) * this.m_BytesPerChar
			ms.m_CharCount := currentLength
		}
		

		; if flag has been set that this instance contains null char ( unicode 0 ) values
		; or any Latin1 (char 0 to 255 ) not printing char
		; in the string then we will get a new MfMemoryString that ignores all non-printing
		; chars for latin1 and output text from there.
		; If we did not get this new MfMemoryString instance then the text output would stop
		; at the first null char ( unicode 0) encountered in the string.
		; Null value can be added into the current instance by extending the length
		; Other non printing chars cna be added by adding not printing char value
		; with methods such as this._AppendCharCode(8, 1)

		; a := ms.ToArray()
		; i := 1
		; While (i < a.Length())
		; {
		; 	OutputDebug % a[i]
		; 	i += 2
		; }
			

		if (this.m_HasNullChar = true)
		{
			
			if (DoSub)
			{
				ms2 := ms.SubString(startIndex, Length).GetStringIgnoreNull()
			}
			else
			{
				ms2 := ms.GetStringIgnoreNull()
			}
			if (AsStringObj)
			{
				str := new MfString(ms2.ToString(), true)
				return str
			}
			return ms2.ToString()
		}
		if (DoSub)
		{
			if (AsStringObj)
			{
				str := new MfString(ms.ToString(startIndex, Length), true)
				return str
			}
			return ms.ToString(startIndex, Length)
		}
		if (AsStringObj)
		{
			str := new MfString(ms.ToString(), true)
			return str
		}
		return ms.ToString()
	}
; 	End:ToString ;}
;{ 	__Delete
	; automatically called by AutoHotkey when class instance is destroyed
	; do a little clean up to release memory
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
					ms := new MfMemoryString(capacity - stringBuilder.m_ChunkOffset,, this.m_Encoding)
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
;{ 	_AppendString
/*
	_AppendString()
		Appends any MfObject or var to current instance
	Parameters:
		obj
			Object or var to add
	Returns:
		Returns current instance after append
	Throws:
		Throws MfArgumentOutOfRangeException if Adding obj goes beyond Max Capacity
	Remarks:
		Private Method
*/
	_AppendString(obj) {
		ms := MfMemoryString.FromAny(obj, this.m_Encoding)
		sLen := ms.m_CharCount
		if (sLen = 0)
		{
			ms := ""
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
; 	End:_AppendString ;}
	;{ 	_AppendHelper
	; msObj is MfMemoryString instance
/*
	_AppendHelper()
		Determines if current instance can append to current chunk or if expansion is needed
		and then appends the value of msObj
	Parameters:
		msObj
			MfMemoryString Instance
		valueCount
			The count in chars that is to be added
	Returns:
		Returns current instance
	Throws:
		Throws MfArgumentOutOfRangeException if Adding obj goes beyond Max Capacity
	Remarks:
		Private Method
*/
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
;{ 	_AppendChar
	; appends a char (character) to the end of the current instance repeatCount number of times
	; internal method
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
;{ 	_AppendCharCode
	; appends a char code (number) to the end of the current instance repeatCount number of times
	; internal method
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
		
		If (this.m_HasNullChar = false && MfMemStrView.IsIgnoreCharLatin1(charCode))
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
; 	End:_AppendCharCode ;}
;{ 	_AppendCharList
/*
	Method: _AppendCharList()

	_AppendCharList()
		Add a list of MfCharList to the current instance
	Parameters:
		lst
			The instance of MfCharList to add to the current instance
		startIndex
			The zero base Index to start reading form lst
		CharCount
			The number of Chars to add from lst to the current instance
	Returns:
		Returns current instance
	Throws:
		Throws MfArgumentOutOfRangeException, MfArgumentNullException
	Remarks:
		Private method
*/
	_AppendCharList(lst, startIndex, charCount) {
		if (startIndex < 0)
		{
			ex := new MfArgumentOutOfRangeException("startIndex", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_GenericPositive"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (charCount < 0)
		{
			ex := new MfArgumentOutOfRangeException("count", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_GenericPositive"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		If (MfNull.IsNull(lst) || lst.m_Count = 0)
		{
			if (startIndex = 0 && charCount = 0)
			{
				return this
			}
			ex := new MfArgumentNullException("lst")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		else
		{
			if (charCount > lst.m_Count - startIndex)
			{
				ex := new MfArgumentOutOfRangeException("count", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			if (charCount = 0)
			{
				return this
			}
			if (!(lst.m_Encoding = this.m_Encoding))
			{
				; different encodings add differently
				ms := new MfMemoryString(charCount + 1, , this.m_Encoding)
				ms.Append(lst.ToString(false, StartIndex, charCount))
				this._AppendString(ms)
				return this
			}
			StartIndex++
			i := 0
			a := lst.m_InnerList
			While (i < charCount)
			{
				this._AppendCharCode(a[StartIndex + i], 1)
				i++
			}
			return this
		}
	}
; 	End:_AppendCharList ;}
;{ 	_GetReplaceIndexsForChunk
/*
	_GetReplaceIndexsForChunk()
		Gets a MfListVar containing the index of all the replacements from
		smalet index to biggest index in a MfStringBuilder chunk
	Parameters:
		Chunk
			MfStringBuilder Chunk
		MsVal
			MfMemoryString instance that is the needle
		startIndex
			The index in the haystack to starch searhing in
		count
			Then number of chars to search
	Returns:
		Returns MfListVar instance containing all the found index values
	Remarks:
		Private method
*/
	_GetReplaceIndexsForChunk(Chunk, MsVal, startIndex, count) {
		; _startsWithMs(chunk, indexInChunk, count, MsValue) {
		replacements := new MfListVar()
		searchLen := MsVal.Length
		if (searchLen = 0)
		{
			return replacements
		}
		i := startIndex
		iCount := count
		while (i < iCount)
		{
			ix := this._startsWithMs(chunk, i, count, MsVal)
			if (ix >= 0)
			{
				replacements.Add(ix)
				i := ix + searchLen
			}
			Else
			{
				break
			}
		}
		return replacements
			
	}
; 	End:_GetReplaceIndexsForChunk ;}
;{ 	_GetCharFromChunk
	; Gets Char letter from mStr at index
	; mStr is instance of MfMemoryString
	; index is the integer positive number position of the index
	; private method
	_GetCharFromChunk(byref mStr, index) {
		return mStr.Char[index]
	}
; 	End:_GetCharFromChunk ;}
;{ 	_GetCharCodeFromChunk
	; Gets Char Number from mStr at index
	; mStr is instance of MfMemoryString
	; index is the integer positive number position of the index
	; private method
	_GetCharCodeFromChunk(byref mStr, index) {
		return mStr.CharCode[index]
	}
; 	End:_GetCharCodeFromChunk ;}
;{ 	_ExpandByABlock
	; Expands the current instance of MfStringBuilder by adding a new block
	; minBlockCharCount is the minimuim number of characters then new block will hold
	; private method
	_ExpandByABlock(minBlockCharCount) {
		if (minBlockCharCount + this.Length > this.m_MaxCapacity)
		{
			ex := new MfArgumentOutOfRangeException("requiredLength", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_SmallCapacity"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
		num := MfMath.Max(minBlockCharCount, MfMath.Min(this.Length, MfStringBuilder.DefaultCapacity))
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
		this.m_ChunkChars := new MfMemoryString(num,, this.m_Encoding)
		
		
	}
; 	End:_ExpandByABlock ;}
;{ _FindChunkForIndex
	; finds the chunk the contains the index
	; index - the Positive integer number of an index within the current instance Length
	; returns MfStringBuilder instance
	; Private method
	_FindChunkForIndex(index) {
		chunk := this
		while (chunk.m_ChunkOffset > index)
		{
			chunk := chunk.m_ChunkPrevious
		}
		return chunk
	}
; End:_FindChunkForIndex ;}

;{ _ConstructorParams
	; Gets the Parameters for the __new(args*) method
	; private Method
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
						if (i = 1)
						{
							if (cnt = 1 || cnt = 2)
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
								i++
								continue
							}
							if (cnt = 3)
							{
								p.AddInteger(arg)
								i++
								continue
							}
							p.AddString(arg)
							i++
							continue
						}
						if (i = 2)
						{
							; param 2 is always an int when not an MfObject
							result := new MfInteger(arg)
							p.Add(result)
							i++
							continue

						}
						if (i = 3)
						{
							if (cnt = 3 && MfNull.IsNull(arg))
							{
								p.Data.Add("_nullSb", true)
								i++
								continue
							}
							result := new MfInteger(arg)
							p.Add(result)
							i++
							continue
						}
						if (i = 4)
						{
							; param 4 is always an int when not an MfObject
							result := new MfInteger(arg)
							p.Add(result)
							i++
							continue
						}
						i++
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
;{ 	_AppendParams
	; Gets the parameters for the Append(args*) method
	; private method
	_AppendParams(MethodName, args*) {

		p := Null
		cnt := MfParams.GetArgCount(args*)

	
		if ((cnt > 0) && MfObject.IsObjInstance(args[1], MfParams))
		{
			p := args[1] ; arg 1 is a MfParams object so we will use it
			; can be up to five parameters
			; Two parameters is not a possibility
			if (p.Count > 3)
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
			if (cnt > 3)
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
						if (i = 1)
						{
							if (cnt = 2)
							{
								; when count is 2 must be char and repeat count
								p.Add(new MfChar(arg))
							}
							else
							{
								p.AddString(arg)
							}
							
						}
						if (i = 2)
						{
							
							p.AddInteger(arg)

						}
						if (i = 3)
						{
							p.AddInteger(arg)
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
; 	End:_AppendParams ;}
;{ 	_InsertParams
	; Gets the parameters for the Insert(args*) method
	; private method
	_InsertParams(MethodName, args*) {

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
						if (i = 2)
						{
							p.AddString(arg)			
						}
						else 
						{
							p.AddInteger(arg)
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
; 	End:_InsertParams ;}
;{ 	_InsertStrInt
	; Inserts one or more copies of a specified string into this instance at the specified character position.
	; index - zero based postive integer index withing the current instance
	; obj, Most any MfObject based object or var string or var number
	; count - the number of times to insert the object
	; MfObject instances are added by calling the ToString() method of the MfObject instance
	; Private Method
	_InsertObjInt(index, obj, count) {
		if (count < 0)
		{
			ex := new MfArgumentOutOfRangeException("count", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_NeedNonNegNum"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		mStr := MfMemoryString.FromAny(obj, this.m_Encoding)
		
		
		if (mStr.Length = 0 || count = 0)
		{
			return this
		}
		insertingChars := mStr.Length * count
		if (insertingChars > this.MaxCapacity - this.Length)
		{
			ex := new MfOutOfMemoryException()
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		chunk := ""
		indexInChunk := 0
		; index in the insert location within the entire instance
		; insertingChars is the length of the string to insert times the count
		this._MakeRoom(index, insertingChars, chunk, indexInChunk, false)
		
		while (count > 0)
		{
			this._ReplaceInPlaceAtChunk(chunk, indexInChunk, mStr, mStr.m_CharCount)
			count--
		}
	}
; 	End:_InsertStrInt ;}
;{ 	_MakeRoom
/*
	_MakeRoom()
		Makes room inside of string builder
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
	Remarks:
		Private Method
*/
	_MakeRoom(index, count, byRef chunk, ByRef indexInChunk, doneMoveFollowingChars) {
		; index in the insert location within the entire instance
		; copyCount1 is the length of the string to insert times the count
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
		BytesPerChar := MfStringBuilder.m_BytesPerChar
		indexInChunk := index - chunk.m_ChunkOffset ; grab the index within the current chunck
		if (!doneMoveFollowingChars && chunk.m_ChunkLength <= (MfStringBuilder.DefaultCapacity * 2) && chunk.m_ChunkChars.CharCapacity - chunk.m_ChunkLength >= count)
		{
			; Advance Position before calling MoveCharsRight
			chunk.m_ChunkChars.SetPosFromCharIndex(chunk.m_ChunkLength)
			;chunk.m_ChunkChars.MoveCharsRight(indexInChunk, Count, Count)
			chunk.m_ChunkChars.MoveCharsRight(indexInChunk, Count)
			
	
			chunk.m_ChunkLength += count
			chunk.m_ChunkChars.SetPosFromCharIndex(chunk.m_ChunkLength)
			return
		}
		Capacity := MfMath.Max(count, MfStringBuilder.DefaultCapacity)
		params := new MfParams()
		Params.AddInteger(Capacity)
		Params.AddInteger(chunk.m_MaxCapacity)
		If (MfNull.IsNull(chunk.m_ChunkPrevious))
		{
			params.Data.Add("_nullSb", true)
		}
		else
		{
			Params.Add(chunk.m_ChunkPrevious)
		}
		params.Data.Add("_InternalOnly", true)
		;newChunk := new MfStringBuilder(Capacity, chunk.m_MaxCapacity, chunk.m_ChunkPrevious)
		newChunk := new MfStringBuilder(Params)
		; the new newChunk will at least the capacity of the string to insert times then number of number of repeats to insert
		newChunk.m_ChunkLength := count
		; Copy the head of the buffer to the  new buffer. 
		copyCount1 := MfMath.Min(count, indexInChunk)
		
		if (copyCount1 > 0)
		{
			ptr := chunk.m_ChunkChars.BufferPtr
			BytesPerChar := MfStringBuilder.m_BytesPerChar
			MfMemoryString.CopyFromAddress(ptr, newChunk.m_ChunkChars, 0, copyCount1)
			
			;Slide characters in the current buffer over to make room. 
			copyCount2 := indexInChunk - copyCount1
			if (copyCount2 >= 0)
			{	
				;ptr := chunk.m_ChunkChars.BufferPtr
				MfMemoryString.CopyFromAddress(ptr + (copyCount1 * BytesPerChar), chunk.m_ChunkChars, 0, copyCount2)
				;chunk.m_ChunkLength := chunk.m_ChunkChars.Length
				indexInChunk := copyCount2
			}
		}
		newChunk.m_ChunkChars.SetPosFromCharIndex(newChunk.m_ChunkLength)
		;newChunk.m_ChunkLength := newChunk.m_ChunkChars.Length
		; chunk previous string builder will now become the current newChunk
		chunk.m_ChunkPrevious := newChunk
		chunk.m_ChunkOffset += count
		if (copyCount1 < count)
		{
			chunk := newChunk
			indexInChunk := copyCount1
		}
	}
; 	End:_MakeRoom ;}
;{ 	_Merge
	; merges current chunks of into a single chunk optionally adding capacity of ExtraCharCount
	; ExtraCharCount - Extra capacity in chars to add the the merged chunk
	; Merge is valuable in some method such as replace() where mergin a bunch of smaller chunks
	; can result in a much faster find and replace
	; Private method
	_Merge(ExtraCharCount=0) {
		if (this.Length = 0)
		{
			return ""
		}
		stringBuilder := this
		OutOfRange := true
		
		iLen := (this.Length + 1)
		ExtraCharCount := ExtraCharCount * MfStringBuilder.m_BytesPerChar
		ms := new MfMemoryString(iLen + ExtraCharCount,, this.m_Encoding)
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
		
		ms.m_MemView.Pos := (this.Length + 1) * this.m_BytesPerChar
		ms.m_CharCount := this.Length
		this.m_ChunkLength := ms.m_CharCount
		this.m_ChunkOffset := 0
		this.m_ChunkPrevious := ""
		this.m_ChunkChars := ""
		this.m_ChunkChars := ms
	}
; 	End:_Merge ;}
;{ 	_Next
	; chunk - MfStringBuilder instance
	; Gets then next chunk from chunk
	; return MfStringBuilder instance
	; Private Method
	 _Next(chunk) {
		if (this.Equals(chunk))
		{
			return Null
		}
		return this._FindChunkForIndex(chunk.m_ChunkOffset + chunk.m_ChunkLength)
	}
; 	End:_Next ;}
;{ 	_Remove
	; removes from an instance of MfStringBuilder
	; startIndex - int
	; count - int
	; chunk - MfStringBuilder
	; indexInChunk - int
	; Private Method
	_Remove(startIndex, count, ByRef chunk, ByRef indexInChunk) {
		endIndex := startIndex + count
		; Find the chunks for the start and end of the block to delete. 
		chunk := this
		endChunk := ""
		endIndexInChunk := 0

		loop
		{
			if (endIndex - chunk.m_ChunkOffset >= 0)
			{
				if (endChunk == "")
				{
					endChunk := chunk
					endIndexInChunk := endIndex - endChunk.m_ChunkOffset
				}
				if (startIndex - chunk.m_ChunkOffset >= 0)
				{
					break
				}
			}
			else
			{
				chunk.m_ChunkOffset -= count
			}
			chunk := chunk.m_ChunkPrevious
		}
		indexInChunk := startIndex - chunk.m_ChunkOffset
		copyTargetIndexInChunk := indexInChunk
		copyCount := endChunk.m_ChunkLength - endIndexInChunk
		if (endChunk.Equals(chunk) = false)
		{
			copyTargetIndexInChunk := 0
			;  Remove the characters after startIndex to end of the chunk
			chunk.m_ChunkLength := indexInChunk
			; set pos in MemoryString to reflect m_ChunkLength
			chunk.m_ChunkChars.SetPosFromCharIndex(chunk.m_ChunkLength)
			
			endChunk.m_ChunkPrevious := chunk
			endChunk.m_ChunkOffset := chunk.m_ChunkOffset + chunk.m_ChunkLength
			;  If the start is 0 then we can throw away the whole start chunk
			if (indexInChunk = 0)
			{
				endChunk.m_ChunkPrevious := chunk.m_ChunkPrevious
				chunk := endChunk
			}
		}
		endChunk.m_ChunkLength -= endIndexInChunk - copyTargetIndexInChunk
		
		
		; remove any characters in the end chunk, by sliding the characters down. 
		if (copyTargetIndexInChunk != endIndexInChunk) ; sometimes no move is necessary
		{
			MfMemoryString.CopyFromIndex(endChunk.m_ChunkChars, endIndexInChunk, endChunk.m_ChunkChars, copyTargetIndexInChunk, copyCount)
			;endChunk.m_ChunkChars.MoveCharsLeft(copyTargetIndexInChunk, endIndexInChunk, copyCount)
		}
		endChunk.m_ChunkChars.SetPosFromCharIndex(endChunk.m_ChunkLength)
		
	}
; 	End:_Remove ;}
;{ 	_Replace
	; helper method to find and replace string value within the current instance
	; MsOldVal - Instance of MfMemoryString of the value to find
	; MsNewVal - Instance of MfMemoryString of the value to replace
	; startIndex - then zero based index to start searching
	; count - the number of chars to limit the search to
	; Private method
	_Replace(byref MsOldVal, byref MsNewVal, startIndex, count) {
		replacements := new MfListVar() ; A list of replacement positions in a chunk to apply
		replacementsCount := 0
		; Find the chunk, indexInChunk for the starting point
		chunk := this._FindChunkForIndex(startIndex)
		indexInChunk := startIndex - chunk.m_ChunkOffset
		iPrev := -1
		searchLen := MsOldVal.m_CharCount
		iPrevIndexChunk := 0
		
		while (count > 0)
		{
			; The folowing commeted out block  was intended to do faster finding of index with chunks. For some reason
			; it was much slower on instances with longer length. It seeem the most effecient way is to exclude it for now
			; Anoter consideration is to get the indexs for current chunk in a seperate list as _GetReplaceIndexsForChunk method does
			; and then add those indexes to the current list.

			;if (iPrev != chunk.m_ChunkOffset && iPrev < -2) ; this line would ensure the entire block was bypassed
			;~ if (iPrev != chunk.m_ChunkOffset)
			;~ {
				;~ if (chunk.m_ChunkLength < searchLen)
				;~ {
					;~ iPrev := chunk.m_ChunkOffset
					;~ count++
					;~ indexInChunk--
				;~ }
				;~ else
				;~ {
					;~ ; only check once per chunk once all index are found
					;~ ; this section will search the entire chunk up to the
					;~ ; end minus the length of (MsOldVal - 1)
					;~ ; usint this _startsWithMs method seem to be about 20 percent faster than _StartsWith
					;~ ; _startsWithMs will not searc from the end of one chunk into the beginning of the next
					;~ ; this is why _startsWith is still included to pick up the oldvalues that cross chuncks
					;~ ix := this._startsWithMs(chunk, indexInChunk, count, MsOldVal)
					;~ if (ix >= 0)
					;~ {
						;~ if (MfNull.IsNull(replacements) || replacements.Count = 0)
						;~ {
							;~ replacements := new MfListVar(5)
						;~ }
						;~ else if (replacementsCount >= replacements.Count)
						;~ {
							;~ newArray := new MfListVar(replacements.Count * 3 // 2 + 4) ; grow by 1.5X but more in the begining
							;~ MfListbase.Copy(replacements, newArray, replacements.Count)
							;~ replacements := newArray
						;~ }
						;~ replacements.Item[replacementsCount++] := ix
						;~ indexInChunk += ix + searchLen
						
						;~ cntAdjust := iPrevIndexChunk > 0 ? iPrevIndexChunk + (ix - searchLen):  (ix + searchLen)
						;~ if (iPrevIndexChunk > 0)
						;~ {
							;~ count += iPrevIndexChunk - (ix + searchLen)
						;~ }
						;~ Else
						;~ {
							;~ count -=  (ix + searchLen)
						;~ }
						
						;~ iPrevIndexChunk := indexInChunk
					;~ }
					;~ else
					;~ {
						;~ ; if there is not match or out of matches for chunk then
						;~ ; set value to one less then the chunk length to search the rest of the chars
						;~ ; posssibly into the next chunk
						;~ iPrev := chunk.m_ChunkOffset
						;~ count -= (chunk.m_ChunkLength - (searchLen - 1))
						;~ indexInChunk :=  (chunk.m_ChunkLength - (searchLen - 1))
					;~ }

				;~ }
			;~ }
			;~ else if (this._StartsWith(chunk, indexInChunk, count, MsOldVal)) ; Look for a match in the chunk,indexInChunk pointer
			if (this._StartsWith(chunk, indexInChunk, count, MsOldVal)) ; Look for a match in the chunk,indexInChunk pointer
			{
				; Push it on my replacements array (with growth), we will do all replacements in a
				; given chunk in one operation below (see ReplaceAllInChunk) so we don't have to slide
				; many times.
				if (MfNull.IsNull(replacements) || replacements.Count = 0)
				{
					replacements := new MfListVar(5)
				}
				else if (replacementsCount >= replacements.Count)
				{
					newArray := new MfListVar(replacements.Count * 3 // 2 + 4) ; grow by 1.5X but more in the begining
					MfListbase.Copy(replacements, newArray, replacements.Count)
					replacements := newArray
				}
				replacements.Item[replacementsCount++] := indexInChunk
				;OutputDebug % "Replacement Count: " . replacementsCount . " Index: " . indexInChunk
				OutputDebug % "2: Before count:" . count . " indexInChunk: " . indexInChunk
				indexInChunk += searchLen
				count -= searchLen
				OutputDebug % "2: After  count:" . count . " indexInChunk: " . indexInChunk

			}
			else
			{
				indexInChunk++
				--count
			}
			if (indexInChunk >= chunk.m_ChunkLength || count = 0) ; Have we moved out of the current chunk
			{
				; Replacing mutates the blocks, so we need to convert to logical index and back afterward. 
				index := indexInChunk + chunk.m_ChunkOffset
				indexBeforeAdjustment := index

				; See if we accumulated any replacements, if so apply them 
				this._ReplaceAllInChunk(replacements, replacementsCount, chunk, MsOldVal.m_CharCount, MsNewVal)
				; The replacement has affected the logical index.  Adjust it.  
				index += ((MsNewVal.m_CharCount - MsOldVal.m_CharCount) * replacementsCount)
				replacementsCount := 0

				chunk := this._FindChunkForIndex(index)
				indexInChunk := index - chunk.m_ChunkOffset
			}
		}
	}
; 	End:_Replace ;}
;{ 	_ReplaceAllInChunk
/*
 *	'replacements' is a MfListVar list of index (relative to the begining of the 'chunk' to remove
 *	'removeCount' characters and replace them with 'value'.   This routine does all those 
 *	replacements in bulk (and therefore very efficiently. 
 *	with the string 'value'.
 *	'sourceChunk' is instance of MfStringBuilder
 *	'Value' is instance of MfMemoryString
 *	Private Method
*/
	_ReplaceAllInChunk(replacements, replacementsCount, sourceChunk, removeCount, value) {
		if (replacementsCount <= 0)
		{
			return
		}

		delta := (value.m_CharCount - removeCount) * replacementsCount
		targetChunk := sourceChunk ; the target as we copy chars down
		targetIndexInChunk := replacements.Item[0]

		; Make the room needed for all the new characters if needed. 
		if (delta > 0)
		{
			this._MakeRoom(targetChunk.m_ChunkOffset + targetIndexInChunk, delta, targetChunk, targetIndexInChunk, true)
		}
		i := 0
		Loop
		{
			; Copy in the new string for the ith replacement
			this._ReplaceInPlaceAtChunk(targetChunk, targetIndexInChunk, value, value.m_CharCount)
			gapStart := replacements.Item[i] + removeCount
			i++
			if (i >= replacementsCount)
			{
				;targetChunk.m_ChunkChars.SetPosFromCharIndex(targetChunk.m_ChunkLength)
				break
			}
			gapEnd := replacements.Item[i]
			if (delta != 0) ; can skip the sliding of gaps if source an target string are the same size.
			{
				subValue := sourceChunk.m_ChunkChars.SubString(gapStart)
				this._ReplaceInPlaceAtChunk(targetChunk, targetIndexInChunk, subValue, gapEnd - gapStart)
			}
			else
			{
				targetIndexInChunk += gapEnd - gapStart
			}
		}
		if (delta < 0)
		{
			; flip delta to remove
			this._Remove(targetChunk.m_ChunkOffset + targetIndexInChunk, Abs(delta), targetChunk, targetIndexInChunk)
		}
	}
; 	End:_ReplaceAllInChunk ;}
;{ 	_ReplaceInPlaceAtChunk
/*
 *	ReplaceInPlaceAtChunk is the logical equivalent of 'memcpy'.  Given a chunk and an index in
 *	that chunk, it copies in 'count' characters from 'value' and updates 'chunk, and indexInChunk to 
 *	point at the end of the characters just copyied (thus you can splice in strings from multiple 
 *	places by calling this mulitple times.  
 *	chunk - StringBuilder
 *	indexInChunk - positive zero based integer of index
 *	value - instance of MfMemoryString to replace
 *	count - integer count of the lendh of value
 *	Private Method
*/
	_ReplaceInPlaceAtChunk(ByRef chunk, ByRef indexInChunk, value, count) {
		; first pass chunk.m_ChunkChars inserts at index 3 the first 8 chars of value
		
		if (count != 0)
		{
			ptr := Value.BufferPtr
			BytesPerChar := MfStringBuilder.m_BytesPerChar
			loop
			{
				lengthInChunk := chunk.m_ChunkLength - indexInChunk
				lengthToCopy := MfMath.Min(lengthInChunk, count)
				
				MfMemoryString.CopyFromAddress(ptr, chunk.m_ChunkChars, indexInChunk, lengthToCopy)
				
				; Advance the index.
				indexInChunk += lengthToCopy
				if (indexInChunk >= chunk.m_ChunkLength)
				{
					chunk := this._Next(chunk)
					indexInChunk := 0
				}
				count -= lengthToCopy
				if (count = 0)
				{
					break
				}
				ptr += (lengthToCopy * BytesPerChar)
			}
		}
	}
	
; 	End:_ReplaceInPlaceAtChunk ;}
;{ 	_StartsWith
	; Returns true if the string that is starts at 'chunk' and 'indexInChunk, and has a logical
	; length of 'count' starts with the string 'value'. 
	; chunk - instance of MfStringBuilder
	; indexInChunk - The zero based positive index within the chunk to start the search
	; count - the number of chars to limit the search to
	; MsValue - instance of MfMemoryString to search for
	; This method will span from the end of one chunk to the start of the next chunk and
	; therefore is suitalbe for searching when there is more then one chunk in the current instance.
	; Private Method
	_StartsWith(chunk, indexInChunk, count, MsValue) {
		if (count = 0)
		{
			return false
		}
		PtrA := chunk.m_ChunkChars.BufferPtr
		PtrB := MsValue.BufferPtr
		BytesPerChar := chunk.m_ChunkChars.m_BytesPerChar
		sType := chunk.m_ChunkChars.m_sType
		len := MsValue.Length ; * BytesPerChar
		indexInChunk := indexInChunk ; * BytesPerChar
		i := 0
		While (i < len)
		{
			if (count = 0)
			{
				return false
			}
			if (indexInChunk >= chunk.m_ChunkLength) 
			{
				chunk := this._Next(chunk)
				if (MfNull.IsNull(chunk))
				{
					return false
				}
				indexInChunk := 0
				PtrA := chunk.m_ChunkChars.BufferPtr
			}

			; See if there no match, break out of the inner for loop
			numA := NumGet(ptrA + 0, indexInChunk * BytesPerChar, sType)
			numB := NumGet(ptrB + 0, i * BytesPerChar, sType)
			
			if (numA != numB)
			{
				return false
			}
			indexInChunk++
			--count
			i++
		}
		return true
	}
; 	End:_StartsWith ;}
;{ 	_startsWithMs
	; Returns found index if the string that is starts at 'chunk' and 'indexInChunk, and has a logical
	; length of 'count' starts with the string 'value'. 
	; chunk - instance of MfStringBuilder
	; indexInChunk - The zero based positive index within the chunk to start the search
	; count - the number of chars to limit the search to
	; MsValue - instance of MfMemoryString to search for
	; This method will NOT span chunks and
	; therefore is NOT suitalbe for searching when there is more then one chunk in the current instance.
	; Method is faster for searching single chunk instances of MfStringBuilder then _StartsWith() because
	; the MfMemoryString.IndexOf() uses a machine code base search to locate the index.
	; Private Method
	_startsWithMs(chunk, indexInChunk, count, MsValue) {
		if (count = 0)
		{
			return -1
		}
		index := chunk.m_ChunkChars.IndexOf(MsValue,indexInChunk)
		return index
	}
; 	End:_startsWithMs ;}
;{ 	_SetChar
	; Sets char letter at index for given sb
	; sb is instance of MfStringBuilder
	; index is the integer positive number position of the index
	; value is the value as single character of string
	; Private method
	_SetChar(ByRef sb, index, value) {
		sb.m_ChunkChars.Char[index] := value
	}
; 	End:_SetChar ;}
;{ 	_SetCharFromChunk
	; Sets char letter at index for given mStr
	; mStr is instance of MfMemoryString
	; index is the integer positive number position of the index
	; value is the value as single character of string
	; Private method
	_SetCharFromChunk(byref mStr, index, value) {
		mStr.Char[index] := value
	}
; 	End:_SetCharFromChunk ;}
;{ 	_ToMemoryString
	; gets a MfMemoryString Instance representing the current string value
	; If current length is less then MaxChunkSize then merge will be called
	; if only one chunk then that chunk MfMemoryString instance is returned
	; otherwise a new MfMemoryString intance is returned from ToString() method
	_ToMemoryString() {
		if (this.m_ChunkOffset > 0 && this.Length < this.MaxChunkSize)
		{
			this._Merge()
		}
		if (this.m_ChunkOffset > 0)
		{
			str := this.ToString()
			ms := new MfMemoryString(str, , this.m_Encoding)
			return ms
		}
		return this.m_ChunkChars
	}
; 	End:_ToMemoryString ;}
;{ 	Constructor Helpers
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
		
		this.m_ChunkChars := new MfMemoryString(capacity,,this.m_Encoding)
		if (length < ms.Length || startIndex > 0)
		{
			this.m_ChunkChars.Append(ms.Substring(startIndex, length))
		}
		else
		{
			this.m_ChunkChars.Append(ms)
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
	_newIntIntSb(size, maxCapacity, previousBlock="") {
		size := MfInteger.GetValue(size)
		maxCapacity := MfInteger.GetValue(maxCapacity)
		this.m_ChunkChars := ""
		this.m_ChunkChars := new MfMemoryString(size,,this.m_Encoding)
		this.m_MaxCapacity := maxCapacity
		this.m_ChunkPrevious := previousBlock
		if (MfNull.IsNull(previousBlock) = false)
		{
			this.m_ChunkOffset := previousBlock.m_ChunkOffset + previousBlock.m_ChunkLength
			this.m_HasNullChar := previousBlock.m_HasNullChar
		}
	}
; 	End:Constructor Helpers ;}
; 	End:Internal Methods ;}
}