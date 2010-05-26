#!/bin/bash
#!/bin/bash

# copy to temp directory
rm -rf ~/tmpcpy/*
cp -R ../data-collector/* ~/tmpcpy/
cp -R ../shared/*.rb ~/tmpcpy/lib/

# remove the config file, and other files we don't want to copy
# rename the prod config file to that gets deployed
rm ~/tmpcpy/lib/so-config.rb ~/tmpcpy/so-test.rb
mv ~/tmpcpy/lib/so-config.prod.rb ~/tmpcpy/lib/so-config.rb

scp -r ~/tmpcpy/* reednj@popacular.com:~/scripts/analyticsoverflow/

# clean temp directory
rm -rf ~/tmpcpy/*
