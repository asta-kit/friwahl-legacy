<?php

if (isset($_GET['delay']))
	$delay = $_GET['delay'];
if (isset($_GET['list']))
        $list = $_GET['list'];
if (isset($_GET['page']))
        $page = $_GET['page'];

if ( ! isset($delay) )
	$delay = 5 ;
if ( ! isset($list) )
	$list = "default" ;
if ( ! isset($page) )
	$page = 0 ;

$list = preg_replace ( "/[^a-zA-Z0-9_\\-]/", "", $list ) ;
$page = intval($page) ;

if ( file_exists($list.".cycle") ) {
	$alist = file ( $list.".cycle" ) ;

	if ( $page >= count($alist) )
		$page = 0 ;
	$nextpage = $page+1 ;
	if ( $nextpage >= count($alist) )
		$nextpage = 0 ;
	
	header("Refresh: ".$delay."; URL=".
	       $_SERVER['SCRIPT_NAME'].
	       "?delay=".urlencode($delay).
	       "&list=".urlencode($list).
	       "&page=".urlencode($nextpage) ) ;

	if ( $page < count($alist) ) {
		$info = apache_lookup_uri ( trim($alist[$page]) ) ;
		if ( isset ( $info->filename ) && 
		     file_exists ( $info->filename ) ) {
			header ("Content-Type: ".$info->content_type) ;
			readfile ( $info->filename ) ;
			exit ;
		}
	}
}
header("HTTP/1.0 404 Not Found");
?>
<HTML>
  <HEAD><TITLE>404 Not Found</TITLE></HEAD>
  <BODY>404 Not Found (<?php print (trim($alist[$page])) ?>)</BODY>
</HTML>
