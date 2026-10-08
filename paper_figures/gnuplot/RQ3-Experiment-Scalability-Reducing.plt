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

# The panels' y axis is a log axis, so gnuplot would put a tic on every decade
# by itself, on top of the four that `set ytics 10, 100` in each panel asks for.
# Those extra ones are the axis' minor tics and they are off here, which leaves
# the y axis showing the odd powers and nothing else: no mark, no line and no
# label at 10^2, 10^4, 10^6 or 10^8. Only the y axis: the x axis keeps its own
# minor tics between the majors `set xtics 3` spaces out.
unset mytics

# Set line styles with distinct colors and thickness
set style line 1 lt rgb "#253494" lw 3 pt 8 ps 1.5
set style line 2 lt rgb "#2b8cbe" lw 3 pt 6 ps 1.5
set style line 3 lt rgb "#74c476" lw 3 pt 2 ps 1.5
set style line 4 lt rgb "#00A000" lw 3 pt 9 ps 1.5
set style line 5 lt rgb "#d4b9da" lw 3 pt 12 ps 1.5
set style line 6 lt rgb "#4F4F4F" lw 3
set style line 7 lt rgb "#bd0026" lw 3 pt 10 ps 1.5

# Set axis and font properties
set xtics font ", 11"
set ytics font ", 11"
set boxwidth 0.9

# The legend of this figure: one key, its four entries in two columns in two
# rows, above the panels, placed so that the centre of its left entry column
# falls on the centre of the white gap between the first and second panel
# (340.62 pt = screen 0.3556) and the centre of its right entry column on the
# centre of the gap between the second and third (655.50 pt = screen 0.6842) -
# the two gaps of the three-panel row. The width increment is what sets the
# distance between the two columns, and here it is negative because this figure's
# left column holds `Baseline(Z3)` and `Baseline(CVC5)`, some 69 pt narrower than
# the mining figure's two Access Analyzer labels: at width 0 the two centres
# would sit further apart than the 314.88 pt (11.11 cm) this figure's wider
# panels leave between its gaps, so the box is pulled in to that distance. One
# unit of width moves the left column 21.2 pt and the right one 10.6 pt, both the
# same way, since the box stays anchored at its right edge. 0.8098 is the anchor
# that then lands the two centres on the two gaps. Measured, not computed: 340.60
# and 655.52 pt against the 340.62 and 655.50 of the gaps. The font is the
# figure's own 11.77 like every other text in it, not a size of its own. The two
# rows stand 30.5 pt apart, up from the 23.3 pt of `spacing 1.0`: that is what
# `spacing 1.30` buys, and it is the only knob used for it - the larger spacing
# also drops the key's own top edge by the same 4 pt it adds above the first row,
# so the block grows downward from the canvas top, which the 2.79 cm of headroom
# above the panels is there to absorb.
set key width -2.043 Left vertical maxrows 2 maxcols 2 reverse samplen 1 at screen 0.8098, 0.968421 font ',11.77' spacing 1.30
set bmargin screen 0.231579
set tmargin at screen 0.8
set rmargin screen 0.86

# Output settings
set output 'results/RQ3-Experiment-Scalability-Reducing.pdf'

