# manylinux2010-based image for compiling Spatial Model Editor python wheels

FROM quay.io/pypa/manylinux2010_x86_64:2020-03-07-1825e8f as builder
MAINTAINER Liam Keegan "liam@keegan.ch"

ARG NPROCS=2
ARG BUILD_DIR=/opt/smelibs
ARG TMP_DIR=/opt/tmpwd

RUN yum install -q -y \
    subversion \
    zlib-devel

RUN /opt/python/cp38-cp38/bin/pip install \
    cmake \
    &&  ln -fs /opt/python/cp38-cp38/bin/cmake /usr/bin/cmake

ARG GMP_VERSION="6.1.2"
RUN mkdir -p $TMP_DIR && cd $TMP_DIR \
    && curl \
        https://gmplib.org/download/gmp/gmp-${GMP_VERSION}.tar.bz2 \
        --output gmp.tar.bz2 \
    && tar xjf gmp.tar.bz2 \
    && cd gmp-${GMP_VERSION} \
    && ./configure \
        --prefix=$BUILD_DIR \
        --disable-shared \
        --disable-assembly \
        --enable-static \
        --with-pic \
        --enable-cxx \
    && make -j$NPROCS \
    && make check \
    && make install \
    && rm -rf $TMP_DIR

ARG LIBEXPAT_VERSION="R_2_2_9"
RUN mkdir -p $TMP_DIR && cd $TMP_DIR \
    && git clone \
        -b $LIBEXPAT_VERSION \
        --depth=1 \
        https://github.com/libexpat/libexpat.git \
    && cd libexpat \
    && mkdir build \
    && cd build \
    && cmake \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=OFF \
        -DCMAKE_C_FLAGS="-fpic -fvisibility=hidden" \
        -DCMAKE_CXX_FLAGS="-fpic -fvisibility=hidden" \
        -DCMAKE_INSTALL_PREFIX=$BUILD_DIR \
        -DEXPAT_BUILD_DOCS=OFF \
        -DEXPAT_BUILD_EXAMPLES=OFF \
        -DEXPAT_BUILD_TOOLS=OFF \
        -DEXPAT_SHARED_LIBS=OFF \
        ../expat \
    && make -j$NPROCS \
    && make test \
    && make install \
    && rm -rf $TMP_DIR

ARG LIBTIFF_VERSION="v4.0.10"
RUN mkdir -p $TMP_DIR && cd $TMP_DIR \
    && git clone \
        -b $LIBTIFF_VERSION \
        --depth=1 \
        https://gitlab.com/libtiff/libtiff.git \
    && cd libtiff \
    && mkdir cmake-build \
    && cd cmake-build \
    && cmake \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=OFF \
        -DCMAKE_C_FLAGS="-fpic -fvisibility=hidden" \
        -DCMAKE_CXX_FLAGS="-fpic -fvisibility=hidden" \
        -DCMAKE_INSTALL_PREFIX=$BUILD_DIR \
        -Djpeg=OFF \
        -Djpeg12=OFF \
        -Djbig=OFF \
        -Dlzma=OFF \
        -Dpixarlog=OFF \
        -Dold-jpeg=OFF \
        -Dzstd=OFF \
        -Dmdi=OFF \
        -Dwebp=OFF \
        -Dzlib=OFF \
        .. \
    && make -j$NPROCS \
    && make test \
    && make install \
    && rm -rf $TMP_DIR

