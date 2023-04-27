import os
import subprocess
import pymatlab
import pexpect

def extract_matlab_values():
    print("downlaod matlab engine ")


def generate_verilog_module(qw,s):
    if os.path.exists("pwl.v"):
        os.remove("pwl.v")    
    verilog_file = open("pwl.v",'w')

    verilog_file.write(f"module pwl(\n")
    verilog_file.write(f"  input signed [{qw-1}:0] x,\n")
    for i in range(s-1):
        verilog_file.write(f"  input signed [{qw-1}:0] x{i},\n")
    for i in range(s):
        verilog_file.write(f"  input signed [{qw-1}:0] k{i},\n")
    for i in range(s):
        verilog_file.write(f"  input signed [{qw-1}:0] b{i},\n")
    verilog_file.write("  input clk,\n")
    verilog_file.write(f"  output reg signed [{2*qw-1}:0] out\n")
    verilog_file.write(");\n")
    verilog_file.write("\n")
    verilog_file.write("\n") 
    verilog_file.write(f"reg signed [{qw-1}:0] x_reg,kx,bx;\n")
    verilog_file.write(f"wire [{s-2}:0] z;\n")
    verilog_file.write("\n")
    verilog_file.write("\n")
    verilog_file.write("always @(posedge clk) begin\n")
    verilog_file.write("  x_reg<=x;\n")
    verilog_file.write("end\n")
    verilog_file.write("\n")
    verilog_file.write("\n") 
    for i in range(s-1):
        verilog_file.write(f"assign z[{i}] = ((x-x{i}) < 0);\n")
    verilog_file.write("\n")
    verilog_file.write("\n") 
    verilog_file.write("always @(*) begin\n")
    verilog_file.write("  case(z)\n")
    for i in range(s):
        binary = '0'*i + '1'*(s-1-i)
        verilog_file.write(f"    {s-1}'b{binary}: begin\n")
        verilog_file.write(f"      kx = k{i};\n")
        verilog_file.write(f"      bx = b{i};\n")
        verilog_file.write("    end\n")
    verilog_file.write("  endcase\n")
    verilog_file.write("end\n")
    verilog_file.write("\n")
    verilog_file.write("\n") 
    verilog_file.write(f"reg signed [{qw-1}:0] P_reg1_high, P_reg2_high;\n")
    verilog_file.write(f"reg signed [{qw-1}:0] P_reg1_low, P_reg2_low;\n")
    verilog_file.write(f"reg [{2*qw-1}:0] mul_out;\n")
    verilog_file.write("\n")
    verilog_file.write("\n")
    verilog_file.write("always @(posedge clk) begin\n")
    verilog_file.write(f"  P_reg1_high <= kx[{qw-1}:{qw//2}] * x_reg[{qw-1}:{qw//2}];\n")
    verilog_file.write(f"  P_reg1_low <= kx[{qw//2 - 1}:0] * x_reg[{qw//2 - 1}:0];\n")
    verilog_file.write(f"  P_reg2_high <= kx[{qw-1}:{qw//2}] * x_reg[{qw//2 - 1}:0];\n")
    verilog_file.write(f"  P_reg2_low <= kx[{qw//2 - 1}:0] * x_reg[{qw-1}:{qw//2}];\n")
    verilog_file.write("end\n")
    verilog_file.write("\n")
    verilog_file.write("\n")
    verilog_file.write(f"reg [{qw-1}:0] bx1,bx2;\n")
    verilog_file.write("always @(posedge clk) begin\n")
    verilog_file.write("  bx1<=bx;\n")
    verilog_file.write("  bx2<=bx1;\n")
    verilog_file.write("end\n")
    verilog_file.write("\n")
    verilog_file.write("\n")
    verilog_file.write("always @(posedge clk) begin\n")
    verilog_file.write(f"  mul_out <= P_reg1_low + (P_reg1_high << {qw})+ (P_reg2_high << {qw//2}) + (P_reg2_low << {qw//2});\n")
    verilog_file.write("end\n")
    verilog_file.write("\n")
    verilog_file.write("\n")
    verilog_file.write("always @(posedge clk) begin\n")
    verilog_file.write(f"  out <= mul_out + bx2;\n")
    verilog_file.write("end\n")
    verilog_file.write("\n")
    verilog_file.write("\n")
    verilog_file.write("endmodule\n")
    verilog_file.close()


def generate_contraints_sdc(s):
    if os.path.exists("constraints_top.sdc"):
        os.remove("constraints_top.sdc")    
    constraints_file = open("constraints_top.sdc",'w')    

    constraints_file.write("create_clock -name clk -period 10 -waveform {0 5} [get_ports \"clk\"]\n")
    constraints_file.write("set_clock_transition -rise 0.1 [get_clocks \"clk\"]\n")
    constraints_file.write("set_clock_transition -fall 0.1 [get_clocks \"clk\"]\n")
    constraints_file.write("set_clock_uncertainty 0.01 [get_ports \"clk\"]\n")
    constraints_file.write("set_input_delay -max 1.0 [get_ports \"x\"] -clock [get_clocks \"clk\"]\n")
    for i in range(s-1):
        constraints_file.write(f"set_input_delay -max 1.0 [get_ports \"x{i}\"] -clock [get_clocks \"clk\"]\n")
    for i in range(s):
        constraints_file.write(f"set_input_delay -max 1.0 [get_ports \"k{i}\"] -clock [get_clocks \"clk\"]\n")
    for i in range(s):
        constraints_file.write(f"set_input_delay -max 1.0 [get_ports \"b{i}\"] -clock [get_clocks \"clk\"]\n")
    
    constraints_file.write("set_output_delay -max 1.0 [get_ports \"out\"] -clock [get_clocks \"clk\"]\n")
    constraints_file.close()


def genus_flow_files(qw,s):
    generate_verilog_module(qw,s)
    generate_contraints_sdc(s)
    

def run_genus():
    csh = pexpect.spawn('csh -c "source new_cshrc_hep"')
    csh.expect('.*>')
    csh.sendline('genus -legacy_ui')
    csh.expect('.*>')
    csh.sendline('source script.tcl')
    csh.expect('.*>')
    csh.close()


def run_matalb(a,b,c,mae_sw):
    session = pymatlab.session_factory()
    result = session.feval('seg_log2','a','b','c','mae_sw')
    session.close()
    return result;
if __name__ == '__main__':
    result = run_matalb
    genus_flow_files(14,13)

