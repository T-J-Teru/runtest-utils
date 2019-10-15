# This file is part of runtest-utils.
#
# runtest-utils is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# runtest-utils is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with runtest-utls.  If not, see <https://www.gnu.org/licenses/>.

SUBDIRS = etc lib

bin_SCRIPTS = bin/compare-tests bin/sum2table bin/sum4way bin/sum-duplicates

manualsdir = $(mandir)/man1
manuals_DATA = doc/compare-tests.1 doc/sum2table.1 doc/sum4way.1 doc/sum-duplicates.1

CLEANFILES = $(bin_SCRIPTS)

EXTRA_DIST = compare-tests sum2table sum4way sum-duplicates

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

