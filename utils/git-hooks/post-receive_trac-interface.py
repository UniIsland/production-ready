#!/usr/bin/env python

# trac-post-commit-hook
# ----------------------------------------------------------------------------
# Copyright (c) 2004 Stephen Hansen
# Copyright (c) 2009 Sebastian Noack
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
#   The above copyright notice and this permission notice shall be included in
#   all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.
# ----------------------------------------------------------------------------

# This git post-receive hook script is meant to interface to the
# Trac (http://www.edgewall.com/products/trac/) issue tracking/wiki/etc
# system. It is based on the Subversion post-commit hook, part of Trac 0.11.
#
# It can be used in-place as post-recevie hook. You only have to fill the
# constants defined just below the imports.
#
# It searches commit messages for text in the form of:
#   command #1
#   command #1, #2
#   command #1 & #2
#   command #1 and #2
#
# Instead of the short-hand syntax "#1", "ticket:1" can be used as well, e.g.:
#   command ticket:1
#   command ticket:1, ticket:2
#   command ticket:1 & ticket:2
#   command ticket:1 and ticket:2
#
# In addition, the ':' character can be omitted and issue or bug can be used
# instead of ticket.
#
# You can have more than one command in a message. The following commands
# are supported. There is more than one spelling for each command, to make
# this as user-friendly as possible.
#
#   close, closed, closes, fix, fixed, fixes
#     The specified issue numbers are closed with the contents of this
#     commit message being added to it.
#   references, refs, addresses, re, see
#     The specified issue numbers are left in their current status, but
#     the contents of this commit message are added to their notes.
#
# A fairly complicated example of what you can do is with a commit message
# of:
#
#    Changed blah and foo to do this or that. Fixes #10 and #12, and refs #12.

import sys
import os
import re
from subprocess import Popen, PIPE
from datetime import datetime
from operator import itemgetter

TRAC_ENV = '/home/www/trac/photoncopy'
GIT_PATH = '/usr/bin/git'
BRANCHES = ['master']
COMMANDS = {'close':      intern('close'),
            'closed':     intern('close'),
            'closes':     intern('close'),
            'fix':        intern('close'),
            'fixed':      intern('close'),
            'fixes':      intern('close'),
            'addresses':  intern('refs'),
            're':         intern('refs'),
            'references': intern('refs'),
            'refs':       intern('refs'),
            'see':        intern('refs')}

# Use the egg cache of the environment if not other python egg cache is given.
if not 'PYTHON_EGG_CACHE' in os.environ:
    os.environ['PYTHON_EGG_CACHE'] = '/tmp/.egg-cache'

# Construct and compile regular expressions for finding ticket references and
# actions in commit messages.
ticket_prefix = '(?:#|(?:ticket|issue|bug)[: ]?)'
ticket_reference = ticket_prefix + '[0-9]+'
ticket_command =  (r'(?P<action>[A-Za-z]*).?'
                   '(?P<ticket>%s(?:(?:[, &]*|[ ]?and[ ]?)%s)*)' %
                   (ticket_reference, ticket_reference))
command_re = re.compile(ticket_command)
ticket_re = re.compile(ticket_prefix + '([0-9]+)')

def call_git(command, args):
    return Popen([GIT_PATH, command] + args, stdout=PIPE).communicate()[0]

def handle_commit(commit, env):
    from trac.ticket.notification import TicketNotifyEmail
    from trac.ticket import Ticket
    from trac.ticket.web_ui import TicketModule
    from trac.util.text import to_unicode
    from trac.util.datefmt import utc

    msg = to_unicode(call_git('rev-list', ['-n', '1', commit, '--pretty=medium']).rstrip())
    eml = to_unicode(call_git('rev-list', ['-n', '1', commit, '--pretty=format:%ae']).splitlines()[1])
    now = datetime.now(utc)

    tickets = {}
    for cmd, tkts in command_re.findall(msg.split('\n\n', 1)[1]):
        action = COMMANDS.get(cmd.lower())
        if action:
            for tkt_id in ticket_re.findall(tkts):
                tickets.setdefault(tkt_id, []).append(action)

    for tkt_id, actions in tickets.iteritems():
        try:
            db = env.get_db_cnx()
            ticket = Ticket(env, int(tkt_id), db)

            if 'close' in actions:
                ticket['status'] = 'closed'
                ticket['resolution'] = 'fixed'

            # determine sequence number...
            cnum = 0
            tm = TicketModule(env)
            for change in tm.grouped_changelog_entries(ticket, db):
                if change['permanent']:
                    cnum += 1

            ticket.save_changes(eml, msg, now, db, cnum + 1)
            db.commit()

            tn = TicketNotifyEmail(env)
            tn.notify(ticket, newticket=0, modtime=now)
        except Exception, e:
            print >>sys.stderr, 'Unexpected error while processing ticket ID %s: %s' % (tkt_id, e)

def handle_ref(old, new, ref, env):
    # If something else than the master branch (or whatever is contained by the
    # constant BRANCHES) was pushed, skip this ref.
    if not ref.startswith('refs/heads/') or ref[11:] not in BRANCHES:
        return

    # Get the list of hashs for commits in the changeset.
    args = (old == '0' * 40) and [new] or [new, '^' + old]
    pending_commits = call_git('rev-list', args).splitlines()

    # Get the subset of pending commits that are laready seen.
    db = env.get_db_cnx()
    cursor = db.cursor()

    try:
        cursor.execute('SELECT sha1 FROM git_seen WHERE sha1 IN (%s)'
            % ', '.join(['%s'] * len(pending_commits)), pending_commits)
        seen_commits = map(itemgetter(0), cursor.fetchall())
    except db.OperationalError:
        # almost definitely due to git_seen missing
        cursor = db.cursor() # in case it was closed
        cursor.execute('CREATE TABLE git_seen (sha1 TEXT)')
        seen_commits = []

    for commit in pending_commits:
        # If the commit was seen yet, we must skip it.
        if commit in seen_commits:
             continue

        # Remember that have seen this commit, so each commit is only processed once.
        try:
             cursor.execute('INSERT INTO git_seen (sha1) VALUES (%s)', [commit])
        except db.IntegrityError:
             # If an integrity error occurs (e.g. because of an other process has
             # seen the script in the meantime), skip it too.
             continue

        try:
             handle_commit(commit, env)
        except Exception, e:
             print >>sys.stderr, 'Unexpected error while processing commit %s: %s' % (commit[:7], e)
             db.rollback()
        else:
             db.commit()

if __name__ == '__main__':
    from trac.env import open_environment
    env = open_environment(TRAC_ENV)

    for line in sys.stdin:
        handle_ref(env=env, *line.split())
