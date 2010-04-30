#!/bin/bash

# copy to temp directory
rm -rf ~/tmpcpy/*
cp -R ../web/* ~/tmpcpy/
cp -R ../shared/*.rb ~/tmpcpy/lib/

# remove the config file, and other files we don't want to copy
rm ~/tmpcpy/lib/so-config.rb

scp -r ~/tmpcpy/* reednj@popacular.com:~/popacular.com/stackoverflow/

# clean temp directory
rm -rf ~/tmpcpy/*
