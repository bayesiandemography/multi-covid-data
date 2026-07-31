YEAR_MIN := 1970
YEAR_MAX := 2025

.PHONY: all clean

all: out/hmd/deaths_raw.rds \
     out/hmd/population_raw.rds \
     out/hmd/e0_per_raw.rds \
     out/stmf/deaths_raw.rds \
     out/wpp/popn_est_raw.rds \
     out/wpp/popn_proj_raw.rds


## hmd

out/hmd/deaths_raw.rds: src/hmd/deaths_raw.R \
  data/hmd/deaths.zip
	Rscript $^ $@

out/hmd/population_raw.rds: src/hmd/population_raw.R \
  data/hmd/population.zip
	Rscript $^ $@

out/hmd/e0_per_raw.rds: src/hmd/e0_per_raw.R \
  data/hmd/e0_per.zip
	Rscript $^ $@


## stmf

out/stmf/deaths_raw.rds: src/stmf/deaths_raw.R \
  data/stmf/STMFinput-2.zip
	Rscript $^ $@


## wpp

out/wpp/popn_est_raw.rds: src/wpp/popn_est_raw.R \
  data/wpp/WPP2024_Population1JanuaryBySingleAgeSex_Medium_1950-2023.gz
	Rscript $^ $@ --year_min=2015

out/wpp/popn_proj_raw.rds: src/wpp/popn_proj_raw.R \
  data/wpp/WPP2024_Population1JanuaryBySingleAgeSex_Medium_2024-2100.gz
	Rscript $^ $@ --year_min=2024 --year_max=2027


## clean

clean:
	rm -rf out
	mkdir out
