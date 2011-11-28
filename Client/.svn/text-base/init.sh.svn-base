#!/bin/sh
#
# Letzte Aktionen fuer den Wahlausschuss zur Initialisierung der Datenbank
#
# (c) 2002-2004 Christoph Moench-Tegeder <moench-tegeder@rz.uni-karlsruhe.de>
#               Peter Schlaile <Peter.Schlaile@stud.uni-karlsruhe.de>
#               Kristof Koehler <Kristof.Koehler@stud.uni-karlsruhe.de>
#
# Published under GPL.
#

createdb wahl
createlang plpgsql wahl
psql -f init.sql wahl > /dev/null
psql -f FriCardWahl.sql wahl > /dev/null
