#!/bin/bash

. ./lib.sh

color_print "Start services"
service apache2 start
service mysql start
