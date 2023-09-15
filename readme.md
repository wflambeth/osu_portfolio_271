# CS 271 - String and Integer I/O in MASM

This project is a demo in 32-bit MASM assembly for x86-64 processors. It focuses on creating macros and procedures for string and integer input/output and storage. 

This was the final project for Oregon State's **CS 271 - Computer Architecture and Assembly Language**, one of my favorite courses in the program. 

## Usage

Upon running `Proj6_lambethw.asm`, users are prompted to input 10 signed decimal integers, in the range `[-2,147,483,648, 2,147,483,647]`. These numbers are read in as strings, then converted to 32-bit integers for storage. Invalid input strings or out-of-range numbers are rejected. 

Once 10 valid integers are read, the program calculates the sum and average of the inputs, then reads these values back to the user along with all of the original input values. All operations for string and integer processing are hand-written by the programmer, not relying on any MASM built-in functionality. 

## Example Run 

```
---- Low-Level I/O ---- A MASM Experience by Will Lambeth ----
Please provide ten signed decimal integers, between -2,147,483,648 and 2,147,483,647.
Once you have, I'll read back the numbers, their sum, and their truncated average.

Please enter a signed number: 1
Please enter a signed number: -1
Please enter a signed number: 4
Please enter a signed number: -4
Please enter a signed number: 180,000
Please enter a signed number: -180,000
Please enter a signed number: +44
Please enter a signed number: -42
Please enter a signed number: 0
Please enter a signed number: .
ERROR: Integer invalid or out of range
Please enter a signed number: 1

You entered the following numbers:
1
-1
4
-4
180,000
-180,000
+44
-42
0
1

Their sum is:
3

And their truncated average is:
0

Thank you!
```
