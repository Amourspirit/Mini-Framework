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
class MfNumber extends MfObject
{
;{ 	MfNumber.NumberBuffer Class
	class NumberBuffer
	{
		static NumberBufferBytes := 114 + A_PtrSize
		precision := 0
		scale := 0
		sign := false
		baseAddress := ""

		__new(stackBuffer) {
			; stackBuffer is the memory addres to array of bytes created via VarSetCapacity
			this.baseAddress := stackBuffer
			VarSetCapacity(this.baseAddress, 8,0)
			NumPut(stackBuffer, this.baseAddress,0, "UChar")
			bytes_per_char := A_IsUnicode ? 2 : 1
			max_chars := MfNumber.NumberBuffer.NumberBufferBytes
			max_bytes := max_chars * bytes_per_char + 2

			VarSetCapacity(this.digits, max_bytes)
			this.precision := 0
			this.scale := 0
			this.sign := false
		}
		
	}
; 	End:MfNumber.NumberBuffer Class ;}

	static Int32Precision := 10
	static Int64Precision := 19
	static NumberMaxDigits := 50
	static UInt32Precision := 10
	static UInt64Precision := 20

	IsWhite(ch) {
		return ch = 32 || (ch >= 9 && ch <= 13)
	}
}