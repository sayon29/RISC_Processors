import re

def clean(line):
    line = line.split('#')[0].split('//')[0]
    return line.strip()

def tokenize(line):
    return line.replace(',', ' ').replace('(', ' ').replace(')', ' ').split()

def get_reg(r):
    return int(re.search(r'\d+', r).group())


def assemble_line(line, pc, labels):

    t = tokenize(line)
    if not t:
        return None

    instr = t[0].lower()

    #-------psuedo--------
    # ret -> jalr x0,0(x1)
    if instr == "ret":
        rs1 = 1
        return (0 << 20) | (rs1 << 15) | (0 << 12) | (0 << 7) | 0x67


    # j label -> jal x0,label
    if instr == "j":

        target = t[1]

        if target in labels:
            imm = labels[target] - pc - 1
        else:
            imm = int(target)

        rd = 0
        return ((imm & 0xFFFFF) << 12) | (rd << 7) | 0x6F


    # li rd,imm -> addi rd,x0,imm
    if instr == "li":

        rd = get_reg(t[1])
        imm = int(t[2])
        rs1 = 0

        return ((imm & 0xFFF) << 20) | (rs1 << 15) | (0 << 12) | (rd << 7) | 0x13


    # return xn -> jalr x0,0(xn)
    if instr == "return":

        rs1 = get_reg(t[1])
        return (0 << 20) | (rs1 << 15) | (0 << 12) | (0 << 7) | 0x67


    # ---------- R type ----------
    r_type = {
        'add':(0,0),'sub':(0x20,0),'sll':(0,1),'slt':(0,2),
        'sltu':(0,3),'xor':(0,4),'srl':(0,5),'sra':(0x20,5),
        'or':(0,6),'and':(0,7)
    }

    if instr in r_type:
        rd, rs1, rs2 = get_reg(t[1]), get_reg(t[2]), get_reg(t[3])
        f7, f3 = r_type[instr]
        return (f7<<25)|(rs2<<20)|(rs1<<15)|(f3<<12)|(rd<<7)|0x33


    # ---------- I type ----------
    if instr in ['addi','slti','sltiu','xori','ori','andi']:

        rd = get_reg(t[1])
        rs1 = get_reg(t[2])
        imm = int(t[3])

        f3 = {'addi':0,'slti':2,'sltiu':3,'xori':4,'ori':6,'andi':7}[instr]

        return ((imm & 0xFFF) << 20) | (rs1<<15) | (f3<<12) | (rd<<7) | 0x13


    # ---------- LW ----------
    if instr == "lw":

        rd = get_reg(t[1])
        imm = int(t[2])
        rs1 = get_reg(t[3])

        return ((imm & 0xFFF)<<20) | (rs1<<15) | (2<<12) | (rd<<7) | 0x03


    # ---------- SW ----------
    if instr == "sw":

        rs2 = get_reg(t[1])
        imm = int(t[2])
        rs1 = get_reg(t[3])

        return ((imm>>5 & 0x7F)<<25) | (rs2<<20) | (rs1<<15) | (2<<12) | ((imm & 0x1F)<<7) | 0x23


    # ---------- BRANCH ----------
    if instr in ['beq','bne','blt','bge','bltu','bgeu']:

        rs1 = get_reg(t[1])
        rs2 = get_reg(t[2])
        target = t[3]

        if target in labels:
            imm = labels[target] - pc - 1
        else:
            imm = int(target) - 1

        f3 = {'beq':0,'bne':1,'blt':4,'bge':5,'bltu':6,'bgeu':7}[instr]

        imm &= 0xFFF  # keep 12 bits

        imm11  = (imm >> 11) & 0x1
        imm10_5 = (imm >> 5) & 0x3F
        imm4_0  = imm & 0x1F

        return (
            (imm11 << 31) |
            (imm10_5 << 25) |
            (rs2 << 20) |
            (rs1 << 15) |
            (f3 << 12) |
            (imm4_0 << 7) |
            0x63
        )

    # ---------- JAL ----------
    if instr == "jal":

        rd = get_reg(t[1])
        target = t[2]

        if target in labels:
            imm = labels[target] - pc - 1
        else:
            imm = int(target)

        return ((imm & 0xFFFFF)<<12) | (rd<<7) | 0x6F


    # ---------- JALR ----------
    if instr == "jalr":

        rd = get_reg(t[1])
        imm = int(t[2])
        rs1 = get_reg(t[3])

        return ((imm & 0xFFF)<<20) | (rs1<<15) | (0<<12) | (rd<<7) | 0x67


    # ---------- LUI ----------
    if instr == "lui":

        rd = get_reg(t[1])
        imm = int(t[2])

        return ((imm & 0xFFFFF)<<12) | (rd<<7) | 0x37


    # ---------- AUIPC ----------
    if instr == "auipc":

        rd = get_reg(t[1])
        imm = int(t[2])

        return ((imm & 0xFFFFF)<<12) | (rd<<7) | 0x17


    return None



def assemble_file(filename):

    with open(filename) as f:
        lines = f.readlines()

    labels = {}
    pc = 0

    # PASS 1: collect labels
    for line in lines:

        line = clean(line)
        if not line:
            continue

        if ":" in line:

            label = line.split(":")[0]
            labels[label] = pc

            line = line.split(":")[1].strip()

        if line:
            pc += 1


    # PASS 2: encode
    pc = 0
    encoded = []

    for line in lines:

        line = clean(line)
        if not line:
            continue

        if ":" in line:
            line = line.split(":")[1].strip()

        if not line:
            continue

        val = assemble_line(line, pc, labels)

        if val is not None:
            encoded.append(val)
            pc += 1

    return encoded



def write_coe(filename, data, radix, is_binary=False):

    with open(filename,'w') as f:

        for i,val in enumerate(data):

            fmt = f"{val:032b}" if is_binary else f"{val:08x}"
            f.write(fmt + "\n")



# -------- MAIN --------

with open("ins.txt") as f:
    pass

encoded = assemble_file("ins.txt")

if encoded:

    write_coe("hex.coe", encoded, 16)
    write_coe("binary.coe", encoded, 2, True)

    print("Assembled", len(encoded), "instructions")

else:
    print("No instructions found")