# TODO: should probably make standard variants based on a more recent base OS?

# Learn from LLVM builder model: https://github.com/llvm/llvm-project/blob/master/llvm/utils/docker/debian8/Dockerfile
# Stage 1: make builder
FROM ubuntu:16.04 AS llvm-builder

RUN apt update && apt install -y --no-install-recommends \
           ca-certificates build-essential python wget git unzip \
           cmake clang-6.0 ninja-build zlib1g-dev

RUN cd /tmp && git clone https://github.com/llvm/llvm-project.git && \
    cd llvm-project && git checkout release/9.x

RUN mkdir -p /tmp/llvm-build /tmp/llvm-inst && cd /tmp/llvm-build && \
    CC=clang-6.0 CXX=clang++-6.0 cmake -GNinja -DCMAKE_INSTALL_PREFIX=/tmp/llvm-inst -DLLVM_ENABLE_PROJECTS="clang;lld" -DLLVM_ENABLE_RTTI=ON -DLLVM_ENABLE_TERMINFO=OFF -DLLVM_TARGETS_TO_BUILD="X86;ARM;NVPTX;AArch64;Mips;PowerPC" -DLLVM_ENABLE_ASSERTIONS=ON -DCMAKE_BUILD_TYPE=Release -DLLVM_BUILD_32_BITS=OFF ../llvm-project/llvm

RUN cd /tmp/llvm-build && ninja && ninja install
# && cd / && rm -rf /tmp/llvm-build

# Stage 2: Produce a minimal release image with build results
FROM ubuntu:16.04
#LABEL maintainer "LLVM Developers"
## Install packages for minimal useful image.
RUN apt update && apt install -y --no-install-recommends \
           ca-certificates build-essential git zlib1g-dev
#    rm -rf /var/lib/apt/lists/*
## Copy build results of stage 1 to /usr/local.
COPY --from=llvm-builder /tmp/llvm-inst/ /usr/local/

# Halide builder:
# cd /tmp && git clone https://github.com/halide/Halide.git && cd Halide
# mkdir -p /tmp/halide-build && cd /tmp/halide-build && CC=clang CXX=clang++ make -j -f ../Halide/Makefile