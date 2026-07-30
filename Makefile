YEAR_MIN := 1970
YEAR_MAX := 2025

.PHONY: all clean

all: out/deaths.csv


## pre-covid

out/deaths.csv: src/precovid/deaths.R \
  data/precovid/deaths.zip
	Rscript $^ $@


## clean

clean:
	rm -rf out
	mkdir out
