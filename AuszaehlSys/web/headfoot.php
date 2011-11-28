<?php

/*

 (c) 2003, 2004 Kristof Koehler <Kristof.Koehler@stud.uni-karlsruhe.de>

 Published under GPL

 */

function head ( $title, $file = "" ) {
	if ( $file != "" ) {
		print "\n<NEWFILE $file $title>\n" ;
	}

	$urnen_total = simple_query("SELECT count(*) FROM urne") ;
	$urnen_done  = simple_query("SELECT count(*) FROM urne WHERE status=".
				    $GLOBALS["ok_status"]) ;
	$stimmen_total = simple_query("SELECT sum(stimmen) FROM urne") ;
	$stimmen_done  = simple_query("SELECT sum(stimmen) FROM urne WHERE status=".
				    $GLOBALS["ok_status"]) ;
?>
<HTML>
  <HEAD><TITLE>Unabhängige Wahlen Uni Karlsruhe - <?=$title?></TITLE>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  </HEAD>
  <BODY bgcolor="#cccccc">
    <TABLE width="100%" cellspacing=0 border=0 cellpadding=3>
      <TR bgcolor="#000099">
        <TD><IMG SRC="wahl-logo.png" alt=""></TD>
        <TD width="100%">
          <FONT size=+1 color="#ffffff"><B>
            Wahlen zum Unabhängigen Modell
            an der Universität Karlsruhe</B></FONT><BR><BR>
          <FONT size=+2 color="#ffffff"><B>
            <?=$title?>
          </B></FONT>
          </TD>
      </TR>
      <TR bgcolor="#6666ff">
        <TD colspan=2><FONT color="#ffffff">
	 Zwischenstand <?=date("j.n.Y H:i")?>, 
         <?=$urnen_done?> von <?=$urnen_total?> Urnen,
         ca. <?=percent($stimmen_done,$stimmen_total)?>% der Stimmzettel,
         <A href="index.html?cache_dummy=<?=time()?>"><FONT color="#ffff00">&Uuml;bersicht</FONT></A>
        </FONT></TD>
      </TR>
    </TABLE>
    <BR>
<?php
}

function foot () {
?>
    <BR>
    <TABLE width="100%" cellspacing=0 border=0 cellpadding=3>
      <TR bgcolor="#000099">
        <TD width="100%"><FONT color="#ffffff">
          Der Wahlausschuss
        </B></FONT></TD>
      </TR>
    </TABLE>
  </BODY>
</HTML>
<?php
}
?>
