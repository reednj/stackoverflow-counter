#!/bin/bash

HOST=reednj@paint.reednj.com 

ssh $HOST "rm -rf ~/so.reednj.com/*"
scp -r ../web/* $HOST:~/so.reednj.com/
scp -r ../shared $HOST:~/so.reednj.com/lib

ssh $HOST "cp ~/code/config_backup/so/so-config.rb ~/so.reednj.com/lib/"
ssh $HOST "scp popacular.com:so.reednj.com/*.json ~/so.reednj.com"
ssh $HOST "mkdir ~/so.reednj.com/tmp; touch ~/so.reednj.com/tmp/restart.txt"
