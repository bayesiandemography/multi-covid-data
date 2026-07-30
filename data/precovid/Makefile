RAW_DIR := hmd_countries_20260615
DATA_DIR := ../data

DEATHS_SRC := $(wildcard $(RAW_DIR)/*/STATS/Deaths_5x1.txt)
DEATHS_OUT := $(DATA_DIR)/deaths.csv
DEATHS_ZIP := $(DEATHS_OUT).zip
DEATHS_SCRIPT := deaths.R

EXPOSURES_SRC := $(wildcard $(RAW_DIR)/*/STATS/Exposures_5x1.txt)
EXPOSURES_OUT := $(DATA_DIR)/exposures.csv
EXPOSURES_ZIP := $(EXPOSURES_OUT).zip
EXPOSURES_SCRIPT := exposures.R

E0PER_SRC := $(wildcard $(RAW_DIR)/*/STATS/E0per.txt)
E0PER_OUT := $(DATA_DIR)/e0per.csv
E0PER_ZIP := $(E0PER_OUT).zip
E0PER_SCRIPT := e0per.R

.PHONY: all clean

all: $(DEATHS_ZIP) $(EXPOSURES_ZIP) $(E0PER_ZIP)

$(DEATHS_OUT): $(DEATHS_SCRIPT) $(DEATHS_SRC) | $(DATA_DIR)
	Rscript $(DEATHS_SCRIPT)

$(EXPOSURES_OUT): $(EXPOSURES_SCRIPT) $(EXPOSURES_SRC) | $(DATA_DIR)
	Rscript $(EXPOSURES_SCRIPT)

$(DEATHS_ZIP): $(DEATHS_OUT)
	rm -f "$@"
	zip -j -q "$@" "$<"
	rm -f "$<"

$(EXPOSURES_ZIP): $(EXPOSURES_OUT)
	rm -f "$@"
	zip -j -q "$@" "$<"
	rm -f "$<"

$(E0PER_OUT): $(E0PER_SCRIPT) $(E0PER_SRC) | $(DATA_DIR)
	Rscript $(E0PER_SCRIPT)

$(E0PER_ZIP): $(E0PER_OUT)
	rm -f "$@"
	zip -j -q "$@" "$<"
	rm -f "$<"

$(DATA_DIR):
	mkdir -p "$@"

clean:
	rm -f "$(DEATHS_OUT)" "$(DEATHS_ZIP)" "$(EXPOSURES_OUT)" "$(EXPOSURES_ZIP)" "$(E0PER_OUT)" "$(E0PER_ZIP)"
