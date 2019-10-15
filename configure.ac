dnl This file is part of runtest-utils.
dnl
dnl runtest-utils is free software: you can redistribute it and/or modify
dnl it under the terms of the GNU General Public License as published by
dnl the Free Software Foundation, either version 3 of the License, or
dnl (at your option) any later version.
dnl
dnl runtest-utils is distributed in the hope that it will be useful,
dnl but WITHOUT ANY WARRANTY; without even the implied warranty of
dnl MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
dnl GNU General Public License for more details.
dnl
dnl You should have received a copy of the GNU General Public License
dnl along with runtest-utls.  If not, see <https://www.gnu.org/licenses/>.

AC_PREREQ(2.69)

AC_INIT([runtest-utils], [0.0.12], [andrew.burgess@embecosm.com])
AM_INIT_AUTOMAKE([foreign])

AC_CHECK_PROGS([POD2MAN], [pod2man], [false])
AC_CHECK_PROGS([SED], [sed], [false])

AC_PROG_INSTALL

AC_CONFIG_FILES([Makefile \
                 etc/Makefile \
                 etc/runtest-utils/Makefile \
                 etc/runtest-utils/filters/Makefile \
                 lib/Makefile \
                 lib/RunTestUtils/Makefile])

AC_OUTPUT
