onbreak {quit -force}
onerror {quit -force}

asim +access +r +m+I2S_clkgen -L xil_defaultlib -L secureip -O5 xil_defaultlib.I2S_clkgen

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure

do {I2S_clkgen.udo}

run -all

endsim

quit -force
