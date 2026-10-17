##
# Channel Discrimination v1.0
#  by MC_8 - Carl M. Gregory <mc8@purehype.net>
#  This script will only run on eggdrop 1.5.5 or greater.
#
# My Website - http://mc.purehype.net:81/
# Have a bug?  http://mc.purehype.net:81/bugzilla/
##

##
# This script will keep users that do not have proper access out of a specific
# channel.
##

##
# HISTORY  ( <Fixed by> - [Found by] - <Info> )
##
# v1.0 (06.27.02)
#  MC_8 - K|mBeRLy - Inital release
##

##
# COMMANDS (dcc)
##
# chanset <#channel> <+/->mc.channel_discrimination
#   This will disable (-) or enable (+) the restriction of users that can join the
#   specific channel.  Or, in other words, will enable or disable this script for the
#   specific channel.
##

##
# Settings
##
#

# What flagged users do you want to exempt?  Set to "-|-" to exempt no one.  Flag
# structure is <global>|<channel>.
set mc_cd2(exempt:flag) "b|-"

# What flag should a user have to join a channel setup as
# '+mc.channel_discrimination'?  Custom flags range from A to Z (caplital).
set mc_cd2(require:flag) D

# Note:
#   If a user is found joinning a channel that isn't exempt and doesn't have the
#   required flag, then he is considered 'in contempt of the script' (I will use this
#   phrase more).

# If a user is found in contempt of the script, how do you want to remove the user
# from the channel?
#   -2 = Permanent ban (no expiration in bot records).
#   -1 = Will not ban (no ban, disable banning).
#    0 = Performs a server ban, but doesn't store the ban in the bot's ban list.
#  Any number greater than 0 will be the time, in min's, in witch the ban will
#  expire.  All ban's will be channel ban's, if you want it to be a global ban -- put
#  a "@" infront of the time.
#    Example:  set mc_bw(bantime) @1440
#  Also, if you want the ban to be 'sticky' (read '.help stick' in the bot's dcc
#  console), append the value with a "!".
#    Example:  set mc_bw(bantime) 1440!
set mc_cd2(contempt:ban) -1

# Do you want to have the user kicked from the channel he/she is contempt on?
#     0 = No
#     1 = Yes
#     2 = Yes, but globally (kick from all channels)
set mc_cd2(contempt:kick) 1

# If you have chosen to ban the user, you now need to specify how you want to mask
# the ban.  If you have chosen to disable banning, then don't worry about this
# setting.
#      0 - *!user@host.domain
#      1 - *!*user@host.domain
#      2 - *!*@host.domain
#      3 - *!*user@*.domain
#      4 - *!*@*.domain
#      5 - nick!user@host.domain
#      6 - nick!*user@host.domain
#      7 - nick!*@host.domain
#      8 - nick!*user@*.domain
#      9 - nick!*@*.domain
#     You can also specify a type of 10 to 19 which correspond to masks 0 to 9.
#     But if the host.domain is a;
#       hostname = Instead of using a * wildcard to replace portions of the
#                  host.domain, it replaces the numbers in the host.domain with
#                  a '?' (question mark) wildcard.
#       ip       = It will mask as normal, with no '?' (question mark)
#                  replacments as does hostname.
set mc_cd2(contempt:banmask) 3

# What do you want the ban and/or kick message to be?
# Replacment veriables:
#   %channel = Channel the user is contempt in.
#   %nick    = The contempt user.
#   %uhost   = The users ident@host.
set mc_cd2(contempt:message) "You do not have access to be in %channel, %nick."


## MC SVS (Script Version Service) v2.2 ##
# Do you want the bot to connection to MC_8's SVS server to see if there's a
# newer version of this module available?  It will only tell you, it's up to you
# to get the newest version and compile it.
#   0 = No, do not enable SVS.
#   1 = Yes, but only inform me of non beta versions.
#   2 = Yes, inform me of all new versions (beta and stable).
set mc_cd2(svs:mode) 2

# Upon finding a newer version, whom do you want to notify?  The notification is
# sent via 'note'.  Separate each user with a space.  For those whom know TCL;
# do not put this in list format, keep it in string format.
set mc_cd2(svs:notify) "MC_8"


##
# TCL Coding below, do not proceed.
##

#Script:mc_cd2

