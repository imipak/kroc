import datetime
import re

# API
# get(key) -- returns the value for the given key
# set(key, value) - sets a value in CFG
# rebase(key, value) - sets a variable and regenerates CFG
#   (use for changing things like TEMP)

now    = datetime.datetime.now()
BASE = {'VERSION'              : '100',
				'BUILD_ARCHITECTURE'   : 'i386',
				'TOOLCHAIN'            : 'kroc',
				'TARGET'               : 'posix',
				'WRAPPER'              : 'posix',
				'PACKAGE_DESCRIPTION'  : 'Native occam-pi for the desktop.',
				'SVN_TRUNK'            : 'https://projects.cs.kent.ac.uk/projects/kroc/svn/kroc/trunk',
				# # # #
				'YMD'                  : now.strftime("%Y%m%d"),
				'YMDHMS'               : now.strftime("%Y%m%d%H%M%S"),
				'TEMP_ROOT'            : '/tmp/@BUILD_ARCHITECTURE@',
				'TEMP'                 : '@TEMP_ROOT@/@TOOLCHAIN@-@TARGET@-@WRAPPER@',
				'PACKAGE_NAME'         : 'concurrency-@TOOLCHAIN@-@WRAPPER@',
				'PACKAGE_BUILD'        : '@TEMP@/@PACKAGE_NAME@',
				'SVN'                  : '@TEMP_ROOT@/src',
				'OBJ'                  : '@SVN@/obj-@TOOLCHAIN@-@TARGET@-@WRAPPER@',
				# Where we pull things from
				# These are all used by the Arduino build...
				'SOURCE_ARDUINO'       : '@SVN@/tvm/arduino',
				'SOURCE_OCCAM'         : '@SOURCE_ARDUINO@/occam',
				'SOURCE_CONF'          : '@SOURCE_OCCAM@/conf',
				'SOURCE_SCRIPTS'       : '@SOURCE_ARDUINO@/scripts',
				'SOURCE_INCLUDE'       : '@SOURCE_OCCAM@/include',
				'SOURCE_DEBIAN'        : '@SVN@/distribution/deb-pkg/DEBIAN.in',
				# Desired filesystem path for installation
				'INSTPATH'             : 'usr',
				'FINAL'                : '/@INSTPATH@',
				# Dstdir installation paths
				'SHARE'                : 'share/@TOOLCHAIN@-@TARGET@',
				'BIN'                  : 'bin',
				'DEST'                 : '@TEMP@/@PACKAGE_NAME@',
				'DEST_ROOT'            : '@DEST@/@INSTPATH@',
				'DEST_BIN'             : '@DEST_ROOT@/@BIN@',
				'DEST_SHARE'           : '@DEST_ROOT@/@SHARE@',
				'DEST_INCLUDE'         : '@DEST_SHARE@/include',
				'DEST_FIRMWARE'        : '@DEST_SHARE@/firmware',
				'DEST_CONF'            : '@DEST_SHARE@/conf',
				'DEST_DEBIAN'          : '@PACKAGE_BUILD@/DEBIAN',
				# FINAL DESTINATIONS
				# Use these for substitution within scripts.
				'FINAL_DEST_ROOT'      : '@FINAL@',
				'FINAL_DEST_BIN'       : '@FINAL@/@BIN@',
				# This really only comes into play for the AVR, as KRoC and the 	
				# TVM put things in sensible places through the destdir mechanism.
				'FINAL_DEST_SHARE'     : '@FINAL@/@SHARE@',
				'FINAL_DEST_INCLUDE'   : '@FINAL@/@SHARE@/include',
				'FINAL_DEST_FIRMWARE'  : '@FINAL_DEST_SHARE@/firmwares',
				'FINAL_DEST_CONF'      : '@FINAL_DEST_SHARE@/conf',
				# OCCPLUG
				'SOURCE_OCCPLUG'       : '@SVN@/tools/occplug',
				'DEST_OCCPLUG_ROOT'    : '@TEMP@/@OCCPLUG_PACKAGE_NAME@',
				'DEST_OCCPLUG'         : '@DEST_OCCPLUG_ROOT@/usr/share/jedit/jars',
				'DEST_OCCPLUG_DEBIAN'  : '@DEST_OCCPLUG_ROOT@/DEBIAN',
				'SOURCE_OCCPLUG_DEBIAN': '@SVN@/distribution/deb-pkg/DEBIAN.occPlug',
				'OCCPLUG_PACKAGE_NAME' : 'occPlug',
				'ERRORLIST_URL'        : 'http://prdownloads.sourceforge.net/jedit-plugins/ErrorList-1.5-bin.zip',
				
			}

CFG = { }

def get (key):
	return CFG[key]

def copy (src):
	tmp = { }
	for key, value in src.iteritems():
		tmp[key] = value
	return tmp

def no_subst_left(hash):
	result = True

	for key, value in hash.iteritems():
		print "CHECKING %s, %s" % (key, value)

		if re.search('@.*?@', value):
			result = False

	return result

def hassubst(str):
	if re.search('@.*?@', str):
		return True
	else:
		return False

def dosubst(str):
	if hassubst(str):
		repls = re.findall('@(.*?)@', str)
		for pat in repls:
			str = re.sub(re.compile('@%s@' % pat), BASE[pat], str)
		return dosubst(str)
	else:
		return str

def refresh ():
	# print "REFRESHING CONFIGURATION"
	tmp = copy(BASE)
	# Go through each key
	for key, value in BASE.iteritems():
		value = dosubst(value)
		tmp[key] = value
	for k, v in tmp.iteritems():
		CFG[k] = v

def rebase (key, value):
	# print "REBASING CONFIGURATION AROUND '%s'" % key
	BASE[key] = value
	refresh ()

def set (key, value):
	CFG[key] = value
