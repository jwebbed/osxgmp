/*
This file is part of OSXGMP.

OSXGMP is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

OSXGMP is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with OSXGMP.  If not, see <http://www.gnu.org/licenses/>.
*/
//
//  BigInt.swift
//  BigNumber
//
//  Created by Otto van Verseveld on 9/17/14.
//  Copyright (c) 2014 Otto van Verseveld. All rights reserved.
//

import Foundation

public enum BigIntError: Error {
    case EmptyStringNumber
    case InvalidBaseNumber
    case InvalidNumberFormat
}

open class BigInt : BigIntObjC {
    deinit {
//        println("calling deinit of \(self)")
    }
    
    //MARK: - GMP Paragraph 5.1 Initialization Functions.
    public override init() {
        super.init()
    }
    public init(nr: BigIntObjC) {
        super.init(bigInt: nr)
    }
    public init(doubleNr: Double) {
        super.init(double: doubleNr)
    }
    public init(intNr: Int) {
        super.init(sLong: intNr)
    }
    public init(uintNr: UInt) {
        super.init(uLong: uintNr)
    }
    fileprivate init(nr: String, base: Int32) throws {
        super.init();
        try self.setStringAndBase(nr, base: base)
    }
    public convenience init(stringNr: String, error: NSErrorPointer) throws {
        try self.init(nr: stringNr, base: 10)
    }
    public convenience init(stringNr: String) throws {
        try self.init(nr: stringNr, base: 10)
    }
    public convenience init(stringNr: String, base: Int32) throws {
        try self.init(nr: stringNr, base: base)
    }
    fileprivate func setStringAndBase(_ stringNr: String, base: Int32) throws {
        guard ((base == 0) || ((base > 1) && (base < 63))) else {
            throw BigIntError.InvalidBaseNumber
        }
        guard stringNr.characters.count > 0 else {
            throw BigIntError.EmptyStringNumber
        }
        var err : NSError?
        let mpzSetStr = super.setFrom(stringNr, withBase: base, error: &err)
        guard !((mpzSetStr == -1) && (stringNr.characters.count > 0)) else {
            throw BigIntError.InvalidNumberFormat
        }
    }

    //- GMP Paragraph 5.3 Combined Initialization and Assignment Functions.
    //=> see 5.1 above!
    
    //MARK: - GMP Paragraph 5.4 Conversion Functions.
    public func toInt() -> Int {
        return (Int)(toSLong())
    }
    public func toUInt() -> UInt {
        return (UInt)(toULong())
    }
    
    //MARK: - GMP Paragraph 5.8 Root Extraction Functions.
    open override class func isPerfectPower(_ op: BigIntObjC) -> Bool {
        return super.isPerfectPower(op)
    }
    open override func isPerfectPower() -> Bool {
        return super.isPerfectPower()
    }
    open override class func isPerfectSquare(_ op: BigIntObjC) -> Bool {
        return super.isPerfectSquare(op)
    }
    open override func isPerfectSquare() -> Bool {
        return super.isPerfectSquare()
    }
    open override class func root(_ op: BigIntObjC, n: GMP_ULONG) -> BigInt {
        return BigInt(nr: super.root(op, n: n))
    }
    open override func root(_ n: GMP_ULONG) -> BigInt {
        return BigInt(nr: super.root(n))
    }
    open override class func sqrt(_ op: BigIntObjC) -> BigInt {
        return BigInt(nr: super.sqrt(op))
    }
    open override func sqrt() -> BigInt {
        return BigInt(nr: super.sqrt())
    }
}

/*----------------------------------------------------------------------------*\
 |  NOTE1: All possible operators are prefixed with BIOP-NN (BigInt OPerator),
 |         where NN=1,...,55
 |
 |  NOTE2: From e.g.
 |    https://medium.com/swift-programming/facets-of-swift-part-5-custom-operators-1080bc78ccc
 |    we learn that we can NOT overload the following:
 |    // ternary-operator:
 |      ? :
 |    // infix-operators:
 |      = is as as? ??
 |    // prefix-operator:
 |      &
 |    // postfix-operator:
 |      ? !
 |    The related BIOP-NN operators start with the prefixed-comment "//X (BIOP-NN)".
 |
 |  NOTE3: Based on the Swift standard library operator overview from e.g.
 |    http://nshipster.com/swift-operators/ and
 |    https://developer.apple.com/library/ios/documentation/swift/conceptual/swift_programming_language/Expressions.html
 |         all candidate operators to be implemented for BigInt can be found.
 |         The overview is sorted (descending) by precedence value.
\*----------------------------------------------------------------------------*/

