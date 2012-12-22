<?php

/*

 (c) 2003, 2004 Kristof Koehler <Kristof.Koehler@stud.uni-karlsruhe.de>

 Published under GPL

 */

class query_queue {
	var $result ;
	var $prev, $current, $next ;

	function query_queue ( $r ) {
		$this->result  = $r ;
		$this->prev    = array() ;
		$this->current = array() ;
		$this->next    = mysql_fetch_assoc($this->result) ;
	}

	function retrieve() {
		$this->prev    = $this->current ;
		$this->current = $this->next ;
		$this->next    = mysql_fetch_assoc($this->result) ;
		return $this->current ;
	}
	function get() {
		return $this->current ;
	}

	function diff_next ( $prefix, $postfix ) {
		return $this->diff($this->next, $prefix, $postfix) ;
	}

	function diff_prev ( $prefix, $postfix ) {
		return $this->diff($this->prev, $prefix, $postfix) ;
	}

	function diff( $cmp, $prefix, $postfix ) {
		$r = array() ;
		reset ( $this->current ) ;
		while ( $x = each ( $this->current ) ) {
			if ( $cmp[$x["key"]] != $x["value"] ) {
				$r[$prefix.$x["key"].$postfix] = true ;
			}
		}
		return $r ;
	}
}


function do_query ( $query, $function ) {
	do_query_pass ( $query, $function, $tmp ) ;
}

function do_query_pass ( $query, $function, &$pass ) {
	$row_number = 0;
	$result = mysql_query ( $query ) ;
	if (!$result) {
		print "<B><FONT color='red'>Database error: ".
			mysql_error() . "</FONT></B>\n" ;
		return ;
	}
	$qq = new query_queue ( $result ) ;
	while ( $row = $qq->retrieve() ) {
		$function( array_merge ( $row,
					 $qq->diff_prev ( "_", "" ),
					 $qq->diff_next ( "", "_" ),
					 array("row_number" => $row_number) ),
			   $pass );
		$row_number++;
	}
	mysql_free_result ( $result ) ;
}


function simple_query ( $query ) {
	$result = mysql_query ( $query ) ;
	if (!$result) {
		print "<B><FONT color='red'>Database error: ".
			mysql_error() . "</FONT></B><BR>".
			$query."<BR>\n" ;
		return ;
	}
	if ( ! $row = mysql_fetch_row ( $result ) ) {
		return ;
	}
	mysql_free_result ( $result ) ;
	return $row[0] ;
}

?>

