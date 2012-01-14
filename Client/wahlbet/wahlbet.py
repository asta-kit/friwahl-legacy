#! /usr/bin/env python

import pgdb
import time
import sys

db = pgdb.connect(database="wahl")

fs_wahl = 2

berechtigte = {}
berechtigte[0] = 20771
berechtigte[1] = 20771
berechtigte[2] = 0
berechtigte[3] = 3466
berechtigte[4] = 5691

fs_berechtigte = {}
fs_berechtigte['chembio'] = 1499.75
fs_berechtigte['geo'] = 536
fs_berechtigte['bau'] = 1167
fs_berechtigte['mathe'] = 1222
fs_berechtigte['info'] = 2454.5
fs_berechtigte['wiwi'] = 3612.5
fs_berechtigte['physik'] = 1494.75
fs_berechtigte['etec'] = 1826.25
fs_berechtigte['geist'] = 1459
fs_berechtigte['machciw'] = 3660.25+1221 # mach+ciw

fs_frauen = {}
fs_frauen['chembio'] = 767
fs_frauen['geo'] = 288
fs_frauen['bau'] = 339
fs_frauen['mathe'] = 395
fs_frauen['info'] = 293.5
fs_frauen['wiwi'] = 872.5
fs_frauen['physik'] = 249
fs_frauen['etec'] = 191.5
fs_frauen['geist'] = 791
fs_frauen['machciw'] = 398.5+388 #mach+ciw

fs_auslaender = {}
fs_auslaender['chembio'] = 113.5
fs_auslaender['geo'] = 71
fs_auslaender['bau'] = 223
fs_auslaender['mathe'] = 117
fs_auslaender['info'] = 534
fs_auslaender['wiwi'] = 406
fs_auslaender['physik'] = 88.5
fs_auslaender['etec'] = 450.5
fs_auslaender['geist'] = 100
fs_auslaender['machciw'] = 786.5+188 #mach+ciw

urne2fs = {}
urne2fs['bau'] = {'bau':1}
urne2fs['chembio'] = {'chembio':1}
urne2fs['etec'] = {'etec':1}
urne2fs['geist'] = {'geist':1}
urne2fs['geo'] = {'geo':1}
urne2fs['info'] = {'info':1}
urne2fs['machciw'] = {'machciw':1}
urne2fs['mathe'] = {'mathe':1}
urne2fs['physik'] = {'physik':1}
urne2fs['wiwi'] = {'wiwi':1}
urne2fs['akk'] = {'chembio':0.022,'geo':0.078,'bau':0.039,'mathe':0.052,'info':0.200,'wiwi':0.087,'physik':0.096,'etec':0.113,'geist':0.035,'machciw':0.279}  # nach rohdaten von wahl 2010
urne2fs['mensa'] = {'chembio':0.028,'geo':0.044,'bau':0.066,'mathe':0.021,'info':0.135,'wiwi':0.141,'physik':0.030,'etec':0.081,'geist':0.012,'machciw':0.441} # nach rohdaten von wahl 2010
urne2fs['rz'] = {'chembio':0.067,'geo':0.027,'bau':0.056,'mathe':0.055,'info':0.129,'wiwi':0.188,'physik':0.073,'etec':0.093,'geist':0.064,'machciw':0.243} # nach berechtige(fs)/sum(berechtigte)
urne2fs['benz'] = {'machciw':0.31,'info':0.11,'mathe':0.08,'etec':0.15,'bau':0.16,'wiwi':0.08,'physik':0.06,'chembio':0.03,'geist':0.03} # nach hs belegung
urne2fs['west'] = {'physik':0.92,'etec':0.08} # schaetzung

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

