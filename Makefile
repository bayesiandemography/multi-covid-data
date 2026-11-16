YEAR_MIN := 1970
YEAR_MAX := 2025
YEAR_REQUIRED_HMD := 2019
YEAR_MIN_WPP := 2000
YEAR_MAX_WPP := 2026
YEAR_REQUIRED_STMF := 2025
WEEK_REQUIRED_STMF := 52
YEAR_MIN_STMF := 2020
YEAR_MAX_STMF := 2025

.PHONY: all clean .COPY

all: out/datasets_final/data_fit.zip \
     out/datasets_final/newdata_nonscaled.zip \
     out/datasets_final/newdata_scaled.zip \
     out/datasets_final/deaths_observed.zip \
     out/figures/fig_population.pdf \
     out/figures/fig_deaths.pdf \
     out/figures/fig_death_rates.pdf


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
	Rscript $^ $@ --year_required=$(YEAR_REQUIRED_HMD)

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
	Rscript $^ $@ --year_required=$(YEAR_REQUIRED_STMF) --week_required=$(WEEK_REQUIRED_STMF)

out/stmf/deaths.rds: src/stmf/deaths.R \
  out/stmf/deaths_raw.rds \
  out/stmf/countries.rds
	Rscript $^ $@ --year_min=$(YEAR_MIN_STMF) --year_max=$(YEAR_MAX_STMF)


## wpp

out/wpp/popn_est_raw.rds: src/wpp/popn_est_raw.R \
  data/wpp/WPP2024_Population1JanuaryBySingleAgeSex_Medium_1950-2023.gz
	Rscript $^ $@ --year_min=$(YEAR_MIN_WPP)

out/wpp/popn_proj_raw.rds: src/wpp/popn_proj_raw.R \
  data/wpp/WPP2024_Population1JanuaryBySingleAgeSex_Medium_2024-2100.gz
	Rscript $^ $@ --year_max=$(YEAR_MAX_WPP)

out/wpp/population.rds: src/wpp/population.R \
  out/wpp/popn_est_raw.rds \
  out/wpp/popn_proj_raw.rds
	Rscript $^ $@


## shared

out/shared/population.rds: src/shared/population.R \
  out/hmd/population.rds \
  out/wpp/population.rds
	Rscript $^ $@ --year_min=$(YEAR_MIN) --year_max=$(YEAR_MAX_WPP)

out/shared/deaths.rds: src/shared/deaths.R \
  out/hmd/deaths.rds \
  out/stmf/deaths.rds
	Rscript $^ $@ --year_min=$(YEAR_MIN) --year_max=$(YEAR_MAX_STMF)

out/shared/exposure.rds: src/shared/exposure.R \
  out/shared/population.rds
	Rscript $^ $@


## datasets_final

out/datasets_final/data_fit.zip: src/datasets_final/data_fit.R \
  out/shared/deaths.rds \
  out/shared/exposure.rds
	Rscript $^ $@

out/datasets_final/newdata_nonscaled.zip: src/datasets_final/newdata_nonscaled.R \
  out/shared/exposure.rds
	Rscript $^ $@

out/datasets_final/newdata_scaled.zip: src/datasets_final/newdata_scaled.R \
  out/shared/exposure.rds
	Rscript $^ $@

out/datasets_final/deaths_observed.zip: src/datasets_final/deaths_observed.R \
  out/shared/deaths.rds
	Rscript $^ $@

# Copy zipped analysis products into the sibling multi-covid-model data directory.
.COPY: out/datasets_final/data_fit.zip \
       out/datasets_final/newdata_nonscaled.zip \
       out/datasets_final/newdata_scaled.zip \
       out/datasets_final/deaths_observed.zip
	mkdir -p ../multi-covid-model/data
	cp out/datasets_final/*.zip ../multi-covid-model/data/
	rm -f ../multi-covid-model/data/*.csv


## figures

out/figures/vals_population.rds: src/figures/vals_population.R \
  out/shared/population.rds
	Rscript $^ $@

out/figures/vals_deaths.rds: src/figures/vals_deaths.R \
  out/hmd/deaths.rds \
  out/stmf/deaths.rds
	Rscript $^ $@ --year_min=$(YEAR_MIN) --year_max=$(YEAR_MAX_STMF)

out/figures/fig_population.pdf: src/figures/fig_population.R \
  out/figures/vals_population.rds
	Rscript $^ $@ --year_min=$(YEAR_MIN_WPP)

out/figures/fig_deaths.pdf: src/figures/fig_deaths.R \
  out/figures/vals_deaths.rds
	Rscript $^ $@ --year_min=$(YEAR_MIN_WPP)

out/figures/fig_death_rates.pdf: src/figures/fig_death_rates.R \
  out/figures/vals_deaths.rds \
  out/datasets_final/data_fit.zip \
  out/datasets_final/newdata_scaled.zip
	Rscript $^ $@ --year_min=$(YEAR_MIN) --year_max=$(YEAR_MAX)


## clean

clean:
	rm -rf out
	mkdir out
