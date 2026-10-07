set terminal pdfcairo font "Times New Roman,11.77" linewidth 1 rounded fontscale 1.35 size 33.8cm, 9.5cm

# Set background and axes styles
set style line 80 lt rgb "#808080"
set style line 81 lt 0
set style line 81 lt rgb "#808080"

# Remove top and right borders for clarity
set grid back linestyle 81
set border 3 back linestyle 80
set xtics nomirror
set ytics nomirror

# Set line styles with distinct colors and thickness
set style line 1 lt rgb "#253494" lw 3 pt 8 ps 1.5
set style line 2 lt rgb "#2b8cbe" lw 3 pt 6 ps 1.5
set style line 3 lt rgb "#74c476" lw 3 pt 2 ps 1.5
set style line 4 lt rgb "#00A000" lw 3 pt 9 ps 1.5
set style line 5 lt rgb "#d4b9da" lw 3 pt 12 ps 1.5
set style line 6 lt rgb "#4F4F4F" lw 3

# Set axis and font properties
set xtics font ", 11"
set ytics font ", 11"
set boxwidth 0.9

# The one legend of the figure, its two entries in one row across the top of the
# canvas - the placement this figure has always used, and the only one that keeps
# both entries: a key this wide cannot be fitted into a single 7.50 cm panel, and
# gnuplot drops entries it cannot fit rather than warning. A real key, not a drawn
# one, as before. The box is right-anchored, gnuplot's default for a key given no
# position word, so 0.85 is where its right edge sits - 1.7 cm left of where the
# row used to end. Its y is this figure's own, not RQ3's: 1.03 of the 9 cm canvas
# this figure used before, carried over as 0.927 of the 10 cm canvas it then used
# so that the taller canvas of that figure would not lift the key off the panels,
# and then dropped 0.03 further, to 0.897 - the half centimetre since taken off the
# bottom edge leaves that height alone, so of the 9.5 cm canvas it uses now the
# same y reads as 0.891579.
set key width 1.5 Left vertical maxrows 1 reverse samplen 1 at screen 0.85, 0.891579 font ',11.77' spacing 2
set bmargin screen 0.241263
set tmargin at screen 0.705895
set rmargin screen 0.86

# Output settings
set output 'results/RQ5-Experiment-MicroBenchmark-Reducing.pdf'

# The RQ3 canvas and the RQ3 layout - 33.8 cm by 9.5 cm, margins 0.11355, 0.88645,
# 0.241263, 0.705895, spacing 0.05355 - so that a panel here is 7.501 cm by
# 4.416 cm, the size of an RQ3 panel, with 1.81 cm of white between neighbours; it
# was 6.75 cm and 47 mm on the 9 cm canvas this figure used before. The label
# coordinates below are the ones RQ3 uses for the same three panels, so the y
# title and the x title sit where that figure puts them, the x title keeping the
# 0.45 cm it leaves below itself to the canvas' bottom edge; the key above is the
# one placement this figure keeps of its own.
#
# The canvas is half a centimetre shorter than the 10 cm it was, and, as in RQ3,
# the half centimetre came off the bottom edge with nothing else: the panels, the
# fonts and every element above the panels keep what they had, which is why the
# two margins read as fractions of 9.5 now. The three panel labels are the
# exception besides the x title: they moved right and down by 2% of the canvas -
# 0.68 cm right, 0.19 cm down - so they sit further into their panels than RQ3's
# own three do.
set label "Time (ms)" rotate by 90 at screen 0.0586, 0.468421 center font ",11.77"
set label "# of allow statements" at screen 0.5, 0.047368 center font ",11.77"
set label "5-Key" at screen 0.1676, 0.647368 center font ",11.77"
set label "6-Key" at screen 0.443, 0.647368 center font ",11.77"
set label "5-Key*" at screen 0.7185, 0.647368 center font ",11.77"

set multiplot layout 1,3 margins 0.11355, 0.88645, 0.241263, 0.705895 spacing 0.05355

set log y
set format y "10^{%L}"
set xrange[-1: 16]
set xtics 3
set size 1, 0.9
set offsets 0.5,0.5,0,0
plot 'archive_data/Experiment-Scalability-RRI-K2.dat' using ($0+1):3 w lp ls 2 title 'AccessRefinary(MiniSAT)', \
     '' using ($0+1):4  w lp ls 3 title 'AccessRefinary(JavaBDD)'

# Figure-level text is written once, not once per panel: gnuplot redraws every
# label and every key on each panel's plot, and each of them here sits at absolute
# screen coordinates, so a second pass lands on top of the first and prints as
# if the text were set in a heavier weight. The first panel draws them above;
# the panels after it must not.
unset label
unset key

set log y
set format y "10^{%L}"
set xrange[-1: 16]
set xtics 3
set size 1, 0.9
set offsets 0.5,0.5,0,0
plot 'archive_data/Experiment-Scalability-RRI-K3.dat' using ($0+1):3 w lp ls 2 notitle, \
     '' using ($0+1):4  w lp ls 3 notitle

unset label
unset key

set log y
set format y "10^{%L}"
set xrange[-1: 16]
set xtics 3
set size 1, 0.9
set offsets 0.5,0.5,0,0
plot 'archive_data/Experiment-Scalability-RRI-K4.dat' using ($0+1):3 w lp ls 2 notitle, \
     '' using ($0+1):4  w lp ls 3 notitle

unset multiplot
