# ClaudeCLangBuild: 개발 빌드와 CI 빌드가 공유하는 툴체인 이미지
# (Docker 이미지 이름은 소문자여야 하므로 태그는 claudeclangbuild)
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates curl gnupg wget lsb-release software-properties-common \
        git make cmake ninja-build cppcheck cloc doxygen clang-format \
        python3 python3-pip pipx build-essential libgtest-dev libgmock-dev \
    && rm -rf /var/lib/apt/lists/*

# LLVM 19 (clang, llvm-cov, llvm-profdata; -fcoverage-mcdc는 18 이상)
RUN wget -qO- https://apt.llvm.org/llvm.sh | bash -s -- 19 \
    && apt-get install -y --no-install-recommends clang-tools-19 llvm-19 \
    && for t in clang clang++ llvm-cov llvm-profdata; do \
         ln -sf /usr/bin/${t}-19 /usr/local/bin/${t}; done \
    && rm -rf /var/lib/apt/lists/*

# 순환복잡도·함수 라인 수 측정
ENV PIPX_HOME=/opt/pipx PIPX_BIN_DIR=/usr/local/bin
RUN pipx install lizard

# PICT (페어와이즈 조합 생성, https://github.com/microsoft/pict)
RUN git clone --depth 1 https://github.com/microsoft/pict.git /tmp/pict \
    && make -C /tmp/pict \
    && install /tmp/pict/pict /usr/local/bin/pict \
    && rm -rf /tmp/pict

ENV CC=clang CXX=clang++
WORKDIR /work
