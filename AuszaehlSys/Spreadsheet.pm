# Spreadsheet widget
# $Id: Spreadsheet.pm 55 2006-01-25 23:40:02Z djpig $
#
# (c) 2003, 2004        Kristof Koehler <Kristof.Koehler@stud.uni-karlsruhe.de>
#
# Published under GPL

package Spreadsheet;
use strict;

use vars qw($VERSION);
$VERSION = '0.1' ;

use Tk::Pretty;
use base qw(Tk::Table);

Construct Tk::Widget 'Spreadsheet';

sub Populate {
    my ( $this, $args ) = @_ ;
    $this->SUPER::Populate($this,$args);
    $this->ConfigSpecs
	( '-takefocus'          => [SELF => 'takeFocus','TakeFocus',0],
	  '-highlightthickness' => [SELF => 'highlightThickness',
				            'HighlightThickness',0],
	  '-nextstartcol'       => [PASSIVE => 'nextstartcol',
				               'NextStartCol',0],
	  '-prevendcol'         => [PASSIVE => 'prevendcol',
				               'PrevEndCol',0]
	  ) ;
}

sub put {
    my ( $this, $row, $col, $wid ) = @_ ;

    if ( ref $wid ) {
	my ( $tag ) = $wid->bindtags ;
	$wid->bind($tag, "<Down>",          [ \&MoveRel,  +1,  0 ] ) ;
	$wid->bind($tag, "<Up>",            [ \&MoveRel,  -1,  0 ] ) ;

	$wid->bind($tag, "<Control-Left>",  [ \&MoveRel,   0, -1 ] ) ;
	$wid->bind($tag, "<Control-Right>", [ \&MoveRel,   0, +1 ] ) ;
	$wid->bind($tag, "<Control-Down>",  [ \&MoveRel,  +1,  0 ] ) ;
	$wid->bind($tag, "<Control-Up>",    [ \&MoveRel,  -1,  0 ] ) ;

	$wid->bind($tag, "<Next>",          [ \&MovePage, +1,  0 ] ) ;
	$wid->bind($tag, "<Prior>",         [ \&MovePage, -1,  0 ] ) ;
	
	$wid->bind($tag, "<Control-Home>",  [ \&MoveRowFract, 0 ] ) ;
	$wid->bind($tag, "<Control-End>",   [ \&MoveRowFract, 1 ] ) ;
	
	$wid->bind($tag, "<Return>",             [ \&MoveNext ] ) ;
	$wid->bind($tag, "<KP_Enter>",           [ \&MoveNext ] ) ;
	$wid->bind($tag, "<Tab>",                [ \&MoveNext ] ) ;
	$wid->bind($tag, "<Shift-Tab>",          [ \&MovePrev ] ) ;
	$wid->bind($tag, "<Shift-ISO_Left_Tab>", [ \&MovePrev ] ) ;
	
    }

    return $this->SUPER::put($row,$col,$wid);
}

#sub delete {
#    my $this = shift;
#    my ($row,$col) = (@_ == 2) ? @_ : @{$t->{Slave}{$_[0]->PathName}};
#    my $old = $this->{Row}[$row][$col] ;
#    if (defined $old) {
#	
#    }
#}

sub moveto {
    my ( $this, $row, $col, $step_row, $step_col ) = @_ ;
    $row = 0 if ( $row < 0 ) ;
    $col = 0 if ( $col < 0 ) ;
    $row = $this->totalRows()-1    if ( $row >= $this->totalRows() ) ;
    $col = $this->totalColumns()-1 if ( $col >= $this->totalColumns() ) ;
    while ( $col >= 0 && $col < $this->totalColumns() &&
	    $row >= 0 && $row < $this->totalRows() ) {
	my ( $new_wid ) = $this->get($row,$col) ;
	if ( defined $new_wid ) {
	    my ( $tf ) = $new_wid->cget("-takefocus") ;
	    if ( ! defined $tf || $tf eq "1" ) {
		$this->see($row,$col) ;
		$new_wid->focus() ;
		return 1 ;
	    }
	}
	if ( $step_row == 0 && $step_col == 0 ) {
	    return 0 ;
	}
	$row += $step_row ;
	$col += $step_col ;
    }
    return 0 ;
    
}

sub MoveRel {
    my ( $wid, $dr, $dc ) = @_ ;
    my ( $tab ) = $wid->parent() ;
    my ( $r, $c ) = $tab->Posn($wid) ;
    $r += $dr ;
    $c += $dc ;
    $tab->moveto( $r, $c, $dr, $dc ) ;
}

sub MovePage {
    my ( $wid, $dr, $dc ) = @_ ;
    my ( $tab ) = $wid->parent() ;
    my ( $r, $c ) = $tab->Posn($wid) ;
    $r += $dr * $tab->cget("-rows") ;
    $c += $dc * $tab->cget("-columns") ;
    $tab->moveto ( $r, $c, -$dr, -$dc ) ;
}

sub MoveRowFract {
    my ( $wid, $rfract ) = @_ ;
    my ( $tab ) = $wid->parent() ;
    my ( $r, $c ) = $tab->Posn($wid) ;
    $r = int(($tab->totalRows()-1) * $rfract) ;
    $tab->moveto ( $r, $c, $r > 0.5 ? -1 : +1, 0 ) ;
}

sub MoveNext {
    my ( $wid ) = @_ ;
    my ( $tab ) = $wid->parent() ;
    my ( $r, $c ) = $tab->Posn($wid) ;
    if ( $c < $tab->totalColumns()-1 && 
	 $tab->moveto ( $r, $c+1, 0, 1 ) ) {
	return ;
    }
    if ( $r < $tab->totalRows()-1 && 
	 $tab->moveto ( $r+1, $tab->cget("-nextstartcol"), 0, 1 ) ) {
	return ;
    }
    for ( $r = 0 ; $r < $tab->totalRows() ; $r++ ) {
	if ( $tab->moveto ( $r, $tab->cget("-nextstartcol"), 0, 1 ) ) {
	    return ;
	}
    }
}

sub MovePrev {
    my ( $wid ) = @_ ;
    my ( $tab ) = $wid->parent() ;
    my ( $r, $c ) = $tab->Posn($wid) ;
    if ( $c > 0 && 
	 $tab->moveto ( $r, $c-1, 0, -1 ) ) {
	return ;
    }
    if ( $r > 0 && 
	 $tab->moveto ( $r-1, $tab->cget("-prevendcol"), 0, -1 ) ) {
	return ;
    }
    for ( $r = $tab->totalRows()-1 ; $r >= 0  ; $r-- ) {
	if ( $tab->moveto ( $r, $tab->cget("-prevendcol"), 0, -1 ) ) {
	    return ;
	}
    }
}

1 ;
