AC_INIT([ilibr], [1.1], [kroc-bugs@kent.ac.uk])
AC_CONFIG_HEADERS([config.h])
AC_CANONICAL_SYSTEM

AM_INIT_AUTOMAKE

dnl Checks for programs.
AC_PROG_CC
AC_PROG_MAKE_SET
AC_PROG_RANLIB

AC_DEFINE(HOST_OS_IS_UNIX,1,[define if host OS is UNIX])

dnl Checks for header files.
AC_HEADER_STDC
AC_CHECK_HEADERS(string.h stdlib.h string.h strings.h unistd.h)

AC_OUTPUT([Makefile tcofflib/Makefile])
