<?php

$envvars = array(
    'DB_HOST',
    'DB_USER',
    'DB_PASSWORD'
);

foreach($envvars as $ENVVAR) {
    if($v = getenv($ENVVAR)) {
        define($ENVVAR, $v);
    }
}
