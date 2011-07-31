#!/usr/bin/python
import sys, random, string
try:
	length = int(sys.argv[1])
except (ValueError, IndexError):
	length = 16
if length < 1 or length > 32:
	length = 16
passwd = ''
for i in range(length):
	passwd = passwd + random.choice( string.ascii_letters + string.digits + string.punctuation )
print passwd