set mc_cd2(script)      "Channel Discrimination"
set mc_cd2(version)     "v1.0"
set mc_cd2(svs:script)  "channel_discrimination"
set mc_cd2(svs:version) "001000000000"
set mc_cd2(svs:server)  "mc.purehype.net"
set mc_cd2(svs:port)    "81"
set mc_cd2(svs:get)     "/"
set mc_cd2(svs:query)   \
	"svs=$mc_cd2(svs:script)&version=$mc_cd2(svs:version)"


catch {unset temp}
if {![info exists numversion] || ($numversion < "1050500")} {
	set temp(tag) "$mc_cd2(script) $mc_cd2(version)"
	putlog "$temp(tag) by MC_8 will only work on eggdrop 1.5.5 or greater."
	putlog "$temp(tag)  will not work with eggdrop $version."
	putlog "$temp(tag)  not loaded."
	return 1
}

setudef flag mc.channel_discrimination

# Error system, v2.0
proc mc:cd2:error {bindproc error {arg ""}} {
	global mc_cd2 version lastbind
	putlog "Error in script $mc_cd2(script) $mc_cd2(version)."
	putlog "       Last bind: $lastbind"
	putlog "       Procedure: $bindproc"
	putlog "            Args: $arg"
	putlog " Eggdrop version: $version"
	putlog "     TCL version: [info tclversion]"
	putlog "  TCL Patchlevel: [info patchlevel]"
	putlog "*** Please tell MC_8 about this BUG, his email     "
	putlog "*** can be found at http://mc.purehype.net:81/ .   "
	putlog "*** Please include the next line in the bug report."
	error $error
}

proc mc:cd2:errchk {command arg} {
	if {[catch {eval $command $arg} return]} {
		mc:cd2:error $command $return $arg
		return 0
	}
	return $return
}
# ^

bind join - * mc:cd2:join
proc mc:cd2:join {nick uhost hand chan} {
 return [mc:cd2:errchk mc:cd2:join_ [list $hand $uhost $hand $chan]]
}
proc mc:cd2:join_ {nick uhost hand chan} {
	global mc_cd2 botnick
	set temp(:cache:chanflag) [mc:cd2:chanflag $chan mc.channel_discrimination]
	if {$temp(:cache:chanflag) && [isbotnick $nick]} {
		foreach user [chanlist $chan] {
			if {[isbotnick $user]} {continue}
			# 5 second delay, it's the bot that just join'd... he's not going to be
			# opped as of yet.  Maby he will get opped after 5 seconds?
			utimer 5 [list mc:cd2:join $user "" [nick2hand $user $chan] $chan]
		}
		return
	}
	if {!$temp(:cache:chanflag) || [isbotnick $nick] ||
	    (($mc_cd2(exempt:flag) != "-|-") &&
	     [matchattr $hand $mc_cd2(exempt:flag) $chan]) ||
	    [matchattr $hand $mc_cd2(require:flag) $chan]} {
		return
	}
	if {$uhost == ""} {set uhost [getchanhost $nick $chan]}
	set temp(message) [mc:cd2:replace $mc_cd2(contempt:message) [list %channel $chan \
	                                                                  %nick    $nick \
	                                                                  %uhost   $uhost]]
  if {$temp(message) == ""} {set temp(message) $mc_cd2(script)}
  set temp(action) ""
	if {[string trim $mc_cd2(contempt:ban) @!] != "-1"} {
		set temp(banmask) [mc:cd2:masktype $nick!$uhost $mc_cd2(contempt:banmask)]
		if {[string match @* $mc_cd2(contempt:ban)]} {
			set temp(global) 1
			set temp(bantime) [string trimleft $mc_cd2(contempt:ban) @]
		} else {
			set temp(global) 0
			set temp(bantime) $mc_cd2(contempt:ban)
		}
		if {[string match *! $temp(bantime)]} {
			set temp(options) sticky
			set temp(bantime) [string trimright $temp(bantime) !]
		} else {
			set temp(options) none
		}
		if {!$temp(bantime)} {
			if {$temp(global)} {
				set temp(channels) [channels]
				lappend temp(action) "banned $temp(banmask) (server ban, global)"
			} else {
				set temp(channels) [list $chan]
				lappend temp(action) "banned $temp(banmask) (server ban, channel)"
			}
			foreach channel $temp(channels) {
				if {![botisop $channel]} {continue}
				pushmode $channel +b $temp(banmask)
			}
		} elseif {$temp(bantime) == "-2"} {
			if {$temp(global)} {
				newban $temp(banmask) $botnick $temp(message) 0 $temp(options)
				lappend temp(action) "banned $temp(banmask) (banlist, global, perm)"
			} else {
				newchanban $chan $temp(banmask) $botnick $temp(message) 0 $temp(options)
				lappend temp(action) "banned $temp(banmask) (banlist, channel, perm)"
			}
		} elseif {$temp(bantime) > "0"} {
			set temp(duration) [duration [expr $temp(bantime)*60]]
			if {$temp(global)} {
				newban $temp(banmask) $botnick $temp(message) $temp(bantime) $temp(options)
				lappend temp(action) \
					"banned $temp(banmask) (banlist, global, $temp(duration))"
			} else {
				newchanban $chan $temp(banmask) $botnick $temp(message) $temp(bantime) \
					$temp(options)
				lappend temp(action) \
					"banned $temp(banmask) (banlist, channel, $temp(duration))"
			}
		}
	}
	if {$mc_cd2(contempt:kick) == "1"} {
		putkick $chan $nick $temp(message)
		lappend temp(action) "kicked (channel)"
	} elseif {$mc_cd2(contempt:kick) == "2"} {
		foreach channel [channels] {
			if {![botisop $channel]} {continue}
			putkick $channel $nick $temp(message)
		}
		lappend temp(action) "kicked (global)"
	}
	set temp(1) "$nick found in contempt while joinning $chan, action(s)"
	putlog "$mc_cd2(script): $temp(1) taken: [join $temp(action) ", "]"
	return
}

