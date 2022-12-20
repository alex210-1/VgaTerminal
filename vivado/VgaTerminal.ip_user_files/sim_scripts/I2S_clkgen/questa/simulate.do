onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib I2S_clkgen_opt

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {I2S_clkgen.udo}

run -all

quit -force
