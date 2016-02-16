#UTC To MTC Converter
Circuit implementation (g20_UTC_to_MTC) that takes in Earth time and date and generates the corresponding Mars time of day.
The circuit is required to calculate the time of day in Mars, given time and date parameters on Earth. The motive behind this circuit implementation is to synchronize both the Earth and Mars clock, i.e. set the Mars clock following the Earth parameters. The implementation of this circuit largely relies on the standardisation discussions and conversion methods stated in the lab slides. The computation of the Mars time involves other modular computations in the process. Notably using the formula given in the lab slides, ‘NDays’ is computed in a process block that takes asynchronous clock and reset signals in the sensitivity list. This variable represents the number of times the YMD counter gets incremented. Another variable ‘day_frac’ which is the day-fraction representation of seconds is computed using one of the previously built lab modules (g20_Seconds_to_Days). Following computation of each of these variables the corresponding Julian Date is evaluated. The circuit finally implements LPM multiplication and add-sub module to extract the hours, minutes and seconds components of MTC, followed by a process block implementation to latch the extracted outputs. The computation primarily employs concepts of fixed point arithmetic. A 1-bit output ‘done’ is asserted when the operation completes.
The g20_UTC_to_MTC circuit has inputs and outputs defined as follows:
- 1-bit asynchronous clock input, specified as ‘clock’
- 1-bit asynchronous reset input, specified as ‘reset’
- Three load inputs named ‘earth_year’= 12-bit, ‘earth_month’= 4-bit and ‘earth_day’= 5-bit
- Three load inputs named ‘earth_hour’= 5-bit, ‘earth_min’= 6-bit and ‘earth_sec’= 6-bit
- Three load outputs named ‘mars_hour’= 5-bit, ‘mars _min’= 6-bit and ‘mars _sec’= 6-bit
- 1-bit output named ‘done’
