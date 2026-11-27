# ClaudeCLangBuild: 개발 빌드와 CI 빌드가 공유하는 툴체인 이미지 (모든 도구는 최신 릴리스로 고정)
# Docker 이미지 이름은 소문자여야 하므로 태그는 claudeclangbuild
FROM ubuntu:26.04

# 버전은 한곳에서 관리한다. 올릴 때는 이 값만 바꾼다.
ARG LLVM_VERSION=23
ARG CMAKE_VERSION=4.5.1
ARG CPPCHECK_VERSION=2.22.0
ARG DOXYGEN_VERSION=1.18.0
ARG GTEST_VERSION=1.18.0
ARG CLOC_VERSION=2.12
ARG PICT_VERSION=3.7.4
ARG LIZARD_VERSION=1.26.1

ENV DEBIAN_FRONTEND=noninteractive
# 미러의 일시적 오류에 대비해 apt 재시도
RUN echo 'Acquire::Retries "5";' > /etc/apt/apt.conf.d/80retries
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates curl wget gnupg lsb-release software-properties-common \
        git make build-essential perl pkg-config python3 python3-pip pipx \
        graphviz \
    && rm -rf /var/lib/apt/lists/*

# LLVM (clang, clang-format, llvm-cov, llvm-profdata; -fcoverage-mcdc 지원)
RUN wget -qO /tmp/llvm.sh https://apt.llvm.org/llvm.sh && bash /tmp/llvm.sh ${LLVM_VERSION} \
    && apt-get install -y --no-install-recommends clang-format-${LLVM_VERSION} clang-tools-${LLVM_VERSION} llvm-${LLVM_VERSION} \
    && for t in clang clang++ clang-format llvm-cov llvm-profdata; do \
         ln -sf /usr/bin/${t}-${LLVM_VERSION} /usr/local/bin/${t}; done \
    && rm -rf /var/lib/apt/lists/* /tmp/llvm.sh

# CMake (Kitware 공식 바이너리) + Ninja (PyPI)
RUN curl -fsSL https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-linux-x86_64.tar.gz \
      | tar -xz -C /opt && ln -sf /opt/cmake-${CMAKE_VERSION}-linux-x86_64/bin/* /usr/local/bin/
ENV PIPX_HOME=/opt/pipx PIPX_BIN_DIR=/usr/local/bin
RUN pipx install ninja && pipx install lizard==${LIZARD_VERSION}

# CppCheck (소스 빌드)
RUN curl -fsSL https://github.com/cppcheck-opensource/cppcheck/archive/refs/tags/${CPPCHECK_VERSION}.tar.gz | tar -xz -C /tmp \
    && cmake -S /tmp/cppcheck-${CPPCHECK_VERSION} -B /tmp/cppcheck-build -G Ninja -DCMAKE_BUILD_TYPE=Release \
         -DUSE_MATCHCOMPILER=ON -DCMAKE_INSTALL_PREFIX=/usr/local \
    && cmake --build /tmp/cppcheck-build && cmake --install /tmp/cppcheck-build \
    && rm -rf /tmp/cppcheck-*

# GoogleTest / GMock (소스 빌드, clang으로)
RUN curl -fsSL https://github.com/google/googletest/archive/refs/tags/v${GTEST_VERSION}.tar.gz | tar -xz -C /tmp \
    && cmake -S /tmp/googletest-${GTEST_VERSION} -B /tmp/gtest-build -G Ninja -DCMAKE_BUILD_TYPE=Release \
         -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_INSTALL_PREFIX=/usr/local \
    && cmake --build /tmp/gtest-build && cmake --install /tmp/gtest-build \
    && rm -rf /tmp/googletest-* /tmp/gtest-build

# Doxygen (공식 바이너리), CLOC (단일 스크립트)
RUN curl -fsSL https://github.com/doxygen/doxygen/releases/download/Release_$(echo ${DOXYGEN_VERSION} | tr . _)/doxygen-${DOXYGEN_VERSION}.linux.bin.tar.gz \
      | tar -xz -C /opt && ln -sf /opt/doxygen-${DOXYGEN_VERSION}/bin/doxygen /usr/local/bin/doxygen
RUN curl -fsSL -o /usr/local/bin/cloc https://github.com/AlDanial/cloc/releases/download/v${CLOC_VERSION}/cloc-${CLOC_VERSION}.pl \
    && chmod +x /usr/local/bin/cloc

# PICT (페어와이즈 조합 생성, 소스 빌드)
RUN curl -fsSL https://github.com/microsoft/pict/archive/refs/tags/v${PICT_VERSION}.tar.gz | tar -xz -C /tmp \
    && make -C /tmp/pict-${PICT_VERSION} && install /tmp/pict-${PICT_VERSION}/pict /usr/local/bin/pict \
    && rm -rf /tmp/pict-*

ENV CC=clang CXX=clang++
WORKDIR /work
