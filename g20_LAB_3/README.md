#Basic Timer
Circuit implementation (g20_Basic_Timer) that acts as a frequency divider and provides an output pulse at each second.
The circuit is implemented following the schematic provided in the lab slides. An LPM down counter module is used to count down from a constant value and set the counter output signal high once the count reaches 0. The circuit is sequential, hence the output has been fed back to the input in order to reset the counter (start over counting down to 0). Hence, counter reset is asserted by implementing OR operation of the ‘reset’ input signal with the counter output/feedback signal. An LPM constant module has been used to feed in a constant value (of specific bits) to the circuit (the constant value to count down from). The calculation for the constant value is given below.
The g20_Basic_Timer has three inputs and two outputs:
- 1-bit clock input, specified as ‘clock’
- 1-bit counter reset input, specified as ‘reset’
- 1-bit counter enable input, specified as ‘enable’
- Two 1-bit outputs named EPULSE and MPULSE

##Constant calculation
𝑃𝑒𝑟𝑖𝑜𝑑=(𝑁+1)∗𝑇𝑐
For earth: Period = 1, Tc = 20ns [=(50 MHz)-1] => N = 49, 999, 999 => 26 bits
For mars: Period = 1.027 491 252, Tc = 20ns [=(50 MHz)-1] => N = 51, 374, 562 => 26 bits
