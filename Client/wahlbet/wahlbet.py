#! /usr/bin/env python

import pgdb
import time
import sys

db = pgdb.connect(database="wahl")

fs_wahl = 2

berechtigte = {}
berechtigte[0] = 22552
berechtigte[1] = 22552	# StuPa
berechtigte[2] = 0	# FS
berechtigte[3] = 3543	# Ausländer
berechtigte[4] = 5998	# Frauen

fs_berechtigte = {}
fs_berechtigte['bau']     = 1429
fs_berechtigte['chembio'] = 1495
fs_berechtigte['ciw']     = 1350
fs_berechtigte['etec']    = 1983
fs_berechtigte['geist']   = 1320
fs_berechtigte['geo']     = 740
fs_berechtigte['info']    = 3068
fs_berechtigte['mach']    = 3910
fs_berechtigte['mathe']   = 1061
fs_berechtigte['physik']  = 1475
fs_berechtigte['wiwi']    = 4256

fs_frauen = {}
fs_frauen['bau']     = 395
fs_frauen['chembio'] = 798
fs_frauen['ciw']     = 406
fs_frauen['etec']    = 213+1.75+1
fs_frauen['geist']   = 814
fs_frauen['geo']     = 320
fs_frauen['info']    = 223+83.5
fs_frauen['mach']    = 412+1
fs_frauen['mathe']   = 383 
fs_frauen['physik']  = 266
fs_frauen['wiwi']    = 841+5.25+83.5

fs_auslaender = {}
fs_auslaender['bau']     = 242
fs_auslaender['chembio'] = 126
fs_auslaender['ciw']     = 174
fs_auslaender['etec']    = 454+3.25+.5
fs_auslaender['geist']   = 114
fs_auslaender['geo']     = 75
fs_auslaender['info']    = 477+54
fs_auslaender['mach']    = 786+.5
fs_auslaender['mathe']   = 112
fs_auslaender['physik']  = 75
fs_auslaender['wiwi']    = 378+9.75+54

urne2fs = {}
urne2fs['chembio'] = {'bau':0.000,'chembio':0.961,'ciw':0.000,'etec':0.000,'geist':0.000,'geo':0.000,'info':0.026,'mach':0.000,'mathe':0.000,'physik':0.000,'wiwi':0.013}
urne2fs['etec']    = {'bau':0.024,'chembio':0.008,'ciw':0.014,'etec':0.847,'geist':0.000,'geo':0.000,'info':0.008,'mach':0.040,'mathe':0.016,'physik':0.014,'wiwi':0.028}
urne2fs['geist']   = {'bau':0.000,'chembio':0.000,'ciw':0.000,'etec':0.000,'geist':1.000,'geo':0.000,'info':0.000,'mach':0.000,'mathe':0.000,'physik':0.000,'wiwi':0.000}
urne2fs['geo']     = {'bau':0.000,'chembio':0.000,'ciw':0.000,'etec':0.000,'geist':0.000,'geo':0.948,'info':0.000,'mach':0.000,'mathe':0.000,'physik':0.052,'wiwi':0.000}
urne2fs['info']    = {'bau':0.000,'chembio':0.000,'ciw':0.004,'etec':0.004,'geist':0.008,'geo':0.000,'info':0.842,'mach':0.017,'mathe':0.054,'physik':0.000,'wiwi':0.071}
urne2fs['machciw'] = {'bau':0.020,'chembio':0.000,'ciw':0.242,'etec':0.002,'geist':0.010,'geo':0.000,'info':0.005,'mach':0.711,'mathe':0.007,'physik':0.000,'wiwi':0.002}
urne2fs['mathe']   = {'bau':0.032,'chembio':0.005,'ciw':0.013,'etec':0.053,'geist':0.011,'geo':0.016,'info':0.232,'mach':0.063,'mathe':0.549,'physik':0.018,'wiwi':0.008}
urne2fs['physik']  = {'bau':0.000,'chembio':0.012,'ciw':0.000,'etec':0.024,'geist':0.000,'geo':0.000,'info':0.010,'mach':0.005,'mathe':0.007,'physik':0.964,'wiwi':0.000}
urne2fs['wiwi']    = {'bau':0.000,'chembio':0.008,'ciw':0.006,'etec':0.000,'geist':0.004,'geo':0.000,'info':0.008,'mach':0.001,'mathe':0.006,'physik':0.001,'wiwi':0.966}

