#!/usr/bin/env bash

export IMAGES

declare -Ag IMAGES=(
  ["3.10"]=python:3.10-alpine
  ["3.10-bullseye"]=python:3.10-bullseye # latest
  ["3.10-slim"]=python:3.10-slim
  ["debian-backports"]=debian:bullseye-backports
  ["debian-slim"]=debian:bullseye-slim
  ["kali"]=kalilinux/kali-rolling
  ["kali-bleeding"]=kalilinux/kali-bleeding-edge
  ["zsh"]=zshusers/zsh
)
for i in alpine archlinux bash busybox centos debian fedora ubuntu; do
  IMAGES["${i}"]="${i}"
done
