#!/bin/bash

ssh reednj@popacular.com "rm -rf ~/so.reednj.com/*"
scp -r ../web/* reednj@popacular.com:~/so.reednj.com/
scp -r ../shared reednj@popacular.com:~/so.reednj.com/lib
ssh reednj@popacular.com "cp ~/code/config_backup/so/so-config.rb ~/so.reednj.com/lib/"

ssh reednj@popacular.com "mkdir ~/so.reednj.com/tmp; touch ~/so.reednj.com/tmp/restart.txt"