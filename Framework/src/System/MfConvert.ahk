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
			return MfConvert._RetrunAsObjBool(Val, _ReturnAsObject)
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
			if (obj.GreaterThenOrEqual(0.0))
			{
				if (obj.LessThen(2147483647.5))
				{
					int num = (int)value;
					double num2 = value - (double)num;
					if (num2 > 0.5 || (num2 == 0.5 && (num & 1) != 0))
					{
						num++;
					}
					return num;
				}
			}
			else if (obj.GreaterThen(-2147483648.5))
			{
				int num3 = (int)value;
				double num4 = value - (double)num3;
				if (num4 < -0.5 || (num4 == -0.5 && (num3 & 1) != 0))
				{
					num3--;
				}
				return num3;
			}
			throw new OverflowException(Environment.GetResourceString("Overflow_Int32"));
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
			return MfConvert._RetrunAsObjInt32(obj.GreaterThen(0), _ReturnAsObject)
		}
		else if (t.IsString)
		{
			if (MfString.IsNullOrEmpty(obj))
			{
				return MfConvert._RetrunAsObjInt32(false, _ReturnAsObject)
			}
			bVal := MfBool.GetValue(obj, false)
			return MfConvert._RetrunAsObjInt32(bVal, _ReturnAsObject)
		}
		
		ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", A_ThisFunc))
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
; 	End:ToInt32 ;}
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
;{ 	_RetrunAsObjByte
	_RetrunAsObjInt32(Value, AsObj) {
		if (AsObj)
		{
			return new MfInteger(Value)
		}
		return Value
	}
; 	End:_RetrunAsObjByte ;}
; End:Internal Methods ;}
}