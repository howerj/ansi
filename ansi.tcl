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
proc erase-line {} { return "\x1b\[2K" }
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

# Partially compliant "format" command, extended with some ANSI escape sequences.
proc format {fmt args} {
	set l [split $fmt ""]
	set w [llength $l]
	set r ""
	for {set i 0; set j 0} {< $i $w} {incr i} {
		set o [lindex $l $i]
		if {eq $o "%"} {
			set s [lindex $l [incr i]]
			set v [lindex $args $j]
			if {eq $s %} { set r $r%
			} elseif {eq $s s} { set r $r$v
			} elseif {eq $s x} { set r $r[string dec2hex $v]; incr j
			} elseif {eq $s X} { set r $r[string toupper [string dec2hex $v]]; incr j
			} elseif {eq $s o} { set r $r[string dec2base $v 8]; incr j
			} elseif {eq $s c} { set r $r[string char $v]; incr j
			} elseif {eq $s @} { set r $r[at-xy $v [lindex $args [incr j]]]
			} elseif {eq $s T} { set r $r[reset]
			} elseif {eq $s H} { set r $r[bold]
			} elseif {eq $s N} { set r $r[blink]
			} elseif {eq $s V} { set r $r[reverse]
			} elseif {eq $s E} { set r $r[erase]
			} elseif {eq $s D} { set r $r[erase-line]
			} elseif {eq $s k} { set r $r[fg black]
			} elseif {eq $s r} { set r $r[fg red]
			} elseif {eq $s g} { set r $r[fg green]
			} elseif {eq $s y} { set r $r[fg yellow]
			} elseif {eq $s b} { set r $r[fg blue]
			} elseif {eq $s m} { set r $r[fg magenta]
			} elseif {eq $s a} { set r $r[fg cyan]
			} elseif {eq $s w} { set r $r[fg white]
			} elseif {eq $s f} { set r $r[sgr 39]
			} elseif {eq $s K} { set r $r[bg black]
			} elseif {eq $s R} { set r $r[bg red]
			} elseif {eq $s G} { set r $r[bg green]
			} elseif {eq $s Y} { set r $r[bg yellow]
			} elseif {eq $s B} { set r $r[bg blue]
			} elseif {eq $s M} { set r $r[bg magenta]
			} elseif {eq $s A} { set r $r[bg cyan]
			} elseif {eq $s W} { set r $r[bg white]
			} elseif {eq $s F} { set r $r[sgr 49]
			} else { return "Error format $s" -1 }
		} else {
			set r $r$o
		}
	}
	return $r
}

# see <https://github.com/howerj/pickle/blob/master/shell>
set seed [clock seconds]
proc random {args} {
	upvar #0 seed x;
	set alen [llength $args]
	if {> $alen 1 } { return "Error args" -1 }
	set ns [lindex $args 0]
	if {> $alen 0 } { set x $ns }
	if {== $x 0} { incr x; }
	set x [xor $x [lshift $x 13]];
	set x [xor $x [rshift $x 17]];
	set x [xor $x [lshift $x  5]];
}
for {set i 0} {< $i 10} {incr i} { random }
unset i


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
#puts [format "%N%rBe %g%Rseeing%F %Vyou%T"]
