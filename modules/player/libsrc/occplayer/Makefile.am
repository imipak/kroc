@SET_MAKE@

AUTOMAKE_OPTIONS = foreign no-dependencies

OCCBUILD = @OCCBUILD@
CFLAGS = @CFLAGS@ @DEFS@ @PLAYER_CFLAGS@

SWIG_SOURCE_FILES = \
	occamplayer.i \
	player.i

SWIG_OUTPUT_FILES = \
	player_wrap.c player_wrap.h occplayer.inc

EXTRA_DIST = \
	$(SWIG_SOURCE_FILES) \
	$(SWIG_OUTPUT_FILES)

if BUILD_OCCPLAYER
occplayer_lib_objs = \
	player_wrap.o

occplayer_libs = occplayer.lib
occplayer_includes = occplayer.inc
endif

libs = $(occplayer_libs)
includes = $(occplayer_includes)

all-local: $(libs) $(includes)

if HAVE_SWIG_OCCAM
player_wrap.c player_wrap.h occplayer.inc: $(SWIG_SOURCE_FILES)
	$(SWIG_OCCAM) @PLAYER_CFLAGS@ player.i
endif

occplayer.lib: $(occplayer_lib_objs)
	$(OCCBUILD) --library occplayer.lib --include occplayer.inc @PLAYER_LIBS@ $(occplayer_lib_objs)

install-exec-local: $(libs) $(includes)
	$(OCCBUILD) --install --prefix "$(prefix)" --destdir "$(DESTDIR)" $(libs) $(includes)

clean-local:
	$(OCCBUILD) --clean $(libs) $(occplayer_lib_objs)

SUFFIXES = .occ .tce .lib

.c.o:
	$(CC) $(CFLAGS) -c $<

.occ.tce:
	$(OCCBUILD) --object $<

# FIXME: These should be shipped with the source.
CLEANFILES = $(SWIG_OUTPUT_FILES)