#!/bin/bash

## see
## http://www.redmine.org/projects/redmine/wiki/HowTo_setup_automatic_refresh_of_repositories_in_Redmine_on_commit

## set up a bare mirror repo here, should be readable by www-data
gitRepo='/home/public/development/tukeq.git'
apiKey='iP8ttLDxxvDYZjxiMSrS'

redmine_fetch_changesets() {
	curl "http://localhost/redmine/sys/fetch_changesets?key=$apiKey" > /dev/null
}

cd $gitRepo
git fetch origin 2>&1 | egrep -q '.' && redmine_fetch_changesets
