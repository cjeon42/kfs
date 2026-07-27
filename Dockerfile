FROM ubuntu:22.04

RUN apt update && apt install -y \
    curl                         \
    gcc-i686-linux-gnu           \
    build-essential              \
    xorriso                      \
    grub-pc                      \
    nasm                         \
    guestfish                    \
    linux-image-generic

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
