Disassembly
===========

The protocol for the display unit was not documented. Therefore some efforts
was needed for reverse engineering.

This directory contains a ROM dump of the original ROM, and a disassembly of
said ROM

Display communication
---------------------

The display communication has not been publicly documented. Some efforts has
therefore been put into reverse engineering the display communication code to
understand the communicataion protocol.

Status of this disassembly
--------------------------

This is a scratch pad for enough reverse engineering of the firmware to achieve
said goal, but no more. This directory is not intended to be organized.

To disassemble
--------------

Download and build [f9dasm](https://github.com/Arakula/f9dasm)

Put The binary in this directory and run `./dasm.sh`

Note, a patched version of f9dasm has been used to widen the indentation to
allow for longer labels