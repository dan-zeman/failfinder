PREFIX=sample
MERGED=_$(PREFIX)_merged.txt
A=MOSES
B=TECTOMT
FROM=1
TO=3
LIMIT=10

define HELP_MESSAGE
# To generate all files and see the final html in your browser just run:
make view_html
# Alternatively, if you have ANSI terminal (for colored output):
make view_ansi
#
# You can specify with parameters:
# A = name of the first system (output)
# B = name of the second system (output)
# n-grams statistics are generated for n = FROM .. TO
# and at most LIMIT top ngrams are shown for each category
# So you can run for example:
make view_html A=MOSES B=GOOGLE TO=2 LIMIT=15
#
# To delete all generated files (whose name starts with underline):
make clean
endef
export HELP_MESSAGE

help:
	@echo "$$HELP_MESSAGE" | egrep --color '^(make.*|)'

merge: $(MERGED)
$(MERGED): merge_src_ref_tst.pl $(PREFIX)_source.gz $(PREFIX)_reference.gz $(PREFIX)_$(A).gz $(PREFIX)_$(B).gz
	./merge_src_ref_tst.pl src=$(PREFIX)_source.gz ref=$(PREFIX)_reference.gz $(A)=$(PREFIX)_$(A).gz $(B)=$(PREFIX)_$(B).gz > $@

_sentences.raw: sentence_compute.pl $(MERGED)
	./sentence_compute.pl < $(MERGED) > $@

_sentences.sorted: _sentences.raw sentence_sort.pl
	./sentence_sort.pl < _sentences.raw > $@

_ngrams.raw: ngram_compute.pl $(MERGED)
	./ngram_compute.pl --from=$(FROM) --to=$(TO) --limit=$(LIMIT) < $(MERGED) > $@

_output.html: _sentences.sorted _ngrams.raw to_html.pl header_template.html
	cat _sentences.sorted | ./to_html.pl --ngrams=_ngrams.raw > $@

view_html: _output.html
	firefox $<

view_ansi: _sentences.sorted to_ansi.pl
	./to_ansi.pl < _sentences.sorted | less -R

clean:
	rm _*
