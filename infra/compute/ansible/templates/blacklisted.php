<?php
$ip = pg_escape_string($_SERVER['REMOTE_ADDR']);
$dbconn = pg_connect("host=localhost dbname=phpdb user=postgres password=admin123");
$query_insert = pg_query($dbconn, "INSERT  INTO blacklistip(ip) VALUES ('$ip');");
//print($ip);
die(header("Location: /test.html"));
?>