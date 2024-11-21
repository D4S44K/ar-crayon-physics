import math
import traceback


def float_to_fixed_int(value, signed, integer_bits, fractional_bits):
    # return integer representation of a fixed point number
    if not signed and value < 0:
        raise ValueError("Negative value not allowed for unsigned fixed point")
    value = int(value * (2**fractional_bits))
    if value >= 2 ** (integer_bits + fractional_bits) and False:
        raise ValueError(f"Value {value} exceeds {integer_bits + fractional_bits} bits")
        print(f"Warning: value {value} exceeds {integer_bits + fractional_bits} bits")
        value = value % (2 ** (integer_bits + fractional_bits))
    return value


def float_to_fixed_str(value, signed, integer_bits, fractional_bits):
    # return binary representation of a fixed point number
    result = ""
    sign = value < 0
    value = float_to_fixed_int(value, signed, integer_bits, fractional_bits)
    #
    if signed:
        sign_rep = "1" if sign else "0"
        result += sign_rep
    value = abs(value)
    #
    if signed and sign:
        value = 2 ** (integer_bits + fractional_bits) - value
    value_rep = bin(value)[2:].zfill(integer_bits + fractional_bits)
    result += value_rep
    #
    total_len = (1 if signed else 0) + integer_bits + fractional_bits
    assert len(result) == total_len
    return result


def check_precision(fix1, fix2):
    # check if two fixed point numbers have the same precision
    if fix1.signed != fix2.signed or fix1.intb != fix2.intb or fix1.fracb != fix2.fracb:
        raise ValueError(
            f"Incompatible fixed point numbers: {fix1.total_bits()} and {fix2.total_bits()}"
        )


class FixedPointDecimal:
    def __init__(self, float_value, signed, integer_bits, fractional_bits):
        if not signed:
            raise ValueError("Unsigned fixed point not supported")
        self.fixed_value = float_to_fixed_int(
            float_value, signed, integer_bits, fractional_bits
        )
        self.signed = signed
        self.intb = integer_bits
        self.fracb = fractional_bits

    def total_bits(self):
        return (1 if self.signed else 0) + self.intb + self.fracb

    def max_rep(self):
        if self.signed:
            return (2 ** (self.intb + self.fracb - 1) - 1) / (2**self.fracb)
        else:
            return (2**self.intb + self.fracb - 1) / (2**self.fracb)

    def min_rep(self):
        if self.signed:
            return -(2 ** (self.intb + self.fracb - 1)) / (2**self.fracb)
        else:
            return 0

    def __str__(self):
        value_str = float_to_fixed_str(
            self.get_float(), self.signed, self.intb, self.fracb
        )
        return (
            f"FixedPointDecimal({value_str}, {self.signed}, {self.intb}, {self.fracb})"
        )

    def __repr__(self):
        return self.__str__()

    def __eq__(self, other):
        if isinstance(other, FixedPointDecimal):
            check_precision(self, other)
            return self.fixed_value == other.fixed_value
        elif isinstance(other, float):
            return self.get_float() == other
        else:
            raise ValueError("Unsupported type")

    def __gt__(self, other):
        if isinstance(other, FixedPointDecimal):
            check_precision(self, other)
            return self.fixed_value > other.fixed_value
        elif isinstance(other, float):
            return self.get_float() > other
        else:
            raise ValueError("Unsupported type")

    def __lt__(self, other):
        return not self.__gt__(other) and not self.__eq__(other)

    def __ge__(self, other):
        return self.__gt__(other) or self.__eq__(other)

    def __le__(self, other):
        return not self.__gt__(other)

    def add_wrap(self, other):
        check_precision(self, other)
        res_value = self.get_float() + other.get_float()
        if res_value >= 2**self.intb:
            res_value = 2**self.intb - 2 ** (-self.fracb)
        elif res_value < -(2**self.intb):
            res_value = -(2**self.intb)
        res = FixedPointDecimal(res_value, self.signed, self.intb, self.fracb)
        return res

    def __add__(self, other):
        check_precision(self, other)
        res_value = self.get_float() + other.get_float()
        if res_value >= 2**self.intb:
            print(f"Warning: overflow in addition; truncating")
            traceback.print_stack()
        res = FixedPointDecimal(res_value, self.signed, self.intb, self.fracb)
        return res

    def __sub__(self, other):
        check_precision(self, other)
        res_value = self.get_float() - other.get_float()
        if res_value < -(2**self.intb):
            print(f"Warning: underflow in subtraction; truncating")
            traceback.print_stack()
        res = FixedPointDecimal(res_value, self.signed, self.intb, self.fracb)
        return res

    def __mul__(self, other):
        check_precision(self, other)
        # if self.total_bits() > 18 or other.total_bits() > 18:
        #     raise ValueError(
        #         f"total bits exceed 18 in either operand. ({self.total_bits()}, {other.total_bits()})"
        #     )
        res_value = self.get_float() * other.get_float()
        res = FixedPointDecimal(res_value, self.signed, self.intb * 2, self.fracb * 2)
        return res

    def __truediv__(self, other):
        check_precision(self, other)
        if other.get_float() == 0:
            raise ValueError("Division by zero")
        res_value = self.get_float() / other.get_float()
        res = FixedPointDecimal(res_value, self.signed, self.intb, self.fracb)
        return res

    def __neg__(self):
        return FixedPointDecimal(-self.get_float(), self.signed, self.intb, self.fracb)

    def sqrt(self):
        if self.fixed_value < 0:
            raise ValueError("Square root of negative number")
        res = FixedPointDecimal(
            math.sqrt(self.get_float()),
            self.signed,
            self.intb,
            self.fracb,
        )
        return res

    def get_float(self):
        return self.fixed_value / (2**self.fracb)

    def convert(self, signed, integer_bits, fractional_bits):
        if signed != self.signed:
            raise ValueError("Cannot convert signedness")
        return FixedPointDecimal(
            self.get_float(), signed, integer_bits, fractional_bits
        )

    def to_sfix32(self):
        return self.convert(True, 20, 11)

    def to_sfix16(self):
        return self.convert(True, 10, 5)


class SFIX16(FixedPointDecimal):
    def __init__(self, float_value):
        super().__init__(float_value, True, 10, 5)

    def __str__(self):
        return f"SFIX16({self.get_float()})"


class SFIX32(FixedPointDecimal):
    def __init__(self, float_value):
        super().__init__(float_value, True, 20, 11)

    def __str__(self):
        return f"SFIX32({self.get_float()})"
