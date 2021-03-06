#!/usr/bin/perl -w

# Auszaehl-Frontend, GUI-Definition
# $Id: AuszaehlEdit.pl 151 2009-01-27 17:56:16Z mariop $
#
# (c) 2003, 2004	Kristof Koehler <Kristof.Koehler@stud.uni-karlsruhe.de>
#
# Published under GPL


sub BEGIN {
    my @path = split /\//, $0 ;
    pop @path ;
    $thispath = join ( "/", @path ) ;
    push @INC, $thispath;
}

$SIG{"CHLD"} = sub { wait() ; } ;

use Tk ;
use DataMain ;
use Auswertung ;
use DBLogin ;
use DBI ;

@foreign_keys =
    ( [qw( wahl        id   liste         wahl     )],
      [qw( liste       id   kandidat      liste    )],
      [qw( wahl        id   wahl_urne     wahl     )],
      [qw( urne        id   wahl_urne     urne     )],
      [qw( liste       id   liste_urne    liste    )],
      [qw( urne        id   liste_urne    urne     )],
      [qw( kandidat    id   kandidat_urne kandidat )],
      [qw( urne        id   kandidat_urne urne     )]
      ) ;

DBLogin( "Auszaehl-Edit", "server", "auszaehl", "auszaehl", \&DoMain ) ;
MainLoop ;

sub DoMain { 
    $dbh = $_[0] ;
    $ENV{DBSERVER} = $_[1] ;
    $main = MainWindow->new( -title => "AuszaehlEdit" ) ;
    DoMenu ( $main, 
	     [ [ "Konfiguration ...",          \&TopConfig       ],
	       undef,
	       [ "Wahlen ...",                 \&TopWahl         ],
	       [ "Wahldaten aktualisieren",    \&AW_wahlen       ],
	       undef,
	       [ "Urnen ...",                  \&TopUrne         ], 
	       [ "Urnen pr�fen",               \&UrnePruefenAlle ],
	       undef,
	       [ "Auswertung (Listen+Kand.)",  \&AW_alles        ],
	       [ "Auswertung (Kandidaten)",    \&AW_kand         ],
	       undef,
	       [ "Schrifts�tze ...",           \&TopTexts        ],
	       [ "WWW-Update",                 \&WebUpdate       ] ] ) ;
}

sub DoMenu {
    my ( $win, $entries ) = @_ ;
    my ( $x, $y ) = ( 0, 0 ) ;
    foreach ( @$entries ) {
	if ( defined $_ ) {
	    my $w ;
	    if ( ref $_ eq "CODE" ) {
		$w = &$_($win) ;
	    } else {
		$w = $win->Button( -text => $_->[0], -command => $_->[1] ) ;
	    }
	    $w->grid(-row=>$y,-column=>$x,-sticky=>"news") ;
	    $x++ ;
	} else {
	    $x = 0 ;
	    $y++ ;
	}
    }
}

sub AW_wahlen {
  Auswertung::DoWahlen($dbh) ;
}

sub AW_alles {
  Auswertung::DoWahlen($dbh) ;
  Auswertung::DoListen($dbh) ;
  Auswertung::DoKandidaten($dbh) ;
}

sub AW_kand {
  Auswertung::DoKandidaten($dbh) ;
}

sub UrnePruefenEine {
    my ( $widget, $urne_id ) = @_ ;
    Auswertung::DoWahlen($dbh) ;
    my $msg = Auswertung::UrnePruefen($dbh, $urne_id) ;
    TextMessage ( $main, "Urnenpruefung", 
		  $msg eq "" ? "In Ordnung" : $msg ) ;
}

sub UrnePruefenAlle {
    Auswertung::DoWahlen($dbh) ;
    my $msg = Auswertung::UrnePruefenAlle($dbh) ;
    if ( $msg eq "" ) {
	$msg = "Alles in Ordnung\n\n" ;
    }
    TextMessage ( $main, "Urnenpruefung", $msg ) ;
}

