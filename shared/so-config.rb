# Nathan Reed, 30/04/2010

$DB_HOST = '127.0.0.1'
$DB_NAME = 'scratch'
$DB_USER = 'linkuser'
$DB_PASS = ''

$IS_PROD = false;

if $IS_PROD
	# this is needed to make the app run on dreamhost... not really sure why
	ENV['GEM_HOME'] = '/home/reednj/.gem/ruby/1.8'
	ENV['GEM_PATH'] = '$GEM_HOME:/usr/lib/ruby/gems/1.8'
end

$TIME_OFFSET = 0
$SITE_TAG_PREFIX = 'so' # tagname prefix in the database
