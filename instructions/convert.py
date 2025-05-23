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

    # Read and parse lines from input
    instructions = []
    with open(input_path, 'r') as fin:
        for line in fin:
            parts = line.strip().split(maxsplit=1)
            if len(parts) == 2:
                hex_val, mnemonic = parts
                rev_bytes = reverse_bytes(hex_val)
                instructions.append((rev_bytes, mnemonic))
            elif len(parts) == 1 and parts[0].startswith("0x"):
                rev_bytes = reverse_bytes(parts[0])
                instructions.append((rev_bytes, ""))

    # Pad with zero instructions if less than 64
    while len(instructions) < 64:
        instructions.append(("00 00 00 00", ""))

    # Write output files
    with open(desc_path, 'w') as desc_out, open(hex_path, 'w') as hex_out:
        for i, (rev_bytes, mnemonic) in enumerate(instructions):
            pc = f"{i * 4:02X}"
            desc_out.write(f"0x{pc}:\t{rev_bytes}\t\t{mnemonic}")
            hex_out.write(f"{rev_bytes}")
            if(i != 63):
                desc_out.write('\n')
                hex_out.write('\n')

# Run the function
process_instructions("raw_instr.txt")
