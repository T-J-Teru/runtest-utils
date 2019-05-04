SUBDIRS = etc lib

bin_SCRIPTS = bin/compare-tests bin/sum2table bin/sum4way

manualsdir = $(mandir)/man1
manuals_DATA = doc/compare-tests.1 doc/sum2table.1 doc/sum4way.1

CLEANFILES = $(bin_SCRIPTS)

EXTRA_DIST = compare-tests sum2table sum4way

do_subst = sed -e 's%use lib "$$FindBin::Bin/lib";%use lib "$$FindBin::Bin/../lib/perl5";%' \
	       -e 's%my $$SYSCONFDIR = "$$FindBin::Bin/etc";%my $$SYSCONFDIR = "${sysconfdir}";%' \
	       -e 's%"~~PACKAGE-VERSION~~"%"${PACKAGE_VERSION}"%'

$(bin_SCRIPTS) : | bin

bin:
	mkdir bin

clean-local:
	-rm -fr bin doc

$(bin_SCRIPTS) : bin/% : %
	$(do_subst) < "$<" > "$@"
	@chmod +x $@


$(manuals_DATA) : | doc
doc :
	mkdir doc

$(manuals_DATA) : doc/%.1 : %
	pod2man --errors=none $< $@

