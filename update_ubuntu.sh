#!/bin/bash

date=`date`
echo " ========================================="
echo " Update ubuntu. Date: $date"
echo " ========================================="
apt-get update && sudo apt-get upgrade -y
