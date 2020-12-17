#!./pickle
# TODO:
# 	- Print formatted with color
# 	- Input methods
# 	- Programs; Tetris, Text Editor, Hack clone
# 	- Get terminal size, cross platform support

# Movement/Basic Terminal Sequences
proc up {x} { return "\x1b\[${x}A" }
proc down {x} { return "\x1b\[${x}B" }
proc forward {x} { return "\x1b\[${x}C" }
proc right {x} { return "\x1b\[${x}D" }
proc at-xy {x y} { return "\x1b\[${x};${y}H" }
proc erase {} { return "\x1b\[2J" }
proc sgr {s} { return "\x1b\[${s}m" }
proc reset   {} { return "\x1b\[0m" }
proc bold    {} { return "\x1b\[1m" }
proc blink   {} { return "\x1b\[5m" }
proc reverse {} { return "\x1b\[7m" }
proc conceal {} { return "\x1b\[8m" }

# NB. Gives wrong error code, "set" used instead of "proc":
# set color {c} { return x }

proc color {c} {
	return [lsearch -exact {black red green yellow blue magenta cyan white} $c]
}

proc fg {c} { return [sgr [+ 30 [color $c]]] }
proc bg {c} { return [sgr [+ 40 [color $c]]] }

proc fix {x} {
	if {eq 0 $x} { return 1 }
	return $x
}

# usage: draw 2 3 "[color red]string"
proc draw {x y c} {
	return "[at-xy $x $y]$c"
}

proc hline {x y len c} {
	set r [at-xy $x $y]
	for {set i 0} {< $i $len} {incr i} {
		set r "${r}${c}"
	}
	return $r
}

proc vline {x y len c} {
	set r ""
	for {set i 0} {< $i $len} {incr i} {
		set r "${r}[at-xy [+ $x $i] $y]$c"
	}
	return $r
}

# TODO: fix drawing when [string length $c] > 1
proc box {x y height width c} {
	set r [hline $x $y $width $c]
	set r $r[vline $x $y $height $c]
	set r $r[vline $x [+ $width [- $y 1]] $height $c]
	return $r[hline [+ $height $x] $y $width $c]
}

proc shadow-box {x y height width c1 c2} {
	set r [box $x $y $height $width $c1]
	return $r[box [incr x] [incr y] $height $width $c2]
}

# TODO: Line wrapping?
proc options {x y c fn lst} {
	set h [llength $lst]
	set w 0
	set r ""
	set off 2
	if {eq 2 [llength $c]} { incr off }
	for {set i 0} {< $i $h} {incr i} {
		set s "[apply $fn [+ $i 1]][lindex $lst $i]"
		set w [max $w [string length $s]]
		set r "$r[at-xy [+ [+ $x $i] $off] [+ $y $off]]$s"
	}
	if {eq 2 [llength $c]} {
		return $r[shadow-box $x $y [+ $h 4] [+ 5 $w] [lindex $c 0] [lindex $c 1]]
	}
	return $r[box $x $y [+ $h 3] [+ 4 $w] [lindex $c 0]]
}

# Partially compliant "format" command, extended with some ANSI escape
# sequences.
proc format {fmt args} {
	set l [split $fmt ""]
	set w [llength $l]
	set r ""
	for {set i 0; set j 0} {< $i $w} {incr i} {
		set o [lindex $l $i]
		if {eq $o "%"} {
			set s [lindex $l [incr i]]
			set v [lindex $args $j]
			incr j
			if {eq $s %} { set r $r%
			} elseif {eq $s s} { set r $r$v
			} elseif {eq $s x} { set r $r[string dec2hex $v]
			} elseif {eq $s X} { set r $r[string toupper [string dec2hex $v]]
			} elseif {eq $s o} { set r $r[string dec2base $v 8]
			} elseif {eq $s c} { set r $r[string char $v]
			} elseif {eq $s T} { set r "$r\x1b\[0m"
			} elseif {eq $s K} { set r "$r\x1b\[30m"
			} elseif {eq $s R} { set r "$r\x1b\[31m"
			} elseif {eq $s G} { set r "$r\x1b\[32m"
			} elseif {eq $s Y} { set r "$r\x1b\[33m"
			} elseif {eq $s B} { set r "$r\x1b\[34m"
			} elseif {eq $s M} { set r "$r\x1b\[35m"
			} elseif {eq $s C} { set r "$r\x1b\[36m"
			} elseif {eq $s W} { set r "$r\x1b\[37m"
			} else { return "Error format $s" -1 }
		} else {
			set r $r$o
		}
	}
	return $r
}

# TODO: Input selection/validation
proc select {x y c lst} { return [options $x $y $c {{i} { return "{$i} - " }} $lst] }
proc radio {x y c lst} { return [options $x $y $c {{i} { return "{ } - "}} $lst] }
proc y/n? {x y c yes no} { return [options $x $y $c {{i} {if {eq 1 $i} { return "{yes} - " }; return "{no}  - "}} [list $yes $no]] }
proc text-box {x y c lst} { return [options $x $y $c {{i} { return "" }} $lst]}

puts [reset][erase][at-xy 1 1]
puts "[bold]ANSI[reset] Loaded"
set bc "{[bg blue] [reset]} {[bg red] [reset]}"
set bc "{[bg blue] [reset]}"
#puts [text-box 4 3 = {"Join Bravely (pell-mell)" "Heaven/Hell?"}]
puts [select 4 3 $bc {"Join Bravely (pell-mell)" "Heaven/Hell?"}]
#puts [y/n? 4 3 $bc Heaven Hell]
puts
