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
				row="$row $tmp"
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
        echo "$1" | tr ' ' '\n' > tmpRow1
        echo "$2" | tr ' ' '\n' > tmpRow2
        paste tmpRow2 tmpRow1 | tr '\t' '*' | paste -s -d+ | bc
        rm tmpRow1 tmpRow2
}

row(){
	echo "$2" |
	while read -r rLine; do
		tmp=`multiply "$1" "$rLine"`
		if [ -n "$row" ]; then
			row="$row $tmp"
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
	echo "$1" |
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

substractRow(){
        echo "$1" | tr ' ' '\n' > tmpRow1
        echo "$2" | tr ' ' '\n' > tmpRow2
        paste tmpRow2 tmpRow1 | tr '\t' '-' | bc | paste -s -d' '
        rm tmpRow1 tmpRow2
}

scalarXvector(){
	echo "$2" | tr ' ' '\n' | sed 's/$/'*$1'/' | bc | paste -s -d' '
}

substractByPivot(){
	tmpA=`echo "$1" | cut -f$3 -d' '`
	tmpB=`echo "$2" | cut -f$3 -d' '`
	tmpAmount=$(($tmpB/$tmpA))
	if [ $? -ne 0 ]; then
		tmpAmount="0"
	fi
	tmpV1=`scalarXvector $tmpAmount "$1"`
	substractRow "$tmpV1" "$2"
}

gausElimination(){
	i=1;
	echo "$1" | 
	while read -r aLine; do
		echo "$1" | tail -n +$(($i+1)) | 
		while read -r bLine; do
			substractByPivot "$aLine" "$bLine" "$i"	
		done
		i=$(($i+1))
	done
}

gausJordan(){
	gaus=`gausElimination $1`

	i=1
	echo "$gaus" |
	while read -r aLine; do
		tmp=`echo "$aLine" | cut -f$i -d' '`
		if [ $tmp -ne 0 ]; then
			scalarXvector $((1/$tmp)) "$aLine"
		else
			scalarCvector 0 "$aLine"
		fi
		i=$(($i+1))
	done

	i=`echo "$1" | head -1 | wc -w`
	echo "$gaus" |
	while read -r aLine; do
		echo "$gaus" | head -$((i-1)) |
		while read -r bLine; do
			substractByPivot "$aLine" "$bLine" $i
		done
		i=$(($i-1))
	done
}

identity(){
        for i in $(seq 1 $1); do
                for j in $(seq 1 $2); do
                        if [ $i -eq $j ]; then
                                tmp="1"
                        else
                                tmp="0"
                        fi
                        if [ -n "$row" ]; then
                                row="$row $tmp"
                        else
                                row="$tmp"
                        fi
                done
                echo "$row"
                row=""
        done
}

invert(){
	tmpN=`echo "$1" | wc -l`
	tmpM=`echo "$1" | head -1 | wc -w`

	echo "$1" > tmpA
	identity $tmpN $tmpM > tmpB
	tmpMatrix=`paste tmpA tmpB`
	tmpMatrix=`gausJordan "$tmpMatrix"`
	echo "$tmpMatrix" | cut -f$(($tmpM+1)) -d' '
}

regresion(){
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
