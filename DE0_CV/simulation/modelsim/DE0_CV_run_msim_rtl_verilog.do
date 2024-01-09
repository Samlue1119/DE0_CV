transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/circut_design/01057024_DEMO11/DE0_CV/design {C:/circut_design/01057024_DEMO11/DE0_CV/design/stack.sv}
vlog -sv -work work +incdir+C:/circut_design/01057024_DEMO11/DE0_CV/design {C:/circut_design/01057024_DEMO11/DE0_CV/design/single_port_ram_128x8.sv}
vlog -sv -work work +incdir+C:/circut_design/01057024_DEMO11/DE0_CV/design {C:/circut_design/01057024_DEMO11/DE0_CV/design/Program_Rom.sv}
vlog -sv -work work +incdir+C:/circut_design/01057024_DEMO11/DE0_CV/design {C:/circut_design/01057024_DEMO11/DE0_CV/design/CPU.sv}

