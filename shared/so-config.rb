# Nathan Reed, 30/04/2010

$DB_HOST = 'localhost'
$DB_NAME = 'stackoverflow_count'
$DB_USER = 'linkuser'
$DB_PASS = ''

$IS_PROD = false;
$ROOT_PATH = '/dev/stackoverflow_count/web/';

if $IS_PROD
	ENV['GEM_HOME'] = '/home/reednj/.gem/ruby/1.8'
	ENV['GEM_PATH'] = '$GEM_HOME:/usr/lib/ruby/gems/1.8'
end

$TIME_OFFSET = 0
