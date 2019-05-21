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

MultipleMatcies(){
	:
}

drawLine(){
	:
}

minmax < $1

exit
while [ $# -ge 1 ]; do
	shift 1
done
