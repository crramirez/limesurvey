#!/bin/bash
set -eu

# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
	local var="$1"
	local fileVar="${var}_FILE"
	local def="${2:-}"
	if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
		echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
		exit 1
	fi
	local val="$def"
	if [ "${!var:-}" ]; then
		val="${!var}"
	elif [ "${!fileVar:-}" ]; then
		val="$(< "${!fileVar}")"
	fi
	export "$var"="$val"
	unset "$fileVar"
}

if [[ "$1" == apache2* ]] || [ "$1" == php-fpm ]; then
	file_env 'LIMESURVEY_DB_HOST' 'mysql'
	file_env 'LIMESURVEY_TABLE_PREFIX' ''
	# if we're linked to MySQL and thus have credentials already, let's use them
	file_env 'LIMESURVEY_DB_USER' "${MYSQL_ENV_MYSQL_USER:-root}"
	if [ "$LIMESURVEY_DB_USER" = 'root' ]; then
		file_env 'LIMESURVEY_DB_PASSWORD' "${MYSQL_ENV_MYSQL_ROOT_PASSWORD:-}"
	else
		file_env 'LIMESURVEY_DB_PASSWORD' "${MYSQL_ENV_MYSQL_PASSWORD:-}"
	fi
	file_env 'LIMESURVEY_DB_NAME' "${MYSQL_ENV_MYSQL_DATABASE:-limesurvey}"
	if [ -z "$LIMESURVEY_DB_PASSWORD" ]; then
		echo >&2 'error: missing required LIMESURVEY_DB_PASSWORD environment variable'
		echo >&2 '  Did you forget to -e LIMESURVEY_DB_PASSWORD=... ?'
		echo >&2
		echo >&2 '  (Also of interest might be LIMESURVEY_DB_USER and LIMESURVEY_DB_NAME.)'
		exit 1
	fi

	if ! [ -e index.php ]; then
		echo >&2 "Limesurvey not found in $(pwd) - copying now..."
		if [ "$(ls -A)" ]; then
			echo >&2 "WARNING: $(pwd) is not empty - press Ctrl+C now if this is an error!"
			( set -x; ls -A; sleep 10 )
		fi
		
		cp -dR /usr/src/limesurvey/. .

		echo >&2 "Complete! Limesurvey has been successfully copied to $(pwd)"
	else
        	echo >&2 "Limesurvey found in $(pwd) - not copying."

		# see http://stackoverflow.com/a/2705678/433558
		sed_escape_lhs() {
			echo "$@" | sed -e 's/[]\/$*.^|[]/\\&/g'
		}
		sed_escape_rhs() {
			echo "$@" | sed -e 's/[\/&]/\\&/g'
		}
		php_escape() {
			php -r 'var_export(('$2') $argv[1]);' -- "$1"
		}
		set_config() {
			key="$1"
			value="$2"
			sed -i "/$key/s/'[^']*'/'$value'/2" application/config/config.php
		}

		set_config 'connectionString' "mysql:host=$LIMESURVEY_DB_HOST;port=3306;dbname=$LIMESURVEY_DB_NAME;"
		set_config 'tablePrefix' "$LIMESURVEY_TABLE_PREFIX"
		set_config 'username' "$LIMESURVEY_DB_USER"
		set_config 'password' "$LIMESURVEY_DB_PASSWORD"

	fi

    chown www-data:www-data -R tmp 
    chown www-data:www-data -R upload 
    chown www-data:www-data -R application/config

	TERM=dumb php -- "$LIMESURVEY_DB_HOST" "$LIMESURVEY_DB_USER" "$LIMESURVEY_DB_PASSWORD" "$LIMESURVEY_DB_NAME" <<'EOPHP'
<?php
// database might not exist, so let's try creating it (just to be safe)

$stderr = fopen('php://stderr', 'w');

list($host, $socket) = explode(':', $argv[1], 2);
$port = 0;
if (is_numeric($socket)) {
	$port = (int) $socket;
	$socket = null;
}

$maxTries = 10;
do {
	$mysql = new mysqli($host, $argv[2], $argv[3], '', $port, $socket);
	if ($mysql->connect_error) {
		fwrite($stderr, "\n" . 'MySQL Connection Error: (' . $mysql->connect_errno . ') ' . $mysql->connect_error . "\n");
		--$maxTries;
		if ($maxTries <= 0) {
			exit(1);
		}
		sleep(3);
	}
} while ($mysql->connect_error);

if (!$mysql->query('CREATE DATABASE IF NOT EXISTS `' . $mysql->real_escape_string($argv[4]) . '`')) {
	fwrite($stderr, "\n" . 'MySQL "CREATE DATABASE" Error: ' . $mysql->error . "\n");
	$mysql->close();
	exit(1);
}

$mysql->close();
EOPHP

fi

exec "$@"
