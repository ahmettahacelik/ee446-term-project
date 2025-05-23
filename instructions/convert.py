import os

def reverse_bytes(hex_str):
    """Reverse 4-byte hex string (e.g., 0x12345678 -> 78 56 34 12)"""
    hex_str = hex_str[2:]  # remove '0x'
    bytes_list = [hex_str[i:i+2] for i in range(0, len(hex_str), 2)]
    return ' '.join(reversed(bytes_list))

def process_instructions(filename):
    base_path = os.path.dirname(os.path.abspath(__file__))
    input_path = os.path.join(base_path, filename)
    desc_path = os.path.join(base_path, "InstructionsDescription.txt")
    hex_path = os.path.join(base_path, "Instructions.hex")

    with open(input_path, 'r') as fin, \
         open(desc_path, 'w') as desc_out, \
         open(hex_path, 'w') as hex_out:

        for i, line in enumerate(fin):
            if i >= 64:
                break  # Limit to 64 instructions
            parts = line.strip().split(maxsplit=1)
            if len(parts) < 2:
                continue  # skip malformed lines
            hex_val, mnemonic = parts
            pc = f"{i * 4:02X}"
            rev_bytes = reverse_bytes(hex_val)

            desc_out.write(f"0x{pc}\t{rev_bytes}\t{mnemonic}\n")
            hex_out.write(f"{rev_bytes}\n")

# Run the function
process_instructions("raw_instr.txt")
