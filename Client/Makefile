include ../Makefile.common

libdir	= $(prefix)/lib/friwahl/server
bindir	= $(prefix)/bin

all:

install:
	$(INSTALL_DIR) $(DESTDIR)$(libdir)
	$(INSTALL_DIR) $(DESTDIR)$(bindir)
	$(INSTALL_SCRIPT) admin.pl $(DESTDIR)$(bindir)/friwahl-admin
	$(INSTALL_SCRIPT) clearing.pl $(DESTDIR)$(libdir)/clearing.pl
	$(INSTALL_SCRIPT) init.sh $(DESTDIR)$(libdir)/init.sh
	$(INSTALL_SCRIPT) clean.sh $(DESTDIR)$(libdir)/clean.sh
	$(INSTALL_DATA) init.sql $(DESTDIR)$(libdir)/init.sql
	$(INSTALL_DATA) clean.sql $(DESTDIR)$(libdir)/clean.sql
	$(INSTALL_DATA) FriCardWahl.sql $(DESTDIR)$(libdir)/FriCardWahl.sql
