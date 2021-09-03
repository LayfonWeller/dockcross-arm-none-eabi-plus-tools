FROM dockcross/base:latest

ENV XCC_PREFIX /usr/xcc
ENV CROSS_TRIPLE arm-none-eabi
ENV CROSS_ROOT ${XCC_PREFIX}/${CROSS_TRIPLE}-cross

ARG GCC_VERSION=gcc-arm-none-eabi-9-2020-q2-update
ARG LLVM_VERSION=11
ARG CPPCHECK_VERSION=2.4
ARG JLINK_VERSION=700

# Install Cppcheck
COPY cppcheck-${CPPCHECK_VERSION}.tar.bz2 cppcheck-${CPPCHECK_VERSION.tar.bz2
RUN tar -xvf cppcheck-${CPPCHECK_VERSION.tar.bz2 \
    && cd cppcheck-${CPPCHECK_VERSION && FILESDIR=/ make install -j \
    && cd .. && rm -rfv cppcheck-${CPPCHECK_VERSION.tar.bz2 cppcheck-${CPPCHECK_VERSION

# Install GCC ARM-NONE-EABI
COPY ${GCC_VERSION}-x86_64-linux.tar.bz2 ${GCC_VERSION}-x86_64-linux.tar.bz2
RUN mkdir ${XCC_PREFIX} \
    && tar -C ${XCC_PREFIX} -xvf ${GCC_VERSION}-x86_64-linux.tar.bz2  \
    && mv ${XCC_PREFIX}/${GCC_VERSION} ${CROSS_ROOT}  \
    && rm -rfv  ${GCC_VERSION}-x86_64-linux.tar.bz2


#install git-lfs doxygen graphviz ccache clang-format jlink
# DEVNOTE CLANG-libs might be require for cppcheck at some point, since cppcheck seem to be able to use clang-tidy; but not for now
COPY JLink_Linux_V${JLINK_VERSION}_x86_64.deb JLink_Linux_V${JLINK_VERSION_x86_64.deb
RUN apt-get update \
    && apt-get install --no-install-recommends --yes ninja-build python3 software-properties-common apt-transport-https ca-certificates git-lfs doxygen graphviz ccache ./JLink_Linux_V${JLINK_VERSION_x86_64.deb \
    && wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key|apt-key add -  \
    && apt-add-repository "deb http://apt.llvm.org/stretch/ llvm-toolchain-stretch-${LLVM_VERSION} main" \
    && apt-get update \
    && apt-get upgrade --no-install-recommends --yes \
    && apt-get install --no-install-recommends --yes clang-format-${LLVM_VERSION} \
    && rm -rfv ./JLink_Linux_V${JLINK_VERSION_x86_64.deb \
    && apt-get autoremove -y \
    && rm -rfv /var/lib/apt/lists/*


# TODO : Ideally a copy of clang working for arm-none-eabi would be appreciated


# TODO Has long has I haven't found out how to make clang-tidy/clang compiler work well with arm-none-eabi, this is not usefull
# # Install IWYU
# COPY include-what-you-use-0.15.src.tar.gz include-what-you-use-0.15.src.tar.gz
# RUN mkdir include-what-you-use/
# RUN mv include-what-you-use-0.15.src.tar.gz include-what-you-use/
# RUN apt-get install --no-install-recommends --yes llvm-${LLVM_VERSION}-dev libclang-${LLVM_VERSION}-dev clang-${LLVM_VERSION}
# RUN cd include-what-you-use/; tar -xf include-what-you-use-0.15.src.tar.gz; cd ..; mkdir build && cd build; cmake -G "Ninja" -DIWYU_LLVM_ROOT_OATH=/usr/lib/llvm-${LLVM_VERSION} ../include-what-you-use/; cmake --build . --target install
# RUN rm -rf include-what-you-use-0.15.src.tar.gz  include-what-you-use/ build
# RUN apt-get remove llvm-${LLVM_VERSION}-dev libclang-${LLVM_VERSION}-dev -y
# # ENV CMAKE_CXX_INCLUDE_WHAT_YOU_USE=""
# # ENV CMAKE_C_INCLUDE_WHAT_YOU_USE=""

COPY Toolchain.cmake ${CROSS_ROOT}/
ENV CMAKE_TOOLCHAIN_FILE ${CROSS_ROOT}/Toolchain.cmake

RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
    && echo $SNIPPET >> "/root/.bashrc"; \
    SNIPPET="export HOST_DOCKER_INTERNAL=`getent hosts host.docker.internal | awk '{ print $1 }'`" \
    && echo $SNIPPET >> "/root/.bashrc"


# ENV AS=${CROSS_ROOT}/bin/${CROSS_TRIPLE}-as \
#     AR=${CROSS_ROOT}/bin/${CROSS_TRIPLE}-ar \
#     CC=${CROSS_ROOT}/bin/${CROSS_TRIPLE}-gcc \
#     CPP=${CROSS_ROOT}/bin/${CROSS_TRIPLE}-cpp \
#     CXX=${CROSS_ROOT}/bin/${CROSS_TRIPLE}-g++ \
#     LD=${CROSS_ROOT}/bin/${CROSS_TRIPLE}-ld \
#     FC=${CROSS_ROOT}/bin/${CROSS_TRIPLE}-gfortran

ENV PATH ${PATH}:${CROSS_ROOT}/bin
ENV CROSS_COMPILE ${CROSS_TRIPLE}-
ENV ARCH arm

# Build-time metadata as defined at http://label-schema.org
ARG BUILD_DATE
ARG IMAGE=dockcross-arm-none-eabi-plus-tools
ARG VERSION=latest
ARG VCS_REF
ARG VCS_URL
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name=$IMAGE \
      org.label-schema.version=$VERSION \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url=$VCS_URL \
      org.label-schema.schema-version="1.0"
ENV DEFAULT_DOCKCROSS_IMAGE ${IMAGE}:${VERSION}
