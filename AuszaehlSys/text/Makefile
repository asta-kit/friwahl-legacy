default:
	@echo "Sinnvolle make-Targets: "
	@echo " * vor der Wahl"
	@echo "    ausschreibung.ps        -> Bekanntmachung der Vorschl�ge"
	@echo "    wahlzettel.ps           -> Wahlzettel"
	@echo "    zaehllisten.ps          -> Z�hllisten"
	@echo " * nach der Wahl"
	@echo "    pruefbericht.ps         -> Ergebnisse der Urnenpr�fung"
	@echo "    ergebnisse.ps           -> Wahlergebnisse"
	@echo "    benachrichtigung.ps     -> Benachrichtigung der Gewinner"
	@echo "Die ps-Dateien k�nnen auch als pdf generiert werden."

%.tex : %.php TESTENV PRE-%
	php -f $< >$@

%.tex : %.pl TESTENV PRE-%
	./$< >$@

%.tex : %.sh TESTENV PRE-%
	./$< >$@

%.dvi : %.tex
	latex $< </dev/null
	-chmod g+rw $(basename $@).*
	-chgrp wahl $(basename $@).*

%.ps : %.dvi
	dvips $<
	-chmod g+rw $(basename $@).*
	-chgrp wahl $(basename $@).*

%.pdf : %.dvi
	dvipdfm -p a4 $<
	-chmod g+rw $(basename $@).*
	-chgrp wahl $(basename $@).*

PRE-% : FORCE
	@true

.PHONY: FORCE clean TESTENV

.DELETE_ON_ERROR:

clean:
	echo clean

clean_old:
	rm -f *.tex *.log *.aux *.bap *.bac *.dvi *.pdf *.txt *.ps

TESTENV:
	@[ -n "$(DBSERVER)" ] || { echo "please set \$$DBSERVER" ; exit -1 ; }

PRE-ausschreibung PRE-wahlzettel PRE-zaehllisten :
	@echo calling Auswertung-Wahlen.pl, DBSERVER=$(DBSERVER)
	cd .. && ./Auswertung-Wahlen.pl $(DBSERVER)
