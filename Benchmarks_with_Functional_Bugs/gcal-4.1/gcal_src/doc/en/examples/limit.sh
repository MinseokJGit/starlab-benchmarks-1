#! /bin/sh

# Automatically generated by mksamp-1.sed from limit.in.

echo "$ gcal %20000506 -f/dev/null -cxl4+ \\"
echo ">      -#'0*d1#999_%s9+5158+00738,120'"
LANGUAGE=en GCAL= GCALPATH=. ../../../src/gcal %20000506 -f/dev/null -#'0*d1#999 %s9+5158+00738,120' -cxl4+ $*

echo "$ gcal %20000506 -f/dev/null -cxl4+ --limit \\"
echo ">      -#'0*d1#999_%s9+5158+00738,120'"
LANGUAGE=en GCAL= GCALPATH=. ../../../src/gcal %20000506 -f/dev/null -#'0*d1#999 %s9+5158+00738,120' -cxl4+ --limit $*

exit 0
