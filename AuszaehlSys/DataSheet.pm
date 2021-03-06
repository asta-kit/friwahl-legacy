# Data Editing Spreadsheet
# $Id: DataSheet.pm 55 2006-01-25 23:40:02Z djpig $
#
# (c) 2003, 2004        Kristof Koehler <Kristof.Koehler@stud.uni-karlsruhe.de>
#
# Published under GPL

package DataSheet;
use strict;

use vars qw($VERSION);
$VERSION = '0.1' ;

use Tk::Pretty;
use base qw(Spreadsheet);

use DataEdit ;
use DataRow ;

Construct Tk::Widget 'DataSheet';

## config ########################################

sub Populate {
    my ( $this, $args ) = @_ ;
    $this->SUPER::Populate($this,$args);
    $this->ConfigSpecs
	( -dataspec     => [METHOD =>  'dataspec',  'DataSpec'      ],
	  -colspec      => [METHOD =>  'colspec',   'ColSpec'       ] ) ;
}

sub dataspec {
    my ( $this, $arg ) = @_ ;
    $this->{"DataEdit"} = DataEdit ( %$arg ) ;
}

sub colspec {
    my ( $this, $arg ) = @_ ;
    $this->{"DataRow"} = DataRow ( @$arg ) ;
}

sub new {
    my $package = shift;
    my $parent  = shift;
    my $obj = $package->SUPER::new($parent,@_) ;
    $obj->set_headers ;
    $obj->update_view ;
    $obj->configure ( -fixedrows    => 1,
		      -fixedcolumns => 1,
		      -nextstartcol => 1,
		      -prevendcol   => $obj->totalColumns-1
		      ) ;
    $obj->bind("<FocusIn>", sub { 
	$_[0]->bind("<FocusIn>",undef) ;
	$_[0]->moveto(1,1,0,1) ; 
    } ) ;
    $obj->focus() ;
    return $obj ;
}

## handling ########################################

# FIXME:
# Focus conservation

sub set_headers {
    my $this = shift ;
    my $c = 1 ;
    my $h ;
    foreach $h ( $this->{"DataRow"}->get_headers ) {
	$this->put ( 0, $c++, $h ) ;
    } 
}

sub update_data {
    my $this = shift ;
    my ( $data, $column, $value ) = @_ ;
    my $eq = ( defined $value == defined $data->{$column} ) ;
    if ( $eq && defined $value ) {
	$eq &= ( $value eq $data->{$column} ) ;
    }
    if ( ! $eq ) {
	$data->{$column} = $value ;
	$this->{"DataEdit"}->set_data ( $data, $column ) ;
    }
    $this->update_view ;
}

sub delete_data {
    my $this = shift ;
    my ( $data ) = @_ ;
    $this->{"DataEdit"}->delete_data ( $data ) ;
    $this->update_view ;
}

sub update_focus {
    my $this = shift ;
    my ( $data ) = @_ ;
#    print "UPDATE Focus\n" ;
#    print Dumper ( $data ) ;
#    $this->{"FocusRow"} = $data ;
    $this->update_view ;
}

sub update_view {
    my $this = shift ;

    my $de = $this->{"DataEdit"} ;
    my $dr = $this->{"DataRow"} ;
    my $data = $de->get_data ;

    my $r ;
    for ( $r = 0 ; $r < scalar(@$data) ; $r++ ) {

	# create new rows
	if ( ($r+1 >= $this->totalRows) ||
	     (ref($this->get($r+1,0)) ne "Tk::Button") ) {
	    ## FIXME: ugly hack, actually needs Table::delete
	    my $w ;
	    my $b = $this->Button(-padx=>0, -pady=>0 ) ;
	    $b->configure(-command => [ sub { $_[0]->focus; }, $b ]) ;
	    my $c = 0 ;
	    foreach $w ( $b, $dr->create_widgets($this) ) {
		my $old = $this->put($r+1,$c++,$w) ;
		if ( defined $old ) {
		    $old->destroy ;
		}
	    }
	}

	my $id = $data->[$r]->{$de->id_column} ;
	
	# set Delete button
	my $b = $this->get($r+1,0) ;

	$b->configure
	    ( -text    => ( defined $id ? " " : "*" ),
	      -state   => ( (defined $id && $de->{"can_delete"})
			    ? "normal" : "disabled" ) ) ;
	$b->bind ( "<Delete>", [ sub { 
	    my ( $wid, $ref ) = @_ ;
	    $wid->parent->delete_data ( $ref ) ;
	}, $data->[$r] ] ) ;
	$b->bind ( "<FocusIn>", [ sub { 
	    my ( $wid, $data ) = @_ ;
	    $wid->parent->update_focus($data) ; 
	}, $data->[$r] ] ) ;
	
	# set Data
	my ( @w, $c ) ;
	for ( $c = 1 ; $c < $this->totalColumns ; $c++ ) {
	    push @w, $this->get($r+1,$c) ;
	}
	$dr->set_data ( \@w, $data->[$r] ) ;

#  	# adapt focus
#  	print "ADAPT\n" ;
#  	print Dumper($r,$this->{"FocusRow"},$data->[$r]) ;
#  	if ( defined $this->{"FocusRow"} ) {
#  	    if ( defined $this->{"FocusRow"}->{$de->id_column} ) {
#  		if ( defined $data->[$r]->{$de->id_column} &&
#  		     ( $this->{"FocusRow"}->{$de->id_column} eq
#  		       $data->[$r]->{$de->id_column} ) ) {
#  		    $this->set_focus_row($r+1) ;
#  		}
#  	    } else {
#  		my $auxid = $this->cget("-auxid") ;
#  		if ( @$auxid > 0 ) {
#  		    my $ok = 1 ;
#  		    my $ai ;
#  		    foreach $ai ( @$auxid ) {
#  			$ok &= ( $this->{"FocusRow"}->{$ai} eq
#  				 $data->[$r]->{$ai} ) ;
#  		    }
#  		    if ( $ok ) {
#  			$this->set_focus_row($r+1) ;
#  		    }
#  		}
#  	    }
#  	}
    }
    
    # delete excess rows
    for ( ; $r+1 < $this->totalRows ; $r++ ) {
	my $c ;
	for ( $c = 0 ; $c < $this->totalColumns ; $c++ ) {
	    my $old = $this->put ( $r+1, $c, undef ) ;
	    if ( defined $old ) {
		$old->destroy ;
	    }
	}
    }
}

#sub set_focus_row {
#    my $this = shift ;
#    my ( $newr ) = @_ ;
#    print "focus: $newr\n" ;
#    my ( $r, $c ) = $this->Posn($this->focusCurrent) ;
#    if ( defined $r ) {
#	$this->moveto ( $newr, $c, 0, 0 ) ;
#    }
#}

1 ;
