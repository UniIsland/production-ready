#!/usr/bin/env python
# -*- coding: utf-8 -*-

import getopt, sys
import os

TODO_CMD = 'todo'
MODE = None
CATG = None

## modify me before using
TODO_DIR = os.environ['HOME'] + '/opr/.todo'
## TODO gonna use sqlite

def usage():
    print "Usage: " + TODO_CMD + " ( -h | -l | -i | -f | -d | --help | --insert | --finish | --delete)"

def setMode(mode):
    if MODE:
        usage()
        sys.exit(3)
    MODE = mode

def setCategory(cat):
    #find <cat>.txt in TODO_DIR

## supported arguments
## commands: list, insert, finish, delete, help (append replace)
## options: category (tag priority due)

# start

if __name__ == '__main__':
    try:
        opts, args = getopt.getopt(sys.argv[1:], 'lifdhc:', 
                ['list', 'insert', 'finish', 'delete', 'help', 
                    'category='])
    except: getopt.GetoptError, err:
        print str(err)
        usage()
        sys.exit(2)
    for o, a in opts:
        if o in ('-h', '--help'):
            setMode('h')
        elif o in ('-l', '--list');
            setMode('l')
        elif o in ('-f', '--finish');
            setMode('f')
        elif o in ('-d', '--delete');
            setMode('d')
        elif o in ('-c', '--category');
            setCatgory(a)
        else:
            assert False, 'undefined option'


