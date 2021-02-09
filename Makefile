XMLINFILES=$(wildcard *.xml.in)
XMLFILES = $(patsubst %.xml.in,%.xml,$(XMLINFILES))

all: po $(XMLFILES) sort

po: $(XMLINFILES)
	make -C po -f Makefile || exit 1

clean:
	@rm -fv *~ *.xml

validate: $(XMLFILES) comps.rng
	# Run xmllint on each file and exit with non-zero if any validation fails
	RES=0; for f in $(XMLFILES); do \
		xmllint --noout --relaxng comps.rng $$f; \
		RES=$$(($$RES + $$?)); \
	done; exit $$RES

sort:
	@# Run xsltproc on each xml.in file and exit with non-zero if any sorting fails
	@RES=0; for f in $(XMLINFILES); do \
		xsltproc --novalid -o $$f comps-cleanup.xsl $$f; \
		RES=$$(($$RES + $$?)); \
	done; exit $$RES

%.xml: %.xml.in
	@xmllint --noout $<
	@if test ".$(CLEANUP)" == .yes; then xsltproc --novalid -o $< comps-cleanup.xsl $<; fi
	./update-comps $@

# Add an easy alias to generate a rawhide comps file
comps-rawhide.xml comps-rawhide: comps-f35.xml
	@mv comps-f35.xml comps-rawhide.xml
