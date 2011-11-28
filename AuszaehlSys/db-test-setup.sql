-- Test-Daten fuer Wahlen, Listen, Kandidaten und Urnen
-- $Id: db-test-setup.sql 53 2006-01-25 16:11:24Z djpig $

use auszaehl;

-- wahl: id, name, wahlberechtigt

DELETE FROM wahl;
INSERT INTO wahl VALUES (1,'StuPa',15432);
INSERT INTO wahl VALUES (2,'FS Physik',765);
INSERT INTO wahl VALUES (3,'FRf',4567);

-- liste: id, wahl, name, nummer, anzeige, R,G,B

DELETE FROM liste;
INSERT INTO liste VALUES (1,1,'FiPS',1,3,1,1,1);
INSERT INTO liste VALUES (2,2,'',0,NULL,0,0,0);
INSERT INTO liste VALUES (3,1,'RCDS',2,5,0,0,0);
INSERT INTO liste VALUES (4,1,'LHG',3,4,1,1,0);
INSERT INTO liste VALUES (5,1,'GAL',4,2,0,1,0);
INSERT INTO liste VALUES (6,1,'JuSo',5,1,1,0,0);
INSERT INTO liste VALUES (7,3,'',0,NULL,0,0,0);

-- kandidat: id, liste, name, listenplatz, adresse

DELETE FROM kandidat;
INSERT INTO kandidat VALUES (1,1,'Fips-1',1,NULL);
INSERT INTO kandidat VALUES (2,1,'Fips-2',2,NULL);
INSERT INTO kandidat VALUES (3,1,'Fips-3',3,NULL);
INSERT INTO kandidat VALUES (4,1,'Fips-4',4,NULL);
INSERT INTO kandidat VALUES (5,1,'Fips-5',5,NULL);
INSERT INTO kandidat VALUES (6,3,'Rcds-1',1,NULL);
INSERT INTO kandidat VALUES (7,3,'Rcds-2',2,NULL);
INSERT INTO kandidat VALUES (8,3,'Rcds-3',3,NULL);
INSERT INTO kandidat VALUES (9,3,'Rcds-4',4,NULL);
INSERT INTO kandidat VALUES (10,4,'lhg-1',1,NULL);
INSERT INTO kandidat VALUES (11,4,'lhg-2',2,NULL);
INSERT INTO kandidat VALUES (12,4,'lhg-3',3,NULL);
INSERT INTO kandidat VALUES (13,4,'lhg-4',4,NULL);
INSERT INTO kandidat VALUES (14,4,'lhg-5',5,NULL);
INSERT INTO kandidat VALUES (15,4,'lhg-6',6,NULL);
INSERT INTO kandidat VALUES (16,5,'gal-1',1,NULL);
INSERT INTO kandidat VALUES (17,5,'gal-2',2,NULL);
INSERT INTO kandidat VALUES (18,5,'gal-3',3,NULL);
INSERT INTO kandidat VALUES (19,5,'gal-4',4,NULL);
INSERT INTO kandidat VALUES (20,5,'gal-5',5,NULL);
INSERT INTO kandidat VALUES (21,6,'juso-1',1,NULL);
INSERT INTO kandidat VALUES (22,6,'juso-2',2,NULL);
INSERT INTO kandidat VALUES (23,6,'juso-3',3,NULL);
INSERT INTO kandidat VALUES (24,2,'fsphys-1',1,NULL);
INSERT INTO kandidat VALUES (25,2,'fsphys-2',2,NULL);
INSERT INTO kandidat VALUES (26,2,'fsphys-3',3,NULL);
INSERT INTO kandidat VALUES (27,2,'fsphys-4',4,NULL);
INSERT INTO kandidat VALUES (28,2,'fsphys-5',5,NULL);
INSERT INTO kandidat VALUES (29,2,'fsphys-6',6,NULL);
INSERT INTO kandidat VALUES (30,7,'Emma Schwarzer',1,NULL);
INSERT INTO kandidat VALUES (31,7,'- Nein -',2,NULL);

-- urne: id, fak, nummer, status

DELETE FROM urne;
INSERT INTO urne VALUES (1,'Physik',1,0,NULL);
INSERT INTO urne VALUES (2,'Physik',2,0,NULL);
INSERT INTO urne VALUES (3,'Physik',3,0,NULL);
INSERT INTO urne VALUES (4,'Physik',4,0,NULL);
INSERT INTO urne VALUES (5,'Physik',5,0,NULL);
INSERT INTO urne VALUES (6,'Mathe',1,0,NULL);
INSERT INTO urne VALUES (7,'Mathe',2,0,NULL);
INSERT INTO urne VALUES (8,'Mathe',3,0,NULL);
INSERT INTO urne VALUES (9,'Etec',1,0,NULL);
INSERT INTO urne VALUES (10,'Etec',2,0,NULL);
INSERT INTO urne VALUES (11,'Etec',3,0,NULL);
INSERT INTO urne VALUES (12,'Mensa',1,0,NULL);
INSERT INTO urne VALUES (13,'WiWi',1,0,NULL);
INSERT INTO urne VALUES (14,'WiWi',2,0,NULL);
INSERT INTO urne VALUES (15,'WiWi',3,0,NULL);
INSERT INTO urne VALUES (16,'WiWi',4,0,NULL);
INSERT INTO urne VALUES (17,'WiWi',5,0,NULL);
INSERT INTO urne VALUES (18,'WiWi',6,0,NULL);

-- ----------------------------------------
