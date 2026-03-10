#===========================================================
#   解析输入参数
#===========================================================
# 顶层模块名称
set DESIGN                  [lindex $argv 0]
# Verilog 源文件列表（用空格分隔的字符串）
set VERILOG_FILES           [string map {"\"" ""} [lindex $argv 1]]
# Include 目录列表（用空格分隔的字符串）
set VERILOG_INCLUDE_DIRS    [string map {"\"" ""} [lindex $argv 2]]
# 输出的图片前缀路径（例如 ./output/my_design_schematic）
set OUTPUT_PREFIX           [lindex $argv 3]

#===========================================================
#   开始 Yosys 流程
#===========================================================
yosys -import

# 1. 设置 Verilog include 路径
set inc_args []
foreach dir $VERILOG_INCLUDE_DIRS {
  lappend inc_args "-I$dir"
}

# 2. 读取所有的 Verilog/SystemVerilog 文件
foreach file $VERILOG_FILES {
  # 如果你的代码是纯 Verilog 2001，可以去掉 -sv
  read_verilog -sv {*}$inc_args $file
}

# 3. 展开并检查设计 (Hierarchy 展开)
# 这里使用 prep 而不是 synth。
# prep 会做基本的层级展开和优化，生成的图更接近 RTL 级别，可读性更好。
# 如果你想要查看经过完整逻辑优化的门级网表图，可以将 prep 替换为: synth -top $DESIGN
prep -top $DESIGN

# 清理未使用的连线和逻辑，让图纸更干净
opt_clean -purge

#===========================================================
#   4. 生成电路图
#===========================================================
log "\[INFO\]: Generating schematic to ${OUTPUT_PREFIX}.svg ..."

# show 命令参数解析：
# -format svg : 生成 SVG 矢量图，放大不失真，适合在浏览器中查看（也可改为 png, pdf 等）
# -prefix     : 生成文件的前缀名称
# -colors     : 根据线宽和类型使用不同的颜色，提高可读性
# $DESIGN     : 指定要画哪个模块的图
show -format svg -prefix $OUTPUT_PREFIX -colors 1 $DESIGN

log "\[INFO\]: Schematic generation done."
