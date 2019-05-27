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
			#echo "$row" >&2
		done
		#echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
		#echo "$row" >&2
		# problem
		if [ -n "$M" ]; then
			M="$M\n$row"
		else
			M="$row"
		fi
		echo "$M" >&2
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

multiplyMatrices(){
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

gaussElimination(){
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

gaussJordan(){
	gauss=`gaussElimination $1`

	i=1
	echo "$gauss" |
	while read -r aLine; do
		tmp=`echo "$aLine" | cut -f$i -d' '`
		if [ "$tmp" != "0" ]; then
			tmp=`echo "scale=20; 1/$tmp" | bc`
			scalarXvector $tmp "$aLine"
		else
			scalarXvector 0 "$aLine"
		fi
		i=$(($i+1))
	done

	i=`echo "$1" | head -1 | wc -w`
	echo "$gauss" |
	while read -r aLine; do
		echo "$gauss" | head -$(($i-1)) |
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
	tmpMatrix=`gaussJordan "$tmpMatrix"`
	echo "$tmpMatrix" | cut -f$(($tmpM+1)) -d' '
	rm tmpA tmpB
}

regresion(){
	AT=`transpon "$1"`
	ATA=`multiplyMatrices "$AT" "$1"`
	ATA1=`invert "$ATA"`
	ATA1AT=`multiplyMatrices "$ATA1" "$AT"`
	ATA1ATb=`multiplyMatrices "$ATA1AT" "$2"`
	echo "$ATA1ATb"
}

exponets(){
        echo "$1" | tr ' ' '\n' |
        while read -r exLine; do
                echo "$exLine" | sed 's/$/'^$(($i-1))'/' | bc
                i=$(($i-1))
        done
}


columnExponention(){
	echo "$1" |
        while read -r eLine; do
                i=`echo "$eLine" | wc -w`
                exponets "$eLine" $i | paste -s -d' '
        done

}

matrixForLinReg(){
	cat "$1" | tail -n +2 | cut -f1 -d' ' > tmpA
	MfLR=`paste tmpA tmpA -d' '`
	columnExponention "$MfLR"
	rm tmpA
}

drawLine(){
	A=`matrixForLinReg "$1"`
	b=`cat "$1" | tail -n +2 | cut -f2 -d' '`
	x=`regresion "$A" "$b"`
	xT=`transpon "$x"`
	firstY=`multiplyMatrices "$xT" "$minX 1"`
	secondY=`multiplyMatrices "$xT" "$maxX 1"`
	
	firstY=`echo "scale=20; 1000-$firstY/$maxY*1000" | bc`
	secondY=`echo "scale=20; (-1)*$secondY/$maxY*1000" | bc`
	echo "
	<path d=\"m 100 $firstY 1000 $secondY \" style=\"fill:none;stroke-width:1px;stroke:#000\"/>
	" >> "$out"
}

drawSVG(){
	echo '<svg width="1200" height="1200" version="1.1" viewBox="0 0 1200 1200" xmlns="http://www.w3.org/2000/svg">
  <!--background-->
  <rect x="0" y="0" width="1200" height="1200" style="fill:#fff"/>
  <rect x="100" y="100" width="1000" height="1000" style="fill:#fff"/>
  '
	echo "  <!--axis x-->
  <path d=\"m 100 1100 1000 0\" style=\"fill:none;stroke-width:2px;stroke:#000\"/>
  <text x=\"1140\" y=\"1110\" style=\"fill:black;font-size:25px;font-family:sans-serif\">$axisX</text>
  <path d=\"m1090 1090 10 10 -10 10 \" style=\"fill:none;stroke-width:2px;stroke:black\" />

  <!--axis y-->
  <path d=\"m 100 1100 0 -1000\" style=\"fill:none;stroke-width:2px;stroke:#000\"/>
  <text x=\"90\" y=\"50\" style=\"fill:black;font-size:25px;font-family:sans-serif\">$axisY</text>
  <path d=\"m90 110 10 -10 10 10 \" style=\"fill:none;stroke-width:2px;stroke:black\" />"
}

axisNumbering(){
	echo "  <!-- axis numbering x in order-->"
	for i in $(seq 1 10); do
	tmp=`echo "scale=2; $i*$maxX/10" | bc`
	echo "
	<path d=\"m $(($i*100+100)) 1090 0 20\" style=\"fill:none;stroke-width:2px;stroke:#000\"/>
	<path d=\"m $(($i*100+100)) 100 0 1000\" style=\"fill:none;stroke-width:1px;stroke:#000\"/>
	<text x=\"$(($i*100+80))\" y=\"1150\"  style=\"fill:black;font-size:25px;font-family:sans-serif\">$tmp</text>"
	done
	echo "  <!-- axis numbering y in order-->"
	for i in $(seq 1 10); do
	tmp=`echo "scale=2; $i*$maxY/10" | bc`
	echo "
	<path d=\" 90 $((1100-$i*100)) 10 0\" style=\"fill:none;stroke-width:2px;stroke:#000\"/>
	<path d=\"m 100 $((1100-$i*100)) 1000 0\" style=\"fill:none;stroke-width:1px;stroke:#000\"/>
	<text x=\"20\" y=\"$((1110-$i*100))\"  style=\"fill:black;font-size:25px;font-family:sans-serif\">$tmp</text>
"
	done
}

placeDots(){
	read line
	echo "   <!--dots in order-->"
	while read -r line; do
		tmpX=`echo "$line" | cut -f1 -d' '`
		tmpY=`echo "$line" | cut -f2 -d' '`

		tmpX=`echo "scale=20; 100+$tmpX/$maxX*1000" | bc`
		tmpY=`echo "scale=20; 1100-$tmpY/$maxY*1000" | bc`
		echo "
		<rect transform=\"translate($tmpX $tmpY) rotate(45)\" width=\"10\" height=\"10\" style=\"paint-order:normal\"/>"
	done
}

minmax < $1

out="out.svg"

drawSVG > "$out"
axisNumbering >> "$out"
placeDots < $1 >> "$out"
drawLine "$1" >> "$out"
echo "</svg>" >> "$out"

exit
while [ $# -ge 1 ]; do
	shift 1
done
