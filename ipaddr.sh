#!/bin/bash
#normal ip addr command using grep to search for my IP, then using pipe to 
#seperate the two i use awk which  prints the second field of the  line. 
ip addr | grep '192\.168\.50\.199/24' | awk '{print $2}'
