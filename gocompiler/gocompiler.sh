 #!/bin/bash

 SRC="/data/junc/golang/compiler"
 DST="/usr/local"

 remove(){
     rm /usr/local/go -rf
 }

 complier_switch(){
     go version

     case $1 in
         "11")
             remove
             tar xf $SRC/go1.11.5.linux-amd64.tar.gz -C $DST
         ;;
         "14")
             remove
             tar xf $SRC/go1.14.4.linux-amd64.tar.gz -C $DST
         ;;
         "18")
             remove
             tar xf $SRC/go1.18.2.linux-amd64.tar.gz -C $DST
         ;;
         "19")
             remove
             tar xf $SRC/go1.19.5.linux-amd64.tar.gz -C $DST
         ;;
     esac

     go version
 }
 
 complier_switch $@
