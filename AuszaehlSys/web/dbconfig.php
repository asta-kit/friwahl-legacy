<?php
mysql_connect($_SERVER["DBSERVER"], "auszaehl-ro", "") 
     or die("Could not connect");
mysql_select_db("auszaehl") 
     or die("Could not select database");

$ok_status = 4 ;
?>
