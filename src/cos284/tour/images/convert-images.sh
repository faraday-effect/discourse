#!/usr/bin/env bash

for pdf_file in *.pdf
do
	stem=${pdf_file%%.*}
	jpg_file="$stem.jpg"
	cmd="convert -trim $pdf_file -quality 100 $jpg_file"
	echo $cmd
	$cmd
done