# v1.1
proc mc:cd2:replace {text subs} {
	if {![catch {string map -nocase $subs $text} output]} {return $output}
	for {set i 0} {[lindex $subs $i] != ""} {incr i 2} {
		set temp(re_syntax) {([\\\*\+\?\{\}\,\(\)\:\[\]\.\^\$\=\!\|])}
		regsub -all -- $temp(re_syntax) [lindex $subs $i] {\\\1} temp(temp)
		regsub -all -- $temp(temp) $text [lindex $subs [expr $i+1]] text
	}; return $text
}

# v1.3
proc mc:cd2:masktype {nuhost type} {
	set ident_max-length 9
	set host_max-length 63
	scan $nuhost {%[^!]!%s} nick uhost
	set temp(split_uhost) [split $uhost @]
	set temp(1) [expr [llength $temp(split_uhost)]-2]
	set ident [join [lrange $temp(split_uhost) 0 $temp(1)] @]
	set host [lindex $temp(split_uhost) end]
	set maskhost 1
	if {[regexp -- {^1[0-9]$} $type]} {
		set temp(w) {([0-9][0-9]?[0-9]?)}
		set temp(x) "^$temp(w)\\.$temp(w)\\.$temp(w)\\.$temp(w)\$"
		if {!(([regexp -- $temp(x) $host temp(1) a b c d]) &&
		     ($a > 0 && $a <= 255 && $b <= 255 && $c <= 255 && $d <= 255))} {
			regsub -all -- {[0-9]} $host ? host
			set maskhost 0
		}
		set type [string index $type 1]
	}
	if {[regexp -- {^[0-4]$} $type]} {set nick "*"}
	if {[regexp -- {^[2479]$} $type]} {set ident "*"}
	if {[regexp -- {^[1368]$} $type]} {regsub -- {^~?(.*)$} $ident *\\1 ident}
	if {[regexp -- {^[3489]$} $type]} {
		if {$maskhost} {set host [lindex [split [maskhost $host] @] end]}
	}
	if {[set cache(x) [string length $ident]] > ${ident_max-length}} {
		set ident "*[string range $ident [expr $cache(x)-${ident_max-length}] end]"
	}
	if {[set cache(x) [string length $host]] > ${host_max-length}} {
		set host "*[string range $host [expr $cache(x)-${host_max-length}] end]"
	}
	return [format "%s!%s@%s" $nick $ident $host]
}

# v2.1
proc mc:cd2:chanflag {channel flag} {
	set temp(1) [string tolower [channel info $channel]]
	if {[lsearch -exact $temp(1) +[string tolower $flag]] >= "0"} {return 1}
	return 0
}


## SVS v2.2
if {![info exists mc_cd2(svs:mode)] ||
    ![regexp -- {^1|0$} $mc_cd2(svs:mode)]} {set mc_cd2(svs:mode) 2}
if {![info exists mc_cd2(svs:notify)]} {
	if {![info exists owner]} {set owner ""}
	set mc_cd2(svs:notify) $owner
}

