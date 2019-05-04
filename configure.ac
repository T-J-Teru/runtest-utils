AC_PREREQ(2.69)

AC_INIT([runtest-utils], [0.0.7], [andrew.burgess@embecosm.com])
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
