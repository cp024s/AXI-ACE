# Set project root and directories
set project_root [file normalize [file dirname [info script]]/..]
set src_dir "$project_root/src"
set include_dir "$project_root/include"

# 🔍 Load package files first (packages should be loaded before other modules)
set pkg_files [glob -nocomplain "$include_dir/*.svh" "$include_dir/*.sv"]
if {$pkg_files ne ""} {
    puts "📦 Loading package files first: $pkg_files"
    read_verilog -sv -incdir $include_dir $pkg_files
} else {
    puts "⚠️ Warning: No package files found in $include_dir!"
}

# 🔍 Load all other SystemVerilog files (excluding package files)
set other_files [glob -nocomplain "$src_dir/*.sv"]
if {$other_files ne ""} {
    puts "✅ Loading design files: $other_files"
    read_verilog -sv -incdir $include_dir $other_files
} else {
    puts "❌ Error: No design files found in $src_dir!"
    exit 1
}
