#!/bin/sh
export PATH=/Applications/MATLAB\_R2018b.app/bin/:$PATH
make
matlab -nodisplay -nosplash -nodesktop -r "run('identify_rectangle.m');exit;" && ./main_exe temp/post_processed.png && python3 textTranslated.py
