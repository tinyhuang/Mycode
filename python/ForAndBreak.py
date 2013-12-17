#!/usr/bin/python
##Break can help you to jump out from for or while
##Continue can help you to skip the rest part in for or while
for i in range(1,10):
    if i == 8:
        break
    print i
else:
    print 'job done'



for j in range(1,10):
    if j > 8:
        continue
    print j
else:
    print "job done"