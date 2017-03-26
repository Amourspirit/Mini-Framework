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
********************************************
* Big Integer Library
* Created 2000, last modified 2009
* Leemon Baird
* www.leemon.com
*
*
* This code defines a bigInt library for arbitrary-precision integers.
* A bigInt is an array of integers storing the value in chunks of bpe bits, 
* little endian (buff[0] is the least significant word).
* Negative bigInts are stored two's complement.  Almost all the functions treat
* bigInts as nonnegative.  The few that view them as two's complement say so
* in their comments.  Some functions assume their parameters have at least one 
* leading zero element. Functions with an underscore at the end of the name put
* their answer into one of the arrays passed in, and have unpredictable behavior 
* in case of overflow, so the caller must make sure the arrays are big enough to 
* hold the answer.  But the average user should never have to call any of the 
* underscored functions.  Each important underscored function has a wrapper function 
* of the same name without the underscore that takes care of the details for you.  
* For each underscored function where a parameter is modified, that same variable 
* must not be used as another argument too.  So, you cannot square x by doing 
* multMod_(x,x,n).  You must use squareMod_(x,n) instead, or do y=dup(x); multMod_(x,y,n).
* Or simply use the multMod(x,x,n) function without the underscore, where
* such issues never arise, because non-underscored functions never change
* their parameters; they always allocate new memory for the answer that is returned.
*
* These functions are designed to avoid frequent dynamic memory allocation in the inner loop.
* For most functions, if it needs a BigInt as a local variable it will actually use
* a global, and will only allocate to it only when it's not the right size.  This ensures
* that when a function is called repeatedly with same-sized parameters, it only allocates
* memory on the first call.
*
* Note that for cryptographic purposes, the calls to Math.random() must 
* be replaced with calls to a better pseudorandom number generator.
*
* In the following, "bigInt" means a bigInt with at least one leading zero element,
* and "integer" means a nonnegative integer less than radix.  In some cases, integer 
* can be negative.  Negative bigInts are 2s complement.
* 
* The following functions do not modify their inputs.
* Those returning a bigInt, string, or Array will dynamically allocate memory for that value.
* Those returning a boolean will return the integer 0 (false) or 1 (true).
* Those returning boolean or int will not allocate memory except possibly on the first 
* time they're called with a given parameter size.
* 
* bigInt  add(x,y)               *return (x+y) for bigInts x and y.  
* bigInt  addInt(x,n)            *return (x+n) where x is a bigInt and n is an integer.
* string  bigInt2str(x,base)     *return a string form of bigInt x in a given base, with 2 <= base <= 95
* int     bitSize(x)             *return how many bits long the bigInt x is, not counting leading zeros
* bigInt  dup(x)                 *return a copy of bigInt x
* boolean equals(x,y)            *is the bigInt x equal to the bigint y?
* boolean equalsInt(x,y)         *is bigint x equal to integer y?
* bigInt  expand(x,n)            *return a copy of x with at least n elements, adding leading zeros if needed
* Array   findPrimes(n)          *return array of all primes less than integer n
* bigInt  GCD(x,y)               *return greatest common divisor of bigInts x and y (each with same number of elements).
* boolean greater(x,y)           *is x>y?  (x and y are nonnegative bigInts)
* boolean greaterShift(x,y,shift)*is (x <<(shift*bpe)) > y?
* bigInt  int2bigInt(t,n,m)      *return a bigInt equal to integer t, with at least n bits and m array elements
* bigInt  inverseMod(x,n)        *return (x**(-1) mod n) for bigInts x and n.  If no inverse exists, it returns null
* int     inverseModInt(x,n)     *return x**(-1) mod n, for integers x and n.  Return 0 if there is no inverse
* boolean isZero(x)              *is the bigInt x equal to zero?
* boolean millerRabin(x,b)       *does one round of Miller-Rabin base integer b say that bigInt x is possibly prime? (b is bigInt, 1<b<x)
* boolean millerRabinInt(x,b)    *does one round of Miller-Rabin base integer b say that bigInt x is possibly prime? (b is int,    1<b<x)
* bigInt  mod(x,n)               *return a new bigInt equal to (x mod n) for bigInts x and n.
* int     modInt(x,n)            *return x mod n for bigInt x and integer n.
* bigInt  mult(x,y)              *return x*y for bigInts x and y. This is faster when y<x.
* bigInt  multMod(x,y,n)         *return (x*y mod n) for bigInts x,y,n.  For greater speed, let y<x.
* boolean negative(x)            *is bigInt x negative?
* bigInt  powMod(x,y,n)          *return (x**y mod n) where x,y,n are bigInts and ** is exponentiation.  0**0=1. Faster for odd n.
* bigInt  randBigInt(n,s)        *return an n-bit random BigInt (n>=1).  If s=1, then the most significant of those n bits is set to 1.
* bigInt  randTruePrime(k)       *return a new, random, k-bit, true prime bigInt using Maurer's algorithm.
* bigInt  randProbPrime(k)       *return a new, random, k-bit, probable prime bigInt (probability it's composite less than 2^-80).
* bigInt  str2bigInt(s,b,n,m)    *return a bigInt for number represented in string s in base b with at least n bits and m array elements
* bigInt  sub(x,y)               *return (x-y) for bigInts x and y.  Negative answers will be 2s complement
* bigInt  trim(x,k)              *return a copy of x with exactly k leading zero elements
*
*
* The following functions each have a non-underscored version, which most users should call instead.
* These functions each write to a single parameter, and the caller is responsible for ensuring the array 
* passed in is large enough to hold the result. 
*
* void    addInt_(x,n)          *do x=x+n where x is a bigInt and n is an integer
* void    add_(x,y)             *do x=x+y for bigInts x and y
* void    copy_(x,y)            *do x=y on bigInts x and y
* void    copyInt_(x,n)         *do x=n on bigInt x and integer n
* void    GCD_(x,y)             *set x to the greatest common divisor of bigInts x and y, (y is destroyed).  (This never overflows its array).
* boolean inverseMod_(x,n)      *do x=x**(-1) mod n, for bigInts x and n. Returns 1 (0) if inverse does (doesn't) exist
* void    mod_(x,n)             *do x=x mod n for bigInts x and n. (This never overflows its array).
* void    mult_(x,y)            *do x=x*y for bigInts x and y.
* void    multMod_(x,y,n)       *do x=x*y  mod n for bigInts x,y,n.
* void    powMod_(x,y,n)        *do x=x**y mod n, where x,y,n are bigInts (n is odd) and ** is exponentiation.  0**0=1.
* void    randBigInt_(b,n,s)    *do b = an n-bit random BigInt. if s=1, then nth bit (most significant bit) is set to 1. n>=1.
* void    randTruePrime_(ans,k) *do ans = a random k-bit true random prime (not just probable prime) with 1 in the msb.
* void    sub_(x,y)             *do x=x-y for bigInts x and y. Negative answers will be 2s complement.
*
* The following functions do NOT have a non-underscored version. 
* They each write a bigInt result to one or more parameters.  The caller is responsible for
* ensuring the arrays passed in are large enough to hold the results. 
*
* void addShift_(x,y,ys)       *do x=x+(y<<(ys*bpe))
* void carry_(x)               *do carries and borrows so each element of the bigInt x fits in bpe bits.
* void divide_(x,y,q,r)        *divide x by y giving quotient q and remainder r
* int  divInt_(x,n)            *do x=floor(x/n) for bigInt x and integer n, and return the remainder. (This never overflows its array).
* int  eGCD_(x,y,d,a,b)        *sets a,b,d to positive bigInts such that d = GCD_(x,y) = a*x-b*y
* void halve_(x)               *do x=floor(|x|/2)*sgn(x) for bigInt x in 2's complement.  (This never overflows its array).
* void leftShift_(x,n)         *left shift bigInt x by n bits.  n<bpe.
* void linComb_(x,y,a,b)       *do x=a*x+b*y for bigInts x and y and integers a and b
* void linCombShift_(x,y,b,ys) *do x=x+b*(y<<(ys*bpe)) for bigInts x and y, and integers b and ys
* void mont_(x,y,n,np)         *Montgomery multiplication (see comments where the function is defined)
* void multInt_(x,n)           *do x=x*n where x is a bigInt and n is an integer.
* void rightShift_(x,n)        *right shift bigInt x by n bits.  0 <= n < bpe. (This never overflows its array).
* void squareMod_(x,n)         *do x=x*x  mod n for bigInts x,n
* void subShift_(x,y,ys)       *do x=x-(y<<(ys*bpe)). Negative answers will be 2s complement.
*
* The following functions are based on algorithms from the _Handbook of Applied Cryptography_
*    powMod_()           = algorithm 14.94, Montgomery exponentiation
*    eGCD_,inverseMod_() = algorithm 14.61, Binary extended GCD_
*    GCD_()              = algorothm 14.57, Lehmer's algorithm
*    mont_()             = algorithm 14.36, Montgomery multiplication
*    divide_()           = algorithm 14.20  Multiple-precision division
*    squareMod_()        = algorithm 14.16  Multiple-precision squaring
*    randTruePrime_()    = algorithm  4.62, Maurer's algorithm
*    millerRabin()       = algorithm  4.24, Miller-Rabin algorithm
*
* Profiling shows:
*     randTruePrime_() spends:
*         10% of its time in calls to powMod_()
*         85% of its time in calls to millerRabin()
*     millerRabin() spends:
*         99% of its time in calls to powMod_()   (always with a base of 2)
*     powMod_() spends:
*         94% of its time in calls to mont_()  (almost always with x==y)
*
* This suggests there are several ways to speed up this library slightly:
*     - convert powMod_ to use a Montgomery form of k-ary window (or maybe a Montgomery form of sliding window)
*         -- this should especially focus on being fast when raising 2 to a power mod n
*     - convert randTruePrime_() to use a minimum r of 1/3 instead of 1/2 with the appropriate change to the test
*     - tune the parameters in randTruePrime_(), including c, m, and recLimit
*     - speed up the single loop in mont_() that takes 95% of the runtime, perhaps by reducing checking
*       within the loop when all the parameters are the same length.
*
* There are several ideas that look like they wouldn't help much at all:
*     - replacing trial division in randTruePrime_() with a sieve (that speeds up something taking almost no time anyway)
*     - increase bpe from 15 to 30 (that would help if we had a 32*32->64 multiplier, but not with JavaScript's 32*32->32)
*     - speeding up mont_(x,y,n,np) when x==y by doing a non-modular, non-Montgomery square
*       followed by a Montgomery reduction.  The intermediate answer will be twice as long as x, so that
*       method would be slower.  This is unfortunate because the code currently spends almost all of its time
*       doing mont_(x,x,...), both for randTruePrime_() and powMod_().  A faster method for Montgomery squaring
*       would have a large impact on the speed of randTruePrime_() and powMod_().  HAC has a couple of poorly-worded
*       sentences that seem to imply it's faster to do a non-modular square followed by a single
*       Montgomery reduction, but that's obviously wrong.
********************************************
*/
class MfBigInt extends MfObject
{
;{ Globals
	static bpe := 0 ; bits stored per array element
	static mask := 0 ; AND this with an array element to chop it down to bpe bits
	static radix := mask + 1 ; equals 2^bpe.  A single 1 bit to the left of the last bit of mask.
	;{ digitStr
	static m_digitStr := ""
	static one := ""
	static m_Init := MfBigInt.StaticInit()
		/*!
			Property: digitStr [get]
				Gets the digitStr value associated with the this instance
			Value:
				Var representing the digitStr property of the instance
			Remarks:
				Readonly Property
		*/
		digitStr[]
		{
			get {
				if (MfBigInt.m_digitStr = "")
				{
					MfBigInt.m_digitStr := new MfBigInt.DigitsChars()
				}
				return MfBigInt.m_digitStr
			}
			set {
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
				ex.SetProp(A_LineFile, A_LineNumber, "digitStr")
				Throw ex
			}
		}
		StaticInit() {
			MfBigInt.bpe := 0
			While ((1 << (MfBigInt.bpe + 1)) > (1 << MfBigInt.bpe))
			{
				; bpe=number of bits in the mantissa on this platform
				MfBigInt.bpe++ ; bpe=number of bits in one element of the array representing the bigInt
				
			}
			MfBigInt.bpe >>= 1
			MfBigInt.mask := ( 1 << MfBigInt.bpe) - 1 ; AND the mask with an integer to get its bpe least significant bits
			MfBigInt.radix := MfBigInt.mask + 1 ; 2^bpe.  a single 1 bit to the left of the first bit of mask

			MfBigInt.one := MfBigInt.int2bigInt(1,1,1)
			return true
		}
	; End:digitStr ;}
	static t := new MfBigInt.DList(0)
	static ss 		:= MfBigInt.t 	; used in mult_()
	static s0 		:= MfBigInt.t 	; used in multMod_(), squareMod_() 
	static s1 		:= MfBigInt.t 	; used in powMod_(), multMod_(), squareMod_() 
	static s2 		:= MfBigInt.t 	; used in powMod_(), multMod_()
	static s3 		:= MfBigInt.t 	; used in powMod_()
	static s4 		:= MfBigInt.t 	; used in mod_()
	static s5 		:= MfBigInt.t 	; used in mod_()
	static s6 		:= MfBigInt.t 	; used in bigInt2str()
	static s7 		:= MfBigInt.t 	; used in powMod_()
	static tt 		:= MfBigInt.t 	; used in GCD_()
	static sa 		:= MfBigInt.t 	; used in mont_()
	static mr_x1 	:= MfBigInt.t 	; used in millerRabin()
	static mr_r 	:= MfBigInt.t 	; used in millerRabin()
	static mr_a 	:= MfBigInt.t 	; used in millerRabin()
	static eg_v 	:= MfBigInt.t 	; used in eGCD_(), inverseMod_()
	static eg_u 	:= MfBigInt.t 	; used in eGCD_(), inverseMod_()
	static eg_A 	:= MfBigInt.t 	; used in eGCD_(), inverseMod_()
	static eg_B 	:= MfBigInt.t 	; used in eGCD_(), inverseMod_()
	static eg_C 	:= MfBigInt.t 	; used in eGCD_(), inverseMod_()
	static eg_D 	:= MfBigInt.t 	; used in eGCD_(), inverseMod_()
	static md_q1 	:= MfBigInt.t	; used in mod_()
	static md_q2 	:= MfBigInt.t	; used in mod_()
	static md_q3 	:= MfBigInt.t	; used in mod_()
	static md_r 	:= MfBigInt.t	; used in mod_()
	static md_r1 	:= MfBigInt.t	; used in mod_()
	static md_r2 	:= MfBigInt.t	; used in mod_()
	static md_tt 	:= MfBigInt.t 	; used in mod_()

	static primes 	:= MfBigInt.t
	static pows 	:= MfBigInt.t
	static s_i 		:= MfBigInt.t
	static s_i2 	:= MfBigInt.t
	static s_R 		:= MfBigInt.t
	static s_rm 	:= MfBigInt.t
	static s_q 		:= MfBigInt.t
	static s_n1 	:= MfBigInt.t 
	 
	; used in randTruePrime_()
	static s_a 		:= MfBigInt.t
	static s_r2 	:= MfBigInt.t
	static s_n 		:= MfBigInt.t
	static s_b 		:= MfBigInt.t
	static s_d 		:= MfBigInt.t
	static s_x1 	:= MfBigInt.t
	static s_x2 	:= MfBigInt.t
	static s_aa 	:= MfBigInt.t 
	  
	static rpprb 	:= MfBigInt.t 	; used in randProbPrimeRounds() (which also uses "primes")

; End:Globals ;}
;{ Methods
;{ 	findPrimes
	;return array of all primes less than integer n
	findPrimes(n) {
		
		s := new MfBigInt.DList(n)
		i := 0
		p := 0
		while (i < n )
		{
			s.Item[i] := 0
			i++
		}
		s.Item[0] := 2
		p := 0 ; first p elements of s are primes, the rest are a sieve
		while (s.Item[p] < n) ; s.Item[p] is the pth prime
		{
			
			i := s.Item[p] * s.Item[p]
			while (i < n) 
			{
				; mark multiples of s.Item[p]
				s.Item[i] := 1
				i += s.Item[p]
			}
			p++
			s.Item[p] := s.Item[p - 1] + 1
			while ((s.Item[p] < n) && (s.Item[s.Item[p]] != 0))
			{
				; find next prime (where s.Item[p] = 0)
				s.Item[p]++
			}
			ans := new MfBigInt.DList(p)
			i := 0
			while (i < p)
			{
				ans.Item[i] := s.Item[i]
				i++
			}
			return ans
		}
	}
; 	End:findPrimes ;}
;{ 	millerRabinInt
	; does a single round of Miller-Rabin base b consider x to be a possible prime?
	; x is a bigInt, and b is an integer, with b<x
	millerRabinInt(x, b) {
		if (MfBigInt.mr_x1.Count != x.Count)
		{
			MfBigInt.mr_x1 := MfBigInt.dup(x)
			MfBigInt.mr_r := MfBigInt.dup(x)
			MfBigInt.mr_a := MfBigInt.dup(x)
		}

		MfBigInt.copyInt_(MfBigInt.mr_a, b)
		return MfBigInt.millerRabin(x, MfBigInt.mr_a)
	}
; 	End:millerRabinInt ;}
;{ 	millerRabin
	; does a single round of Miller-Rabin base b consider x to be a possible prime?
	; x and b are bigInts with b<x
	millerRabin(x, b) {
		i := 0, j := 0, k := 0 , s := 0

		if (MfBigInt.mr_x1.length != x.length)
		{
			MfBigInt.mr_x1 := MfBigInt.dup(x)
			MfBigInt.mr_r := MfBigInt.dup(x)
			MfBigInt.mr_a := MfBigInt.dup(x)
		}

		MfBigInt.copy_(MfBigInt.mr_a, b)
		MfBigInt.copy_(MfBigInt.mr_r, x)
		MfBigInt.copy_(MfBigInt.mr_x1, x)

		MfBigInt.addInt_(MfBigInt.mr_r, -1)
		MfBigInt.addInt_(MfBigInt.mr_x1, -1)

		if (MfBigInt.isZero(MfBigInt.mr_r))
		{
			return 0
		}

		k := 0
		while (MfBigInt.mr_r.Item[k] = 0)
		{
			k++
		}
		i := 1
		j := 2
		while (mod(MfBigInt.mr_r.Item[k], j) = 0)
		{
			j *= 2
			i++
		}
		s := (k * MfBigInt.bpe) + i - 1
		if (s != 0)
		{
			MfBigInt.rightShift_(MfBigInt.mr_r, s)
		}

		MfBigInt.powMod_(MfBigInt.mr_a, MfBigInt.mr_r, x)

		if (!MfBigInt.equalsInt(MfBigInt.mr_a, 1) && !MfBigInt.equals(MfBigInt.mr_a, MfBigInt.mr_x1))
		{
			j := 1
			while ((j <= s) && (!MfBigInt.equals(MfBigInt.mr_a, MfBigInt.mr_x1)))
			{
				MfBigInt.squareMod_(MfBigInt.mr_a, x)
				if (MfBigInt.equalsInt(MfBigInt.mr_a, 1))
				{
					return 0
				}
				j++
			}
			if (!MfBigInt.equals(MfBigInt.mr_a, MfBigInt.mr_x1))
			{
				return 0
			}
		}
		return 1
	}
; 	End:millerRabin ;}
;{ 	bitSize
	; returns how many bits long the bigInt is, not counting leading zeros.
	bitSize(x) {
		j := x.Count -1
		if (j = 0)
		{
			return 0
		}
		while ((j > 0) && (x.Item[j] = 0))
		{
			j--
		}
		z := 0
		w := x.Item[j]
		While (w >= 1)
		{
			w >>= 1
			z++
		}
		z += MfBigInt.bpe * j
		return z
	}
; 	End:bitSize ;}
;{ 	expand
	; return a copy of x with at least n elements, adding leading zeros if needed
	expand(x, n) {
		ans := MfBigInt.int2bigInt(0, (x.Count > n ? x.Count : n) * MfBigInt.bpe, 0)
		MfBigInt.copy_(ans, x)
		return ans
	}
; 	End:expand ;}
;{ 	randTruePrime
	; return a k-bit true random prime using Maurer's algorithm.
	randTruePrime(k) {
		ans := MfBigInt.int2bigInt(0, k, 0)
		MfBigInt.randTruePrime_(ans,k)
		return MfBigInt.trim(ans, 1)
	}
; 	End:randTruePrime ;}
;{ 	randProbPrime
	; return a k-bit random probable prime with probability of error < 2^-80
	randProbPrime(k) {
		if (k >= 600)
			return MfBigInt.randProbPrimeRounds(k, 2) ;numbers from HAC table 4.3
		if (k >= 550)
			return MfBigInt.randProbPrimeRounds(k, 4)
		if (k >= 500)
			return MfBigInt.randProbPrimeRounds(k, 5)
		if (k >= 400)
			return MfBigInt.randProbPrimeRounds(k, 6)
		if (k >= 350)
			return MfBigInt.randProbPrimeRounds(k, 7)
		if (k >= 300)
			return MfBigInt.randProbPrimeRounds(k, 9)
		if (k >= 250)
			return MfBigInt.randProbPrimeRounds(k, 12) ; numbers from HAC table 4.4
		if (k >= 200)
			return MfBigInt.randProbPrimeRounds(k, 15)
		if (k >= 150)
			return MfBigInt.randProbPrimeRounds(k, 18)
		if (k >= 100)
			return MfBigInt.randProbPrimeRounds(k, 27)

		return MfBigInt.randProbPrimeRounds(k, 40) ; number from HAC remark 4.26 (only an estimate)
	}
; 	End:randProbPrime ;}
;{ 	randProbPrimeRounds
	; return a k-bit probable random prime using n rounds of Miller Rabin (after trial division with small primes)	
	randProbPrimeRounds(k, n) {
		B := 30000 ; B is largest prime to use in trial division
		i := 0
		divisible := 0
		ans := MfBigInt.int2bigInt(0, k, 0)

		; optimization: try larger and smaller B to find the best limit.
		if (MfBigInt.primes.Count = 0)
		{
			MfBigInt.primes := MfBigInt.findPrimes(30000)
		}
		if (MfBigInt.rpprb.Count != ans.Count)
		{
			MfBigInt.rpprb := MfBigInt.dup(ans)
		}
		loop
		{
			; keep trying random values for ans until one appears to be prime
			; optimization: pick a random number times L=2*3*5*...*p, plus a 
			; random element of the list of all numbers in [0,L) not divisible by any prime up to p.
			; This can reduce the amount of random number generation.

			MfBigInt.randBigInt_(ans, k, 0) ; ans = a random odd number to check
			ans.Item[0] |= 1
			divisible := 0

			; check ans for divisibility by small primes up to B
			i := 0
			while ((i < MfBigInt.primes.Count) && (MfBigInt.primes.Item[i] <= B))
			{
				if (MfBigInt.modInt(ans, MfBigInt.primes.Item[i]) = 0 && !(MfBigInt.equalsInt(ans, MfBigInt.primes.Item[i])))
				{
					divisible := 1
					break
				}
				i++
			}

			; optimization: change millerRabin so the base can be bigger than the number being checked, then eliminate the while here.
			i := 0
			while ((i < n) && !divisible)
			{
				MfBigInt.randBigInt_(MfBigInt.rpprb, k, 0)
				while (!MfBigInt.greater(ans, MfBigInt.rpprb)) ;pick a random rpprb that's < ans
				{
					MfBigInt.randBigInt_(MfBigInt.rpprb, k, 0)
				}
				if (!MfBigInt.millerRabin(ans, MfBigInt.rpprb))
				{
					divisible := 1
				}
				i++
			}
			if (!divisible)
			{
				return ans
			}
		}
	}
; 	End:randProbPrimeRounds ;}
;{ 	mod
	;return a new bigInt equal to (x mod n) for bigInts x and n.
	mod(x, n) {
		ans := MfBigInt.dup(x)
		MfBigInt.mod_(ans, n)
		return MfBigInt.trim(ans, 1)
	}
; 	End:mod ;}
;{ 	addInt
	; return (x+n) where x is a bigInt and n is an integer.
	addInt(x, n) {
		ans := MfBigInt.expand(x, x.Count + 1)
		MfBigInt.addInt_(ans, n)
		return MfBigInt.trim(ans, 1)
	}
; 	End:addInt ;}
;{ 	mult
	; return x*y for bigInts x and y. This is faster when y<x.
	mult(x, y) {
		ans := MfBigInt.expand(x, x.Count + y.Count)
		MfBigInt.mult_(ans, y)
		return MfBigInt.trim(ans, 1)
	}
; 	End:mult ;}
;{ 	powMod
	; return (x**y mod n) where x,y,n are bigInts and ** is exponentiation.  0**0=1. Faster for odd n.
	powMod(x, y, n) {
		ans := MfBigInt.expand(x, n.Count)

		; this should work without the trim, but doesn't
		MfBigInt.powMod_(ans, MfBigInt.trim(y, 2), MfBigInt.trim(n, 2), 0)
		return MfBigInt.trim(ans, 1)
	}
; 	End:powMod ;}
;{ 	sub
	; return (x-y) for bigInts x and y.  Negative answers will be 2s complement
	sub(x,y) {
		ans := MfBigInt.expand(x, (x.Count > y.Count ? x.Count + 1 : y.Count + 1))
		MfBigInt.sub_(ans, y)
		return MfBigInt.trim(ans, 1)
	}
; 	End:sub ;}
;{ 	add
	; return (x+y) for bigInts x and y.  
	add(x,y) {
		ans := MfBigInt.expand(x, (x.Count > y.Count ? x.Count + 1 : y.Count + 1))
		MfBigInt.add_(ans, y)
		return MfBigInt.trim(ans, 1)
	}
; 	End:add ;}
;{ 	inverseMod
	; return (x**(-1) mod n) for bigInts x and n.  If no inverse exists, it returns null
	inverseMod(x,n) {
		 ans := MfBigInt.expand(x, n.Count)
		 s := MfBigInt.inverseMod_(ans, n)
		 return s ? MfBigInt.trim(ans, 1) : null
	}
; 	End:inverseMod ;}
;{ 	multMod
	; return (x*y mod n) for bigInts x,y,n.  For greater speed, let y<x.
	 multMod(x,y,n) {
	 	ans := MfBigInt.expand(x, n.Count)
	 	MfBigInt.multMod_(ans,y,n)
	 	return MfBigInt.trim(ans, 1)
	 }
; 	End:multMod ;}
;{ 	randTruePrime_
	; generate a k-bit true random prime using Maurer's algorithm,
	; and put it into ans.  The bigInt ans must be large enough to hold it.
	randTruePrime_(byref ans, k) {

		if (MfBigInt.primes.Count = 0)
		{
			MfBigInt.primes := MfBigInt.findPrimes(30000) ; check for divisibility by primes <=30000
		}

		if (MfBigInt.pows.Count = 0)
		{
			wf := A_FormatFloat
			SetFormat, FloatFast, 0.16
			try
			{
				MfBigInt.pows := MfBigInt.DList(512)
				j := 0
				while (j < 512)
				{
					tmp := ((j / 511.0) - 1.0) + 0.0
					tmpPow := 2 ** tmp
					MfBigInt.pows.Item[j] := tmpPow
					j++
				}
			}
			catch e
			{
				throw e
			}
			finally
			{
				SetFormat, FloatFast, %wf%
			}
				
		}
		wf := A_FormatFloat
		try
		{
			SetFormat, FloatFast, 0.16
			;c and m should be tuned for a particular machine and value of k, to maximize speed
			c := 0.1 ; c=0.1 in HAC
			m := 20 ;generate this k-bit number by first recursively generating a number that has between k/2 and k-m bits 
			recLimit := 20 ;stop recursion when k <=recLimit.  Must have recLimit >= 2

			if (MfBigInt.s_i2.Count != ans.Count)
			{
				MfBigInt.s_i2 	:= MfBigInt.dup(ans)
				MfBigInt.s_R 	:= MfBigInt.dup(ans)
				MfBigInt.s_n1 	:= MfBigInt.dup(ans)
				MfBigInt.s_r2 	:= MfBigInt.dup(ans)
				MfBigInt.s_d 	:= MfBigInt.dup(ans)
				MfBigInt.s_x1 	:= MfBigInt.dup(ans)
				MfBigInt.s_x2 	:= MfBigInt.dup(ans)
				MfBigInt.s_b 	:= MfBigInt.dup(ans)
				MfBigInt.s_n 	:= MfBigInt.dup(ans)
				MfBigInt.s_i 	:= MfBigInt.dup(ans)
				MfBigInt.s_rm 	:= MfBigInt.dup(ans)
				MfBigInt.s_q 	:= MfBigInt.dup(ans)
				MfBigInt.s_a 	:= MfBigInt.dup(ans)
				MfBigInt.s_aa 	:= MfBigInt.dup(ans)
			}
			if (k <= recLimit)
			{
				; generate small random primes by trial division up to its square root
				pm := (1 << ((k + 2) >> 1)) - 1 ; pm is binary number with all ones, just over sqrt(2^k)
				MfBigInt.copyInt_(ans, 0)
				dd := 1
				while (dd)
				{
					dd := 0
					; random, k-bit, odd integer, with msb 1
					tmp := floor(MfBigInt.Random_() * (1 << k))
					ans.Item[0] := 1 | (1 << (k - 1)) | tmp
					j := 1
					while ((j < MfBigInt.primes.Count) && ((MfBigInt.primes.Item[j] & pm) = MfBigInt.primes.Item[j]))
					{
						; trial division by all primes 3...sqrt(2^k)
						if (0 = Mod(ans.Item[0], MfBigInt.primes.Item[j]))
						{
							dd := 1
							break
						}
						j++
					}
					MfBigInt.carry_(ans)
					return

				}
			}
			B := c * k * k ; try small primes up to B (or all the primes[] array if the largest is less than B).
			if (k > 2 * m) ; generate this k-bit number by first recursively generating a number that has between k/2 and k-m bits
			{
				r := 1
				while ((k - (k * r)) <= m)
				{
					tmp := floor(MfBigInt.Random_() * 512)
					r := MfBigInt.pows.Item[tmp]
				}
			}
			else
			{
				r := 0.5
			}

			; simulation suggests the more complex algorithm using r=.333 is only slightly faster.
			recSize := floor(r * k) + 1
			MfBigInt.randTruePrime_(MfBigInt.s_q, recSize)
			MfBigInt.copyInt_(MfBigInt.s_i2, 0)
			MfBigInt.s_i2.Item[floor((k - 2) / MfBigInt.bpe)] |= (Mod((1 << (k - 2)), MfBigInt.bpe)) ; s_i2=2^(k-2)
			MfBigInt.divide_(MfBigInt.s_i2, MfBigInt.s_q, MfBigInt.s_i, MfBigInt.s_rm) ; s_i=floor((2^(k-1))/(2q))
			z =: MfBigInt.bitSize(MfBigInt.s_i)
			loop
			{
				loop
				{
					MfBigInt.randBigInt_(MfBigInt.s_R, z, 0)
					if (MfBigInt.greater(MfBigInt.s_i, MfBigInt.s_R))
					{
						break
					}
				}
				; now s_R is in the range [0,s_i-1]
				MfBigInt.addInt_(MfBigInt.s_R, 1) ; now s_R is in the range [1,s_i]
				MfBigInt.add_(MfBigInt.s_R, MfBigInt.s_i) ; now s_R is in the range [s_i+1,2*s_i]

				MfBigInt.copy_(MfBigInt.s_n, MfBigInt.s_q)
				MfBigInt.mult_(MfBigInt.s_n, MfBigInt.s_R)
				MfBigInt.multInt_(MfBigInt.s_n, 2)
				MfBigInt.addInt_(MfBigInt.s_n, 1) ; s_n=2*s_R*s_q+1

				MfBigInt.copy_(MfBigInt.s_r2, MfBigInt.s_R)
				MfBigInt.multInt_(MfBigInt.s_r2, 2) ; s_r2=2*s_R

				; check s_n for divisibility by small primes up to B
				divisible := 0
				j := 0
				while ((j < MfBigInt.primes.Count) && (MfBigInt.primes.Item[j] < B))
				{
					if ((MfBigInt.modInt(MfBigInt.s_n, MfBigInt.primes.Item[j]) = 0)
						&& (!MfBigInt.equalsInt(MfBigInt.s_n, MfBigInt.primes.Item[j])))
					{
						divisible := 1
						break
					}
				}
				if (!divisible) ; if it passes small primes check, then try a single Miller-Rabin base 2
				{
					if (!MfBigInt.millerRabinInt(MfBigInt.s_n, 2)) ; this line represents 75% of the total runtime for randTruePrime_ 
					{
						divisible := 1
					}
				}
				if (!divisible)
				{
					MfBigInt.addInt_(MfBigInt.s_n, -3)
					j := MfBigInt.s_n.Count - 1
					while ((MfBigInt.s_n.Item[j] = 0) && (j > 0))
					{
						j--
					}
					zz := 0
					w := MfBigInt.s_n.Item[j]
					While (w)
					{
						w >>= 1
						zz++
					}
					zz += MfBigInt.bpe * j ; zz=number of bits in s_n, ignoring leading zeros
					loop
					{
						; generate z-bit numbers until one falls in the range [0,s_n-1]
						MfBigInt.randBigInt_(MfBigInt.s_a, zz, 0)
						if (MfBigInt.greater(MfBigInt.s_n, MfBigInt.s_a))
						{
							break
						}
					}
					; now s_a is in the range [0,s_n-1]
					MfBigInt.addInt_(MfBigInt.s_n, 3) ; now s_a is in the range [0,s_n-4]
					MfBigInt.addInt_(MfBigInt.s_a, 2) ; now s_a is in the range [2,s_n-2]
					MfBigInt.copy_(MfBigInt.s_b, MfBigInt.s_a)
					MfBigInt.copy_(MfBigInt.s_n1, MfBigInt.s_n)
					MfBigInt.addInt_(MfBigInt.s_n1, -1)
					MfBigInt.powMod_(MfBigInt.s_b, MfBigInt.s_n1, MfBigInt.s_n) ; s_b=s_a^(s_n-1) modulo s_n
					MfBigInt.addInt_(MfBigInt.s_b, -1)
					if (MfBigInt.isZero(MfBigInt.s_b))
					{
						MfBigInt.copy_(MfBigInt.s_b, MfBigInt.s_a)
						MfBigInt.powMod_(MfBigInt.s_b, MfBigInt.s_r2, MfBigInt.s_n)
						MfBigInt.addInt_(MfBigInt.s_b, -1)
						MfBigInt.copy_(MfBigInt.s_aa, MfBigInt.s_n)
						MfBigInt.copy_(MfBigInt.s_d, MfBigInt.s_b)
						MfBigInt.GCD_(MfBigInt.s_d, MfBigInt.s_n)
						if (MfBigInt.equalsInt(MfBigInt.s_d, 1))
						{
							MfBigInt.copy_(ans, MfBigInt.s_aa)
							return
						}
					}
				}
			}
		}
		catch e
		{
			throw e
		}
		finally
		{
			SetFormat, FloatFast, %wf%
		}

	}
; 	End:randTruePrime_ ;}
;{ 	randBigInt_
	; Set b to an n-bit random BigInt.  If s=1, then the most significant of those n bits is set to 1.
	; Array b must be big enough to hold the result. Must have n>=1
	randBigInt_(byref b, n, s) {
		i := 0
		while (i < b.Count)
		{
			b.Item[i] := 0
			i++
		}
		wf := A_FormatFloat
		SetFormat, FloatFast, 0.16
		try
		{
			a := floor((n - 1) / MfBigInt.bpe) + 1
			i := 0
			while (i < a)
			{
				b.Item[i] := floor(MfBigInt.Random_() * (1 << (MfBigInt.bpe -1)))
				i++
			}
			b.Item[a -1] &= (2 << (mod((n -1), MfBigInt.bpe))) - 1
			if (s = 1)
			{
				b.Item[a - 1] |= (1 << (mod((n-1), MfBigInt.bpe)))
			}
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
; 	End:randBigInt_ ;}
;{ 	GCD
	; Return the greatest common divisor of bigInts x and y (each with same number of elements).
	GCD(x, y) {
		xc := MfBigInt.dup(x)
		yc := MfBigInt.dup(y)
		MfBigInt.GCD_(xc, yc)
		return xc
	}
; 	End:GCD ;}
;{ 	GCD_
	; set x to the greatest common divisor of bigInts x and y (each with same number of elements).
	; y is destroyed.
	GCD_(byref x, byref y) {
		if(MfBigInt.tt.Count != x.Count)
		{
			MfBigInt.tt := MfBigInt.dup(x)
		}
		sing := 1
		while (sing)
		{
			; while y has nonzero elements other than y[0]
			sing := 0
			i := 1
			while (i < y.Count)
			{
				if (y.Item[i])
				{
					sing := 1
					break
				}
				i++
			}
			if (!sing)
			{
				break ; quit when y all zero elements except possibly y[0]
			}

			i := x.Count - 1
			while ((i >= 0) && (x.Item[i] = 0))
			{
				; find most significant element of x
				i--
			}
			xp := x.Item[i]
			yp := y.Item[i]
			A := 1
			B := 0
			c := 0
			D := 1
			while ((yp + C != 0) && (yp + D != 0))
			{
				q := floor((xp + A) / (yp + C))
				qp := floor((xp + B) / (yp + D))
				if (q != qp)
				{
					break
				}
				t := A - q * C
				A := C
				C := t ; do (A,B,xp, C,D,yp) = (C,D,yp, A,B,xp) - q*(0,0,0, C,D,yp)
				t := B - q * D
				B := D
				D := t
				t := xp - q * yp
				xp := yp
				yp := t
			}
			if (B)
			{
				MfBigInt.copy_(MfBigInt.tt, x)
				MfBigInt.linComb_(x, y, A, B) ; x=A*x+B*y
				MfBigInt.linComb_(y, MfBigInt.tt, D, C) ; y=D*y+C*tt
			}
			else
			{
				MfBigInt.mod_(x, y)
				MfBigInt.copy_(MfBigInt.tt, x)
				MfBigInt.copy_(x, y)
				MfBigInt.copy_(y, MfBigInt.tt)
			}
			if (y.Item[0] = 0)
			{
				return
			}
			t := MfBigInt.modInt(x, y.Item[0])
			MfBigInt.copyInt_(x, y.Item[0])
			y.Item[0] := t
			while (y.Item[0] != 0)
			{
				x.Item[0] := mod(x.Item[0], y.Item[0])
				t := x.Item[0]
				x.Item[0] := y.Item[0]
				y.Item[0] := t
			}
		}
	}
; 	End:GCD_ ;}
;{ 	inverseMod_
	; do x=x**(-1) mod n, for bigInts x and n.
	; If no inverse exists, it sets x to zero and returns 0, else it returns 1.
	; The x array must be at least as large as the n array.
	inverseMod_(byref x, byref n) {
		k := 1 + 2 * MfMath.Max(x.Count, n.Count)

		; if both inputs are even, then inverse doesn't exist
		if (!(x.Item[0] & 1) && !(n.Item[0] & 1))
		{
			MfBigInt.copyInt_(x, 0)
			return false
		}
		if (MfBigInt.eg_u.Count != k)
		{
			MfBigInt.eg_u := new MfBigInt.DList(k)
			MfBigInt.eg_v := new MfBigInt.DList(k)
			MfBigInt.eg_A := new MfBigInt.DList(k)
			MfBigInt.eg_B := new MfBigInt.DList(k)
			MfBigInt.eg_C := new MfBigInt.DList(k)
			MfBigInt.eg_D := new MfBigInt.DList(k)
		}

		MfBigInt.copy_(MfBigInt.eg_u, x)
		MfBigInt.copy_(MfBigInt.eg_v, n)
		MfBigInt.copyInt_(MfBigInt.eg_A, 1)
		MfBigInt.copyInt_(MfBigInt.eg_B, 0)
		MfBigInt.copyInt_(MfBigInt.eg_C, 0)
		MfBigInt.copyInt_(MfBigInt.eg_D, 1)

		loop
		{
			while (!(MfBigInt.eg_u.Item[0] & 1))
			{
				MfBigInt.halve_(MfBigInt.eg_u)
				if (!(MfBigInt.eg_A.Item[0] & 1) && !(MfBigInt.eg_B.Item[0] & 1))
				{
					; if eg_A==eg_B==0 mod 2
					MfBigInt.halve_(MfBigInt.eg_A)
					MfBigInt.halve_(MfBigInt.eg_B)
				}
				else
				{
					MfBigInt.add_(MfBigInt.eg_A, n)
					MfBigInt.halve_(MfBigInt.eg_A)
					MfBigInt.sub_(MfBigInt.eg_B, x)
					MfBigInt.halve_(MfBigInt.eg_B)
				}
			}

			; while eg_v is even
			while (!(MfBigInt.eg_v.Item[0] & 1))
			{
				MfBigInt.halve_(MfBigInt.eg_v)
				; if eg_C==eg_D==0 mod 2
				if (!(MfBigInt.eg_C.Item[0] & 1) && !(MfBigInt.eg_D.Item[0] & 1))
				{
					MfBigInt.halve_(MfBigInt.eg_C)
					MfBigInt.halve_(MfBigInt.eg_D)
				}
				else
				{
					MfBigInt.add_(MfBigInt.eg_C, n)
					MfBigInt.halve_(MfBigInt.eg_C)
					MfBigInt.sub_(MfBigInt.eg_D, x)
					MfBigInt.halve_(MfBigInt.eg_D)
				}
			}

			; eg_v <= eg_u
			if (!MfBigInt.greater(MfBigInt.eg_v, MfBigInt.eg_u))
			{
				MfBigInt.sub_(MfBigInt.eg_u, MfBigInt.eg_v)
				MfBigInt.sub_(MfBigInt.eg_A, MfBigInt.eg_C)
				MfBigInt.sub_(MfBigInt.eg_B, MfBigInt.eg_D)
			}
			else
			{
				MfBigInt.sub_(MfBigInt.eg_v, MfBigInt.eg_u)
				MfBigInt.sub_(MfBigInt.eg_C, MfBigInt.eg_A)
				MfBigInt.sub_(MfBigInt.eg_D, MfBigInt.eg_B)
			}
			if (MfBigInt.equalsInt(MfBigInt.eg_u, 0))
			{
				if (MfBigInt.negative(MfBigInt.eg_C))
				{
					; make sure answer is nonnegative
					MfBigInt.add_(MfBigInt.eg_C, n)
				}
				MfBigInt.copy_(x, MfBigInt.eg_C)
				if (!MfBigInt.equalsInt(MfBigInt.eg_v, 1))
				{
					;if GCD_(x,n)!=1, then there is no inverse
					MfBigInt.copyInt_(x, 0)
					return false
				}
				return true
			}
		}
	}
; 	End:inverseMod_ ;}
;{ 	inverseModInt
	inverseModInt(x, n) {
		a := 1
		b := 0
		t := ""
		loop
		{
			if (x = 1)
			{
				return a
			}
			if (x = 0)
			{
				return 0
			}
			b -= a * floor(n / x)
			n := Mod(n, x)

			; to avoid negatives, change this b to n-b, and each -= to +=
			if (n = 1)
			{
				return b
			}
			if (n = 0)
			{
				return 0
			}
			a -= b * floor(z / n)
			x := mod(x, n)
		}
	}
; 	End:inverseModInt ;}
;{ 	eGCD_
	; Given positive bigInts x and y, change the bigints v, a, and b to positive bigInts such that:
	;      v = GCD_(x,y) = a*x-b*y
	; The bigInts v, a, b, must have exactly as many elements as the larger of x and y.
	eGCD_(byref x, byref y, byref v, byref a, byref b) {
		g := 0
		k := MfMath.Max(z.Count, y.Count)
		if (MfBigInt.eg_u.Count != k)
		{
			MfBigInt.eg_u := new MfBigInt.DList(k)
			MfBigInt.eg_A := new MfBigInt.DList(k)
			MfBigInt.eg_B := new MfBigInt.DList(k)
			MfBigInt.eg_C := new MfBigInt.DList(k)
			MfBigInt.eg_D := new MfBigInt.DList(k)
		}
		while (!(x.Item[0] & 1) && !(y.Item[0] & 1))
		{ 
			; while x and y both even
			MfBigInt.halve_(x)
			MfBigInt.halve_(y)
			g++
		}
		MfBigInt.copy_(MfBigInt.eg_u, x)
		MfBigInt.copy_(v, y)
		MfBigInt.copyInt_(MfBigInt.eg_A, 1)
		MfBigInt.copyInt_(MfBigInt.eg_B, 0)
		MfBigInt.copyInt_(MfBigInt.eg_C, 0)
		MfBigInt.copyInt_(MfBigInt.eg_D, 1)
		loop
		{
			; while u is even
			while (!(MfBigInt.eg_u.Item[0] & 1))
			{ 
				MfBigInt.halve_(MfBigInt.eg_u)

				; if A==B==0 mod 2
				if (!(MfBigInt.eg_A.Item[0] & 1) && !(MfBigInt.eg_B.Item[0] & 1))
				{ 
					MfBigInt.halve_(MfBigInt.eg_A)
					MfBigInt.halve_(MfBigInt.eg_B)
				}
				else
				{
					MfBigInt.add_(MfBigInt.eg_A, y)
					MfBigInt.halve_(MfBigInt.eg_A)
					MfBigInt.sub_(MfBigInt.eg_B, x)
					MfBigInt.halve_(MfBigInt.eg_B)
				}
			}

			; while v is even
			while (!(v.Item[0] & 1))
			{ 
				MfBigInt.halve_(v)

				; if C==D==0 mod 2
				if (!(MfBigInt.eg_C.Item[0] & 1) && !(MfBigInt.eg_D.Item[0] & 1))
				{ 
					MfBigInt.halve_(MfBigInt.eg_C)
					MfBigInt.halve_(MfBigInt.eg_D)
				}
				else
				{
					MfBigInt.add_(MfBigInt.eg_C, y)
					MfBigInt.halve_(MfBigInt.eg_C)
					MfBigInt.sub_(MfBigInt.eg_D, x)
					MfBigInt.halve_(MfBigInt.eg_D)
				}
			}

			; v<=u
			if (!MfBigInt.greater(v, MfBigInt.eg_u))
			{ 
				MfBigInt.sub_(MfBigInt.eg_u, v)
				MfBigInt.sub_(MfBigInt.eg_A, MfBigInt.eg_C)
				MfBigInt.sub_(MfBigInt.eg_B, MfBigInt.eg_D)
			}
			else
			{ 	; v>u
				MfBigInt.sub_(v, MfBigInt.eg_u)
				MfBigInt.sub_(MfBigInt.eg_C, MfBigInt.eg_A)
				MfBigInt.sub_(MfBigInt.eg_D, MfBigInt.eg_B)
			}
			if (MfBigInt.equalsInt(MfBigInt.eg_u, 0))
			{
				; make sure a (C)is nonnegative
				if (MfBigInt.negative(MfBigInt.eg_C))
				{ 
					MfBigInt.add_(MfBigInt.eg_C, y)
					MfBigInt.sub_(MfBigInt.eg_D, x)
				}
				MfBigInt.multInt_(MfBigInt.eg_D, -1) ; make sure b (D) is nonnegative
				MfBigInt.copy_(a, MfBigInt.eg_C)
				MfBigInt.copy_(b, MfBigInt.eg_D)
				MfBigInt.leftShift_(v, g)
				return
			}
		}
	}
; 	End:eGCD_ ;}
;{ 	negative
	; is bigInt x negative?
	negative(byref x) {
		return ((x.Item[x.count - 1] >> (MfBigInt.bpe - 1)) & 1)
	}
; 	End:negative ;}
;{ 	greaterShift
	; is (x << (shift*bpe)) > y?
	; x and y are nonnegative bigInts
	; shift is a nonnegative integer
	greaterShift(byref x, byref y, shift) {
		kx := x.Count
		ky := y.Count
		k := ((kx + shift) < ky) ? (kx + shift) : ky
		i := ky - 1 - shift
		while (i >= 0 && i < kx)
		{
			if (x.Item[i] > 0)
			{
				return 1 ; if there are nonzeros in x to the left of the first column of y, then x is bigger
			}
			i++
		}

		i := kx - 1 + shift
		while (i < ky)
		{
			if (y.Item[i] > 0)
			{
				return 0 ; if there are nonzeros in y to the left of the first column of x, then x is not bigger
			}
			i++
		}
		
		i := k - 1
		while (i >= shift)
		{
			if (x.Item[i - shift] > y.Item[i])
			{
				return 1
			}
			else if (x.Item[i - shift] < y.Item[i])
			{
				return 0
			}
			i--
		}
		return 0
	}
; 	End:greaterShift ;}
;{ 	greater
	; is x > y? (x and y both nonnegative)
	greater(x, y) {
		k := (x.Count < y.Count) ? x.Count : y.Count
		i := x.Count
		while (i < y.Count)
		{
			if (y.Item[i])
			{
				return 0
			}
			i++
		}

		i := y.Count
		while (i < x.Count)
		{
			if (x.Item[i])
			{
				return 1 ; x has more digits
			}
			i++
		}
		i := k -1
		while (i >= 0)
		{
			if (x.Item[i] > y.Item[i])
			{
				return 1
			}
			else if (x.Item[i] < y.Item[i])
			{
				return 0
			}
			i--
		}
		return 0
	}
; 	End:greater ;}
;{ 	divide_
	; divide x by y giving quotient q and remainder r.  (q=floor(x/y),  r=x mod y).  All 4 are bigints.
	; x must have at least one leading zero element.
	; y must be nonzero.
	; q and r must be arrays that are exactly the same length as x. (Or q can have more).
	; Must have x.length >= y.length >= 2.
	divide_(ByRef x, ByRef y, ByRef q, ByRef r) {
		MfBigInt.copy_(r, x)
		ky := y.Count
		; ky is number of elements in y, not including leading zeros
		while (y.Item[ky - 1] = 0)
		{
			i--
		}

		; normalize: ensure the most significant element of y has its highest bit set
		b := y.Item[ky - 1]
		a := 0
		while (b)
		{
			b >>= 1
		}
		a := MfBigInt.bpe - a ; a is how many bits to shift so that the high order bit of y is leftmost in its array element

		; multiply both by 1<<a now, then divide both by that at the end
		MfBigInt.leftShift_(y, a)
		MfBigInt.leftShift_(r, a)

		kx := r.Count
		while(r.Item[kx - 1] == 0 && kx > ky)
		{
			kx--
		}

		MfBigInt.copyInt_(q, 0) ; q=0
		while (!MfBigInt.greaterShift(y, r, kx - ky))
		{
			MfBigInt.subShift_(r, y, kx - ky)
			q.Item[kx - ky]++
		}
		i := kx
		while (i >= ky)
		{
			if (r.Item[i] = y.Item[ky - 1])
			{
				q.Item[i - ky] := MfBigInt.mask
			}
			else
			{
				q.Item[i - ky] := floor((r.Item[i] * MfBigInt.radix + r.Item[i - 1]) / y.Item[ky - 1])
			}
			loop
			{
				y2 := (ky > 1 ? y.Item[ky - 2] : 0) * q.Item[i - ky]
				c := y2 >> MfBigInt.bpe
				y2 := y2 & MfBigInt.mask
				y1 := c + q.Item[i - ky] * y.Item[ky - 1]
				c := y1 >> MfBigInt.bpe
				y1 := y1 & MfBigInt.mask

				if (c = r.Item[i] ? y1 = r[i - 1] ? y2 > (i > 1 ? r.Item[i - 2] : 0) : y1 > r.Item[i - 1] : c > r.Item[i])
				{
					q.Item[i - ky]--
				}
				else
				{
					break
				}
			}
			
			MfBigInt.linCombShift_(r, y, -q.Item[i - ky], i - ky) ; r=r-q.Item[i-ky] * MfBigInt.leftShift_(y, i - ky)
			if (MfBigInt.negative(r))
			{
				MfBigInt.addShift_(r, y, i - ky)
				q.Item[i - ky]--
			}
			i--
		}
		MfBigInt.rightShift_(y, a) ; undo the normalization step
		MfBigInt.rightShift_(r, a) ; undo the normalization step
	}
; 	End:divide_ ;}
;{ 	modInt
	; return x mod n for bigInt x and integer n.
	modInt(x, n) {
		c := 0
		i := x.Count - 1
		while (i >= 0)
		{
			tmp := c * MfBigInt.radix + x.Item[i]
			c := mod(tmp, n)
			i--
		}
		return c
	}
; 	End:modInt ;}
;{ int2bigInt
	; convert the integer t into a bigInt with at least the given number of bits.
	; the returned array stores the bigInt in bpe-bit chunks, little endian (buff[0] is least significant word)
	; Pad the array with leading zeros so that it has at least minSize elements.
	; There will always be at least one leading 0 element.
	int2bigInt(t, bits, minSize) {   
	  
	  k := ceil(bits / MfBigInt.bpe) + 1
	  k := minSize > k ? minSize : k
	  buff := new MfBigInt.DList(k)
	  MfBigInt.copyInt_(buff, t)
	  return buff
	}
; End:int2bigInt ;}
;{ 	str2bigInt
	; return the bigInt given a string representation in a given base.  
	; Pad the array with leading zeros so that it has at least minSize elements.
	; If base=-1, then it reads in a comma-separated list of array elements in decimal.
	; The array will always have at least one leading zero, unless base=-1.
	str2bigInt(s, base, minSize) {
		sLst := MfBigInt.DList.FromString(s, false) ; string to list, ignore whitespace is false
		k := sLst.Count
		if (base = -1)
		{
		 	; comma-separated list of array elements in decimal
		 	x := new MfBigInt.DList()
		 	loop
		 	{
		 		y := new MfBigInt.DList(x.Count + 1)
		 		i := 0
		 		while (i < x.Count)
		 		{
		 			y.Item[i + 1] := x.Item[i]
		 			i++
		 		}
		 		y.Item[0] := MfBigInt._ParseInt(sLst, 10)
		 		x := y
		 		d := sLst.IndexOf(",")
		 		if (d < 1)
		 		{
		 			break
		 		}
		 		sLst := sLst.SubList(d + 1)
		 		if (sLst.Count = 0)
		 		{
		 			break
		 		}
		 	}
		 	if (x.Count < minSize)
		 	{
		 		y := new MfBigInt.DList(minSize)
		 		MfBigInt.copy_(y, x)
		 		return y
		 	}
		 	return x
		}
		x := MfBigInt.int2bigInt(0, base * k, 0)
		i := 0
		while (i < k)
		{
			d := MfBigInt.digitStr.IndexOf(sLst.Item[i])
			if (base <= 36 && d >= 36) ;convert lowercase to uppercase if base<=36
			{
				d -= 26
			}
			; stop at first illegal character
			if (d >= base || d < 0)
			{
				break
			}
			MfBigInt.multInt_(x, base)
			MfBigInt.addInt_(x, d)
			i++
		}
		k := x.Count
		; strip off leading zeros
		while (k > 0 && !x.Item[k - 1])
		{
			k--
		}
		k := minSize > k + 1 ? minSize : k + 1
		y := new MfBigInt.DList(k)
		kk := k < x.Count ? k : x.Count
		i := 0
		while (i < kk)
		{
			y.Item[i] := x.Item[i]
			i++
		}
		while (i < k)
		{
			y.Item[i] := 0
			i++
		}
		return y
	}
; 	End:str2bigInt ;}
;{ 	equalsInt
	; is bigint x equal to integer y?
	; y must have less than bpe bits
	equalsInt(x, y) {
		if (x.Item[0] != y)
		{
			return 0
		}
		i := 1
		while (i < x.Count)
		{
			if (x.Item[i])
			{
				return 0
			}
			i++
		}
		return 1
	}
; 	End:equalsInt ;}
;{ 	equals
	; are bigints x and y equal?
	; this works even if x and y are different lengths and have arbitrarily many leading zeros
	equals(x, y) {
		 k := x.Count < y.Count ? x.Count : y.Count
		 i := 0
		 while (i < k)
		 {
		 	if (x.Item[i] != y.Item[i])
		 	{
		 		return false
		 	}
		 	i++
		 }
		 if (x.Count > y.Count)
		 {
		 	while (i < x.Count)
		 	{
		 		if (x.Item[i])
		 		{
		 			return false
		 		}
		 		i++
		 	}
		 }
		 else
		 {
		 	while (i < y.Count)
		 	{
		 		if (y.Item[i])
		 		{
		 			return false
		 		}
		 		i++
		 	}
		 }
		 return true
	}
; 	End:equals ;}
;{ 	isZero
	;is the bigInt x equal to zero?
	isZero(x) {
		i := 0
		while (i < x.Count)
		{
			if (x.Item[i])
			{
				return false
			}
			i++
		}
		return true
	}
; 	End:isZero ;}
;{ 	bigInt2str
	; convert a bigInt into a string in a given base, from base 2 up to base 95.
	;Base -1 prints the contents of the array representing the number.
	bigInt2str(x, base) {
		s := ""
		if (MfBigInt.s6.Count != x.Count)
		{
			MfBigInt.s6 := MfBigInt.dup(x)
		}
		else
		{
			MfBigInt.copy_(MfBigInt.s6, x)
		}
		if (base = -1)
		{
			i := x.Count - 1
			while (i > 0)
			{
				s .= x.Item[i] . ","
				i--
			}
			s .= x.Item[0]
		}
		else
		{
			while (!MfBigInt.isZero(MfBigInt.s6))
			{
				t := MfBigInt.divInt_(MfBigInt.s6, base)
				s := MfBigInt.digitsStr.Item[t] . s
			}
		}
		if (s = "")
		{
			s := "0"
		}
		return s
	}
; 	End:bigInt2str ;}
;{ 	dup
	; returns a duplicate of bigInt x
	dub(x) {
		buff := new MfBigInt.DList(x.Count)
		MfBigInt.copy_(buff, x)
		return buff
	}
; 	End:dup ;}
;{ 	copy_
	; do x=y on bigInts x and y.  x must be an array
	; at least as big as y (not counting the leading zeros in y).
	copy_(ByRef x, y) {
		k := x.Count < y.Count ? x.Count : y.Count
		i := 0
		while (i < k)
		{
			x.Item[i] := y.Item[i]
			i++
		}
		i := k
		while (i < x.Count)
		{
			x.Item[i] := 0
			i++
		}
	}
; 	End:copy_ ;}
;{ 	copyInt_
	; do x=y on bigInt x and integer y.
	copyInt_(ByRef x, n) {
		c := n
		i := 0
		while (i < x.Count)
		{
			x.Item[i] := c & MfBigInt.mask
			c >>= MfBigInt.bpe
			i++
		}
	}
; 	End:copyInt_ ;}
;{ 	addInt_
	; do x=x+n where x is a bigInt and n is an integer.
	; x must be large enough to hold the result.
	addInt_(ByRef x, n) {
		x.Item[0] += n
		k := x.Count
		c := 0
		i := 0
		while (i < k)
		{
			c += x.Item[i]
			b := 0
			if (c < 0)
			{
				b := -(c >> MfBigInt.bpe)
				c += b * MfBigInt.radix
			}
			x.Item[i] := c & MfBigInt.mask
			c := (c >> MfBigInt.bpe) - b
			if (!c)
			{
				; stop carrying as soon as the carry is zero
				return
			}
			i++
		}
	}
; 	End:addInt_ ;}
;{ 	rightShift_
	; right shift bigInt x by n bits.  0 <= n < bpe.
	rightShift_(ByRef x, n) {
		 k := n // MfBigInt.bpe
		 if (k)
		 {
		 	i := 0
		 	while (i < x.Count - k)
		 	{
		 		x.Item[i] :=  x.Item[i + k]	
		 		i++
		 	}
		 	while (i < x.Count)
		 	{
		 		x.Item[i] := 0
		 		i++
		 	}
		 	n := mod(n, MfBigInt.bpe)
		 }
		 i := 0
		 while (i < x.Count -1)
		 {
		 	x.Item[i] := MfBigInt.mask & ((x.Item[i + 1] << (MfBigInt.bpe - n)) | (x.Item[i] >> n))
		 	i++
		 }
		 x.Item[i] >>= n
	}
; 	End:rightShift_ ;}
;{ 	halve_
	halve_(ByRef x) {
		i := 0
		while (i < x.Count - 1)
		{
			x.Item[i] := MfBigInt.mask & ((x.Item[i + 1] << (MfBigInt.bpe - 1)) | (x.Item[i] >> 1))
			i++
		}
		; most significant bit stays the same
		x.Item[i] := (x.Item[i] >> 1) | (x.Item[i] & (MfBigInt.radix >> 1))
	}
; 	End:halve_ ;}
;{ 	leftShift_
	; left shift bigInt x by n bits.
	leftShift_(ByRef x, n) {
		k := n // MfBigInt.bpe
		if (k)
		{
			i := x.Count
			While (i >= k)
			{
				x.Item[i] := x.Item[i - k]
				i--
			}
			while (i >= 0)
			{
				x.Item[i] := 0
				i--
			}
			n := mod(n, MfBigInt.bpe)
		}
		if (!n)
		{
			return
		}
		i := x.Count - 1
		while (i > 0)
		{
			x.Item[i] := MfBigInt.mask & ((x.Item[i] << n) | (x.Item[i - 1] >> (MfBigInt.bpe - n)))
			i--
		}
		x.Item[i] := MfBigInt.mask & (x.Item[i] << n)
	}
; 	End:leftShift_ ;}
;{ 	multInt_
	; do x=x*n where x is a bigInt and n is an integer.
	; x must be large enough to hold the result.
	multInt_(ByRef x, n) {
		if (!n)
		{
			return
		}
		k := x.Count
		c := 0
		i := 0
		while (i < k)
		{
			c += x.Item[i] * n
			b := 0
			if (c < 0)
			{
				b := -(c >> MfBigInt.bpe)
				c += b * MfBigInt.radix
			}
			x.Item[i] := c & MfBigInt.mask
			c := (c >> MfBigInt.bpe) - b
			i++
		}
	}
; 	End:multInt_ ;}
;{ 	divInt_
	; do x=floor(x/n) for bigInt x and integer n, and return the remainder
	divInt_(byRef x, n) {
		r := 0
		i := x.Count - 1
		while (i >= 0)
		{
			s := r * MfBigInt.radix + x.Item[i]
			x.Item[i] := s // n
			r := Mod(s , n)
			i--
		}
		return r
	}
; 	End:divInt_ ;}
;{ 	linComb_
	; do the linear combination x=a*x+b*y for bigInts x and y, and integers a and b.
	; x must be large enough to hold the answer.
	linComb_(ByRef x, y, a, b) {
		k := x.Count < y.Count ? x.Count : y.Count
		kk := x.Count
		c := 0
		i := 0
		while (i < k)
		{
			c += a * x.Item[i] + b * y.Item[i]
			x.Item[i] := c & MfBigInt.mask
			c >>= MfBigInt.bpe
			i++
		}
		i := k
		While (i < kk)
		{
			c += a * x.Item[i]
			x.Item[i] := c & MfBigInt.mask
			c >>= MfBigInt.bpe
			i++
		}
	}
; 	End:linComb_ ;}
;{ 	linCombShift_
	; do the linear combination x=a*x+b*(y<<(ys*bpe)) for bigInts x and y, and integers a, b and ys.
	; x must be large enough to hold the answer.
	linCombShift_(ByRef x, y, b, ys) {
		k := x.Count < ys + y.Count ? x.Count : ys + y.Count
		kk := x.Count
		c := 0
		i := ys
		while (i < k)
		{
			c += x.Item[i] + b * y.Item[i - ys]
			x.Item[i] := c & MfBigInt.mask
			c >>= MfBigInt.bpe
			i++
		}
		i := k
		while (c && i < kk)
		{
			c += x.Item[i]
			x.Item[i] := c & MfBigInt.mask
			c >>= MfBigInt.bpe
			i++
		}
	}
; 	End:linCombShift_ ;}
;{ 	addShift_
	; do x=x+(y<<(ys*bpe)) for bigInts x and y, and integers a,b and ys.
	; x must be large enough to hold the answer.
	addShift_(ByRef x, y, ys) {
		k := x.Count < ys + y.Count ? x.Count : ys + y.Count
		kk := x.Count
		c := 0
		i := ys
		while (i < k)
		{
			c += x.Item[i] + y.Item[i - ys]
			x.Item[i] := c & MfBigInt.mask
			c >>= MfBigInt.bpe
			i++
		}
		i := k
		while (c && i < kk)
		{
			c += x.Item[i]
			x.Item[i] := c & MfBigInt.mask
			c >>= MfBigInt.bpe
			i++
		}
	}
; 	End:addShift_ ;}
;{ 	subShift_
	; do x=x-(y<<(ys*bpe)) for bigInts x and y, and integers a,b and ys.
	; x must be large enough to hold the answer.
	subShift_(ByRef x, y, ys) {
		k := x.Count < ys + y.Count ? x.Count : ys + y.Count
		kk := x.Count
		c := 0
		i := ys
		while (i < k)
		{
			c += x.Item[i] - y.Item[i - ys]
			x.Item[i] := c & MfBigInt.mask
			c >>= MfBigInt.bpe
			i++
		}
		i := k
		while (c && i < kk)
		{
			c += x.Item[i]
			x.Item[i] := c & MfBigInt.mask
			c >>= MfBigInt.bpe
			i++
		}
	}
; 	End:subShift_ ;}
;{ 	sub_
	; do x=x-y for bigInts x and y.
	; x must be large enough to hold the answer.
	; negative answers will be 2s complement
	sub_(ByRef x, y) {
		k := x.Count < y.Count ? x.Count : y.Count
		c := 0
		i := 0
		while (i < k)
		{
			c += x.Item[i] - y.Item[i]
			x.Item[i] := c & MfBigInt.mask
			c >>= MfBigInt.bpe
			i++
		}
		i := k
		while (c && i < x.Count)
		{
			c += x.Item[i]
			x.Item[i] := c & MfBigInt.mask
			c >>= MfBigInt.bpe
			i++
		}
	}
; 	End:sub_ ;}
;{ 	add_
	; do x=x+y for bigInts x and y.
	; x must be large enough to hold the answer.
	add_(ByRef x, y) {
		k := x.Count < y.Count ? x.Count : y.Count
		c := 0
		i := 0
		while (i < k)
		{
			c += x.Item[i] + y.Item[i]
			x.Item[i] := c & MfBigInt.mask
			c >>= MfBigInt.bpe
			i++
		}
		i := k
		while (c && i < x.Count)
		{
			c += x.Item[i]
			x.Item[i] := c & MfBigInt.mask
			c >>= MfBigInt.bpe
			i++
		}
	}
; 	End:add_ ;}
;{ 	mult_
	; do x=x*y for bigInts x and y.  This is faster when y<x.
	mult_(ByRef x, y) {
		if (MfBigInt.ss.Count != 2 * x.Count)
		{
			MfBigInt.ss := new MfBigInt.DList(2 * x.length)
		}
		MfBigInt.copyInt_(MfBigInt.ss, 0)
		i := 0
		while (i < y.Count)
		{
			if (y.Item[i])
			{
				MfBigInt.linCombShift_(MfBigInt.ss, x, y.Item[i], i)
			}
			i++
		}
		MfBigInt.copy_(x, MfBigInt.ss)
	}
; 	End:mult_ ;}
;{ 	mod_
	; do x=x mod n for bigInts x and n.
	mod_(ByRef x, byRef n) {
		if (MfBigInt.s4.Count != x.Count)
		{
			MfBigInt.s4 := MfBigInt.dup(x)
		}
		else
		{
			MfBigInt.copy_(MfBigInt.s4, x)
		}
		if (s5.Count != x.Count)
		{
			MfBigInt.s5 := MfBigInt.dup(x)
		}
		MfBigInt.divide_(MfBigInt.s4, n, MfBigInt.s5, x) ; x = remainder of s4 / n
	}
; 	End:mod_ ;}
;{ 	multMod_
	; do x=x*y mod n for bigInts x,y,n.
	; for greater speed, let y<x.
	multMod_(ByRef x, ByRef y, ByRef n) {
		if (MfBigInt.s0.Count != 2 * x.Count)
		{
			MfBigInt.s0 := new MfBigInt.DList(2 * x.Count)
		}
		MfBigInt.copyInt_(MfBigInt.s0, 0)
		i := 0
		while (i < y.Count)
		{
			if(y.Item[i])
			{
				MfBigInt.linCombShift_(MfBigInt.s0, x, y.Item[i], i)
			}
			i++
		}
		MfBigInt.mod_(MfBigInt.s0, n)
		MfBigInt.copy_(x, MfBigInt.s0)
	}
; 	End:multMod_ ;}
;{ 	squareMod_
	; do x=x*x mod n for bigInts x,n.
	squareMod_(byRef x, byRef n) {
		kk := x.Count
		; ignore leading zeros in x
		while (kx > 0 && !x.Item[kx - 1])
		{
			kx--
		}
		; k=# elements in the product, which is twice the elements in the larger of x and n
		k := kx > n.Count ? 2 * kx : 2 * n.Count
		if (MfBigInt.s0.Count != k)
		{
			MfBigInt.s0 := new MfBigInt.DList(k)
		}
		MfBigInt.copyInt_(MfBigInt.s0, 0)
		i := 0
		while (i < kx)
		{
			c := MfBigInt.s0.Item[2 * i] + x.Item[i] * x.Item[i]
			MfBigInt.s0.Item[2 * i] := c & MfBigInt.mask
			c >>= MfBigInt.bpe
			j := i + 1
			while (j < kx)
			{
				c := MfBigInt.s0.Item[i + j] + 2 * x.Item[i] * x.Item[j] + c
				MfBigInt.s0.Item[i + j] := (c & MfBigInt.mask)
				c >>= MfBigInt.bpe
				j++
			}
			MfBigInt.s0.Item[i + kx] := c
			i++
		}
		MfBigInt.mod_(MfBigInt.s0, n)
		MfBigInt.copy_(x, MfBigInt.s0)
	}
; 	End:squareMod_ ;}
;{ 	trim
	; return x with exactly k leading zero elements
	trim(x, k) {
		i := x.Count
		while (i > 0 && !x.Item[i - 1])
		{
			i--
		}
		y := new MfBigInt.DList(i + k)
		MfBigInt.copy_(y, x)
		return y
	}
; 	End:trim ;}
;{ 	powMod_
	; do x=x**y mod n, where x,y,n are bigInts and ** is exponentiation.  0**0=1.
	; this is faster when n is odd.  x usually needs to have as many elements as n.
	powMod_(ByRef x, ByRef y, ByRef n) {
		if (MfBigInt.s7.Count != n.Count)
		{
			MfBigInt.s7 := MfBigInt.dup(n)
		}
		; for even modulus, use a simple square-and-multiply algorithm,
		; rather than using the more complex Montgomery algorithm.
		if ((n.Item[0] & 1) = 0)
		{
			MfBigInt.copy_(MfBigInt.s7, x)
			MfBigInt.copyInt_(x, 1)
			while (!MfBigInt.equalsInt(y, 0))
			{
				if (y.Item[0] & 1)
				{
					MfBigInt.multMod_(x, MfBigInt.s7, n)
				}
				MfBigInt.divInt_(y, 2)
				MfBigInt.squareMod_(MfBigInt.s7, n)
			}
			return
		}
		; calculate np from n for the Montgomery multiplications
		MfBigInt.copyInt_(MfBigInt.s7, 0)
		kn := n.Count
		while (kn > 0 && !n[kn - 1])
		{
			kn--
		}
		np := MfBigInt.radix - MfBigInt.inverseModInt(MfBigInt.modInt(n, MfBigInt.radix), MfBigInt.radix)
		MfBigInt.s7.Item[kn] := 1
		MfBigInt.multMod_(x, MfBigInt.s7, n) ; x = x * 2**(kn*bp) mod n

		if (MfBigInt.s3.Count != x.Count)
		{
			MfBigInt.s3 := MfBigInt.dup(x)
		}
		else
		{
			MfBigInt.copy_(MfBigInt.s3, x)
		}
		k1 := y.Count - 1
		; k1=first nonzero element of y
		while (k1 > 0 & !y.Item[k1])
		{
			k1--
		}
		if (y.Item[k1] = 0)
		{
			; anything to the 0th power is 1
			MfBigInt.copyInt_(x, 1)
			return
		}
		k2 := 1 << (MfBigInt.bpe - 1)
		; k2=position of first 1 bit in y[k1]
		while (k2 && !(y.Item[k1] & k2))
		{
			k2 >>= 1
		}
		loop
		{
			if (!(k2 >>= 1))
			{ 
				;look at next bit of y
				k1--
				if (k1 < 0)
				{
					MfBigInt.mont_(x, MfBigInt.one, n, np)
					return
				}
				k2 := 1 << (MfBigInt.bpe - 1)
			}
			MfBigInt.mont_(x, x, n, np)
			if (k2 & y.Item[k1]) ; if next bit is a 1
			{
				MfBigInt.mont_(x, MfBigInt.s3, n, np)
			}
		}
	}
; 	End:powMod_ ;}
;{ 	mont_
	; do x=x*y*Ri mod n for bigInts x,y,n, 
	;   where Ri = 2**(-kn*bpe) mod n, and kn is the 
	;   number of elements in the n array, not 
	;   counting leading zeros.  
	; x array must have at least as many elemnts as the n array
	; It's OK if x and y are the same variable.
	; must have:
	;   x,y < n
	;   n is odd
	;   np = -(n^(-1)) mod radix
	mont_(byRef x, ByRef y, ByRef n, np) {
		kn := n.Count
		ky := y.Count

		if (MfBigInt.sa.Count != kn)
		{
			MfBigInt.sa := new MfBigInt.DList(kn)
		}

		MfBigInt.copyInt_(MfBigInt.sa, 0)
		; ignore leading zeros of n
		while (kn > 0 && n.Item[kn - 1] = 0)
		{
			kn--
		}
		; ignore leading zeros of y
		while (ky > 0 && y.Item[ky - 1] = 0)
		{
			ky--
		}

		; sa will never have more than this many nonzero elements.
		ks := MfBigInt.sa.Count - 1

		; the following loop consumes 95% of the runtime for randTruePrime_() and powMod_() for large numbers
		i := 0
		while (i < kn)
		{
			t := MfBigInt.sa.Item[0] + x.Item[i] * y.Item[0]
			ui := ((t & MfBigInt.mask) * np) & MfBigInt.mask ; the inner "& mask" was needed on Safari (but not MSIE) at one time
			c := (t + ui * n.Item[0]) >> MfBigInt.bpe
			t := x.Item[i]

			; do sa=(sa+x[i]*y+ui*n)/b   where b=2**bpe.  Loop is unrolled 5-fold for speed
			j := 1
			while (j < ky - 4)
			{
				c += MfBigInt.sa.Item[j] + ui * n.Item[j] + t * y.Item[j]
				MfBigInt.sa.Item[j - 1] := c & MfBigInt.mask
				c >>= MfBigInt.bpe
				j++
				c += MfBigInt.sa.Item[j] + ui * n.Item[j] + t * y.Item[j]
				MfBigInt.sa.Item[j - 1] := c & MfBigInt.mask
				c >>= MfBigInt.bpe
				j++
				c += MfBigInt.sa.Item[j] + ui * n.Item[j] + t * y.Item[j]
				MfBigInt.sa.Item[j - 1] := c & MfBigInt.mask
				c >>= MfBigInt.bpe
				j++
				c += MfBigInt.sa.Item[j] + ui * n.Item[j] + t * y.Item[j]
				MfBigInt.sa.Item[j - 1] := c & MfBigInt.mask
				c >>= MfBigInt.bpe
				j++
				c += MfBigInt.sa.Item[j] + ui * n.Item[j] + t * y.Item[j]
				MfBigInt.sa.Item[j - 1] := c & MfBigInt.mask
				c >>= MfBigInt.bpe
				j++
			}
			while (j < ky)
			{
				c += MfBigInt.sa.Item[j] + ui * n.Item[j] + t * y.Item[j]
				MfBigInt.sa.Item[j - 1] := c & MfBigInt.mask
				c >>= MfBigInt.bpe
				j++
			}
			while (j < kn - 4)
			{
				c += MfBigInt.sa.Item[j] + ui * n.Item[j]
				MfBigInt.sa.Item[j - 1] := c & MfBigInt.mask
				c >>= MfBigInt.bpe
				j++
				c += MfBigInt.sa.Item[j] + ui * n.Item[j]
				MfBigInt.sa.Item[j - 1] := c & MfBigInt.mask
				c >>= MfBigInt.bpe
				j++
				c += MfBigInt.sa.Item[j] + ui * n.Item[j]
				MfBigInt.sa.Item[j - 1] := c & MfBigInt.mask
				c >>= MfBigInt.bpe
				j++
				c += MfBigInt.sa.Item[j] + ui * n.Item[j]
				MfBigInt.sa.Item[j - 1] := c & MfBigInt.mask
				c >>= MfBigInt.bpe
				j++
				c += MfBigInt.sa.Item[j] + ui * n.Item[j]
				MfBigInt.sa.Item[j - 1] := c & MfBigInt.mask
				c >>= MfBigInt.bpe
				j++
			}
			while (j < kn)
			{
				c += sa.Item[j] + ui * n.Item[j]
				MfBigInt.sa.Item[j - 1] := c & MfBigInt.mask
				c >>= MfBigInt.bpe
				j++
			}
			while (j < ks)
			{
				c += MfBigInt.sa.Item[j]
				MfBigInt.sa.Item[j - 1] := c & MfBigInt.mask
				c >>= MfBigInt.bpe
				j++
			}
			MfBigInt.sa.Item[j - 1] := c & MfBigInt.mask
			i++
		}
		if (!MfBigInt.greater(n, MfBigInt.sa))
		{
			MfBigInt.sub_(MfBigInt.sa, n)
		}
		MfBigInt.copy_(x, MfBigInt.sa)
	}
; 	End:mont_ ;}
; End:Methods ;}
	
;{ Internal Methods
	_ParseInt(s) {
		if (MfObject.IsObjInstance(s, MfBigInt.DList))
		{
			lst := s
		}
		else
		{
			
			lst := MfBigInt.DList.FromString(s, false) ; ignore whitespace
		}
		
		if (lst.Count = 0)
		{
			return 0
		}
		i := 0
		IsNeg := false
		StartIndex := 0
		if (lst.Item[0] = "-")
		{
			i++
			StartIndex++
			IsNeg := true
		}
		if (lst.Item[0] = "+")
		{
			i++
			StartIndex++
		}
		while (i < lst.Count)
		{
			if(Mfunc.IsInteger(lst.Item[i]) = false)
			{
				break
			}
			i++

		}
		int := lst.ToString("",StartIndex, i)
		if (MfString.IsNullOrEmpty(int))
		{
			return 0
		}
		else if (int = 0)
		{
			return 0
		}
		else
		{
			int := int + 0
			return IsNeg? -int:int
		}
		
	}
;{ 	Random_
	; generates a random number between 0.0 and 1.0 with decimal percision of 16
	Random_() {
		wf := A_FormatFloat
		SetFormat, FloatFast, 0.16
		rand := 0.0
		rand := Mfunc.Random(0.0, 1.0)
		SetFormat, FloatFast, %wf%
		return rand
	}
; 	End:Random_ ;}
; End:Internal Methods ;}

;{ Internal Classes
;{ 	class DigitsChars
	class DigitsChars extends MfList
	{
		__new() {
			base.__new()
			if (this.__Class != "MfBigInt.DigitsChars" && this.__Class != "DigitsChars") {
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Sealed_Class","MfString"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			_digitsStr := "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_=!@#$%^&*()[]{}|;:,.<>/?``~ \'""+-"
			Loop, Parse, _digitsStr
			{
				_newCount := this.m_InnerList.Count + 1
				this.m_InnerList[_newCount] := A_LoopField
				this.m_InnerList.Count := _newCount
				;this.Add(A_LoopField)
			}
			this.m_IsFixedSize := true
			this.m_IsReadOnly := true
			this.m_isInherited := false
		}
	;{ 	methods
	;{ 	Contains()			- Overrides - MfListBase
	/*!
		Method: Contains()
			Overrides MfListBase.Contains()
		Contains(obj)
			Determines whether the MfList contains a specific element.
		Parameters
			obj
				The Object to locate in the MfList
			Returns
				Returns true if the MfList contains the specified value otherwise, false.
		Throws
			Throws MfNullReferenceException if called as a static method.
		Remarks
			This method performs a linear search; therefore, this method is an O(n) operation, where n is Count.
			This method determines equality by calling MfObject.CompareTo().
	*/
		Contains(obj) {
			this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
			bObj := IsObject(obj)
			if (IsObject(obj))
			{
				return false
			}
			retval := false
			
			for k, v in this
			{
				; case sensitive search
				if (obj == v) {
					retval := true
					break
				}
			}
			return retval
		}
	;	End:Contains(obj) ;}
	;{ 	Clone
		; override base
	Clone() {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		return  := new MfBigInt.DigitsChars()
	}
; 	End:Clone ;}
	;{ 	IndexOf()			- Overrides - MfListBase
	/*
		Method: IndexOf()
			Overrides MfListBase.IndexOf()
		IndexOf(obj)
			Searches for the specified Object and returns the zero-based index of the first occurrence within the entire MfList.
		Parameters
			obj
				The object to locate in the MfList
		Returns
			Returns  index of the first occurrence of value within the entire MfList,
		Throws
			Throws MfNullReferenceException if called as a static method.
		Remarks
			This method performs a linear search; therefore, this method is an O(n) operation, where n is Count.
			This method determines equality by calling MfObject.CompareTo().
	*/
		IndexOf(obj) {
			this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
			i := 0
			bFound := false
			if (IsObject(obj))
			{
				return -1
			}
			int := -1
			for k, v in this
			{
				; case sensitive search
				if (obj == v) {
					bFound := true
					break
				}
				i++
			}
			if (bFound = true) {
				int := i
				return int
			}
			return int
		}
	;	End:IndexOf() ;}
	/*
		Method: Is()
		Overrides MfObject.Is()
		
			OutputVar := instance.Is(ObjType)

		Is(ObjType)
			Gets if current instance of MfEnum.EnumItem is of the same type as ObjType or derived from ObjType.
		Parameters
			ObjType
				The object or type to compare to this instance Type.
				ObjType can be an instance of MfType or an object derived from MfObject or an instance of or a string containing
				the name of the object type such as "MfObject"
		Returns
			Returns true if current object instance is of the same Type as the ObjType or if current instance is derived
			from ObjType or if ObjType = "MfEnum.EnumItem" or ObjType = "EnumItem"; Otherwise false.
		Remarks
			If a string is used as the Type case is ignored so "MfObject" is the same as "mfobject"
	*/
		Is(ObjType) {
			typeName := MfType.TypeOfName(ObjType)
			if ((typeName = "MfBigInt.DigitsChars") || (typeName = "DigitsChars")) {
				return true
			}
			return base.Is(typeName)
		}
	; End:Is() ;}
; 	End:methods ;}
	;{	IsFixedSize[]
;{ 	Properties
	m_IsFixedSize := false
	/*!
		Property: IsFixedSize [get]
			Gets a value indicating if the MfListBase has a fixed size.
		Value:
			Boolean var
		Gets:
			Returns False
		Remarks:
			Read-only property.
			Can be overridden in derived classes.
	*/
		IsFixedSize[]
		{
			get {
				return this.m_IsFixedSize
			}
			set {
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				Throw ex
			}
		}
	;	End:IsFixedSize[] ;}
	m_IsReadOnly := false
	;{	IsReadOnly[]
	/*
		Property: IsReadOnly [get]
			Gets a value indicating if the MfListBase is read-only.
		Value:
			Boolean var
		Gets:
			Returns False
		Remarks:
			Read-only property.
			Can be overridden in derived classes.
	*/
		IsReadOnly[]
		{
			get {
				return return this.m_IsReadOnly
			}
			set {
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				Throw ex
			}
		}
	;	End:IsReadOnly[] ;}
	} 
; 	End:Properties ;}
; 	End:class DigitsChars ;
;{ 	class DList
	; zero based index list that can contain var value of number or string
	; adding of objects to this list is not supported
	; List is case sensitive
	; constructor parame Size determins the default number of element in the list
	; constructor param default determinst the defalut value added to the list if Size is > 0
	;	default can be null such as ""
	class DList extends MfList
	{
		__new(Size=0, default=0) {
			base.__new()
			if (Size > 0)
			{
				i := 0
				while (i <= size)
				{
					this.Add(default)
					i++
				}
			}

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
			_newCount := this.m_InnerList.Count + 1
			this.m_InnerList[_newCount] := obj
			this.m_InnerList.Count := _newCount
			retval := _newCount - 1
			return retval
		}
	;	End:Add(value) ;}
	;{ 	Clone
		Clone() {
			cLst := new MfBigInt.DList(0)
			cLst.Clear()
			for i, n in this
			{
				cLst.Add(n)
			}
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
			if (this.Count <= 0) {
				return retval
			}
			for k, v in this
			{
				if (obj == v) {
					retval := true
					break
				}
			}
			return retval
		}
	;	End:Contains(obj) ;}
		FromString(s, includeWhiteSpace=true) {
			this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
			lst := new MfBigInt.DList()
			if (s = "")
			{
				return lst
			}
			Loop, Parse, s
			{
				if (includeWhiteSpace)
				{
					lst.Add(A_LoopField)
				}
				else
				{
					if (A_LoopField == " " || A_LoopField = "`r" || A_LoopField = "`n")
					{
						continue
					}
					lst.Add(A_LoopField)
				}
			}
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
			while (i < this.Count)
			{
				v := this.Item[i]
				if (obj == v) {
					bFound := true
					break
				}
				i++
			}
			if (bFound = true) {
				int := i
				return int
			}
			return int
		}
	;	End:IndexOf() ;}
	;{ 	Insert()			- Overrides - MfListBase
	/*!
		Method: Insert()
			Overrides MfList.Insert()
		Insert(index, obj)
			Inserts an element into the MfList at the specified index.
		Parameters
			index
				The zero-based index at which value should be inserted.
			obj
				The object to insert.
		Throws
			Throws MfArgumentOutOfRangeException if index is less than zero.-or index is greater than MfList.Count
		Remarks
			If index is equal to Count, value is added to the end of MfGenericList.
			In MfList the elements that follow the insertion point move down to accommodate the new element.
			This method is an O(n) operation, where n is Count.
	*/
		Insert(index, obj) {
			
			if ((index < 0) || (index > this.Count))
			{
				ex := new MfArgumentOutOfRangeException("index", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			If (index = this.Count)
			{
				this.Add(obj)
				return
			}
			i := index + 1 ; step up to one based index for AutoHotkey array
			this.m_InnerList.InsertAt(i, obj)
			this.m_InnerList.Count ++
		}
	;	End:Insert(index, obj) ;}
	;{ 	Is()				- Overrides - MfPrimitive
	/*
		Method: Is()
		Overrides MfObject.Is()
		
			OutputVar := instance.Is(ObjType)

		Is(ObjType)
			Gets if current instance of MfEnum.EnumItem is of the same type as ObjType or derived from ObjType.
		Parameters
			ObjType
				The object or type to compare to this instance Type.
				ObjType can be an instance of MfType or an object derived from MfObject or an instance of or a string containing
				the name of the object type such as "MfObject"
		Returns
			Returns true if current object instance is of the same Type as the ObjType or if current instance is derived
			from ObjType or if ObjType = "MfEnum.EnumItem" or ObjType = "EnumItem"; Otherwise false.
		Remarks
			If a string is used as the Type case is ignored so "MfObject" is the same as "mfobject"
	*/
		Is(ObjType) {
			typeName := MfType.TypeOfName(ObjType)
			if ((typeName = "MfBigInt.DList") || (typeName = "DList")) {
				return true
			}
			return base.Is(typeName)
		}
	; End:Is() ;}
	;{ 	RemoveAt()			- Overrides - MfListBase
	/*!
		Method: RemoveAt()
			Overrides MfList.RemoveAt()
		RemoveAt()
			Removes the MfList item at the specified index.
		Parameters
			index
				The zero-based index of the item to remove.
				Can be instance of MfInteger or var integer.
		Returns
			On Success returns the Object or var that was removed at index; Otherwise returns null.
		Throws
			Throws MfArgumentOutOfRangeException if index is less than zero.-or index is equal to or greater than Count
		Remarks
			This method is not overridable.
			In MfGenericList the elements that follow the removed element move up to occupy the vacated spot.
			This method is an O(n) operation, where n is Count.
	*/
		RemoveAt(index) {
			_index := index
			if ((_index < 0) || (_index >= this.m_InnerList.Count)) {
				ex := new MfArgumentOutOfRangeException("index", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			i := _index + 1 ; step up to one based index for AutoHotkey array
			vRemoved := this.m_InnerList.RemoveAt(i)
			iLen := this.m_InnerList.Length()
			; if vremoved is an empty string or vRemoved is 0 then, If (vRemoved ) would computed to false
			if (iLen = _index) {
				this.m_InnerList.Count --
			} else {
				ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_FailedToRemove"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			return vRemoved
		}
	;	End:RemoveAt(int) ;}
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
				len := maxIndex
			}
			
			
			i := startIndex
			iCount := 0
			while iCount < len
			{
				v := this.Item[i]
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
		SubList(startIndex=0, endIndex="") {
			lst := new MfBigInt.DList()
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
				len := maxIndex
			}
			
			
			i := startIndex
			iCount := 0
			while iCount < len
			{
				lst.Add(this.Item[i])
				i++
				iCount++
			}
			return lst

		}
; 		End:SubList ;}
	;{ 	Properties
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
				_index := Index
				if (_index < 0 || _index >= this.Count) {
					return ""
				}
				_index ++ ; increase value for one based array
				return this.m_InnerList[_index]
			}
			set {
				_index := Index
				if (_index >= this.Count) {
					ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				if (_index >= this.Count) {
					i := this.Count - 1
					while (i <= _index)
					{
						this.Add(0)
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
;{ Internal Classes
}