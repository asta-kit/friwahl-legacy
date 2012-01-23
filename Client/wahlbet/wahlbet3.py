#! /usr/bin/env python2

import pgdb
import time
import sys

db = pgdb.connect(database="wahl")

fs_wahl = 2

berechtigte = {}
berechtigte[0] = 22552
berechtigte[1] = 22552	# StuPa
berechtigte[2] = 0	# FS
berechtigte[3] = 3543	# Auslaender
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

fs_quote = {}
fs_quote['bau']     = 0.47
fs_quote['chembio'] = 0.45979899
fs_quote['ciw']     = 0.45933457
fs_quote['etec']    = 0.47076923
fs_quote['geist']   = 0.65644172
fs_quote['geo']     = 0.47500000
fs_quote['info']    = 0.47164179
fs_quote['mach']    = 0.45933457
fs_quote['mathe']   = 0.44780218
fs_quote['physik']  = 0.48201439
fs_quote['wiwi']    = 0.54709532

urne2fs = {}
urne2fs['chembio'] = {'bau':0.000,'chembio':0.964,'ciw':0.000,'etec':0.000,'geist':0.000,'geo':0.000,'info':0.026,'mach':0.000,'mathe':0.000,'physik':0.000,'wiwi':0.010}
urne2fs['etec']    = {'bau':0.025,'chembio':0.009,'ciw':0.015,'etec':0.847,'geist':0.000,'geo':0.000,'info':0.008,'mach':0.040,'mathe':0.015,'physik':0.013,'wiwi':0.028}
urne2fs['geist']   = {'bau':0.000,'chembio':0.000,'ciw':0.000,'etec':0.000,'geist':1.000,'geo':0.000,'info':0.000,'mach':0.000,'mathe':0.000,'physik':0.000,'wiwi':0.000}
urne2fs['geo']     = {'bau':0.000,'chembio':0.000,'ciw':0.000,'etec':0.000,'geist':0.000,'geo':0.955,'info':0.000,'mach':0.000,'mathe':0.000,'physik':0.044,'wiwi':0.000}
urne2fs['info']    = {'bau':0.000,'chembio':0.000,'ciw':0.004,'etec':0.004,'geist':0.009,'geo':0.000,'info':0.840,'mach':0.016,'mathe':0.057,'physik':0.000,'wiwi':0.071}
urne2fs['machciw'] = {'bau':0.021,'chembio':0.000,'ciw':0.253,'etec':0.002,'geist':0.011,'geo':0.000,'info':0.004,'mach':0.699,'mathe':0.007,'physik':0.000,'wiwi':0.002}
urne2fs['mathe']   = {'bau':0.033,'chembio':0.005,'ciw':0.013,'etec':0.052,'geist':0.012,'geo':0.019,'info':0.226,'mach':0.062,'mathe':0.553,'physik':0.018,'wiwi':0.008}
urne2fs['physik']  = {'bau':0.000,'chembio':0.014,'ciw':0.000,'etec':0.022,'geist':0.000,'geo':0.000,'info':0.010,'mach':0.004,'mathe':0.008,'physik':0.962,'wiwi':0.000}
urne2fs['wiwi']    = {'bau':0.000,'chembio':0.009,'ciw':0.006,'etec':0.000,'geist':0.004,'geo':0.000,'info':0.008,'mach':0.001,'mathe':0.005,'physik':0.001,'wiwi':0.965}

urne2fs['akk']     = {'bau':0.036,'chembio':0.059,'ciw':0.115,'etec':0.142,'geist':0.056,'geo':0.043,'info':0.169,'mach':0.158,'mathe':0.035,'physik':0.047,'wiwi':0.138}
urne2fs['mensa']   = {'bau':0.077,'chembio':0.023,'ciw':0.168,'etec':0.081,'geist':0.017,'geo':0.022,'info':0.096,'mach':0.268,'mathe':0.039,'physik':0.054,'wiwi':0.155}
urne2fs['rz']      = {'bau':0.077,'chembio':0.023,'ciw':0.168,'etec':0.081,'geist':0.017,'geo':0.022,'info':0.096,'mach':0.268,'mathe':0.039,'physik':0.054,'wiwi':0.155}
urne2fs['west']    = {'bau':0.000,'chembio':0.000,'ciw':0.000,'etec':0.057,'geist':0.000,'geo':0.000,'info':0.000,'mach':0.000,'mathe':0.000,'physik':0.943,'wiwi':0.000}

for value in fs_berechtigte.itervalues():
    berechtigte[fs_wahl] += value

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