bind time - "00 00 *" mc:cd2:do_svs
proc mc:cd2:do_svs {{args ""}} {
	global mc_cd2
	if {!$mc_cd2(svs:mode)} {return 0}
	if {[catch {
	        socket -async $mc_cd2(svs:server) $mc_cd2(svs:port)
	           } sid]} {
		putloglev d * "$mc_cd2(script): SVS socket error: $sid"
		return 1
	}
	fconfigure $sid -blocking 0 -buffering line
	set tout [after 60000 "mc:cd2:svs_talk $sid timeout"]
	fileevent $sid readable "mc:cd2:svs_talk $sid $tout"
	puts $sid "GET $mc_cd2(svs:get)?$mc_cd2(svs:query) HTTP/1.0\
	         \nHost: $mc_cd2(svs:server):$mc_cd2(svs:port)\n"
	flush $sid
}

proc mc:cd2:svs_talk {sid tout} {
	global mc_cd2
	set array [list svs temp $sid]
	if {$tout == "timeout"} {
		set temp(1) "$mc_cd2(svs:server):$mc_cd2(svs:port)"
		putloglev d * \
			"$mc_cd2(script): SVS Warning: Timed out connecting to $temp(1)."
		catch {unset mc_cd2($array)}
		close $sid
		return 0
	}
	if {[eof $sid]} {
		catch {unset mc_cd2($array)}
		close $sid
		return 1
	}
	gets $sid get
	after cancel $tout
	if {![info exist mc_cd2($array)]} {
		if {$get == ""} {set mc_cd2($array) 1}
		return -1
	}
	if {($get == "") || [catch {llength $get}]} {
		return -2
	}
	switch -- [lindex $get 0] {
		003 {
			set temp(reply) [lrange $get 1 end]
			set temp(reply:0) [lindex $temp(reply) 0]
			set temp(reply:1) [lindex $temp(reply) 1]
			set temp(reply:2) [lindex $temp(reply) 2]
			set temp(reply:3) [lindex $temp(reply) 3]
			set temp(reply:4) [lindex $temp(reply) 4]
			set temp(reply:5) [lindex $temp(reply) 5]
			if {$temp(reply:0) != $mc_cd2(svs:script)} {
				set temp(1) "wanted $mc_cd2(svs:script), got $temp(reply:0)"
				putloglev d * "$mc_cd2(script): SVS Error: $temp(1)"
				unset mc_cd2($array)
				close $sid
				return -3
			}
			if {$mc_cd2(svs:mode) == "1"} {
				set temp(svs:version) [string range $mc_cd2(svs:version) 0 8]999
			} else {
				set temp(svs:version) [string range $mc_cd2(svs:version) 0 11]
			}
			if {$temp(reply:1) > $temp(svs:version)} {
				set temp(note) $temp(reply:5)
				regsub -all -- %0 $temp(note) $temp(reply:0) temp(note)
				regsub -all -- %1 $temp(note) $temp(reply:1) temp(note)
				regsub -all -- %2 $temp(note) $temp(reply:2) temp(note)
				regsub -all -- %3 $temp(note) $temp(reply:3) temp(note)
				regsub -all -- %4 $temp(note) $temp(reply:4) temp(note)
				regsub -all -- %version $temp(note) $mc_cd2(version) temp(note)
				foreach temp(to) [split $mc_cd2(svs:notify) ",; "] {
					if {$temp(to) == ""} {continue}
					regsub -- %nick $temp(note) $temp(to) temp(note2)
					set temp(lunotes) [notes $temp(to) -[notes $temp(to)]]]
					if {[string match *$temp(note2)* $temp(lunotes)]} {
						set temp(found_note) 0
						foreach temp(unote) $temp(lunotes) {
							if {$temp(note2) == [lindex $temp(unote) 2]} {
								set temp(found_note) 1
								break
							}
						}
						if {$temp(found_note)} {continue}
					}
					set temp(error) "sending note to $temp(to) -> "
					switch -- [sendnote SVS $temp(to) $temp(note2)] {
						0 {
							if {![validuser $temp(to)]} {
								append temp(error) "invalid user"
							} else {append temp(error) "unknown error"}
							putloglev d * \
								"$mc_cd2(script): SVS sendnote error: $temp(error)"
						}
						3 {
							append temp(error) "notebox too full"
							putloglev d * \
								"$mc_cd2(script): SVS sendnote error: $temp(error)"
						}
					}
				}
			}
			unset mc_cd2($array)
			close $sid
			return 2
		}
	}
}
## ^

putlog "$mc_cd2(script) $mc_cd2(version) by MC_8 loaded."