sub WebUpdate {
    system ( "$thispath/web/publish.sh" ) ;
}

sub TopTexts {
    my @Texts =
	( [ "Bekanntmachung der Wahlvorschl�ge", "ausschreibung"    ],
	  [ "Wahlzettel",                        "wahlzettel"       ], 
	  [ "Zaehllisten",                       "zaehlliste"       ],
	  [ "Pr�fbericht der Urnen",             "pruefbericht"     ],  
	  [ "Wahlergebnisse",                    "ergebnisse"       ], 
	  [ "Benachrichtigung der Gewinner",     "benachrichtigung" ] );

    my ( $texttop ) = $main->Toplevel ( -title => "Schrifts�tze" ) ;
    my ( $fmt ) = "ps" ;
    $texttop->Optionmenu ( -options => [ [ "als PostScript", "ps"  ],
					 [ "als PDF",        "pdf" ] ],
			   -variable => \$fmt )
	->pack( -side=>"top", -expand=>1, -fill=>"both") ;
    foreach ( @Texts ) {
	$texttop->Button ( -text    => $_->[0],
			   -command => [ \&DoText, $_->[1], \$fmt ] )
	    ->pack( -side=>"top", -expand=>1, -fill=>"both") ;
    }
}

sub DoText {
    my ( $base, $refext ) = @_ ;
    my ( $out ) ;
    if (open (CMD,"make -C $thispath/text $base.$$refext 2>&1 </dev/null|")){
	while ( <CMD> ) {
	    $out .= $_ ;
	}
	close CMD ;
	print $out;
	if ( $! ) {
	    system "gv $thispath/text/$base.$$refext &" ;
	} else {
	    TextMessage ( $main, "Problem bei Schriftsatz-Erzeugung", $out ) ;
	}
    } else {
	TextMessage ( $main, "Schriftsatz-Erzeugung", 
		      "Fehler beim Ausf�hren" ) ;
    }
}

sub TextMessage {
    my ( $main, $title, $msg ) = @_ ;
    my $msgtop = $main->Toplevel( -title => $title ) ;
    my $txt = $msgtop->Scrolled("Text",-scrollbars=>"osoe" ) ;
    $txt->pack(-side=>"top", -expand=>1, -fill=>"both") ;
    $txt->insert('end',$msg) ;
    $txt->configure(-state=>'disabled') ;
    $msgtop->Button( -text=>"Schliessen",
		     -command=>[ sub { $_[0]->destroy ; }, $msgtop ] )
	->pack(-side=>"top") ;
}

## Config ##################################################

sub TopConfig {
    DataTop ( $main, "Konfiguration",
	      { dbh           => $dbh,
		foreign       => \@foreign_keys,
		select_fields => [ "config.id", 
				   "config.name",
				   "config.value" ],
		select_from   => "config",
		select_order  => "config.id",
		edit_table    => "config",
		id_column     => "config.id",
		can_delete    => 0
		},
	      [ { type      => "label",
		  field     => "config.name"
		  },
		{ type      => "entry",
		  field     => "config.value",
		  width     => 80
		  },
		] ) ;
}

## Wahl ##################################################