//MARK: - Prefix operators
//- (BIOP_01) Increment: prefix operator ++
//- (BIOP_02) Decrement: prefix operator --
//- (BIOP_03) Unary plus: prefix operator +
//- (BIOP_04) Unary minus: prefix operator -
//- (BIOP_05) Logical NOT: prefix operator !
//- (BIOP_06) Bitwise NOT: prefix operator ~


//MARK: - Infix operators
//MARK: -- Exponentiative
//MARK: ---- (BIOP_07) Power:
infix operator ** : BitwiseShiftPrecedence
public func ** (lhs: BigInt, rhs: UInt) -> BigInt {
    return BigInt(nr: BigIntObjC.power(lhs, exp: rhs))
}
//- (BIOP_08) Bitwise left shift: infix operator << BitwiseShiftPrecedence
//- (BIOP_09) Bitwise right shift: infix operator >> BitwiseShiftPrecedence

//MARK: -- Multiplicative
//MARK: ---- (BIOP_10) Multiply:
infix operator * : MultiplicationPrecedence
public func * (lhs: BigInt, rhs: BigInt) -> BigInt {
    return BigInt(nr: BigIntObjC.mul(lhs, op2: rhs))
}
public func * (lhs: BigInt, rhs: Int) -> BigInt {
    return BigInt(nr: BigIntObjC.mulSLong(lhs, op2: rhs))
}
public func * (lhs: BigInt, rhs: UInt) -> BigInt {
    return BigInt(nr: BigIntObjC.mulULong(lhs, op2: rhs))
}
public func * (lhs: Int, rhs: BigInt) -> BigInt {
    return BigInt(nr: BigIntObjC.mulSLong(rhs, op2: lhs))
}
public func * (lhs: UInt, rhs: BigInt) -> BigInt {
    return BigInt(nr: BigIntObjC.mulULong(rhs, op2: lhs))
}
//MARK: ==-- (BIOP_11) Divide:
infix operator / : MultiplicationPrecedence
public func / (lhs: BigInt, rhs: BigInt) -> BigInt {
    return BigInt(nr: BigIntObjC.div(lhs, d: rhs))
}
public func / (lhs: BigInt, rhs: Int) -> BigInt {
    return BigInt(nr: BigIntObjC.divSLong(lhs, d: rhs))
}
public func / (lhs: BigInt, rhs: UInt) -> BigInt {
    return BigInt(nr: BigIntObjC.divULong(lhs, d: rhs))
}
public func / (lhs: Int, rhs: BigInt) -> BigInt {
    return BigInt(nr: BigIntObjC.div(BigInt(intNr: lhs), d: rhs))
}
public func / (lhs: UInt, rhs: BigInt) -> BigInt {
    return BigInt(nr: BigIntObjC.div(BigInt(uintNr: lhs), d: rhs))
}
//MARK: ==-- (BIOP_12) Remainder:
infix operator % : MultiplicationPrecedence
public func % (lhs: BigInt, rhs: BigInt) -> BigInt {
    return BigInt(nr: BigIntObjC.mod(lhs, d: rhs))
}
public func % (lhs: BigInt, rhs: Int) -> BigInt {
    return BigInt(nr: BigIntObjC.mod(lhs, d: BigInt(intNr: rhs)))
}
public func % (lhs: BigInt, rhs: UInt) -> BigInt {
    return BigInt(nr: BigIntObjC.mod(lhs, d: BigInt(uintNr: rhs)))
}
public func % (lhs: Int, rhs: BigInt) -> BigInt {
    return BigInt(nr: BigIntObjC.mod(BigInt(intNr: lhs), d: rhs))
}
public func % (lhs: UInt, rhs: BigInt) -> BigInt {
    return BigInt(nr: BigIntObjC.mod(BigInt(uintNr: lhs), d: rhs))
}
//- (BIOP_13) Multiply, ignoring overflow: infix operator &* MultiplicationPrecedence
//- (BIOP_14) Divide, ignoring overflow: infix operator &/ MultiplicationPrecedence
//- (BIOP_15) Remainder, ignoring overflow: infix operator &% MultiplicationPrecedence
//- (BIOP_16) Bitwise AND: infix operator & MultiplicationPrecedence

