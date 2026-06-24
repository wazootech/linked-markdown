SOURCE = paper.md
HEADER = header.preamble
OUTPUT = paper.pdf
BIB = references.bib

PANDOC = pandoc

all: $(OUTPUT)

$(OUTPUT): $(SOURCE) $(HEADER) $(BIB)
	$(PANDOC) $(SOURCE) \
		--include-in-header=$(HEADER) \
		--bibliography=$(BIB) \
		--citeproc \
		--pdf-engine=xelatex \
		--toc \
		--number-sections \
		--no-highlight \
		-o $(OUTPUT)

clean:
	rm -f $(OUTPUT)

.PHONY: all clean
