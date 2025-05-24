def read_file_to_list(filename):
    """
    Reads a text file and returns a list where each element is a line in the file.

    :param filename: The name of the file to read.
    :return: A list of strings, where each string is a line from the file.
    """
    with open(filename, 'r') as file:
        lines = file.readlines()
        # Stripping newline characters from each line
        lines = [line.strip() for line in lines]
    return lines

class Instruction:
    """
    Parses and decodes a 32-bit RISC-V instruction in hexadecimal format.
    Supports core RV32I instructions and basic logging.
    """
    def __init__(self, instruction):
        # Convert to 32-bit binary string (MSB at index 0)
        self.binary_instr = format(int(instruction, 16), '032b')

        # Extract common fields (Different than ARM)
        self.opcode = int(self.binary_instr[25:32], 2)  # bits 6-0 (LSB side)
        self.rd = int(self.binary_instr[20:25], 2)      # destination register
        self.funct3 = int(self.binary_instr[17:20], 2)  # 3-bit function code
        self.rs1 = int(self.binary_instr[12:17], 2)     # source register 1
        self.rs2 = int(self.binary_instr[7:12], 2)      # source register 2
        self.funct7 = int(self.binary_instr[0:7], 2)    # 7-bit function code

        # Extract and process immediates
        self._extract_immediates()
        self._decode_instruction()

    def _extract_immediates(self):
        """Extract and sign-extend immediates for all instruction types"""
        # I-type
        self.imm_i = self._sign_extend(int(self.binary_instr[0:12], 2), 12)

        # S-type
        imm_s = int(self.binary_instr[0:7], 2) << 5 | int(self.binary_instr[20:25], 2)
        self.imm_s = self._sign_extend(imm_s, 12)

        # B-type
        imm_b = (int(self.binary_instr[0]) << 12 | int(self.binary_instr[24]) << 11 |
                 int(self.binary_instr[1:7], 2) << 5 | int(self.binary_instr[20:24], 2) << 1)
        self.imm_b = self._sign_extend(imm_b, 13)

        # U-type
        self.imm_u = int(self.binary_instr[0:20], 2) << 12  # Already shifted

        # J-type
        imm_j = (int(self.binary_instr[0]) << 20 | int(self.binary_instr[12:20], 2) << 12 |
                 int(self.binary_instr[11]) << 11 | int(self.binary_instr[1:11], 2) << 1)
        self.imm_j = self._sign_extend(imm_j, 21)

    def _sign_extend(self, value, bits):
        """Sign-extend a value to 32 bits"""
        if (value >> (bits - 1)) & 1:  # If sign bit set
            return value | (-1 << bits)
        return value
    
    def _decode_instruction(self):
        """Determine specific instruction based on opcode and function codes"""
        self.instruction_name = "UNKNOWN"

        # R-type instructions (OP-IMM for shifts)
        if self.opcode == 0x33:
            if self.funct3 == 0x0:
                self.instruction_name = "SUB" if self.funct7 == 0x20 else "ADD"
            elif self.funct3 == 0x1:
                self.instruction_name = "SLL"
            elif self.funct3 == 0x2:
                self.instruction_name = "SLT"  # New
            elif self.funct3 == 0x3:
                self.instruction_name = "SLTU"  # New
            elif self.funct3 == 0x4:
                self.instruction_name = "XOR"
            elif self.funct3 == 0x5:
                self.instruction_name = "SRL" if self.funct7 == 0x00 else "SRA"
            elif self.funct3 == 0x6:
                self.instruction_name = "OR"
            elif self.funct3 == 0x7:
                self.instruction_name = "AND"

        # I-type instructions
        elif self.opcode == 0x13:
            if self.funct3 == 0x0:
                self.instruction_name = "ADDI"
            elif self.funct3 == 0x1:
                self.instruction_name = "SLLI"
            elif self.funct3 == 0x2:
                self.instruction_name = "SLTI"  # New
            elif self.funct3 == 0x3:
                self.instruction_name = "SLTIU"  # New
            elif self.funct3 == 0x4:
                self.instruction_name = "XORI"
            elif self.funct3 == 0x5:
                self.instruction_name = "SRLI" if self.funct7 == 0x00 else "SRAI"
            elif self.funct3 == 0x6:
                self.instruction_name = "ORI"
            elif self.funct3 == 0x7:
                self.instruction_name = "ANDI"

        elif self.opcode == 0x03:
            if self.funct3 == 0x0:
                self.instruction_name = "LB"
            elif self.funct3 == 0x1:
                self.instruction_name = "LH"
            elif self.funct3 == 0x2:
                self.instruction_name = "LW"
            elif self.funct3 == 0x4:
                self.instruction_name = "LBU"
            elif self.funct3 == 0x5:
                self.instruction_name = "LHU"

        elif self.opcode == 0x23:
            if self.funct3 == 0x0:
                self.instruction_name = "SB"
            elif self.funct3 == 0x1:
                self.instruction_name = "SH"
            elif self.funct3 == 0x2:
                self.instruction_name = "SW"

        elif self.opcode == 0x63:
            if self.funct3 == 0x0:
                self.instruction_name = "BEQ"
            elif self.funct3 == 0x1:
                self.instruction_name = "BNE"
            elif self.funct3 == 0x4:
                self.instruction_name = "BLT"
            elif self.funct3 == 0x5:
                self.instruction_name = "BGE"
            elif self.funct3 == 0x6:
                self.instruction_name = "BLTU"
            elif self.funct3 == 0x7:
                self.instruction_name = "BGEU"

        elif self.opcode == 0x6F:
            self.instruction_name = "JAL"
        elif self.opcode == 0x67:
            self.instruction_name = "JALR"
        elif self.opcode == 0x37:
            self.instruction_name = "LUI"
        elif self.opcode == 0x17:
            self.instruction_name = "AUIPC"

    def log(self, logger):
        """Log instruction details with operand information"""
        logger.debug("****** Current Instruction *********")
        logger.debug("Binary: %s", self.binary_instr)
        logger.debug("Decoded: %s", self.instruction_name)

        # Updated operand logging
        if self.instruction_name in ["ADD", "SUB", "XOR", "OR", "AND",
                                     "SLL", "SRL", "SRA", "SLT", "SLTU"]:
            logger.debug("R-type: rd=x%d, rs1=x%d, rs2=x%d",
                         self.rd, self.rs1, self.rs2)

        elif self.instruction_name in ["ADDI", "XORI", "ORI", "ANDI",
                                       "SLTI", "SLTIU"]:  # New
            logger.debug("I-type: rd=x%d, rs1=x%d, imm=%d (0x%x)",
                         self.rd, self.rs1, self.imm_i, self.imm_i)

        elif self.instruction_name in ["SLLI", "SRLI", "SRAI"]:
            shamt = self.imm_i & 0x1F  # 5-bit shift amount
            logger.debug("Shift: rd=x%d, rs1=x%d, shamt=%d",
                         self.rd, self.rs1, shamt)
        
def reverse_hex_string_endiannes(hex_string):  
    reversed_string = bytes.fromhex(hex_string)
    reversed_string = reversed_string[::-1]
    reversed_string = reversed_string.hex()        
    return  reversed_string

class ByteAddressableMemory:
    def __init__(self, size):
        self.size = size
        self.memory = bytearray(size)  # Initialize memory as a bytearray of the given size

    def read(self, address):
        if address < 0 or address + 4 > self.size:
            raise ValueError("Invalid memory address or length")
        return_val = bytes(self.memory[address : address + 4])
        return_val = return_val[::-1]
        return return_val

    def write(self, address, data):
        if address < 0 or address + 4> self.size:
            raise ValueError("Invalid memory address or data length")
        data_bytes = data.to_bytes(4, byteorder='little')
        self.memory[address : address + 4] = data_bytes        