//MARK: -- Additive
//MARK: ---- (BIOP_17) Add:
infix operator + : AdditionPrecedence
public func + (lhs: BigInt, rhs: BigInt) -> BigInt {
    return BigInt(nr: BigIntObjC.add(lhs, op2: rhs))
}
public func + (lhs: BigInt, rhs: Int) -> BigInt {
    return BigInt(nr: BigIntObjC.addSLong(lhs, op2: rhs))
}
public func + (lhs: BigInt, rhs: UInt) -> BigInt {
    return BigInt(nr: BigIntObjC.addULong(lhs, op2: rhs))
}
public func + (lhs: Int, rhs: BigInt) -> BigInt {
    return BigInt(nr: BigIntObjC.addSLong(rhs, op2: lhs))
}
public func + (lhs: UInt, rhs: BigInt) -> BigInt {
    return BigInt(nr: BigIntObjC.addULong(rhs, op2: lhs))
}
//MARK: ---- (BIOP_18) Substract:
infix operator - : AdditionPrecedence
public func - (lhs: BigInt, rhs: BigInt) -> BigInt {
    return BigInt(nr: BigIntObjC.sub(lhs, op2: rhs))
}
public func - (lhs: BigInt, rhs: Int) -> BigInt {
    return BigInt(nr: BigIntObjC.subSLong(lhs, op2: rhs))
}
public func - (lhs: BigInt, rhs: UInt) -> BigInt {
    return BigInt(nr: BigIntObjC.subULong(lhs, op2: rhs))
}
public func - (lhs: Int, rhs: BigInt) -> BigInt {
    let res = BigInt(nr: BigIntObjC.subSLong(rhs, op2: lhs))
    res.neg()
    return res
}
public func - (lhs: UInt, rhs: BigInt) -> BigInt {
    let res = BigInt(nr: BigIntObjC.subULong(rhs, op2: lhs))
    res.neg()
    return res
}
//- (BIOP_19) Add with overflow: infix operator &+ AdditionPrecedence
//- (BIOP_20) Substract with overflow: infix operator &- AdditionPrecedence
//- (BIOP_21) Bitwise OR: infix operator | AdditionPrecedence
//- (BIOP_22) Bitwise XOR: infix operator ^ AdditionPrecedence

//MARK: -- Range
//- (BIOP_23) Half-open range: infix operator ..< RangeFormationPrecedence
//- (BIOP_24) Closed range: infix operator ... RangeFormationPrecedence

//MARK: -- Cast
//X (BIOP_25) Type check: infix operator is CastingPrecedence
//X (BIOP_26) Type cast: infix operator as CastingPrecedence

//MARK: -- Comparative
//MARK: ---- (BIOP_27) Less than:
infix operator < : ComparisonPrecedence
public func < (lhs: BigInt, rhs: BigInt) -> Bool {
    return lhs.compare(rhs) < 0
}
public func < (lhs: BigInt, rhs: Int) -> Bool {
    return lhs.compare(withSLong: rhs) < 0
}
public func < (lhs: BigInt, rhs: UInt) -> Bool {
    return lhs.compare(withULong: rhs) < 0
}
public func < (lhs: Int, rhs: BigInt) -> Bool {
    return rhs.compare(withSLong: lhs) > 0
}
public func < (lhs: UInt, rhs: BigInt) -> Bool {
    return rhs.compare(withULong: lhs) > 0
}
//MARK: ---- (BIOP_28) Less than or equal:
infix operator <= : ComparisonPrecedence
public func <= (lhs: BigInt, rhs: BigInt) -> Bool {
    return lhs.compare(rhs) <= 0
}
public func <= (lhs: BigInt, rhs: Int) -> Bool {
    return lhs.compare(withSLong: rhs) <= 0
}
public func <= (lhs: BigInt, rhs: UInt) -> Bool {
    return lhs.compare(withULong: rhs) <= 0
}
public func <= (lhs: Int, rhs: BigInt) -> Bool {
    return rhs.compare(withSLong: lhs) > 0
}
public func <= (lhs: UInt, rhs: BigInt) -> Bool {
    return rhs.compare(withULong: lhs) > 0
}
//MARK: ---- (BIOP_29) Greater than:
infix operator > : ComparisonPrecedence
public func > (lhs: BigInt, rhs: BigInt) -> Bool {
    return lhs.compare(rhs) > 0
}
public func > (lhs: BigInt, rhs: Int) -> Bool {
    return lhs.compare(withSLong: rhs) > 0
}
public func > (lhs: BigInt, rhs: UInt) -> Bool {
    return lhs.compare(withULong: rhs) > 0
}
public func > (lhs: Int, rhs: BigInt) -> Bool {
    return rhs.compare(withSLong: lhs) < 0
}
public func > (lhs: UInt, rhs: BigInt) -> Bool {
    return rhs.compare(withULong: lhs) < 0
}
//MARK: ---- (BIOP_30) Greater than or equal:
infix operator >= : ComparisonPrecedence
public func >= (lhs: BigInt, rhs: BigInt) -> Bool {
    return lhs.compare(rhs) >= 0
}
public func >= (lhs: BigInt, rhs: Int) -> Bool {
    return lhs.compare(withSLong: rhs) >= 0
}
public func >= (lhs: BigInt, rhs: UInt) -> Bool {
    return lhs.compare(withULong: rhs) >= 0
}
public func >= (lhs: Int, rhs: BigInt) -> Bool {
    return rhs.compare(withSLong: lhs) < 0
}
public func >= (lhs: UInt, rhs: BigInt) -> Bool {
    return rhs.compare(withULong: lhs) < 0
}
//MARK: ---- (BIOP_31) Equal:
infix operator == : ComparisonPrecedence
public func == (lhs: BigInt, rhs: BigInt) -> Bool {
    return lhs.compare(rhs) == 0
}
public func == (lhs: BigInt, rhs: Int) -> Bool {
    return lhs.compare(withSLong: rhs) == 0
}
public func == (lhs: BigInt, rhs: UInt) -> Bool {
    return lhs.compare(withULong: rhs) == 0
}
public func == (lhs: Int, rhs: BigInt) -> Bool {
    return rhs.compare(withSLong: lhs) == 0
}
public func == (lhs: UInt, rhs: BigInt) -> Bool {
    return rhs.compare(withULong: lhs) == 0
}
//MARK: ---- (BIOP_32) Not equal:
infix operator != : ComparisonPrecedence
public func != (lhs: BigInt, rhs: BigInt) -> Bool {
    return lhs.compare(rhs) != 0
}
public func != (lhs: BigInt, rhs: Int) -> Bool {
    return lhs.compare(withSLong: rhs) != 0
}
public func != (lhs: BigInt, rhs: UInt) -> Bool {
    return lhs.compare(withULong: rhs) != 0
}
public func != (lhs: Int, rhs: BigInt) -> Bool {
    return rhs.compare(withSLong: lhs) != 0
}
public func != (lhs: UInt, rhs: BigInt) -> Bool {
    return rhs.compare(withULong: lhs) != 0
}
//- (BIOP_33) Identical: infix operator === ComparisonPrecedence
//- (BIOP_34) Not identical: infix operator !== ComparisonPrecedence
//- (BIOP_35) Pattern match: infix operator ~= ComparisonPrecedence

