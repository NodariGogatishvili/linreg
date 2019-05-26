#!/bin/dash

help(){
	echo'
	[options] [File]

-h help

input file structure example

x            y
1            1
2            4
3            9
2.5         6.25
40          1600

-r ad regresion curve
   r and r1 linear

-c(size)   circle insted of rectangle fordots
  example: -c10
           -c10px

-nr not rotated of rectangle for dots

-dstyle=" [options] "
    dots style
   -style="width:10;height:10;fill:red;stroke-width:1px;stroke:green;"

-cstyle=" [options] "
     regresion curve style
     -style="fill:none;stroke-width:2px;stroke:#000;"

-tstyle=" [options] "
     polynomial regresion exuation text style
     -style="fill:green;font-size:20pt;font-family:sans-serif"

-gstile=" [options] "
      grid style
      -gstyle="fill:none;stroke-width:1px;stroke:#000;stroke-dasharray:4 1 2 3"

-lstile=" [options]"
      lable style
      -lstyle="fill:black;font-size:25px;font-family:sans-serif"

-bstyle=" [options]"
       background style. Wtijout -bstyle trasparent bacground
       -bstyle="fill:rgba(40,100,255,1)"
'
}

minmax(){
	read -r x y
	axisX="$x"
	axisY="$y"
	read -r x y
	minX="$x"
	maxX="$x"
	minY="$y"
	maxY="$y"
	while read -r x y; do
		if [ $x -le $minX ]; then
			minX="$x"
		fi
		if [ $x -ge $maxX ]; then
			maxX="$x"
		fi
		if [ $y -le $minY ]; then
			minY="$y"
		fi
		if [ $y -ge $maxY ]; then
			maxY="$y"
		fi
	done
}


place(){
	:	
}

transpon(){
	tSize=`echo "$1" | head -1 |  wc -w`
	for i in $(seq 1 $tSize); do
		echo "$1" |
		while read -r line; do
			tmp=`echo "$line" | cut -f$i -d' '`
			if [ -n "$row" ]; then
				row="$row" "$tmp"
			else
				row="$tmp"
			fi
		done
		if [ -n "$M" ]; then
			M="$M\n$row"
		else
			M="$row"
		fi
		row=""
	done
	echo "$M"
	M=""
}

multiply(){
	paste <(echo "$1" | tr ' ' '\n') <(echo "$2" | tr ' ' '\n') | tr '\t' '*' |
		paste -s -d+ | bc
}

row(){
	echo "$2" |
	while read -r rLine; do
		tmp=`multiply "$1" "$rLine"`
		if [ -n "$row" ]; then
			row="$row" "$tmp"
		else
			row="$tmp"
		fi
	done
	echo "$row"
	row=""
}

multipleMatcies(){
	n=`echo "$1" | wc -l`
	m=`echo "$1" | head -1 | wc -w`
	M2=`transpon "$2"`
	while read -r mLine; do
		tmp=`row "$mLine" "$M2"`
		if [ -n "$row" ]; then
			row="$row\n$tmp"
		else
			row="$tmp"
		fi
	done
	echo "$row"
	row=""
}

invert(){
	:
}

drawLine(){
	:
}

drawSVG(){
	:
}

minmax < $1

exit
while [ $# -ge 1 ]; do
	shift 1
done
