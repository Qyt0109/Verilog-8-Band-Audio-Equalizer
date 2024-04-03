import struct

def float_to_fixed_point_binary(value, total_bits, fraction_bits, is_signed=True):
    if is_signed:
        max_val = (1 << (total_bits - 1)) - 1
        min_val = -(1 << (total_bits - 1))
    else:
        max_val = (1 << total_bits) - 1
        min_val = 0

    if value > max_val:
        raise ValueError("Value exceeds maximum representable value for the given parameters")
    elif value < min_val:
        raise ValueError("Value is below minimum representable value for the given parameters")

    scale = 2 ** fraction_bits
    scaled_value = int(value * scale)
    return bin(scaled_value & (2 ** total_bits - 1))[2:].zfill(total_bits)

def fixed_point_binary_to_float(value, total_bits, fraction_bits, is_signed=True):
    scale = 2 ** fraction_bits

    if is_signed and value[0] == '1':
        # For signed numbers, if the MSB is 1, it's negative
        value_int = int(value, 2) - (1 << total_bits)
    else:
        value_int = int(value, 2)

    return value_int / scale

if __name__ == "__main__":
    # Example usage:
    value = -0.000158126130000594975399605401911173885
    total_bits = 16
    fraction_bits = 15
    is_signed = True

    print("Value:", value)

    fixed_point_representation = float_to_fixed_point_binary(value, total_bits, fraction_bits, is_signed)
    print("Fixed-point binary representation:", fixed_point_representation)

    converted_float = fixed_point_binary_to_float(fixed_point_representation, total_bits, fraction_bits, is_signed)
    print("Converted float value:", converted_float)

    print("Abs error:", abs(value - converted_float))
