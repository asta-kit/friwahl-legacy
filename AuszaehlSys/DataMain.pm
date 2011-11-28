# Main and Toplevel DataSheet windows 
# $Id: DataMain.pm 55 2006-01-25 23:40:02Z djpig $
#
# (c) 2003, 2004        Kristof Koehler <Kristof.Koehler@stud.uni-karlsruhe.de>
#
# Published under GPL

package DataMain;
use Exporter ();
@ISA       = qw(Exporter);
@EXPORT    = qw(DataMain DataTop);

use strict ;

use Tk;
use DataSheet ;

sub DataMain {
    my ( $title, $dataspec, $colspec ) = @_ ;

    my $main = MainWindow->new( -title => $title ) ;
    $main->bind("all", "<Tab>", sub{} ) ;
    $main->bind("all", "<Shift-Tab>", sub{} ) ;
    $main->bind("all", "<Shift-ISO_Left_Tab>", sub{} ) ;

    my $ds = $main->DataSheet( -scrollbars => "se",
			       -dataspec => $dataspec,
			       -colspec  => $colspec,
			       -columns  => 15 ) ;
    $ds->pack(-side=>"top", -expand=>1, -fill=>"both") ;

    $main->bind("<F5>", sub { $ds->update_view } ) ;
}

sub DataTop {
    my ( $parent, $title, $dataspec, $colspec ) = @_ ;

    my $top = $parent->Toplevel( -title => $title ) ;
    $top->bind("all", "<Tab>", sub{} ) ;
    $top->bind("all", "<Shift-Tab>", sub{} ) ;
    $top->bind("all", "<Shift-ISO_Left_Tab>", sub{} ) ;

    my $ds = $top->DataSheet( -scrollbars => "se",
			      -dataspec => $dataspec,
			      -colspec  => $colspec,
			      -columns  => 15 ) ;
    $ds->pack(-side=>"top", -expand=>1, -fill=>"both") ;
    
    $top->bind("<F5>", sub { $ds->update_view } ) ;
}