sub TopWahl {
    DataTop ( $main, "Wahlen",
	      { dbh           => $dbh,
		foreign       => \@foreign_keys,
		select_fields => [ "wahl.id", 
				   "wahl.name_kurz",
				   "wahl.name_lang",
				   "wahl.wahlberechtigt",
				   "wahl.sitze",
				   "wahl.sitze_wert",
				   "wahl.max_stimmen",
				   "wahl.max_stimmen_wert",
				   "wahl.max_kumulieren",
				   "wahl.max_kumulieren_wert",
				   "wahl.panaschieren" ],
		select_from   => "wahl",
		select_order  => "wahl.id",
		edit_table    => "wahl",
		id_column     => "wahl.id",
		default_row   => { "wahl.id"             => undef,
				   "wahl.name_kurz"      => "",
				   "wahl.name_lang"      => "",
				   "wahl.wahlberechtigt" => undef,
				   "wahl.sitze"          => "",
				   "wahl.max_stimmen"    => "",
				   "wahl.max_kumulieren" => "",
				   "wahl.panaschieren"   => 0 }
	    },
	      [ { type      => "entry",
		  field     => "wahl.name_kurz",
		  header    => "Wahl",
		  width     => 20
		  },
		{ type      => "entry",
		  field     => "wahl.name_lang",
		  header    => "ausfuerliche Bezeichnung",
		  width     => 40
		  },
		{ type      => "entry",
		  field     => "wahl.wahlberechtigt",
		  header    => "Wahlberechtige",
		  width     => 7,
		  emptynull => 1
		  },
		{ type      => "entry",
		  field     => "wahl.sitze",
		  header    => "Sitze",
		  width     => 15
		  },
		{ type      => "label",
		  field     => "wahl.sitze_wert",
		  background => "#f8f8f8"
		  },
		{ type      => "entry",
		  field     => "wahl.max_stimmen",
		  header    => "max Stimmen",
		  width     => 15
		  },
		{ type      => "label",
		  field     => "wahl.max_stimmen_wert",
		  background => "#f8f8f8"
		  },
		{ type      => "entry",
		  field     => "wahl.max_kumulieren",
		  header    => "max Kumul.",
		  width     => 15
		  },
		{ type      => "label",
		  field     => "wahl.max_kumulieren_wert",
		  background => "#f8f8f8"
		  },
	        { type      => "check",
		  field     => "wahl.panaschieren",
		  header    => "Pan." 
		  },
		{ type      => "button",
		  text      => "Listen ...",
		  command   => sub {
		      my ( $sheet, $ref ) = @_ ;
		      if ( defined $ref->{"wahl.id"} ) {
			  TopListe ( $ref->{"wahl.id"}, 
				     $ref->{"wahl.name_kurz"} ) ;
		      }
		  } },
		{ type      => "button",
		  text      => "Urnen ...",
		  command   => sub {
		      my ( $sheet, $ref ) = @_ ;
		      if ( defined $ref->{"wahl.id"} ) {
			  TopWahlUrne ( $ref->{"wahl.id"}, undef ) ;
		      }
		  } }
		] ) ;
}

