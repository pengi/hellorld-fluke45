Display Protocol
================

Packet framing
--------------

Packets can be sent in an arbitrary number of bytes. In reality, only 1 or 2
byte packets have been seen.

Most significant bit of each byte is a start-of-packet bit, set to 1 on first
byte in each packet, 0 in all following. Making each byte having 7 usable bits
for commands

Following description includes that bit in the commmands

There seems to be no return values from the display to the main CPU. Only a
signal for synchronization of when the display is ready for next command.
Malformed commands seems however to assert that signal to trigger an error.

Some basic information about the protocol and startup sequence can be found in
the Fluke 45 Service manual under:

 - Chapter 2 - Theory of Operation
   - Display Assembly
     - 2-47 Display Controller with FIP

Commands
--------

```
pppp = position, right to left
vvvv = value
i    = intensity
        if one bit  - 0=dimmed 1=full
        if two bits - 00=off 01=no change 10=dimmed 11=full
.    = dont care

                    v - seen in firmware

10001ppp 0pvvvvii     - set segment
10010ppp 0pvvvviv     - set some garbage font
10011ppp 0pvvvvi0   x - set digit
10011ppp 0pvvvvi1   x - set number
10100ppp 0pvvvv0f   x = seg segment, probably?
10101.ii              - set all
10101000            x - clear screen
10101011            x - all on
11000ttt 0ttttttt   x - beep - t = duration, in steps of ~3ms
11001000            x - keep alive
11100000              - Reset
1011pppp              - Clear digit / grid
11110010            x - ??? error sending, uses disp_send8_int
```

Segment Layout
--------------

Segment layout is available in service manual for Fluke 45. `pppp` referes to
grid number and `vvvv` when setting segment refers to anode number within a
grid.