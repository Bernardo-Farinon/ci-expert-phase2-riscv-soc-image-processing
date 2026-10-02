import sys

# Mapeamento oficial dos 32 registadores inteiros do RISC-V
REGS = ["zero","ra","sp","gp","tp","t0","t1","t2","s0","s1",
        "a0","a1","a2","a3","a4","a5","a6","a7",
        "s2","s3","s4","s5","s6","s7","s8","s9","s10","s11",
        "t3","t4","t5","t6"]

def sign_extend(val, bits):
    """Garante que os números negativos (complemento para 2) são lidos corretamente."""
    if val & (1 << (bits - 1)):
        val -= (1 << bits)
    return val

def disasm(hex_str, pc):
    inst = int(hex_str, 16)
    
    # Extração dos blocos padrão da instrução RISC-V (RV32I)
    opcode = inst & 0x7F
    rd     = (inst >> 7) & 0x1F
    f3     = (inst >> 12) & 0x7
    rs1    = (inst >> 15) & 0x1F
    rs2    = (inst >> 20) & 0x1F

    if opcode == 0x37: # LUI (Load Upper Immediate)
        imm = (inst >> 12) & 0xFFFFF
        return f"lui\t{REGS[rd]}, 0x{imm:x}"
        
    elif opcode == 0x17: # AUIPC (Add Upper Immediate to PC)
        imm = (inst >> 12) & 0xFFFFF
        return f"auipc\t{REGS[rd]}, 0x{imm:x}"
        
    elif opcode == 0x6f: # JAL (Jump and Link)
        imm = ((inst >> 31) << 20) | (((inst >> 12) & 0xFF) << 12) | (((inst >> 20) & 0x1) << 11) | (((inst >> 21) & 0x3FF) << 1)
        target = pc + sign_extend(imm, 21)
        return f"jal\t{REGS[rd]}, 0x{target:x}"
        
    elif opcode == 0x67: # JALR
        imm = sign_extend((inst >> 20) & 0xFFF, 12)
        return f"jalr\t{REGS[rd]}, {imm}({REGS[rs1]})"
        
    elif opcode == 0x63: # BRANCHES (beq, bne, blt, bge...)
        imm = ((inst >> 31) << 12) | (((inst >> 7) & 0x1) << 11) | (((inst >> 25) & 0x3F) << 5) | (((inst >> 8) & 0xF) << 1)
        ops = {0:"beq", 1:"bne", 4:"blt", 5:"bge", 6:"bltu", 7:"bgeu"}
        target = pc + sign_extend(imm, 13)
        return f"{ops.get(f3, 'b?')}\t{REGS[rs1]}, {REGS[rs2]}, 0x{target:x}"
        
    elif opcode == 0x03: # LOADS (lw, lb, lbu...)
        imm = sign_extend((inst >> 20) & 0xFFF, 12)
        ops = {0:"lb", 1:"lh", 2:"lw", 4:"lbu", 5:"lhu"}
        return f"{ops.get(f3, 'l?')}\t{REGS[rd]}, {imm}({REGS[rs1]})"
        
    elif opcode == 0x23: # STORES (sw, sb, sh)
        imm = sign_extend(((inst >> 25) << 5) | ((inst >> 7) & 0x1F), 12)
        ops = {0:"sb", 1:"sh", 2:"sw"}
        return f"{ops.get(f3, 's?')}\t{REGS[rs2]}, {imm}({REGS[rs1]})"
        
    elif opcode == 0x13: # OP-IMM (addi, andi, slli...)
        imm = sign_extend((inst >> 20) & 0xFFF, 12)
        if f3 == 0: return f"addi\t{REGS[rd]}, {REGS[rs1]}, {imm}"
        if f3 == 7: return f"andi\t{REGS[rd]}, {REGS[rs1]}, {imm}"
        if f3 == 6: return f"ori\t{REGS[rd]}, {REGS[rs1]}, {imm}"
        if f3 == 4: return f"xori\t{REGS[rd]}, {REGS[rs1]}, {imm}"
        shamt = imm & 0x1F
        if f3 == 1: return f"slli\t{REGS[rd]}, {REGS[rs1]}, {shamt}"
        if f3 == 5: return f"{'srai' if (inst>>30) else 'srli'}\t{REGS[rd]}, {REGS[rs1]}, {shamt}"
        
    elif opcode == 0x33: # OP (add, sub, and, or...)
        if f3 == 0: return f"{'sub' if (inst>>30) else 'add'}\t{REGS[rd]}, {REGS[rs1]}, {REGS[rs2]}"
        ops = {1:"sll", 2:"slt", 3:"sltu", 4:"xor", 5:("sra" if (inst>>30) else "srl"), 6:"or", 7:"and"}
        return f"{ops.get(f3, 'op')}\t{REGS[rd]}, {REGS[rs1]}, {REGS[rs2]}"
        
    # Se não for uma instrução, é um dado puro (ex: a tabela de matriz no 0x6DC)
    return f".word\t0x{hex_str}"

if __name__ == "__main__":
    pc = 0
    with open('sim_rom.init', 'r') as f:
        print("ADDR\tCODE\t\tASSEMBLY")
        print("-" * 50)
        for line in f:
            line = line.strip()
            if line:
                print(f"{pc:04x}:\t{line}\t{disasm(line, pc)}")
                pc += 4