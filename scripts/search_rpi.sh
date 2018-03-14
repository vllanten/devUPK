#!/bin/bash


sudo nmap -sP $1/24 | awk '/^Nmap/{ip=$NF}/B8:27:EB/{print ip}'

