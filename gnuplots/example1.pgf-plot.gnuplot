set table "example1.pgf-plot.table"; set format "%.5f"
set format "%.7e";; plot [-10:10] real(sin(x)**besj0(x))*besj0(x)+2*1/x 
