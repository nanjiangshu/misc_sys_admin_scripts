#!/bin/bash

date=`date`
echo " ========================================="
echo " Update ubuntu. Date: $date"
echo " ========================================="
sudo apt-get update && sudo apt-get upgrade -y && sudo apt --fix-broken install
