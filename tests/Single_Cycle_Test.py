# ==============================================================================
# Authors:              Doğu Erkan Arkadaş
#
# Cocotb Testbench:     For Single Cycle ARM Laboratory
#
# Description:
# ------------------------------------
# Test bench for the single cycle laboratory, used by the students to check their designs
#
# License:
# ==============================================================================

import logging
import cocotb
from Helper_lib import read_file_to_list,Instruction, ByteAddressableMemory,reverse_hex_string_endiannes
from Helper_Student import Log_Datapath,Log_Controller
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge, Edge, Timer
from cocotb.binary import BinaryValue

class TB:
    def __init__(self, Instruction_list,dut,dut_PC,dut_regfile):
        self.dut = dut
        self.dut_PC = dut_PC   
        self.dut_regfile = dut_regfile
        self.Instruction_list = Instruction_list
        #Configure the logger
        self.logger = logging.getLogger("Performance Model")
        self.logger.setLevel(logging.DEBUG)
        #Initial values are all 0 as in a FPGA
        self.PC = 0
        self.Register_File = [0 for _ in range(32)]

        #Memory is a special class helper lib to simulate HDL counterpart    
        self.memory = ByteAddressableMemory(4096)

        self.clock_cycle_count = 0        
          
    #Calls user populated log functions    
    def log_dut(self):
        Log_Datapath(self.dut,self.logger)
        Log_Controller(self.dut,self.logger)

    #Compares and logs the PC and register file of Python module and HDL design
    def compare_result(self):
        self.logger.debug("************* Performance Model / DUT Data  **************")
        self.logger.debug("PC:%d \t PC:%d",self.PC,self.dut_PC.value.integer)
        for i in range(32):
            self.logger.debug("Register%d: %d \t %d",i,self.Register_File[i], self.dut_regfile.Reg_Out[i].value.integer)
            assert self.Register_File[i] == self.dut_regfile.Reg_Out[i].value
        assert self.PC == self.dut_PC.value
        
    #Function to write into the register file
    def write_to_register_file(self, register_no, data):
        if register_no != 0:
            self.Register_File[register_no] = data & 0xFFFFFFFF # To make sure, the size is less than 32 bits

    #A model of the verilog code to confirm operation, data is In_data
    def performance_model (self):
        self.logger.debug("**************** Clock cycle: %d **********************",self.clock_cycle_count)
        self.clock_cycle_count = self.clock_cycle_count+1
        #Read current instructions, extract and log the fields
        self.logger.debug("**************** Instruction No: %d **********************",int((self.PC)/4))
        current_instruction = self.Instruction_list[int((self.PC)/4)]
        current_instruction = current_instruction.replace(" ", "")
        #We need to reverse the order of bytes since little endian makes the string reversed in Python
        current_instruction = reverse_hex_string_endiannes(current_instruction)

        self.PC = self.PC + 4
        #Call Instruction calls to get each field from the instruction
        instr = Instruction(current_instruction)
        instr.log(self.logger)

        name = instr.instruction_name
        rf = self.Register_File

        if name == "ADD":
            self.write_to_register_file(instr.rd, rf[instr.rs1] + rf[instr.rs2])
        elif name == "SUB":
            self.write_to_register_file(instr.rd, rf[instr.rs1] - rf[instr.rs2])
        elif name == "SLL":
            self.write_to_register_file(instr.rd, rf[instr.rs1] << (rf[instr.rs2] & 0x1F))
        elif name == "SLT":
            rs1_val = rf[instr.rs1] & 0xFFFFFFFF
            rs2_val = rf[instr.rs2] & 0xFFFFFFFF
            # Convert to signed 32-bit
            if rs1_val & 0x80000000:
                rs1_val -= 0x100000000
            if rs2_val & 0x80000000:
                rs2_val -= 0x100000000
            self.write_to_register_file(instr.rd, int(rs1_val < rs2_val))

        elif name == "SLTU":
            self.write_to_register_file(instr.rd, int((rf[instr.rs1] & 0xFFFFFFFF) < (rf[instr.rs2] & 0xFFFFFFFF)))
        elif name == "XOR":
            self.write_to_register_file(instr.rd, rf[instr.rs1] ^ rf[instr.rs2])
        elif name == "SRL":
            self.write_to_register_file(instr.rd, (rf[instr.rs1] & 0xFFFFFFFF) >> (rf[instr.rs2] & 0x1F))
        elif name == "SRA":

            val =  rf[instr.rs1]
            shamt = (rf[instr.rs2] & 0x1F)
            val &= 0xFFFFFFFF  # Force 32-bit
            if val & 0x80000000:
                # Negative number: fill with 1s from the left
                for _ in range(shamt):
                    val = (val >> 1) | 0x80000000
            else:
                # Positive number: normal shift
                val = val >> shamt
            result = val & 0xFFFFFFFF
            self.write_to_register_file(instr.rd,result)
        elif name == "OR":
            self.write_to_register_file(instr.rd, rf[instr.rs1] | rf[instr.rs2])
        elif name == "AND":
            self.write_to_register_file(instr.rd, rf[instr.rs1] & rf[instr.rs2])

        elif name == "ADDI":
            self.write_to_register_file(instr.rd, rf[instr.rs1] + instr.imm_i)
        elif name == "SLLI":
            self.write_to_register_file(instr.rd, rf[instr.rs1] << (instr.imm_i & 0x1F))
        elif name == "SLTI":
            rs1_val = rf[instr.rs1] & 0xFFFFFFFF
            imm_val = instr.imm_i & 0xFFFFFFFF
            if rs1_val & 0x80000000:
                rs1_val -= 0x100000000
            if imm_val & 0x80000000:
                imm_val -= 0x100000000
            self.write_to_register_file(instr.rd, int(rs1_val < imm_val))
        elif name == "SLTIU":
            self.write_to_register_file(instr.rd, int((rf[instr.rs1] & 0xFFFFFFFF) < (instr.imm_i & 0xFFFFFFFF)))
        elif name == "XORI":
            self.write_to_register_file(instr.rd, rf[instr.rs1] ^ instr.imm_i)
        elif name == "SRLI":
            self.write_to_register_file(instr.rd, (rf[instr.rs1] & 0xFFFFFFFF) >> (instr.imm_i & 0x1F))
        elif name == "SRAI":
            self.write_to_register_file(instr.rd, rf[instr.rs1] >> (instr.imm_i & 0x1F))
        elif name == "ORI":
            self.write_to_register_file(instr.rd, rf[instr.rs1] | instr.imm_i)
        elif name == "ANDI":
            self.write_to_register_file(instr.rd, rf[instr.rs1] & instr.imm_i)


        elif name == "LB":
            addr = rf[instr.rs1] + instr.imm_i
            if addr == 0x404:
                val = 0xFFFFFFFF
            else:
                val = int.from_bytes(self.memory.read(addr)[-1:], 'little', signed=True)
            self.write_to_register_file(instr.rd, val)
        elif name == "LH":
            addr = rf[instr.rs1] + instr.imm_i
            if addr == 0x404:
                val = 0xFFFFFFFF
            else:
                byte1 = self.memory.memory[addr]  # LSB
                byte2 = self.memory.memory[addr + 1]  # MSB
                val = int.from_bytes([byte1, byte2], byteorder='little', signed=True)
            self.write_to_register_file(instr.rd, val)

        elif name == "LW":
            addr = rf[instr.rs1] + instr.imm_i
            if addr == 0x404:
                val = 0xFFFFFFFF
            else:
                val = int.from_bytes(self.memory.read(addr), 'little', signed=True)
            self.write_to_register_file(instr.rd, val)
        elif name == "LBU":
            addr = rf[instr.rs1] + instr.imm_i
            if addr == 0x404:
                val = 0xFFFFFFFF
            else:
                val = int.from_bytes(self.memory.read(addr)[-1:], 'little', signed=False)
            self.write_to_register_file(instr.rd, val)
        elif name == "LHU":
            addr = rf[instr.rs1] + instr.imm_i
            if addr == 0x404:
                val = 0xFFFFFFFF
            else:
                byte1 = self.memory.memory[addr]  # LSB
                byte2 = self.memory.memory[addr + 1]  # MSB
                val = int.from_bytes([byte1, byte2], byteorder='little', signed=False)
            self.write_to_register_file(instr.rd, val)

        elif name == "SB":
            addr = rf[instr.rs1] + instr.imm_s
            self.memory.write(addr, rf[instr.rs2] & 0xFF)
        elif name == "SH":
            addr = rf[instr.rs1] + instr.imm_s
            self.memory.write(addr, rf[instr.rs2] & 0xFFFF)
        elif name == "SW":
            addr = rf[instr.rs1] + instr.imm_s
            self.memory.write(addr, rf[instr.rs2])

        elif name == "BEQ":
            if rf[instr.rs1] == rf[instr.rs2]: self.PC += instr.imm_b - 4
        elif name == "BNE":
            if rf[instr.rs1] != rf[instr.rs2]: self.PC += instr.imm_b - 4
        elif name == "BLT":
            rs1_val = rf[instr.rs1] & 0xFFFFFFFF
            rs2_val = rf[instr.rs2] & 0xFFFFFFFF
            if rs1_val & 0x80000000:
                rs1_val -= 0x100000000
            if rs2_val & 0x80000000:
                rs2_val -= 0x100000000
            if rs1_val < rs2_val:
                self.PC += instr.imm_b - 4  # -4 because PC already advanced
        elif name == "BGE":
            rs1_val = rf[instr.rs1] & 0xFFFFFFFF
            rs2_val = rf[instr.rs2] & 0xFFFFFFFF
            if rs1_val & 0x80000000:
                rs1_val -= 0x100000000
            if rs2_val & 0x80000000:
                rs2_val -= 0x100000000
            if rs1_val >= rs2_val:
                self.PC += instr.imm_b - 4  # Adjust for already incremented PC
        elif name == "BLTU":
            if (rf[instr.rs1] & 0xFFFFFFFF) < (rf[instr.rs2] & 0xFFFFFFFF): self.PC += instr.imm_b - 4
        elif name == "BGEU":
            if (rf[instr.rs1] & 0xFFFFFFFF) >= (rf[instr.rs2] & 0xFFFFFFFF): self.PC += instr.imm_b - 4

        elif name == "JAL":
            self.write_to_register_file(instr.rd, self.PC)
            self.PC += instr.imm_j - 4
        elif name == "JALR":
            tmp = self.PC
            self.PC = (rf[instr.rs1] + instr.imm_i) & ~1
            self.write_to_register_file(instr.rd, tmp)

        elif name == "LUI":
            self.write_to_register_file(instr.rd, instr.imm_u)
        elif name == "AUIPC":
            self.write_to_register_file(instr.rd, self.PC - 4 + instr.imm_u)

        return True


    async def run_test(self):
        self.performance_model()
        #Wait 1 us the very first time bc. initially all signals are "X"
        await Timer(1, units="us")
        self.log_dut()
        await RisingEdge(self.dut.clk)
        await FallingEdge(self.dut.clk)
        self.compare_result()
        while(int(self.Instruction_list[int((self.PC)/4)].replace(" ", ""),16)!=0):
            self.performance_model()
            #Log datapath and controller before clock edge, this calls user filled functions
            self.log_dut()
            await RisingEdge(self.dut.clk)
            await FallingEdge(self.dut.clk)
            self.compare_result()
                
                   
@cocotb.test()
async def Single_cycle_test(dut):
    #Generate the clock
    await cocotb.start(Clock(dut.clk, 10, 'us').start(start_high=False))
    #Reset onces before continuing with the tests
    dut.reset.value=1
    await RisingEdge(dut.clk)
    dut.reset.value=0
    await FallingEdge(dut.clk)
    instruction_lines = read_file_to_list('Instructions.hex')
    #Give PC signal handle and Register File MODULE handle
    tb = TB(instruction_lines,dut, dut.fetchPC, dut.my_datapath.Register_file_inst)
    await tb.run_test()