# Same panel geometry as the Percentage figure of the optimization overview -
# three panels 7.501 cm wide, 18.1 mm of white between them, on the same 33.8 cm
# by 10 cm canvas - so a panel here is exactly the size of a panel there and of
# a panel of the RQ3 mining figure. The 18.1 mm is half the 36.0 mm this figure
# used to carry: the white that comes out of the two gaps can neither leave the
# canvas nor widen the panels, both being fixed, so it goes to the two outer
# margins instead, 3.84 cm each against the 2.70 cm and 1.35 cm they were. The
# three panels as one block are then centred on the canvas, and the first panel
# no longer starts on the 0.08 line the left axis of the rest of the family uses.
# The two titles follow the block: the y title keeps its 1.86 cm of clearance
# from the axis it labels, the x title sits at the block's centre, which is the
# canvas centre 0.5. The shared 4.41 cm height is that figure's own.
#
# This canvas is 9.5 cm, half a centimetre shorter than the 10 cm it was. The half
# centimetre came off the bottom edge and nothing else came with it: the panels
# keep the 4.41 cm height and the two 3.84 cm outer margins they had, the fonts
# keep their size, and every element that is not below the panels keeps the height
# it had above the canvas' top edge. That is why the vertical coordinates below
# read as fractions of 9.5 rather than of 10 and are no longer the round 0.2792
# and 0.7206, and why the headroom above the panels is still 2.79 cm, which is
# what the key above is drawn in. The x title is the one thing that moved, up by
# that half centimetre and so towards the panels - which is what the shorter
# canvas was for - and it keeps the 0.45 cm it leaves below itself to the canvas'
# bottom edge, so the gap from the axis down to it is 1.84 cm instead of 2.34 cm.
# The panels keep the y-axis title off the plots entirely,
# which is what that figure does and what leaves the first panel its full height.
#
# The three panel labels sit at the same 1.15 cm from their own panel's left edge
# as they always did, so each one follows its panel and all three have moved.
# The 5-Key*
# panel is the new one: the two reducer baselines were run on that dataset one
# round per policy, Z3 measuring the first three policies before its first
# timeout and CVC5 the first five, so their two curves stop where the
# measurements stop and the rest of their range is the sentinel.
# The y axis runs one decade higher than the data: 10^1 to 10^8, where every
# curve's own maximum is the 3600000 s timeout sentinel at 10^6.6. The decade of
# headroom is what keeps the topmost tick label off the panel's top edge, where
# the panel's own label sits. Only the odd powers are labelled - 10^1, 10^3,
# 10^5, 10^7 - so the labelled grid lines stand two decades apart and the even
# powers carry neither a label nor a line. The list is written out rather than
# left to `set format y`, which sees the axis as a log axis and would label every
# decade: on it the explicit positions still take the format, so the four labels
# come out in the same `10^{n}` shape as before.
set label "Time (ms)" rotate by 90 at screen 0.0586, 0.468421 center font ",11.77"
set label "# of allow statements" at screen 0.5, 0.047368 center font ",11.77"
set label "5-Key" at screen 0.1476, 0.667368 center font ",11.77"
set label "6-Key" at screen 0.423, 0.667368 center font ",11.77"
set label "5-Key*" at screen 0.6985, 0.667368 center font ",11.77"

set multiplot layout 1,3 margins 0.11355, 0.88645, 0.241263, 0.705895 spacing 0.05355

set log y
set format y "10^{%L}"
set xrange[-1: 16]
set xtics 3
set yrange[10: 1e8]
set ytics 10, 100
set size 1, 0.9
set offsets 0.5,0.5,0,0
plot 'archive_data/Experiment-Scalability-RRI-K2.dat' using ($0+1):1 w lp ls 1 title 'Baseline(Z3)', \
     '' using ($0+1):2  w lp ls 2 title 'Baseline(CVC5)', \
     '' using ($0+1):4  w lp ls 3 title 'AccessRefinery(W/O All)', \
     'archive_data/Experiment-Scalability-RRI-K2-WAll.dat' using ($0+1):1 w lp ls 7 title 'AccessRefinery(W/ All)'

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
set yrange[10: 1e8]
set ytics 10, 100
set size 1, 0.9
set offsets 0.5,0.5,0,0
plot 'archive_data/Experiment-Scalability-RRI-K3.dat' using ($0+1):1 w lp ls 1 title 'Baseline(Z3)', \
     '' using ($0+1):2  w lp ls 2 title 'Baseline(CVC5)', \
     '' using ($0+1):4  w lp ls 3 title 'AccessRefinery(W/O All)', \
     'archive_data/Experiment-Scalability-RRI-K3-WAll.dat' using ($0+1):1 w lp ls 7 title 'AccessRefinery(W/ All)'

unset label
unset key

set log y
set format y "10^{%L}"
set xrange[-1: 16]
set xtics 3
set yrange[10: 1e8]
set ytics 10, 100
set size 1, 0.9
set offsets 0.5,0.5,0,0
plot 'archive_data/Experiment-Scalability-RRI-K4.dat' using ($0+1):1 w lp ls 1 title 'Baseline(Z3)', \
     '' using ($0+1):2  w lp ls 2 title 'Baseline(CVC5)', \
     '' using ($0+1):4  w lp ls 3 title 'AccessRefinery(W/O All)', \
     'archive_data/Experiment-Scalability-RRI-K4-WAll.dat' using ($0+1):1 w lp ls 7 title 'AccessRefinery(W/ All)'

unset multiplot
