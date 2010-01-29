INPUT_FILE=sample.txt

all: compare

compare:
	cat sample.txt | ./sentence_compute.pl | ./sentence_sort.pl | ./sentence_html.pl > sample.html
	firefox sample.html

    
