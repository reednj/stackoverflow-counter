#!/bin/bash

HOST=reednj@paint.reednj.com 

ssh $HOST "rm -rf ~/so.reednj.com/*"
scp -r ../* $HOST:~/so.reednj.com/

ssh $HOST "cp ~/code/config_backup/so/so-config.rb ~/so.reednj.com/lib/"
ssh $HOST "cd ~/so.reednj.com; rm yearly-tags.json; ln ~/yearly-tags.json"
ssh $HOST "mkdir ~/so.reednj.com/tmp; touch ~/so.reednj.com/tmp/restart.txt"