//MARK: -- Conjunctive
//- (BIOP_36) Logical AND: infix operator && LogicalConjunctionPrecedence

//MARK: -- Disjunctive
//- (BIOP_37) Logical OR: infix operator || LogicalConjunctionPrecedence

//MARK: -- Nil Coalescing
// Note that despite the ordering in the file, NilCoalescingPrecedence fits above the ComparisonPrecedence
//X (BIOP_38) Nil coalescing: infix operator ?? NilCoalescingPrecedence

//MARK: -- Ternary Conditional
//X (BIOP_39) Ternary conditional: infix operator ?: TernaryPrecedence

//MARK: -- Assignment
//X (BIOP_40) Assign: infix operator = AssignmentPrecedence
//MARK: ---- (BIOP_41) Multiply and assign:
infix operator *= : AssignmentPrecedence
public func *= (lhs: inout BigInt, rhs: BigIntObjC) {
    return lhs.mul(rhs)
}
public func *= (lhs: inout BigInt, rhs: Int) {
    return lhs.mulSLong(rhs)
}
public func *= (lhs: inout BigInt, rhs: UInt) {
    return lhs.mulULong(rhs)
}
//- (BIOP_42) Divide and assign: infix operator /= AssignmentPrecedence
//- (BIOP_43) Remainder and assign: infix operator %= AssignmentPrecedence
//MARK: ---- (BIOP_44) Add and assign:
infix operator += : AssignmentPrecedence
public func += (lhs: inout BigInt, rhs: BigIntObjC) {
    return lhs.add(rhs)
}
public func += (lhs: inout BigInt, rhs: Int) {
    return lhs.addSLong(rhs)
}
public func += (lhs: inout BigInt, rhs: UInt) {
    return lhs.addULong(rhs)
}
//MARK: ---- (BIOP_45) Substract and assign:
infix operator -= : AssignmentPrecedence
public func -= (lhs: inout BigInt, rhs: UInt) {
    return lhs.subULong(rhs)
}
//- (BIOP_46) Power and assign: infix operator **= AssignmentPrecedence
//- (BIOP_47) Left bit shift and assign: infix operator <<= AssignmentPrecedence
//- (BIOP_48) Right bit shift and assign: infix operator >>= AssignmentPrecedence
//- (BIOP_49) Bitwise AND and assign: infix operator &= AssignmentPrecedence
//- (BIOP_50) Bitwise XOR and assign: infix operator ^= AssignmentPrecedence
//- (BIOP_51) Bitwise OR and assign: infix operator |= AssignmentPrecedence
//- (BIOP_52) Logical AND and assign: infix operator &&= AssignmentPrecedence
//- (BIOP_53) Logical OR and assign: infix operator ||= AssignmentPrecedence


//MARK: - Postfix operators
//- (BIOP_54) Increment: postfix operator ++
//- (BIOP_55) Decrement: postfix operator --