sub TopListe {
    my ( $wahlid, $wahlname ) = @_ ;
    DataTop ( $main, "Listen - $wahlname",
	      { dbh           => $dbh,
		foreign       => \@foreign_keys,
		select_fields => [ "liste.id", 
				   "liste.wahl",
				   "liste.name_kurz",
				   "liste.name_lang",
				   "liste.nummer",
				   "liste.sitze",
				   "liste.los",
				   "liste.anzeige_nummer",
				   "liste.anzeige_red",
				   "liste.anzeige_green",
				   "liste.anzeige_blue" ],
		select_from   => "liste",
		select_order  => "liste.id",
		select_where  => "liste.wahl=".$dbh->quote($wahlid),
		edit_table    => "liste",
		id_column     => "liste.id",
		default_row   => { "liste.id"             => undef,
				   "liste.wahl"           => $wahlid,
				   "liste.name_kurz"      => "",
				   "liste.name_lang"      => "",
				   "liste.nummer"         => undef,
				   "liste.sitze"          => undef,
				   "liste.los"            => undef,
				   "liste.anzeige_nummer" => undef,
				   "liste.anzeige_red"    => "0.0",
				   "liste.anzeige_green"  => "0.0",
				   "liste.anzeige_blue"   => "0.0" },
		fixed         => [ [ "liste.wahl", $wahlid, 1 ] ]
		},
	      [ { type      => "entry",
		  field     => "liste.name_kurz",
		  header    => "Name (kurz)" },
		{ type      => "entry",
		  field     => "liste.name_lang",
		  header    => "Name (lang)" },
		{ type      => "entry",
		  field     => "liste.nummer",
		  header    => "Nr",
		  width     => 5,
		  emptynull => 1 },
		{ type      => "entry",
		  field     => "liste.anzeige_nummer",
		  header    => "Anzeige-Nr",
		  width     => 5,
		  emptynull => 1 },
		{ type      => "entry",
		  field     => "liste.anzeige_red",
		  header    => "R",
		  width     => 4 },
		{ type      => "entry",
		  field     => "liste.anzeige_green",
		  header    => "G",
		  width     => 4 },
		{ type      => "entry",
		  field     => "liste.anzeige_blue",
		  header    => "B",
		  width     => 4 },
		{ type      => "entry",
		  field     => "liste.sitze",
		  header    => "Sitze",
		  width     => 5,
		  emptynull => 1 },
		{ type      => "entry",
		  field     => "liste.los",
		  header    => "Los",
		  width     => 5,
		  emptynull => 1 },
		{ type      => "button",
		  text      => "Kandidaten ...",
		  command   => [ sub {
		      my ( $wahlname, $sheet, $ref ) = @_ ;
		      if ( defined $ref->{"liste.id"} ) {
			  TopKandidat ( $ref->{"liste.id"}, 
					$ref->{"liste.name_kurz"},
					$wahlname ) ;
		      }
		  }, $wahlname ] },
		{ type      => "button",
		  text      => "Urnen ...",
		  command   => sub {
		      my ( $sheet, $ref ) = @_ ;
		      if ( defined $ref->{"liste.id"} ) {
			  TopListeUrne ( undef, $ref->{"liste.id"}, undef ) ;
		      }
		  } }
		] ) ;
}

sub TopKandidat {
    my ( $listeid, $listename, $wahlname ) = @_ ;
    DataTop ( $main, "Kandidaten - $listename ($wahlname)",
	      { dbh           => $dbh,
		foreign       => \@foreign_keys,
		select_fields => [ "kandidat.id", 
				   "kandidat.liste",
				   "kandidat.listenplatz",
				   "kandidat.typ",
				   "kandidat_typ.name",
				   "kandidat.vorname",
				   "kandidat.nachname",
				   "kandidat.fach",
				   "kandidat.strasse",
				   "kandidat.plz",
				   "kandidat.ort",
				   "kandidat.status",
				   "kandidat_status.name" ],
		select_from   => "kandidat, kandidat_typ, kandidat_status",
		select_order  => "kandidat.id",
		select_where  => "kandidat.status = kandidat_status.id ".
		                 "AND kandidat.typ = kandidat_typ.id ".
		                 "AND kandidat.liste=".$dbh->quote($listeid),
		edit_table    => "kandidat",
		id_column     => "kandidat.id",
		default_row   => { "kandidat.id"          => undef,
				   "kandidat.liste"       => $listeid,
				   "kandidat.listenplatz" => undef,
				   "kandidat.typ"         => 0,
				   "kandidat_typ.name"    => "",
				   "kandidat.vorname"     => "",
				   "kandidat.nachname"    => "",
				   "kandidat.fach"        => "",
				   "kandidat.strasse"     => "",
				   "kandidat.plz"         => "",
				   "kandidat.ort"         => "",
				   "kandidat.status"      => 0,
				   "kandidat_status.name" => "" },
		fixed         => [ [ "kandidat.liste", $listeid, 1 ] ]
		},
	      [ { type      => "entry",
		  field     => "kandidat.listenplatz",
		  header    => "Platz",
		  width     => 4,
		  emptynull => 1 },
		{ type      => "choice",
		  field     => "kandidat.typ",
		  textfield => "kandidat_typ.name",
		  header    => "Typ",
		  list      => $dbh->selectall_arrayref
		      ("SELECT name, id FROM kandidat_typ ORDER BY id"),
		  width     => 10 },
		{ type      => "entry",
		  field     => "kandidat.vorname",
		  header    => "Vorname" },
		{ type      => "entry",
		  field     => "kandidat.nachname",
		  header    => "Nachname" },
		{ type      => "entry",
		  field     => "kandidat.fach",
		  header    => "Fach" },
		{ type      => "entry",
		  field     => "kandidat.strasse",
		  header    => "Strasse" },
		{ type      => "entry",
		  field     => "kandidat.plz",
		  header    => "PLZ",
	          width     => 5 },
		{ type      => "entry",
		  field     => "kandidat.ort",
		  header    => "Ort" },
		{ type      => "choice",
		  field     => "kandidat.status",
		  textfield => "kandidat_status.name",
		  header    => "Status",
		  list      => $dbh->selectall_arrayref
		      ("SELECT name, id FROM kandidat_status ORDER BY id")
		  },
		{ type      => "button",
		  text      => "Urnen ...",
		  command   => sub {
		      my ( $sheet, $ref ) = @_ ;
		      if ( defined $ref->{"kandidat.id"} ) {
			  TopKandidatUrne ( undef, undef,
					    $ref->{"kandidat.id"}, undef ) ;
		      }
		  } }
		] ) ;
}

