#!/usr/bin/perl -w
#
# Ausgabe einer Liste aller Waehler und der jeweiligen abgegebenen
# Stimmen, um auch was auf Papier zu kriegen
#
# (c) 2002-2004 Christoph Moench-Tegeder <moench-tegeder@rz.uni-karlsruhe.de>
#               Peter Schlaile <Peter.Schlaile@stud.uni-karlsruhe.de>
#               Kristof Koehler <Kristof.Koehler@stud.uni-karlsruhe.de>
#
# Published under GPL.
#
# Dieses Programm wird auf dem Wahlserver installiert. Am letzten Tag
# der Wahl kann der Wahlausschuss mit diesem Programm eine Liste
# aller Waehler erzeugen, um allen denjenigen, die nicht EDV-technisch
# erfasst werden wollen, trotzdem die Chance zur Wahl zu geben. Der
# Abgleich erfolgt dann per Hand.
# Die Ausgabe erfolgt auf stdout und kann in eine Datei umgeleitet
# werden.
#
# Vorausgesetzte Perl-Module:
#  - Pg (Zu PostgreSQL, libpgperl)
#

use strict;
use Pg;

my ($dbconn, $ret, $sql, $wr, @row, @mwahl);
my ($matr, $buchst, $wid, $wstr);

$dbconn=Pg::connectdb("dbname=wahl");
$ret=$dbconn->status;
if($ret eq PGRES_CONNECTION_BAD) {
	die("PostgreSQL: " . $dbconn->errorMessage . "\n");
	}

print("\nWaehlerliste, generiert am ", scalar(localtime()), "\n\n");
print("Wahlen <-> Nummer-Zuordnung:\n");
$ret=$dbconn->exec("select * from t_wahlen order by wahl_nr");
if(not $ret->resultStatus eq PGRES_TUPLES_OK) {
	die("PostgreSQL: " . $dbconn->errorMessage . "\n");
	}

while(@row=$ret->fetchrow()) {
	print(join(' ', @row), "\n");
	}
print("\nBeginn der Liste\n\nWaehler-ID", " "x10, "\n", "="x60, "\n");

$sql="select waehler_matr, waehler_buchst from t_waehler order by waehler_matr";
$ret=$dbconn->exec($sql);
while(@row=$ret->fetchrow()) {
	$wstr="";
	$wid=$row[0] . $row[1];
	$sql="select hat_wahl from t_hat where hat_matr=" . $row[0];
	$wr=$dbconn->exec($sql);
	while(@mwahl=$wr->fetchrow()) {
		$wstr.=$mwahl[0] . " ";
		}
	printf('%15s %s', $wid, $wstr . "\n");
	}

print("="x60, "\nEnde der Liste\n\n");

$dbconn->reset();
exit(0);

