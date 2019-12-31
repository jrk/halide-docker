# Learn from LLVM builder model: https://github.com/llvm/llvm-project/blob/master/llvm/utils/docker/debian8/Dockerfile
# Stage 1: make builder
FROM ubuntu:16.04 AS halide-builder

RUN apt update && apt install -y --no-install-recommends \
           ca-certificates build-essential python wget git unzip \
           cmake clang-6.0 ninja-build

RUN cd /tmp && git clone https://github.com/llvm/llvm-project.git && \
    cd llvm-project && git checkout release/9.x

RUN mkdir -p /tmp/llvm-build /tmp/llvm-inst && cd /tmp/llvm-build && \
    CC=clang-6.0 CXX=clang++-6.0 cmake -GNinja -DCMAKE_INSTALL_PREFIX=/tmp/llvm-inst -DLLVM_ENABLE_PROJECTS="clang;lld" -DLLVM_ENABLE_RTTI=ON -DLLVM_ENABLE_TERMINFO=OFF -DLLVM_TARGETS_TO_BUILD="X86;ARM;NVPTX;AArch64;Mips;PowerPC" -DLLVM_ENABLE_ASSERTIONS=ON -DCMAKE_BUILD_TYPE=Release -DLLVM_BUILD_32_BITS=OFF ../llvm-project/llvm

RUN cd /tmp/llvm-build && ninja && ninja install

# Stage 2: Produce a minimal release image with build results
