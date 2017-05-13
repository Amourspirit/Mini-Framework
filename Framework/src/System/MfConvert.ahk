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
class MfConvert extends MfObject
{
;{ Methods
;{ 	ToBoolean
	ToBoolean(obj, ReturnAsObject = false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		ObjCheck := MfConvert._IsNotMfObj(obj)
		if (ObjCheck)
		{
			ObjCheck.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ObjCheck
		}
		_ReturnAsObject := MfBool.GetValue(ReturnAsObject, false)
		
		
		T := new MfType(obj)
		if (T.IsIntegerNumber)
		{
			return MfConvert._RetrunAsObjBool(obj.GreaterThen(0), _ReturnAsObject)

		}
		else if (t.IsFloat)
		{
			return MfConvert._RetrunAsObjBool(obj.GreaterThen(0.0), _ReturnAsObject)
		}
		else if (t.IsBoolean)
		{
			if (_ReturnAsObject)
			{
				return obj
			}
			return obj.Value
		}
		else if (t.IsUInt64)
		{
			return MfConvert._RetrunAsObjBool(obj.GreaterThen(0), _ReturnAsObject)
		}
		else if (t.IsBigInt)
		{
			return MfConvert._RetrunAsObjBool(obj.GreaterThen(0), _ReturnAsObject)
		}
		else if (t.IsString)
		{
			if (MfString.IsNullOrEmpty(obj))
			{
				return MfConvert._RetrunAsObjBool(false, _ReturnAsObject)
			}
			bVal := MfBool.GetValue(obj, false)
			return MfConvert._RetrunAsObjBool(bVal, _ReturnAsObject)
		}
		
		ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", A_ThisFunc))
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
; 	End:ToBoolean ;}
;{ 	ToByte
	ToByte(obj, ReturnAsObject = false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		ObjCheck := MfConvert._IsNotMfObj(obj)
		if (ObjCheck)
		{
			ObjCheck.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ObjCheck
		}
		_ReturnAsObject := MfBool.GetValue(ReturnAsObject, false)
		
		
		T := new MfType(obj)
		if (T.IsIntegerNumber)
		{
			if ((obj.Value < MfByte.MinValue) || (obj.Value > MfByte.MaxValue))
			{
				ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_Byte"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			return MfConvert._RetrunAsObjByte(obj.Value, _ReturnAsObject)

		}
		else if (t.IsFloat)
		{
			return MfConvert.ToByte(MfConvert.ToInt32(obj, true), _ReturnAsObject)
		}
		else if (t.IsBoolean)
		{
			if (obj.Value = true)
			{
				return MfConvert._RetrunAsObjByte(1, _ReturnAsObject)
			}
			return MfConvert._RetrunAsObjByte(0, _ReturnAsObject)
		}
		else if (t.IsUInt64)
		{
			if ((obj.LessThen(MfByte.MinValue)) || (obj.GreaterThen(MfByte.MaxValue)))
			{
				ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_Byte"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			return MfConvert._RetrunAsObjByte(obj.Value + 0, _ReturnAsObject)
		}
		else if (t.IsBigInt)
		{
			if ((obj.LessThen(MfByte.MinValue)) || (obj.GreaterThen(MfByte.MaxValue)))
			{
				ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_Byte"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			return MfConvert._RetrunAsObjByte(obj.Value + 0, _ReturnAsObject)
		}
		else if (t.IsString)
		{
			if (MfString.IsNullOrEmpty(obj))
			{
				return MfConvert._RetrunAsObjByte(0, _ReturnAsObject)
			}
			Val := MfByte.Parse(obj.Value)
			return MfConvert._RetrunAsObjByte(Val, _ReturnAsObject)
		}

		ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", A_ThisFunc))
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
; 	End:ToByte ;}
	ToChar(obj, ReturnAsObject = false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		ObjCheck := MfConvert._IsNotMfObj(obj)
		if (ObjCheck)
		{
			ObjCheck.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ObjCheck
		}
		_ReturnAsObject := MfBool.GetValue(ReturnAsObject, false)
		if (MfObject.IsObjInstance(obj, MfByte))
		{
			value := new MfChar()
			value.CharCode := obj.Value
			if (_ReturnAsObject)
			{
				return value
			}
			return value.Value
		}
		if (MfObject.IsObjInstance(obj, MfChar))
		{
			if (_ReturnAsObject)
			{
				return obj
			}
			return obj.Value
		}
		
		if (MfObject.IsObjInstance(obj, MfInt16))
		{
			if (obj.Value < 0)
			{
				ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_Char"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			value := new MfChar()
			value.CharCode := obj.Value
			if (_ReturnAsObject)
			{
				return value
			}
			return value.Value
		}
		if (MfObject.IsObjInstance(obj, MfInteger) || MfObject.IsObjInstance(obj, MfInt64))
		{
			if (obj.Value < 0 || obj.Value > 65535)
			{
				ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_Char"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			value := new MfChar()
			value.CharCode := obj.Value
			if (_ReturnAsObject)
			{
				return value
			}
			return value.Value
		}
		if (MfObject.IsObjInstance(obj, MfUInt64) || MfObject.IsObjInstance(obj, MfBigInt))
		{
			if (obj.LessThen(0)  || obj.GreaterThen(65535))
			{
				ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_Char"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			value := new MfChar()
			value.CharCode := obj.Value + 0
			if (_ReturnAsObject)
			{
				return value
			}
			return value.Value
		}
		if (MfObject.IsObjInstance(obj, MfString))
		{
			if (obj.Length != 1)
			{
				ex := new MfFormatException(MfEnvironment.Instance.GetResourceString("Format_NeedSingleChar"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			value := new MfChar(obj.Value)
			if (_ReturnAsObject)
			{
				return value
			}
			return value.Value
		}
		if (MfObject.IsObjInstance(obj, MfBool) = true)
		{
			ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_FromTo", "Boolean", "Char"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (MfObject.IsObjInstance(obj, MfFloat) = true)
		{
			ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_FromTo", "Float", "Char"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", A_ThisFunc))
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex

	}
;{ 	ToInt16
	ToInt16(obj, ReturnAsObject = false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		ObjCheck := MfConvert._IsNotMfObj(obj)
		if (ObjCheck)
		{
			ObjCheck.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ObjCheck
		}
		_ReturnAsObject := MfBool.GetValue(ReturnAsObject, false)
		
		T := new MfType(obj)
		if (T.IsIntegerNumber)
		{
			if ((obj.Value < MfInt16.MinValue) || (obj.Value > MfInt16.MaxValue))
			{
				ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_Int32"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			if (_ReturnAsObject = false)
			{
				return obj.Value
			}
			return new MfInt16(obj.Value)
			

		}
		else if (t.IsFloat)
		{
			int32 := MfConvert.ToInt32(obj, true)
			return MfConvert.ToInt16(int32, ReturnAsObject)
		}
		else if (t.IsBoolean)
		{
			i := 0
			if (obj.Value = true)
			{
				i := 1
			}
			if (_ReturnAsObject)
			{
				return new MfInt16(i)
			}
			return i
		}
		else if (t.IsUInt64)
		{
			if (obj.GreaterThen(MfInt16.MaxValue))
			{
				ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_Int32"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			if (_ReturnAsObject = false)
			{
				return obj.Value + 0
			}
			return new MfInt16(obj.Value + 0)
		}
		else if (t.IsBigInt)
		{
			if (obj.LessThen(MfInt16.MinValue) || obj.GreaterThen(MfInt16.MaxValue))
			{
				ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_Int32"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			if (_ReturnAsObject = false)
			{
				return obj.Value + 0
			}
			return new MfInt16(obj.Value + 0)
		}
		else if (t.IsString)
		{
			if (MfString.IsNullOrEmpty(obj))
			{
				return MfConvert._RetrunAsObjInt32(false, _ReturnAsObject)
			}
			i := MfInt16.Parse(obj)
			if (_ReturnAsObject = false)
			{
				return i.Value 
			}
			return i
		}
		
		ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", A_ThisFunc))
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
; 	End:ToInt16 ;}
;{ 	ToInt32
	ToInt32(obj, ReturnAsObject = false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		ObjCheck := MfConvert._IsNotMfObj(obj)
		if (ObjCheck)
		{
			ObjCheck.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ObjCheck
		}
		_ReturnAsObject := MfBool.GetValue(ReturnAsObject, false)
		
		T := new MfType(obj)
		if (T.IsIntegerNumber)
		{
			if ((obj.Value < MfInteger.MinValue) || (obj.Value > MfInteger.MaxValue))
			{
				ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_Int32"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			return MfConvert._RetrunAsObjInt32(obj.Value, _ReturnAsObject)

		}
		else if (t.IsFloat)
		{
			tFloat := new MfFloat(obj.Value,,,obj.Format)
			if (tFloat.GreaterThenOrEqual(0.0))
			{
				if (tFloat.LessThen(2147483647.5))
				{
					i := Floor(obj.Value)
					tFloat.Subtract(i)
					if ((tFloat.GreaterThen(0.5)) || ((tFloat.Equals(0.5)) && (i & 1) != 0))
					{
						i++
					}
					return MfConvert._RetrunAsObjInt32(i, _ReturnAsObject)
				}
			}
			else if (tFloat.GreaterThen(-2147483648.5))
			{
				i := Ceil(tFloat.Value)
				tFloat.Subtract(i)
				if ((tFloat.LessThen(-0.5)) || ((tFloat.Equals(-0.5)) && (i & 1) != 0))
				{
					i--
				}
				return MfConvert._RetrunAsObjInt32(i, _ReturnAsObject)
			}
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_Int32"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		else if (t.IsBoolean)
		{
			i := 0
			if (obj.Value = true)
			{
				i := 1
			}
			if (_ReturnAsObject)
			{
				return new MfInteger(i, true)
			}
			return i
		}
		else if (t.IsUInt64)
		{
			if (obj.GreaterThen(MfInteger.MaxValue))
			{
				ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_Int32"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			i := obj.Value + 0
			return MfConvert._RetrunAsObjInt32(i, _ReturnAsObject)
		}
		else if (t.IsBigInt)
		{
			if (obj.LessThen(MfInteger.MinValue) || obj.GreaterThen(MfInteger.MaxValue))
			{
				ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_Int32"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			if (_ReturnAsObject = false)
			{
				return obj.Value + 0
			}
			return new MfInteger(obj.Value + 0)
		}
		else if (t.IsString)
		{
			if (MfString.IsNullOrEmpty(obj))
			{
				return MfConvert._RetrunAsObjInt32(false, _ReturnAsObject)
			}
			i := MfInteger.Parse(obj)
			return MfConvert._RetrunAsObjInt32(i, _ReturnAsObject)
		}
		
		ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", A_ThisFunc))
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
; 	End:ToInt32 ;}
;{ ToInt64
	ToInt64(obj, ReturnAsObject = false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		ObjCheck := MfConvert._IsNotMfObj(obj)
		if (ObjCheck)
		{
			ObjCheck.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ObjCheck
		}
		_ReturnAsObject := MfBool.GetValue(ReturnAsObject, false)
		
		T := new MfType(obj)
		if (T.IsIntegerNumber)
		{
			if ((obj.Value < MfInt64.MinValue) || (obj.Value > MfInt64.MaxValue))
			{
				ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_Int64"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			return MfConvert._RetrunAsObjInt64(obj.Value, _ReturnAsObject)

		}
		else if (t.IsFloat)
		{
			wf := Mfunc.SetFormat(MfSetFormatNumberType.Instance.FloatFast, obj.Format)
			try
			{
				int := MfConvert._FloatToInt64(obj.Value)
				if (_ReturnAsObject)
				{
					return new new MfInt64(int, true)
				}
			}
			catch e
			{
				throw e
			}
			finally
			{
				 Mfunc.SetFormat(MfSetFormatNumberType.Instance.FloatFast, wf)
			}
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_Int64"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		else if (t.IsBoolean)
		{
			i := 0
			if (obj.Value = true)
			{
				i := 1
			}
			if (_ReturnAsObject)
			{
				return new MfInt64(i)
			}
			return i
		}
		else if (t.IsUInt64)
		{
			if (obj.GreaterThen(MfInt64.MaxValue))
			{
				ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_Int64"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			i := obj.Value + 0
			return MfConvert._RetrunAsObjInt64(i, _ReturnAsObject)
		}
		else if (t.IsBigInt)
		{
			if (obj.LessThen(MfInt64.MaxValue) || obj.GreaterThen(MfInt64.MaxValue))
			{
				ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_Int64"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			i := obj.Value + 0
			return MfConvert._RetrunAsObjInt64(i, _ReturnAsObject)
		}
		else if (t.IsString)
		{
			if (MfString.IsNullOrEmpty(obj))
			{
				return MfConvert._RetrunAsObjInt64(0, _ReturnAsObject)
			}
			i := MfInt64.Parse(obj)
			return MfConvert._RetrunAsObjInt64(i, _ReturnAsObject)
		}
		
		ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", A_ThisFunc))
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
; End:ToInt64 ;}
;{ 	ToUInt64
	ToUInt64(obj, ReturnAsObject = false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		ObjCheck := MfConvert._IsNotMfObj(obj)
		if (ObjCheck)
		{
			ObjCheck.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ObjCheck
		}
		_ReturnAsObject := MfBool.GetValue(ReturnAsObject, false)
		
		T := new MfType(obj)
		if (T.IsIntegerNumber)
		{
			if ((obj.Value < 0))
			{
				ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_UInt64"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			if (_ReturnAsObject = false)
			{
				return obj.Value
			}
			return new MfUInt64(obj)

		}
		else if (t.IsFloat)
		{
			int64 := MfConvert.ToInt64(obj, true)
			if ((int64.Value < 0))
			{
				ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_UInt64"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			if (_ReturnAsObject = false)
			{
				return int64.Value
			}
			return new MfUInt64(int64)
		}
		else if (t.IsBoolean)
		{
			i := 0
			if (obj.Value = true)
			{
				i := 1
			}
			if (_ReturnAsObject)
			{
				return new MfUInt64(i)
			}
			return i
		}
		else if (t.IsUInt64)
		{
			if (obj.GreaterThen(MfInt64.MaxValue))
			{
				ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_UInt64"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			if (_ReturnAsObject)
			{
				return obj
			}
			return := obj.Value
		}
		else if (t.IsBigInt)
		{
			if (obj.LessThen(0) || obj.GreaterThen(MfUInt64.MaxValue))
			{
				ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_UInt64"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			if (_ReturnAsObject)
			{
				return new MfUInt64(obj)
			}
			return obj.Value
		}
		else if (t.IsString)
		{
			bigx := MfBigInt.Parse(obj)
			return MfConvert.ToUInt64(bigx, _ReturnAsObject)
		}
		
		ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", A_ThisFunc))
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
;{ 	ToUInt64

	ToString(obj) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfObject.IsObjInstance(obj, MfBool))
		{
			return obj.ToString()
		}
		If (IsObject(obj))
		{
			return ""
		}
		return obj
		
	}
; End:Methods ;}
;{ Internal Methods
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
;{ 	_RetrunAsObjBool
	_RetrunAsObjBool(Value, AsObj) {
		if (AsObj)
		{
			return new MfBool(Value)
		}
		return Value
	}
; 	End:_RetrunAsObjBool ;}
;{ 	_RetrunAsObjByte
	_RetrunAsObjByte(Value, AsObj) {
		if (AsObj)
		{
			return new MfByte(Value)
		}
		return Value
	}
; 	End:_RetrunAsObjByte ;}
;{ 	_RetrunAsObjInt32
	_RetrunAsObjInt32(Value, AsObj) {
		if (AsObj)
		{
			return new MfInteger(Value)
		}
		return Value
	}
; 	End:_RetrunAsObjInt32 ;}
;{ 	_RetrunAsObjInt64
	_RetrunAsObjInt64(Value, AsObj) {
		if (AsObj)
		{
			return new MfInt64(Value)
		}
		return Value
	}
; 	End:_RetrunAsObjInt64 ;}
;{ 	_RetrunAsObjUInt64
	_RetrunAsObjUInt64(Value, AsObj) {
		if (AsObj)
		{
			return new MfUInt64(Value)
		}
		return Value
	}
; 	End:_RetrunAsObjUInt64 ;}
;{ 	_ByteToSByte
	_SByteToByte(InputNum) {
		VarSetCapacity(var, 2)
		NumPut(InputNum,var,"CHAR")
		num := NumGet(var,,"UCHAR")
		VarSetCapacity(var, 0)
		return num
	}
; 	End:_ByteToSByte ;}
;{ 	_ByteToSByte
	_ByteToSByte(InputNum) {
		VarSetCapacity(var, 2)
		NumPut(InputNum,var,"UCHAR")
		num := NumGet(var,,"CHAR")
		VarSetCapacity(var, 0)
		return num
	}
; 	End:_ByteToSByte ;}
;{ 	_UInt32ToInt32
	_UInt32ToInt32(InputNum) {
		VarSetCapacity(var, 4)
		NumPut(InputNum,var,"UInt")
		num := NumGet(var,,"Int")
		VarSetCapacity(var, 0)
		return num
	}
; 	End:_UInt32ToInt32 ;}
;{ 	_UInt16ToInt16
	_UInt16ToInt16(InputNum) {
		VarSetCapacity(var, 4)
		NumPut(InputNum,var,"UShort")
		num := NumGet(var,,"Short")
		VarSetCapacity(var, 0)
		return num
	}
; 	End:_UInt16ToInt16 ;}
;{ 	_Int16ToUInt16
	_Int16ToUInt16(InputNum) {
		VarSetCapacity(var, 4)
		NumPut(InputNum,var,"Short")
		num := NumGet(var,,"UShort")
		VarSetCapacity(var, 0)
		return num
	}
; 	End:_Int16ToUInt16 ;}
	_Int64ToUInt32(inputNum) {
		VarSetCapacity(Var, 8, 0)       ; Variable to hold integer
		NumPut(inputNum, Var, 0, "Int64" ) ; Input as Integer 64
		retval := NumGet(Var, 0, "UInt32") ; Retrieve it as 'Un-Signed Integer 32'
		VarSetCapacity(Var, 0) 
		return retval
	}
	_Int64ToInt32(inputNum) {
		VarSetCapacity(Var, 8, 0)       ; Variable to hold integer
		NumPut(inputNum, Var, 0, "Int64" ) ; Input as Integer 64
		retval := NumGet(Var, 0, "Int32") ; Retrieve it as 'Signed Integer 32'
		VarSetCapacity(Var, 0) 
		return retval
	}
	_Int64ToInt16(inputNum) {
		VarSetCapacity(Var, 8, 0)       ; Variable to hold integer
		NumPut(inputNum, Var, 0, "Int64" ) ; Input as Integer 64
		retval := NumGet(Var, 0, "Short") ; Retrieve it as 'Signed Integer 16'
		VarSetCapacity(Var, 0) 
		return retval
	}
	_Int64ToUInt16(inputNum) {
		VarSetCapacity(Var, 8, 0)       ; Variable to hold integer
		NumPut(inputNum, Var, 0, "Int64" ) ; Input as Integer 64
		retval := NumGet(Var, 0, "UShort") ; Retrieve it as 'Un-Signed Integer 16'
		VarSetCapacity(Var, 0) 
		return retval
	}
	_Int64ToByte(inputNum) {
		VarSetCapacity(Var, 8, 0)       ; Variable to hold integer
		NumPut(inputNum, Var, 0, "Int64" ) ; Input as Integer 64
		retval := NumGet(Var, 0, "UChar") ; Retrieve it as 'Signed Integer 32'
		VarSetCapacity(Var, 0) 
		return retval
	}
	_Int64ToSByte(inputNum) {
		VarSetCapacity(Var, 8, 0)       ; Variable to hold integer
		NumPut(inputNum, Var, 0, "Int64" ) ; Input as Integer 64
		retval := NumGet(Var, 0, "Char") ; Retrieve it as 'Signed Integer Byte'
		VarSetCapacity(Var, 0) 
		return retval
	}
	;{ _DoubleToInt64()
/*
	Method: _DoubleToInt64()
		Converts Double into Int64
	parameters
		input
			The Double var to convert to Int64 var
	Returns
		Int64 signed var
	Remarks
		Internal Method
		Static method
*/
	_DoubleToInt64(inputNum) {
	    VarSetCapacity(Var, 8, 0)       ; Variable to hold integer
	    NumPut(inputNum, Var, 0, "Double" ) ; Input as Integer 64
	    retval := NumGet(Var, 0, "Int64") ; Retrieve it as 'Signed Integer 64'
	    VarSetCapacity(var, 0)
	    return retval
	}
; End:_DoubleToInt64() ;}
; End:Internal Methods ;}
}