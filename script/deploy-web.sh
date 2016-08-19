#!/bin/bash

HOST=reednj@paint.reednj.com 

ssh $HOST "rm -rf ~/so.reednj.com/*"
scp -r ../* $HOST:~/so.reednj.com/

ssh $HOST "cp ~/code/config_backup/so/so-config.rb ~/so.reednj.com/lib/"
ssh $HOST "scp popacular.com:so.reednj.com/*.json ~/so.reednj.com"
ssh $HOST "mkdir ~/so.reednj.com/tmp; touch ~/so.reednj.com/tmp/restart.txt"