urne2fs['akk']     = {'bau':0.035,'chembio':0.054,'ciw':0.112,'etec':0.144,'geist':0.051,'geo':0.038,'info':0.173,'mach':0.163,'mathe':0.035,'physik':0.051,'wiwi':0.141}
urne2fs['mensa']   = {'bau':0.074,'chembio':0.021,'ciw':0.162,'etec':0.081,'geist':0.016,'geo':0.019,'info':0.098,'mach':0.274,'mathe':0.038,'physik':0.058,'wiwi':0.156}
urne2fs['rz']      = {'bau':0.074,'chembio':0.021,'ciw':0.162,'etec':0.081,'geist':0.016,'geo':0.019,'info':0.098,'mach':0.274,'mathe':0.038,'physik':0.058,'wiwi':0.156}
urne2fs['west']    = {'bau':0.000,'chembio':0.000,'ciw':0.000,'etec':0.063,'geist':0.000,'geo':0.000,'info':0.000,'mach':0.000,'mathe':0.000,'physik':0.938,'wiwi':0.000}

for value in fs_berechtigte.itervalues():
    berechtigte[fs_wahl] += value

fs_quote = {}
for fs in fs_berechtigte.iterkeys():
    fs_quote[fs] = fs_berechtigte[fs] / float(fs_berechtigte[fs]*2 + fs_auslaender[fs] + fs_frauen[fs])


cursor = db.cursor()

wahlen = {}
cursor.execute('SELECT * FROM t_wahlen;')
for row in cursor.fetchall():
    wahlen[row[0]] = row[1]

cursor.execute('SELECT COUNT(waehler_matr) FROM t_waehler;')
waehler_gesammt = cursor.fetchone()[0]

waehler = {}
for wahl in wahlen.iterkeys():
    cursor.execute('SELECT COUNT(hat_matr) FROM t_hat WHERE hat_wahl=%(wahl)li;', {'wahl':wahl})
    waehler[wahl] = cursor.fetchone()[0]

votes = 0
fsvotes = 0
for key, this_votes in waehler.iteritems():
    if key == 0:
        continue
    if key == fs_wahl:
        fsvotes = this_votes
    votes += this_votes

cursor.execute('SELECT urne_wer, urne_inhalt FROM t_urnen;')
urnen = {}
for row in cursor.fetchall():
    urnen[row[0]] = row[1]

# So das Fachschaften ohne Urnen funktionieren
urnen_commulated = {}
for urne in urne2fs.iterkeys():
    urnen_commulated[urne] = 0

for urne in urnen.iterkeys():
    key = urne.strip('0123456789')
    if not urnen_commulated.has_key(key):
        urnen_commulated[key] = 0
    urnen_commulated[key] += urnen[urne]

data = {}
data['date'] = str(time.strftime('%d.%m.%y %H:%M %Z', time.localtime()))

data['global'] = 100.0 * waehler_gesammt / float(berechtigte[0])
for wahl in wahlen.iterkeys():
    data['wahl%i' % wahl] = 100.0 * waehler[wahl] / float(berechtigte[wahl])
    data['votes%i' % wahl] = waehler[wahl]
    data['berechtigte%i' % wahl] = berechtigte[wahl]

fs_fsvotes = {}

for fs in fs_berechtigte.iterkeys():
    fs_fsvotes[fs] = 0

for urne in urnen_commulated.iterkeys():
    for fs in urne2fs[urne].iterkeys():
        fs_fsvotes[fs] += urnen_commulated[urne]*urne2fs[urne][fs]*fs_quote[fs]

for fs in fs_berechtigte.iterkeys():
    data['fs_%s' % fs] = 100.0 * fs_fsvotes[fs] / float(fs_berechtigte[fs])
    data['fsvotes_%s' % fs] = fs_fsvotes[fs]
    data['fsberechtigte_%s' % fs] = fs_berechtigte[fs]

for urnen in urnen_commulated.iterkeys():
    data['zettel_%s' % urnen] = urnen_commulated[urnen]

out = open(sys.argv[1]).read()

print out % data,

