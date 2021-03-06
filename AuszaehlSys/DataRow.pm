# Row of data editing widgets
# $Id: DataRow.pm 151 2009-01-27 17:56:16Z mariop $
#
# (c) 2003, 2004        Kristof Koehler <Kristof.Koehler@stud.uni-karlsruhe.de>
#
# Published under GPL

package DataRow;
use Exporter ();
@ISA       = qw(Exporter);
@EXPORT    = qw(DataRow);

use strict ;

my $stdfont = [ -family => "Helvetica", 
		-weight => "normal",
		-size   => 8 ] ;

sub DataRow {
    my $this = {} ;
    $this->{"columns"} = [ @_ ] ;
    bless $this ;
    return $this ;
}

sub get_headers {
    my $this = shift ;
    my $cols = $this->{"columns"} ;
    my $spec ;
    my @headers ;
    foreach $spec ( @$cols ) {
	push @headers, ( defined $spec->{"header"} ?
			 $spec->{"header"} : "" ) ;
    }
    return @headers ;
}

sub create_widgets {
    my $this = shift ;
    my ( $parent ) = @_ ;
    my $cols = $this->{"columns"} ;
    my $column ;
    my @widgets ;
    foreach $column ( @$cols ) {
	my $type = $column->{"type"} ;
	push @widgets, &{$DataRow::create_handler{$type}} 
	( $parent, $column ) ;
    }
    return @widgets ;
}

sub set_data {
    my $this = shift ;
    my ( $wid_aref, $data_href ) = @_ ;
    my $cols = $this->{"columns"} ;
    my $i ;
    for ( $i = 0 ; $i < scalar(@$cols) ; $i++ ) {
	my $data = ( defined $cols->[$i]{"field"} ?
		     $data_href->{$cols->[$i]{"field"}} : undef ) ;
	my $type = $cols->[$i]{"type"} ;
        &{$DataRow::set_data_handler{$type}} 
	( $wid_aref->[$i], $cols->[$i], $data, $data_href ) ;
	$wid_aref->[$i]->bind("<FocusIn>", [ sub { 
	    my ( $widget, $ref ) = @_ ;
	    $widget->parent->update_focus($ref) ; 
	}, $data_href ]) ;
    }
}

sub register_widget {
    my ( $name, $create, $set_data ) = @_ ;
    $DataRow::create_handler{$name} = $create ;
    $DataRow::set_data_handler{$name} = $set_data ;
}

########################################

register_widget ( "label", sub {

    my ( $parent, $column ) = @_ ;
    my $w = $parent->Label(-background => "white",
			   -anchor     => "w",
			   -relief     => "flat",
			   -font       => $stdfont ) ;
    if ( defined $column->{"background"} ) {
	$w->configure( -background => $column->{"background"} ) ;
    }
    return $w ;

},  sub {

    my ( $widget, $column, $data, $ref ) = @_ ;
    $widget->configure(-text=>$data) ;
} ) ;

########################################

register_widget ( "entry", sub {

    my ( $parent, $column ) = @_ ;
    my $w = $parent->Entry( -exportselection   => 1,
			    -background        => "white",
			    -selectbackground  => "darkblue",
			    -selectforeground  => "white",
			    -selectborderwidth => 0,
			    -relief            => "flat",
			    -font              => $stdfont  ) ;
    if ( defined $column->{"width"} ) {
	$w->configure( -width => $column->{"width"} ) ;
    }
    return $w ;

}, sub {

    my ( $widget, $column, $data, $ref ) = @_ ;
    $widget->delete(0,'end') ;
    if ( defined $data ) {
	$widget->insert(0,$data) ;
    } else {
	# small hack.
	# if we did non do this, just stepping through a NULL-edit widget
	# would result in the comparison NULL != "" and the column would
	# be set to ""
	if ( ! $column->{"emptynull"} ) {
	    $ref->{$column->{"field"}} = "" ;
	}
    }

    $widget->bind("<FocusOut>", [ sub {
	my ( $widget, $ref, $column, $emptynull ) = @_ ;

	my $val = $widget->get() ;
        $val = Encode::encode("iso-8859-1", $val) 
        if utf8::is_utf8($val); 

	if ( $emptynull && $val eq "" ) {
	    $val = undef ;
	}

	$widget->parent->update_data($ref,$column,$val) ;
	
    }, $ref, $column->{"field"}, $column->{"emptynull"} ]) ;

} ) ;

########################################

register_widget ( "check", sub {

    my ( $parent, $column ) = @_ ;
    return $parent->Checkbutton() ;

}, sub {
    
    my ( $widget, $column, $data, $ref ) = @_ ;
    my $v = $widget->cget("-variable") ;
    $$v = $data ;
    
    $widget->configure(-command => [ sub {
	my ( $widget, $ref, $column ) = @_ ;
	my $v = $widget->cget("-variable") ;
	$widget->parent->update_data($ref,$column,$$v) ;
    }, $widget, $ref, $column->{"field"} ]) ;
    
} ) ;


########################################

register_widget ( "choice", sub {

    my ( $parent, $column ) = @_ ;
    my $var ;
    my $w = $parent->Optionmenu(-variable   => \$var,
				-pady       => 0,
				-background => "white",
				-relief     => "flat",
				-anchor     => "w",
				-font       => $stdfont  ) ;
    if ( defined $column->{"list"} ) {
	$w->configure( -options => $column->{"list"} ) ;
    }
    return $w ;

}, sub {
    
    my ( $widget, $column, $data, $ref ) = @_ ;

    if ( defined $column->{"query"} ) {
	$widget->configure( -options => $column->{"dbh"}->
			    selectall_arrayref($column->{"query"}) ) ;
    } elsif ( defined $column->{"function"} ) {
	$widget->configure( -options => call_function ( $column->{"function"},
							$ref ) ) ;
    }

    my $tvar = $widget->cget("-textvariable") ;
    if ( defined $column->{"textfield"} ) {
	$$tvar = $ref->{$column->{"textfield"}} ;
    } else {
	my $var = $widget->cget("-variable") ;
	$$var = $data ;
	my $opts = $widget->cget("-options") ;
	my $o ;
	if ( defined $opts ) {
	    foreach $o ( @$opts ) {
		if ( $o->[1] eq $data ) {
		    $$tvar = $o->[0] ;
		}
	    }
	}
    }
    
    $widget->configure(-command => [ sub {
	my ( $widget, $ref, $column ) = @_ ;
	my $v = $widget->cget("-variable") ;
	$widget->parent->update_data($ref,$column,$$v) ;
    }, $widget, $ref, $column->{"field"} ]) ;
    
} ) ;


########################################

register_widget ( "button", sub {

    my ( $parent, $column ) = @_ ;
    return $parent->Button( -text => $column->{"text"},
			    -padx => 2, 
			    -pady => 0,
			    -font => $stdfont  ) ;

}, sub {
    
    my ( $widget, $column, $data, $ref ) = @_ ;

    $widget->configure(-command => [ sub {
	my ( $widget, $ref, $column ) = @_ ;
	call_function ( $column->{"command"}, $widget->parent, $ref ) ;
    }, $widget, $ref, $column ]) ;
    
} ) ;

########################################

sub call_function {
    my ( $base, @arg ) = @_ ;
    my ( @base ) ;
    my ( $fn ) ;
    if ( ref ( $base ) eq "CODE" ) {
        @base = () ;
        $fn = $base ;
    } else {
        @base = @$base ;
        $fn = shift @base ;
    }
    return &$fn ( @base, @arg ) ;
}

1
