#!/usr/bin/python
import random

mynumber = random.randrange(10,20)

print mynumber

running = True

while running:
    myguess = int(raw_input("it is a int number between 10 to 20, guess it:    "))
    
    if myguess == mynumber:
        print "you got it, the number is",mynumber
        running = False
    elif myguess < mynumber:
        print "try to guess bigger one"
    else:
        print "try to guess smaller one"
        
print "job done"