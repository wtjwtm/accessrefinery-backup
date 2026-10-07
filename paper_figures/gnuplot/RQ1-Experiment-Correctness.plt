set terminal pdfcairo font "Times New Roman,13" linewidth 1 rounded fontscale 1.35 size 26cm, 6.5cm

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
set style line 1 lt rgb "#A00000" lw 3 pt 1 ps 1.5
set style line 2 lt rgb "#74c476" lw 3 pt 6 ps 1.5
set style line 3 lt rgb "#2b8cbe" lw 3 pt 2 ps 1.5
set style line 4 lt rgb "#00A000" lw 3 pt 9 ps 1.5
set style line 5 lt rgb "#253494" lw 3 pt 12 ps 1.5
set style line 6 lt rgb "#4F4F4F" lw 3

# Set axis and font properties
set xtics font ", 13"
set ytics font ", 13"
set boxwidth 0.1

set bmargin screen 0.278462
set tmargin at screen 0.892308
set rmargin screen 0.87

# Output settings
set output 'results/RQ1-Experiment-Correctness.pdf'

set style fill pattern
set boxwidth 0.9

# Set labels
set label "The ID of datasets" at screen 0.54, 0.064615 center font ",13"
set label "Real-world" at screen 0.195, 0.892308 center font ",13"
set label "Synthetic" at screen 0.655, 0.892308 center font ",13"

# Multiplot layout and axis settings
# The canvas is 6.5 cm, half a centimetre shorter than the 7 cm it was, and the
# half centimetre came off the bottom edge with nothing else: the two panels keep
# their 4.13 cm height, the fonts their size, and everything that is not below the
# panels the height it had above the canvas' top edge, which is why the vertical
# coordinates read as fractions of 6.5 and are no longer the round 0.35 and 0.94.
# The x title is the one thing that moved, up by that half centimetre and so
# towards the panels, and it keeps the 0.42 cm it leaves below itself, so the gap
# from the axis down to it is 1.53 cm instead of 2.03 cm.

set multiplot layout 1,2 margins 0.10, 0.96, 0.3, 0.935385 spacing 0.09
set ylabel "# of Intents" offset 1.5,0
set xrange [0: 520]
set yrange [0: 90]
set ytics 20
plot 'archive_data/Experiment-Effectiveness-RealWorld.dat' using 2 w l ls 3 t''

# Figure-level text is written once, not once per panel: gnuplot redraws every
# label on each panel's plot, and each of them here sits at absolute
# screen coordinates, so a second pass lands on top of the first and prints as
# if the text were set in a heavier weight. The first panel draws them above;
# the panels after it must not.
unset label

unset ylabel
set boxwidth 0.5
set xrange [0: 13]
set yrange [0: 5]
set ytics 1
plot 'archive_data/Experiment-Correctness-Synthetic.dat' using ($0+1):2 with boxes ls 3 fs pattern 7 notitle

unset multiplot