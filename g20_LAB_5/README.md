#S Squared Mars Clock
##Description of System Features
In this lab we integrated all the modules that have been previously built throughout the duration of the course. For making the components functional in the whole integrated system, a new controller module has been implemented. This internally handles all the circuitry required to provide a user interface for the final product.
Features of the integrated system includes:
- Displaying the time on Mars
- Displaying the time on Earth
- Displaying the date on Earth
- Setting time zones on Earth
- Setting time zones on Mars
- Setting time and date on Earth, with added functionality of enabling the Daylight Saving
- Synchronization of Earth and Mars times

##Altera Controls
- Power button
- Slider switches with unique functionalities, depending on their positional combination-
  - SW0-SW2: mode switches
  - SW3-SW4: display switches (only when in display mode)
  - SW3-SW9: set switches for parameter input (only when in set mode)
- Pushbuttons with functionalities including-
  - KEY3: reset switch
    - KEY2: perform switch
- LED indicator light (LEDR0)

##Quick Guide
- Power button- turns on the system
- Choose mode of operation SW2-SW0
- Display mode-
  - “000” displays time parameters for earth, also asserts LEDR0 when DLS is ON
  - “001” displays date parameters for earth
  - “010” displays time parameters for mars
- Set mode-
  - “011” sets time zone for earth
  - “100” sets time zone for mars
  - “101” sets earth time and date
- Sync mode-
  - “110” syncs earth and mars time
- Display selection SW4-SW3 (when in display mode)
  - “00” displays seconds or days
  - “01” displays minutes or months
  - “10” displays hours or years
- Parameter set bits SW9-SW3 (when in set mode)
