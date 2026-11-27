# 툴체인 컨테이너: clang/LLVM(MC/DC 커버리지), CppCheck, lizard, PICT, CMake
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates curl gnupg wget lsb-release software-properties-common \
        git make cmake ninja-build cppcheck cloc python3 python3-pip pipx \
        build-essential g++ \
    && rm -rf /var/lib/apt/lists/*

# LLVM 19 (clang, llvm-cov, llvm-profdata; -fcoverage-mcdc는 18 이상)
RUN wget -qO- https://apt.llvm.org/llvm.sh | bash -s -- 19 \
    && apt-get install -y --no-install-recommends clang-tools-19 llvm-19 \
    && for t in clang clang++ llvm-cov llvm-profdata; do \
         ln -sf /usr/bin/${t}-19 /usr/local/bin/${t}; done \
    && rm -rf /var/lib/apt/lists/*

# 순환 복잡도 측정
RUN pipx install lizard && ln -sf /root/.local/bin/lizard /usr/local/bin/lizard

# PICT (페어와이즈 조합 생성, https://github.com/microsoft/pict)
RUN git clone --depth 1 https://github.com/microsoft/pict.git /tmp/pict \
    && make -C /tmp/pict \
    && install /tmp/pict/pict /usr/local/bin/pict \
    && rm -rf /tmp/pict

WORKDIR /work
