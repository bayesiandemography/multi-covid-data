YEAR_MIN := 1960
YEAR_MAX := 2025
# 1 January after the last year, so exposure exists for YEAR_MAX.
YEAR_MAX_POPULATION := $(shell expr $(YEAR_MAX) + 1)
WEEK_REQUIRED_STMF := 52

.PHONY: all clean .COPY nso

all: out/data.csv.zip \
     out/fig_lifeexp.pdf


## hmd

out/hmd/deaths_raw.rds: src/hmd/deaths_raw.R \
  data/hmd/deaths.zip
	Rscript $^ $@

out/hmd/population_raw.rds: src/hmd/population_raw.R \
  data/hmd/population.zip
	Rscript $^ $@

out/hmd/lifeexp_raw.rds: src/hmd/lifeexp_raw.R \
  data/hmd/lifeexp.zip
	Rscript $^ $@

out/hmd/countries.rds: src/hmd/countries.R \
  out/hmd/deaths_raw.rds \
  data/hmd/countries.csv
	Rscript $^ $@

out/hmd/deaths.rds: src/hmd/deaths.R \
  out/hmd/deaths_raw.rds \
  out/hmd/countries.rds
	Rscript $^ $@

out/hmd/population.rds: src/hmd/population.R \
  out/hmd/population_raw.rds \
  out/hmd/countries.rds
	Rscript $^ $@

out/hmd/lifeexp.rds: src/hmd/lifeexp.R \
  out/hmd/lifeexp_raw.rds \
  out/hmd/countries.rds
	Rscript $^ $@


## stmf

out/stmf/deaths_raw.rds: src/stmf/deaths_raw.R \
  data/stmf/STMFinput-2.zip
	Rscript $^ $@

out/stmf/countries.rds: src/stmf/countries.R \
  data/stmf/countries.csv \
  data/stmf/STMFinput-2.zip
	Rscript $^ $@ --year_required=$(YEAR_MAX) --week_required=$(WEEK_REQUIRED_STMF)

out/stmf/deaths.rds: src/stmf/deaths.R \
  out/stmf/deaths_raw.rds \
  out/stmf/countries.rds
	Rscript $^ $@ --year_min=$(YEAR_MIN) --year_max=$(YEAR_MAX)


## wpp

out/wpp/popn_est_raw.rds: src/wpp/popn_est_raw.R \
  data/wpp/WPP2024_Population1JanuaryBySingleAgeSex_Medium_1950-2023.gz
	Rscript $^ $@ --year_min=$(YEAR_MIN)

out/wpp/popn_proj_raw.rds: src/wpp/popn_proj_raw.R \
  data/wpp/WPP2024_Population1JanuaryBySingleAgeSex_Medium_2024-2100.gz
	Rscript $^ $@ --year_max=$(YEAR_MAX_POPULATION)

out/wpp/population.rds: src/wpp/population.R \
  out/wpp/popn_est_raw.rds \
  out/wpp/popn_proj_raw.rds
	Rscript $^ $@


## intermediate

out/intermediate/population.rds: src/intermediate/population.R \
  out/hmd/population.rds \
  out/wpp/population.rds
	Rscript $^ $@ --year_min=$(YEAR_MIN) --year_max=$(YEAR_MAX_POPULATION)

out/intermediate/deaths.rds: src/intermediate/deaths.R \
  out/hmd/deaths.rds \
  out/stmf/deaths.rds \
  out/nso/deaths.rds
	Rscript $^ $@ --year_min=$(YEAR_MIN) --year_max=$(YEAR_MAX)

out/intermediate/exposure.rds: src/intermediate/exposure.R \
  out/intermediate/population.rds
	Rscript $^ $@

out/intermediate/vals_lifeexp.rds: src/intermediate/vals_lifeexp.R \
  out/data.csv.zip \
  out/hmd/lifeexp.rds
	Rscript $^ $@

out/data.csv.zip: src/data.R \
  out/intermediate/deaths.rds \
  out/intermediate/exposure.rds
	Rscript $^ $@

out/fig_lifeexp.pdf: src/fig_lifeexp.R \
  out/intermediate/vals_lifeexp.rds
	Rscript $^ $@

# Copy the analysis product into the sibling multi-covid-model data directory.
.COPY: out/data.csv.zip
	mkdir -p ../multi-covid-model/data
	cp out/data.csv.zip ../multi-covid-model/data/
	rm -f ../multi-covid-model/data/*.csv


## nso

out/nso/canada.rds: src/nso/canada.R \
  data/nso/13100768-eng.zip
	Rscript $^ $@

out/nso/hong_kong.rds: src/nso/hong_kong.R \
  data/nso/get.php
	Rscript $^ $@

out/nso/ireland.rds: src/nso/ireland.R \
  data/nso/VSA29.20260827020459.csv \
  data/nso/VSA07.20260827020411.csv
	Rscript $^ $@

out/nso/japan.rds: src/nso/japan.R \
  data/nso/R7toukeihyou.xlsx
	Rscript $^ $@

out/nso/korea.rds: src/nso/korea.R \
  data/nso/2025%EB%85%84+%EC%B6%9C%EC%83%9D.%EC%82%AC%EB%A7%9D%ED%86%B5%EA%B3%84%28%EC%9E%A0%EC%A0%95%29.pdf
	Rscript $^ $@

out/nso/taiwan.rds: src/nso/taiwan.R \
  data/nso/114%e5%b9%b4%e5%b9%b4%e9%bd%a1%e5%88%a5%e7%b5%b1%e8%a8%881150622.xlsx
	Rscript $^ $@

out/nso/deaths.rds: src/nso/deaths.R \
  out/nso/canada.rds \
  out/nso/hong_kong.rds \
  out/nso/ireland.rds \
  out/nso/japan.rds \
  out/nso/korea.rds \
  out/nso/taiwan.rds \
  out/hmd/countries.rds
	Rscript $^ $@ --year_min=$(YEAR_MIN) --year_max=$(YEAR_MAX)

nso: out/nso/canada.rds \
     out/nso/hong_kong.rds \
     out/nso/ireland.rds \
     out/nso/japan.rds \
     out/nso/korea.rds \
     out/nso/taiwan.rds \
     out/nso/deaths.rds


## clean

clean:
	rm -rf out
	mkdir out
