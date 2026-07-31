YEAR_MIN := 1970
YEAR_MAX := 2025

.PHONY: all clean

all: out/precovid/deaths_raw.rds \
     out/precovid/population_raw.rds \
     out/precovid/e0_per_raw.rds \
     out/covid-deaths/deaths_raw.rds


## pre-covid

out/precovid/deaths_raw.rds: src/precovid/deaths_raw.R \
  data/precovid/deaths.zip
	Rscript $^ $@

out/precovid/population_raw.rds: src/precovid/population_raw.R \
  data/precovid/population.zip
	Rscript $^ $@

out/precovid/e0_per_raw.rds: src/precovid/e0_per_raw.R \
  data/precovid/e0_per.zip
	Rscript $^ $@


## covid-deaths

out/covid-deaths/deaths_raw.rds: src/covid-deaths/deaths_raw.R \
  data/covid-deaths/STMFinput-2.zip
	Rscript $^ $@


## clean

clean:
	rm -rf out
	mkdir out