## Urne ##################################################

sub TopUrne {
    DataTop ( $main, "Urnen",
	      { dbh           => $dbh,
		foreign       => \@foreign_keys,
		select_fields => [ "urne.id", 
				   "urne.fakultaet",
				   "urne.nummer",
				   "urne.status",
				   "urne.stimmen",
				   "urne_status.name" ],
		select_from   => "urne, urne_status",
		select_where  => "urne.status = urne_status.id",
		select_order  => "urne.id",
		edit_table    => "urne",
		id_column     => "urne.id",
		default_row   => { "urne.id"             => undef,
				   "urne.fakultaet"      => "",
				   "urne.nummer"         => undef,
				   "urne.status"         => 0,
				   "urne_status.name"    => "",
				   "urne.stimmen"        => undef },
	    },
	      [ { type      => "entry",
		  field     => "urne.fakultaet",
		  header    => "Fakultaet" 
		  },
		{ type      => "entry",
		  field     => "urne.nummer",
		  header    => "Nummer",
		  width     => 10,
		  emptynull => 1 
		  },
		{ type      => "choice",
		  field     => "urne.status",
		  textfield => "urne_status.name",
		  header    => "Status",
		  list      => $dbh->selectall_arrayref
		      ("SELECT name, id FROM urne_status ORDER BY id")
		  },
		{ type      => "entry",
		  field     => "urne.stimmen",
		  header    => "Stimmzettel",
		  width     => 10,
		  emptynull => 1 
		  },
		{ type      => "button",
		  text      => "Wahlen ...",
		  command   => sub {
		      my ( $sheet, $ref ) = @_ ;
		      if ( defined $ref->{"urne.id"} ) {
			  TopWahlUrne ( undef, $ref->{"urne.id"} ) ;
		      }
		  } },
		{ type      => "button",
		  text      => "Pr�fen ...",
		  command   => sub {
		      my ( $sheet, $ref ) = @_ ;
		      if ( defined $ref->{"urne.id"} ) {
			  UrnePruefenEine ( $sheet, $ref->{"urne.id"} ) ;
		      }
		  } },
		] ) ;
}

## Urne -> * ########################################