ARG LLVM_VERSION="9.0.1"
RUN mkdir -p $TMP_DIR && cd $TMP_DIR \
    && git clone \
        -b llvmorg-$LLVM_VERSION \
        --depth=1 \
        https://github.com/llvm/llvm-project.git \
    && cd llvm-project/llvm \
    && mkdir build \
    && cd build \
    && cmake \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=$BUILD_DIR \
        -DPYTHON_EXECUTABLE:FILEPATH=/opt/python/cp38-cp38/bin/python \
        -DLLVM_DEFAULT_TARGET_TRIPLE=x86_64-unknown-linux-gnu \
        -DLLVM_TARGETS_TO_BUILD="X86" \
        -DLLVM_BUILD_TOOLS=OFF \
        -DLLVM_INCLUDE_TOOLS=OFF \
        -DLLVM_BUILD_EXAMPLES=OFF \
        -DLLVM_INCLUDE_EXAMPLES=OFF \
        -DLLVM_BUILD_TESTS=OFF \
        -DLLVM_INCLUDE_TESTS=OFF \
        -DLLVM_INCLUDE_DOCS=OFF \
        -DLLVM_BUILD_UTILS=OFF \
        -DLLVM_INCLUDE_UTILS=OFF \
        -DLLVM_INCLUDE_GO_TESTS=OFF \
        -DLLVM_BUILD_BENCHMARKS=OFF \
        -DLLVM_INCLUDE_BENCHMARKS=OFF \
        -DLLVM_ENABLE_LIBPFM=OFF \
        -DLLVM_ENABLE_ZLIB=OFF \
        -DLLVM_ENABLE_DIA_SDK=OFF \
        -DLLVM_BUILD_INSTRUMENTED_COVERAGE=OFF \
        -DLLVM_ENABLE_BINDINGS=OFF \
        -DLLVM_ENABLE_RTTI=ON \
        -DLLVM_ENABLE_TERMINFO=OFF \
        -DLLVM_ENABLE_LIBXML2=OFF \
        -DLLVM_ENABLE_WARNINGS=OFF \
        -DLLVM_POLLY_BUILD=OFF \
        -DLLVM_POLLY_LINK_INTO_TOOLS=OFF \
        .. \
    && make -j$NPROCS \
    && make install \
    && rm -rf $TMP_DIR

