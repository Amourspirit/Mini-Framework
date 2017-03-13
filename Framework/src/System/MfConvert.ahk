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
				return new MfInteger(i)
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
				i := Round(obj.Value)
				return MfConvert._RetrunAsObjInt64(i, _ReturnAsObject)
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
				return new MfInteger(i)
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
; End:Internal Methods ;}
}