sub TopWahlUrne {
    my ( $wahlid, $urneid ) = @_ ;
    my @where ;
    if ( defined $wahlid ) {
        push @where, "wahl.id=".$dbh->quote($wahlid) ;
    }
    if ( defined $urneid ) {
        push @where, "urne.id=".$dbh->quote($urneid) ;
    }
    DataTop ( $main, "Wahl/Urne",
	      { dbh           => $dbh,
		foreign       => \@foreign_keys,
		select_fields => [ "wahl.id", 
				   "wahl.name_kurz",
				   "urne.id",
				   "urne.fakultaet",
				   "urne.nummer",
				   "wahl_urne.id",
				   "wahl_urne.wahl",
				   "wahl_urne.urne",
				   "wahl_urne.stimmzettel",
				   "wahl_urne.stimmzettel_ungueltig",
				   "wahl_urne.listen_ungueltig",
				   "wahl_urne.listen_enthaltungen",
				   "wahl_urne.kandidaten_ungueltig",
				   "wahl_urne.kandidaten_enthaltungen" ],
		select_from   => ( "(wahl, urne) LEFT JOIN wahl_urne ON ".
				   "wahl_urne.wahl = wahl.id AND ".
				   "wahl_urne.urne = urne.id" ),
	        select_order  => "wahl.name_kurz, wahl.id, ".
                                 "urne.fakultaet, urne.nummer, urne.id",
		select_where  => join(" AND ", @where),
		edit_table    => "wahl_urne",
		id_column     => "wahl_urne.id",
		fixed         => [ [ "wahl_urne.wahl", "wahl.id", 0 ],
				   [ "wahl_urne.urne", "urne.id", 0 ] ]
		},
	      [ 
		{ type      => "label",
		  field     => "wahl.name_kurz",
		  header    => "Wahl" },
		{ type      => "label",
		  field     => "urne.fakultaet",
		  header    => "Urne" },
		{ type      => "label",
		  field     => "urne.nummer" },
		{ type      => "entry",
		  field     => "wahl_urne.stimmzettel",
		  header    => "Stimmz.",
		  width     => 10,
		  emptynull => 1 },
		{ type      => "entry",
		  field     => "wahl_urne.stimmzettel_ungueltig",
		  header    => "Stimmz. ung.",
		  width     => 10,
		  emptynull => 1 },
		{ type      => "entry",
		  field     => "wahl_urne.listen_ungueltig",
		  header    => "Liste ung.",
		  width     => 10,
		  emptynull => 1 },
		{ type      => "entry",
		  field     => "wahl_urne.listen_enthaltungen",
		  header    => "Liste enth.",
		  width     => 10,
		  emptynull => 1 },
		{ type      => "entry",
		  field     => "wahl_urne.kandidaten_ungueltig",
		  header    => "Kand. ung.",
		  width     => 10,
		  emptynull => 1 },
		{ type      => "entry",
		  field     => "wahl_urne.kandidaten_enthaltungen",
		  header    => "Kand. enth.",
		  width     => 10,
		  emptynull => 1 },
		{ type      => "button",
		  text      => "Listen ...",
		  command   => sub {
		      my ( $sheet, $ref ) = @_ ;
		      if ( defined $ref->{"urne.id"} ) {
			  TopListeUrne ( $ref->{"wahl.id"}, 
					 undef, $ref->{"urne.id"} ) ;
		      }
		  } },
		{ type      => "button",
		  text      => "Kandidaten ...",
		  command   => sub {
		      my ( $sheet, $ref ) = @_ ;
		      if ( defined $ref->{"urne.id"} ) {
			  TopKandidatUrne ( $ref->{"wahl.id"}, 
					    undef, undef, 
					    $ref->{"urne.id"} ) ;
		      }
		  } },
		] ) ;
}

