set terminal pdfcairo font "Times New Roman,11.77" linewidth 1 rounded fontscale 1.35 size 33.8cm, 8.5cm

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
# both entries: a key this wide cannot be fitted into one panel, and gnuplot drops
# entries it cannot fit rather than warning. A real key, not a drawn one, as before.
# The box is right-anchored, gnuplot's default for a key given no position word, so
# 0.85 is where its right edge sits - 1.7 cm left of where the row used to end.
set key width 1.5 Left vertical maxrows 1 reverse samplen 1 at screen 0.85, 1.031765 font ',11.77' spacing 2
set bmargin screen 0.258824
set tmargin at screen 0.894118
set rmargin screen 0.86

# Output settings
set output 'results/RQ5-Experiment-MicroBenchmark-Mining.pdf'

# The same canvas and the same panel geometry as its reducing sibling and the
# Percentage figure of the optimization overview: 33.8 cm by 8.5 cm, the same
# outer margins and the same 47 mm of white between panels, the same 4.41 cm panel
# height, the left margin at 3.38 cm, so the three figures print at one width, and
# the first panel's left edge and the last panel's right edge fall on the same two
# vertical lines down the page. This figure has two panels where those have three,
# and the width that would have been the third panel goes into the two: 12.49 cm
# each against their 6.75 cm. The y-axis title and the x title sit at this
# figure's own canvas coordinates - the x title centred on the two-panel block at
# 0.52, where the Percentage figure's is centred on its own block at 0.5 - and the
# panel labels keep their place within their panel rather than on the canvas, as
# in the rest of the family.
#
# The canvas is half a centimetre shorter than the 9 cm it was, and the half
# centimetre came off the bottom edge: the panels keep their 4.41 cm height, the
# fonts their size, and everything that is not below the panels the height it had
# above the canvas' top edge, which is why the vertical coordinates are fractions
# of 8.5 and no longer the round 0.31 and 0.80. The two panel labels moved right
# and down by 2% of the canvas - 0.68 cm right, 0.17 cm down - which puts them
# further into the panels than the Percentage figure's own three. The x title rose
# by that half centimetre with the canvas' bottom edge, keeping the 0.45 cm it
# leaves below itself, so the gap from the axis down to it is 1.84 cm instead of
# 2.34 cm.
set label "Time (ms)" rotate by 90 at screen 0.025, 0.523529 center font ",11.77"
set label "# of allow statements" at screen 0.52, 0.052941 center font ",11.77"
set label "5-Key" at screen 0.144, 0.725882 center font ",11.77"
set label "6-Key" at screen 0.654, 0.725882 center font ",11.77"

set multiplot layout 1,2 margins 0.08, 0.96, 0.269412, 0.788235 spacing 0.14

set log y
set format y "10^{%L}"
set xrange[-1: 16]
set xtics 3
set size 1, 0.9
set offsets 0.5,0.5,0,0
plot 'archive_data/Experiment-Scalability-MCI-K2.dat' using ($0+1):4 w lp ls 2 title 'AccessRefinery(MiniSAT)', \
     '' using ($0+1):5  w lp ls 3 title 'AccessRefinery(JavaBDD)'

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
plot 'archive_data/Experiment-Scalability-MCI-K3.dat' using ($0+1):4 w lp ls 2 title 'AccessRefinery(MiniSAT)', \
     '' using ($0+1):5  w lp ls 3 title 'AccessRefinery(JavaBDD)'

unset multiplot
