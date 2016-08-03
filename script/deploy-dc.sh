#!/bin/bash
#!/bin/bash

# copy to temp directory
TMP=/tmp/so
mkdir -p $TMP

rm -rf $TMP/*
cp -R ../data-collector/* $TMP/
cp -R ../shared/*.rb $TMP/lib/

scp -r $TMP/* reednj@popacular.com:~/scripts/analyticsoverflow/
ssh reednj@popacular.com "cp ~/code/config_backup/so/so-config.rb ~/scripts/analyticsoverflow/lib/"

# clean temp directory
rm -rf $TMP/*
