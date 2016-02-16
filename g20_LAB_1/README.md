#Seconds to Day
Circuit implementation (g20_Seconds_to_Days) that converts a time of day in seconds to a day fraction representation
The Seconds to Days converter circuit is a combinational circuit that shifts an input vector by a certain number of bit positions and adds subsequently. This version of the circuit only shifts to the left. The bits on the right are added as zeros. The circuit was built using 9 adders and 9 shifters. The function implemented by the circuit is : d = (N*2^23 + N*2^22 + N*2^17 + N*2^13 + N*2^11 + N*2^10 + N*2^9 + N*2^6 + N*2^2+ N)/2^40; where N represents time of day in seconds and d represents day fraction.
The Seconds-to-Days circuit has one input and one output:
- 17 bits input called seconds (pin named Seconds in the diagram), representing the original vector being added and shifted simultaneously
- 40 bits output called day_fraction (pin named Days in the diagram), representing the final output of the circuit
