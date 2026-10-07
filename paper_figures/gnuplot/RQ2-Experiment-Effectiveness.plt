set terminal pdfcairo font "Times New Roman,12.67" linewidth 1 rounded fontscale 1.35 size 33.8cm, 8.5cm

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
set style line 1 lt rgb "#2b8cbe" lw 3 pt 6 ps 1.0   # Before Reducing: blue circle
set style line 2 lt rgb "#74c476" lw 3 pt 2 ps 1.0   # After Reducing: green cross

# Set axis and font properties
set xtics font ", 11"
set ytics font ", 11"
set boxwidth 0.9

set key width -0.05 Left vertical maxrows 1 reverse samplen 1 at screen 0.755, 1.021176 font ',12.67' spacing 2
set bmargin screen 0.258824
set tmargin at screen 0.894118
set rmargin screen 0.86

# Output settings
set output 'results/RQ2-Experiment-Effectiveness.pdf'

# The canvas is 8.5 cm, half a centimetre shorter than the 9 cm it was, and the
# half centimetre came off the bottom edge with nothing else: the panels keep the
# 4.41 cm height, the fonts their size, and everything that is not below the
# panels the height it had above the canvas' top edge, which is why the vertical
# coordinates read as fractions of 8.5 and are no longer the round 0.31 and 0.80.
# The x title is the one thing that moved, up by that half centimetre and so
# towards the panels, and it keeps the 0.45 cm it leaves below itself to the
# canvas' bottom edge, so the gap from the axis down to it is 1.84 cm instead of
# 2.34 cm.
#
# The four panel labels are the exception besides the x title: they moved right
# and down by 2% of the canvas - 0.68 cm right, 0.17 cm down - so they sit
# further into their panels than the rest of the family's do.

set multiplot layout 1,4 margins 0.08, 0.96, 0.269412, 0.788235 spacing 0.05

# vertical y-axis title on the far left, inside the canvas
set label "# of Intents" rotate by 90 at screen 0.025, 0.523529 center font ",12.67"

set label "The ID of datasets" at screen 0.171, 0.052941 center font ",12.67"
set label "# of allow statements" at screen 0.636, 0.052941 center font ",12.67"

# --- Panel 1 (Real-world): lines only, no point markers ---
set yrange[0: 90]
set ytics 20
set xrange[0: 520]
set xtics 150
set size 1, 0.9
set offsets 0.5,0.5,0,0
set label "Real-world" at screen 0.155, 0.725882 center font ",12.67"
plot 'archive_data/Experiment-Effectiveness-RealWorld.dat' using 2 w l ls 1 t'Before Reducing', \
	'' using 3 w l ls 2 t'After Reducing'

# Figure-level text is written once, not once per panel: gnuplot redraws every
# label and every key on each panel's plot, and each of them here sits at absolute
# screen coordinates, so a second pass lands on top of the first and prints as
# if the text were set in a heavier weight. The first panel draws them above;
# the panels after it must not.
unset label
unset key

# --- Panel 2 (5-Key) ---
set log y
set format y "10^{%L}"
unset yrange
set xrange[0: 15]
set xtics 3
set size 1, 0.9
set offsets 0.5,0.5,0,0
set label "5-Key" at screen 0.375, 0.725882 center font ",12.67"
plot 'archive_data/Experiment-Effectiveness-Synthetic-K2.dat' using ($0+1):2 w lp ls 1 t'Before Reducing', \
	'' using ($0+1):1 w lp ls 2 t'After Reducing'

unset label
unset key

# --- Panel 3 (6-Key) ---
set log y
set format y "10^{%L}"
set xrange[0: 15]
set xtics 3
set size 1, 0.9
set offsets 0.5,0.5,0,0
set label "6-Key" at screen 0.605, 0.725882 center font ",12.67"
plot 'archive_data/Experiment-Effectiveness-Synthetic-K3.dat' using ($0+1):2 w lp ls 1 t'Before Reducing', \
	'' using ($0+1):1 w lp ls 2 t'After Reducing'

unset label
unset key

# --- Panel 4 (5-Key*) ---
set log y
set format y "10^{%L}"
set xrange[0: 15]
set xtics 3
set size 1, 0.9
set offsets 0.5,0.5,0,0
set label "5-Key*" at screen 0.835, 0.725882 center font ",12.67"
plot 'archive_data/Experiment-Effectiveness-Synthetic-K4.dat' using ($0+1):2 w lp ls 1 t'Before Reducing', \
	'' using ($0+1):1 w lp ls 2 t'After Reducing'

unset multiplot
