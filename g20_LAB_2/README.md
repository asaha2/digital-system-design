#Binary to BCD
Circuit implementation (g20_binary_to_BCD) that converts a 6-bit binary value to its 2-digit Binary-Coded-Decimal (BCD) representation.
This circuit is implemented using a lookup table (LUT). In the LUT approach, a memory unit is used that has an entry for every 64 possible input pattern. In the Altera, the LPM module implementation is used for the circuit design, and the code snippet given in the lab specification is used for declaration the lpm_rom component. An .mif file is created to specify the contents of the LUT, which is being referred to in the code. 
The binary_to_BCD has two inputs and one output:
-	6-bit value named `bin` which represents the binary input
-	1-bit clock input, specified as `clock`
-	8-bit output named `BCD` which represents the converted decimal value

#Dayseconds
Circuit implementation (g20_dayseconds) that takes in a time specified in hours, minutes and seconds and computes the time specified as the number of seconds since midnights. This circuit is implemented using LPM modules lpm_multiply and lpm_add_sub to carry out the required arithmetic operations. The operation basic to the implementation of this circuit is given in the following:
DaySeconds = Seconds + (60*(Minutes + (60 * Hours)))
**this formulation gives a smaller circuit than fully expanded expression
The DaySeconds has three inputs and one output:
-	5-bit value input named ‘Hours’ which represents hours value of time
-	6-bit value input named ‘Minutes’ which represents minutes value of time
-	6-bit value input named ‘Seconds’ which represents seconds value of time
-	17-bit value output named ‘DaySeconds’ which represents the required time specified as the number of seconds since midnight
