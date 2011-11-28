<?php

/*

 (c) 2003, 2004 Kristof Koehler <Kristof.Koehler@stud.uni-karlsruhe.de>

 Published under GPL

 */

function rgbtohex ( $r, $g, $b ) {
	return sprintf ( "#%02x%02x%02x", 255*$r, 255*$g, 255*$b ) ;
}

function colorTD ( $text, $align, $r, $g, $b, $span = 1 ) {
        $y = $r*.299 + $g*.587 + $b*.114;
	$fg = ($y > 0.4) ? "#000000" : "#ffffff" ;
	return ( "<TD align='$align' bgcolor='".rgbtohex($r,$g,$b)."' ".
		 "colspan=$span><FONT color='$fg'>".
		 $text.
		 "</FONT></TD>" ) ;
}

function section ( $text ) {
	print "<FONT size=+2><B>$text</B></FONT><BR>\n" ;
}

function image ( $file, $alt = "" ) {
	print "<IMG src='$file?cache_dummy=".time()."' alt='$alt'><BR>\n" ;
}

function percent ( $part, $total ) {
	return ($total == 0) ? 0 :
		round(100*$part/$total,1) ;
}

function get_query_array ( $row, &$array ) {
	array_push ( $array, $row ) ;
}

function listname ( $short, $long ) {
	if ( $short != "" ) {
		$tmp = "$short" ;
		if ( $long != "" )
			$tmp .= " ($long)" ;
		
	} else {
		$tmp = "$long" ;
	}
	return $tmp ;
}

?>