sub TopListeUrne {
    my ( $wahlid, $listeid, $urneid ) = @_ ;
    my @where ;
    if ( defined $wahlid ) {
        push @where, "wahl.id=".$dbh->quote($wahlid) ;
    }
    if ( defined $listeid ) {
        push @where, "liste.id=".$dbh->quote($listeid) ;
    }
    if ( defined $urneid ) {
        push @where, "urne.id=".$dbh->quote($urneid) ;
    }
    DataTop ( $main, "Liste/Urne",
	      { dbh           => $dbh,
		foreign       => \@foreign_keys,
		select_fields => [ "wahl.name_kurz",
				   "liste.id", 
				   "liste.name_kurz",
				   "urne.id",
				   "urne.fakultaet",
				   "urne.nummer",
				   "liste_urne.id",
				   "liste_urne.liste",
				   "liste_urne.urne",
				   "liste_urne.stimmen" ],
		select_from   => ( "(wahl,liste,urne) LEFT JOIN liste_urne ON ".
				   "liste_urne.liste = liste.id AND ".
				   "liste_urne.urne = urne.id" ),
	        select_order  => "wahl.name_kurz, wahl.id, liste.nummer, ".
                                 "urne.fakultaet, urne.nummer, urne.id",
		select_where  => join(" AND ", "liste.wahl=wahl.id", @where),
		edit_table    => "liste_urne",
		id_column     => "liste_urne.id",
		fixed         => [ [ "liste_urne.liste", "liste.id", 0 ],
				   [ "liste_urne.urne",  "urne.id",  0 ] ]
		},
	      [ 
		{ type      => "label",
		  field     => "wahl.name_kurz",
		  header    => "Wahl" },
		{ type      => "label",
		  field     => "liste.name_kurz",
		  header    => "Liste" },
		{ type      => "label",
		  field     => "urne.fakultaet",
		  header    => "Urne" },
		{ type      => "label",
		  field     => "urne.nummer" },

		{ type      => "entry",
		  field     => "liste_urne.stimmen",
		  header    => "Stimmen",
		  width     => 10,
		  emptynull => 1 },
		] ) ;
}

sub TopKandidatUrne {
    my ( $wahlid, $listeid, $kandidatid, $urneid ) = @_ ;
    my @where ;
    if ( defined $wahlid ) {
        push @where, "wahl.id=".$dbh->quote($wahlid) ;
    }
    if ( defined $listeid ) {
        push @where, "liste.id=".$dbh->quote($listeid) ;
    }
    if ( defined $kandidatid ) {
        push @where, "kandidat.id=".$dbh->quote($kandidatid) ;
    }
    if ( defined $urneid ) {
        push @where, "urne.id=".$dbh->quote($urneid) ;
    }
    DataTop ( $main, "Kandidat/Urne",
	      { dbh           => $dbh,
		foreign       => \@foreign_keys,
		select_fields => [ "wahl.name_kurz",
				   "kandidat.id", 
				   "kandidat.vorname",
				   "kandidat.nachname",
				   "urne.id",
				   "urne.fakultaet",
				   "urne.nummer",
				   "kandidat_urne.id",
				   "kandidat_urne.kandidat",
				   "kandidat_urne.urne",
				   "kandidat_urne.stimmen" ],
		select_from   => ( "(wahl,liste,kandidat,urne) ".
				   "LEFT JOIN kandidat_urne ON ".
				   "kandidat_urne.kandidat = kandidat.id AND ".
				   "kandidat_urne.urne = urne.id" ),
		select_where  => join(" AND ", "liste.wahl=wahl.id", 
				      "kandidat.liste = liste.id", @where),
	        select_order  => "wahl.name_kurz, wahl.id, liste.nummer, ".
		                 "kandidat.listenplatz, kandidat.id, ".
                                 "urne.fakultaet, urne.nummer, urne.id",
		edit_table    => "kandidat_urne",
		id_column     => "kandidat_urne.id",
		fixed         => [ ["kandidat_urne.kandidat","kandidat.id",0],
				   ["kandidat_urne.urne",    "urne.id",    0] ]
		},
	      [ 
		{ type      => "label",
		  field     => "wahl.name_kurz",
		  header    => "Wahl" },
		{ type      => "label",
		  field     => "kandidat.vorname",
		  header    => "Kandidat" },
		{ type      => "label",
		  field     => "kandidat.nachname" },
		{ type      => "label",
		  field     => "urne.fakultaet",
		  header    => "Urne" },
		{ type      => "label",
		  field     => "urne.nummer" },

		{ type      => "entry",
		  field     => "kandidat_urne.stimmen",
		  header    => "Stimmen",
		  width     => 10,
		  emptynull => 1 },
		] ) ;
}

