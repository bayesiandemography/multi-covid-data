YEAR_MIN := 1970
YEAR_MAX := 2025

.PHONY: all clean

all: out/precovid/deaths_raw.rds \
     out/precovid/population_raw.rds \
     out/precovid/e0_per_raw.rds \
     out/covid-deaths/deaths_raw.rds \
     out/covid-population/popn_est_raw.rds \
     out/covid-population/popn_proj_raw.rds


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


## covid-population

out/covid-population/popn_est_raw.rds: src/covid-population/popn_est_raw.R \
  data/covid-population/WPP2024_PopulationBySingleAgeSex_Medium_1950-2023.gz
	Rscript $^ $@ --year_min=2015

out/covid-population/popn_proj_raw.rds: src/covid-population/popn_proj_raw.R \
  data/covid-population/WPP2024_PopulationBySingleAgeSex_Medium_2024-2100.gz
	Rscript $^ $@ --year_min=2024 --year_max=2027


## clean

clean:
	rm -rf out
	mkdir out