ARG TBB_VERSION="v2020.1"
RUN mkdir -p $TMP_DIR && cd $TMP_DIR \
    && git clone \
        -b $TBB_VERSION \
        --depth=1 \
        https://github.com/intel/tbb.git \
    && cd tbb \
    && make tbb \
        stdver=c++17 \
        extra_inc=big_iron.inc \
        -j$NPROCS \
    && mkdir -p $BUILD_DIR/lib \
    && cp build/*_release/*.a $BUILD_DIR/lib \
    && mkdir -p $BUILD_DIR/include \
    && cp -r include/tbb $BUILD_DIR/include/. \
    && rm -rf $TMP_DIR

ARG MUPARSER_VERSION="v2.2.6.1"
RUN mkdir -p $TMP_DIR && cd $TMP_DIR \
    && git clone \
        -b $MUPARSER_VERSION \
        --depth=1 \
        https://github.com/beltoforion/muparser.git \
    && cd muparser \
    && mkdir cmake-build \
    && cd cmake-build \
    && cmake \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=OFF \
        -DCMAKE_C_FLAGS="-fpic -fvisibility=hidden" \
        -DCMAKE_CXX_FLAGS="-fpic -fvisibility=hidden" \
        -DCMAKE_INSTALL_PREFIX=$BUILD_DIR \
        -DBUILD_TESTING=ON \
        -DENABLE_OPENMP=OFF \
        -DENABLE_SAMPLES=OFF \
        .. \
    && make -j$NPROCS \
    && make test \
    && make install \
    && rm -rf $TMP_DIR

ARG QT5_VERSION="v5.14.1"
RUN mkdir -p $TMP_DIR && cd $TMP_DIR \
    && git clone \
        https://code.qt.io/qt/qt5.git \
    && cd qt5 \
    && git checkout $QT5_VERSION \
    && git submodule update --init qtbase \
    && cd .. \
    && mkdir build \
    && cd build \
    && ../qt5/qtbase/configure \
        -opensource \
        -confirm-license \
        -prefix $BUILD_DIR \
        -release \
        -static \
        -silent \
        -no-xcb \
        -sql-sqlite \
        -qt-zlib \
        -qt-libjpeg \
        -qt-libpng \
        -qt-pcre \
        -qt-harfbuzz \
        -no-compile-examples \
        -nomake tests \
        -nomake examples \
        -no-opengl \
        -no-openssl \
        -no-sql-odbc \
        -no-icu \
        -no-feature-concurrent \
        -no-feature-xml \
        -feature-testlib \
    && make -j$NPROCS \
    && make install \
    && rm -rf $TMP_DIR

ARG FMT_VERSION="6.1.2"
RUN mkdir -p $TMP_DIR && cd $TMP_DIR \
    && git clone \
        -b $FMT_VERSION \
        --depth=1 \
        https://github.com/fmtlib/fmt.git \
    && cd fmt \
    && mkdir build \
    && cd build \
    && cmake \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=OFF \
        -DCMAKE_C_FLAGS="-fpic -fvisibility=hidden" \
        -DCMAKE_CXX_FLAGS="-fpic -fvisibility=hidden" \
        -DCMAKE_INSTALL_PREFIX=$BUILD_DIR \
        -DCMAKE_CXX_STANDARD=17 \
        -DFMT_DOC=OFF \
        .. \
    && make -j$NPROCS \
    && make test \
    && make install \
    && rm -rf $TMP_DIR

ARG SPDLOG_VERSION="v1.5.0"
RUN mkdir -p $TMP_DIR && cd $TMP_DIR \
    && git clone \
        -b $SPDLOG_VERSION \
        --depth=1 \
        https://github.com/gabime/spdlog.git \
    && cd spdlog \
    && mkdir cmake-build \
    && cd cmake-build \
    && cmake \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=OFF \
        -DCMAKE_C_FLAGS="-fpic -fvisibility=hidden" \
        -DCMAKE_CXX_FLAGS="-fpic -fvisibility=hidden" \
        -DCMAKE_INSTALL_PREFIX=$BUILD_DIR \
        -DSPDLOG_BUILD_TESTS=ON \
        -DSPDLOG_BUILD_EXAMPLE=OFF \
        -DSPDLOG_FMT_EXTERNAL=ON \
        -DSPDLOG_NO_THREAD_ID=ON \
        -DSPDLOG_NO_ATOMIC_LEVELS=ON \
        -DCMAKE_PREFIX_PATH=$BUILD_DIR \
        .. \
    && make -j$NPROCS \
    && make test \
    && make install \
    && rm -rf $TMP_DIR

ARG SYMENGINE_VERSION="v0.6.0"
RUN mkdir -p $TMP_DIR && cd $TMP_DIR \
    && git clone \
        -b $SYMENGINE_VERSION \
        --depth=1 \
        https://github.com/symengine/symengine.git \
    && cd symengine \
    && mkdir build \
    && cd build \
    && cmake \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=OFF \
        -DCMAKE_C_FLAGS="-fpic -fvisibility=hidden" \
        -DCMAKE_CXX_FLAGS="-fpic -fvisibility=hidden" \
        -DCMAKE_INSTALL_PREFIX=$BUILD_DIR \
        -DBUILD_BENCHMARKS=OFF \
        -DGMP_INCLUDE_DIR=$BUILD_DIR/include \
        -DGMP_LIBRARY=$BUILD_DIR/lib/libgmp.a \
        -DCMAKE_PREFIX_PATH=$BUILD_DIR \
        -DWITH_LLVM=ON \
        -DWITH_COTIRE=OFF \
        -DWITH_SYMENGINE_THREAD_SAFE=OFF \
        .. \
    && make -j$NPROCS \
    && make test \
    && make install \
    && rm -rf $TMP_DIR

ARG DUNE_COPASI_VERSION="v0.2.0"
RUN mkdir -p $TMP_DIR && cd $TMP_DIR \
    && echo 'CMAKE_FLAGS=" -G '"'"'Unix Makefiles'"'"'"' > opts.txt \
    && echo 'CMAKE_FLAGS+=" -DCMAKE_CXX_STANDARD=17 "' >> opts.txt \
    && echo 'CMAKE_FLAGS+=" -DCMAKE_BUILD_TYPE=Release "' >> opts.txt \
    && echo 'CMAKE_FLAGS+=" -DCMAKE_INSTALL_PREFIX='"$BUILD_DIR"' "' >> opts.txt \
    && echo 'CMAKE_FLAGS+=" -DGMPXX_INCLUDE_DIR:PATH='"$BUILD_DIR"'/include "' >> opts.txt \
    && echo 'CMAKE_FLAGS+=" -DGMPXX_LIB:FILEPATH='"$BUILD_DIR"'/lib/libgmpxx.a "' >> opts.txt \
    && echo 'CMAKE_FLAGS+=" -DGMP_LIB:FILEPATH='"$BUILD_DIR"'/lib/libgmp.a "' >> opts.txt \
    && echo 'CMAKE_FLAGS+=" -DCMAKE_PREFIX_PATH='"$BUILD_DIR"' "' >> opts.txt \
    && echo 'CMAKE_FLAGS+=" -Dfmt_ROOT='"$BUILD_DIR"' "' >> opts.txt \
    && echo 'CMAKE_FLAGS+=" -DDUNE_PYTHON_VIRTUALENV_SETUP=0 -DDUNE_PYTHON_ALLOW_GET_PIP=0 "' >> opts.txt \
    && echo 'CMAKE_FLAGS+=" -DCMAKE_DISABLE_FIND_PACKAGE_QuadMath=TRUE -DBUILD_TESTING=OFF "' >> opts.txt \
    && echo 'CMAKE_FLAGS+=" -DDUNE_USE_ONLY_STATIC_LIBS=ON -DF77=true"' >> opts.txt \
    && echo 'CMAKE_FLAGS+=" -DDUNE_COPASI_SD_EXECUTABLE=ON"' >> opts.txt \
    && echo 'CMAKE_FLAGS+=" -DDUNE_COPASI_MD_EXECUTABLE=ON"' >> opts.txt \
    && echo 'CMAKE_FLAGS+=" -DCMAKE_CXX_FLAGS='"'"'-fvisibility=hidden -fpic -static-libstdc++'"'"' "' >> opts.txt \
    && echo 'MAKE_FLAGS="-j'"$NPROCS"' VERBOSE=1"' >> opts.txt \
    && export DUNE_OPTIONS_FILE="opts.txt" \
    && export DUNECONTROL=./dune-common/bin/dunecontrol \
    && git clone \
        -b ${DUNE_COPASI_VERSION}  \
        --depth 1 \
        --recursive \
        https://gitlab.dune-project.org/copasi/dune-copasi.git \
    && bash dune-copasi/.ci/setup.sh \
    && rm -rf dune-testtools \
    && bash dune-copasi/.ci/build.sh \
    && $DUNECONTROL make install \
    && rm -rf $TMP_DIR

ARG LIBSBML_REVISION="26285"
RUN mkdir -p $TMP_DIR && cd $TMP_DIR \
    && svn \
        -q \
        co https://svn.code.sf.net/p/sbml/code/branches/libsbml-experimental@$LIBSBML_REVISION \
    && cd libsbml-experimental \
    && mkdir build \
    && cd build \
    && cmake \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=OFF \
        -DCMAKE_C_FLAGS="-fpic -fvisibility=hidden" \
        -DCMAKE_CXX_FLAGS="-fpic -fvisibility=hidden" \
        -DCMAKE_INSTALL_PREFIX=$BUILD_DIR \
        -DENABLE_SPATIAL=ON \
        -DWITH_CPP_NAMESPACE=ON \
        -DLIBSBML_SKIP_SHARED_LIBRARY=ON \
        -DWITH_BZIP2=OFF \
        -DWITH_ZLIB=OFF \
        -DWITH_SWIG=OFF \
        -DWITH_LIBXML=OFF \
        -DWITH_EXPAT=ON \
        -DLIBEXPAT_INCLUDE_DIR=$BUILD_DIR/include \
        -DLIBEXPAT_LIBRARY=$BUILD_DIR/lib64/libexpat.a \
        .. \
    && make -j$NPROCS \
    && make install \
    && rm -rf $TMP_DIR

FROM quay.io/pypa/manylinux2010_x86_64:2020-03-07-1825e8f

ARG BUILD_DIR=/opt/smelibs

# Install cmake and ccache
RUN /opt/python/cp38-cp38/bin/pip install \
        cmake \
    && ln -fs /opt/python/cp38-cp38/bin/cmake /usr/bin/cmake \
    && yum install -q -y \
        ccache

# Setup ccache
ENV CCACHE_DIR=/tmp/ccache
ENV CCACHE_BASEDIR=/tmp
ENV CMAKE_CXX_COMPILER_LAUNCHER="ccache"

# SME static libs
COPY --from=builder $BUILD_DIR $BUILD_DIR
ENV CMAKE_PREFIX_PATH="$BUILD_DIR;$BUILD_DIR/lib64/cmake"

# PyPy binaries/headers
COPY --from=pypywheels/manylinux2010-pypy_x86_64 /opt/pypy /opt/pypy