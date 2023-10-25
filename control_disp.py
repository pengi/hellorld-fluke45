#!/usr/bin/env python3

import serial
import time

#
# This script is used as a tool to reverse-engineer the protocol between the
# main CPU and the display unit.
#
# Use together with src/display_proxy.asm, with the fluke 45 connected to a the
# computer using a null modem cable (and probably a USB-Serial cable)
#
# The display_proxy program will then forward what's sent over RS-232 directly
# to the display unit, without having to re-flash the EEPROM
#

ser = serial.Serial('/dev/ttyUSB0', 9600, timeout=1)

# Flush buffer
ser.read(1024)

def send(bytes):
    for b in bytes:
        ser.write([b])
        # Wait for reply to keep in sync
        if int(ser.read(1)) != 0:
            print("Error sending %02x" % (b,))

def keepalive():
    """
    Send a no-op command for keep the display alive
    
    The display will reset if it hasn't got any data in a while
    """
    send([0xc8])

def set_all(intensity):
    """
    Set all segments to same intensity
    
    intensity is one of:
        0 = all off
        1 = no change (not used)
        2 = dimmed
        3 = all on
    """
    send([0xa8])

def clear():
    """
    Clear screen
    """
    set_all(0)

def clear_digit(num):
    """
    Clear screen
    """
    send([0xb0 | num])

def beep(len = 100):
    """
    BEEP
    
    length is a value 0-0x3ff in steps of approximately 3ms
    """
    len = len & 0x3ff
    send([
        0xc0 | (len >> 7),
        len & 0x7f])

def send_cmd(upper, pos, num, flags):
    """
    Send a two byte command in common format
    """
    send([
        upper | ((pos >> 1) & 0x07),
        ((pos << 6) & 0x40) | ((num << 2) & 0x3c) | (flags & 0x03)
    ])

def _dim2int(dim):
    if dim:
        return 0
    else:
        return 2

def digit(pos, num, dim = False):
    """
    Set a digit on a given position to a given value

    Enumerated as grid number, from right to left
    """
    send_cmd(0x98, pos, num, _dim2int(dim) | 0)

def letter(pos, num, dim = False):
    """
    Set a digit on a given position to a given letter

    The alphabet is however only 16 letters: " cHhJLnoPrtUuy*?"

    Enumerated as grid number, from right to left
    """
    send_cmd(0x98, pos, num, _dim2int(dim) | 1)

def shapes(pos, num, dim=False):
    """
    Set a digit to some pre-defined shapes
    """
    send_cmd(0x90, pos, num // 2, _dim2int(dim) | (num % 2))

def segment(pos, num, on, dim = False):
    """
    Turn a signle segment on or off

    Positioned first at grid, then segment number.
    """
    if (True, False) == (on, dim):
        flags = 3
    elif (True, True) == (on, dim):
        flags = 2
    else:
        flags = 0
    # flags == 1: no update
    send_cmd(0x88, pos, num, flags)

def display_value(value, secondary=False, dim=False):
    """
    Display an integer value on either main or secondary display
    """
    if secondary:
        offset = 0
    else:
        offset = 6
    
    if value < 0:
        value = -value
        neg = True
    else:
        neg = False
    
    for i in range(5):
        if value == 0:
            letter(i + offset, 0, dim)
            if neg:
                segment(i + offset, 6, True, dim)
            neg = False
        else:
            if i < 4:
                segment(i + offset, 10, False, dim)
            digit(i + offset, value % 10, dim)
        value //= 10
    segno = 9 if secondary else 10
    segment(4 + offset, segno, neg, dim)

def hellorld():
    """
    Print hellorld! on the display

    At this state, it's mostly to test the commands
    """
    # H
    letter(9, 2, False)
    # e
    segment(8, 0, True, False)
    segment(8, 3, True, False)
    segment(8, 4, True, False)
    segment(8, 5, True, False)
    segment(8, 6, True, False)
    # l
    letter(7, 5, False)
    # l
    letter(6, 5, False)
    # o
    digit(4, 0, False) 
    # r
    segment(3, 0, True, False)
    segment(3, 1, True, False)
    segment(3, 4, True, False)
    segment(3, 5, True, False)
    segment(3, 6, True, False)
    segment(3, 8, True, False)
    # l
    letter(2, 5, False)
    # d
    segment(1, 1, True, False)
    segment(1, 2, True, False)
    segment(1, 3, True, False)
    segment(1, 4, True, False)
    segment(1, 6, True, False)
    # !
    segment(0, 1, True, False)
    segment(0, 8, True, False)


# Do a simple routine for testing
keepalive()
clear()
while True:
    hellorld()
    time.sleep(1)
    for i in range(11):
        clear_digit(10-i)
        time.sleep(0.05)
    time.sleep(0.3)
