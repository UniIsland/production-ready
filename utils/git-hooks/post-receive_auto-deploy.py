#!/usr/bin/env python

## git post-receive hook to auto deploy changes in specific branches
## to live web server.
##
## Author: HUANG, Tao
## Last Modified: Aug 8th, 2011

import sys
import os
import logging
from subprocess import Popen, PIPE

GIT_PATH = '/usr/bin/git'
HOME = os.environ['HOME']
Branches = {
        'refs/heads/live': [0, HOME + '/trunk/live', 'origin', 'live'],
        'refs/heads/master': [0, HOME + '/trunk/testing', 'origin', 'master'],
        }
LogFile = HOME + '/log/deploy.log'

logging.basicConfig(level = logging.DEBUG,
        filename = LogFile,
        format = "%(asctime)s %(levelname)s:\t%(message)s")

del os.environ['GIT_DIR']

for line in sys.stdin:
    commit = line.split()
    if commit[2] in Branches:
        Branches[commit[2]][0] += 1

for v in Branches.itervalues():
    if v[0]:
        print 'deploying changes automatically to branch "', v[3], '":',
        sp = Popen([GIT_PATH, 'pull', v[2], v[3]], cwd = v[1],
                stdout = PIPE, stderr = PIPE)
        msg, err = sp.communicate()
        retval = sp.wait()
        if retval == 0:
            print 'succeeded.'
            logging.info('deploy to "' + v[3] + '" succeeded.')
        else:
            print 'error occured.'
            print msg
            print err
            logging.info("\n" + msg)
            logging.error("\n" + err)

