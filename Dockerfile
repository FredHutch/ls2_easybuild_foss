FROM fredhutch/ls2_easybuild:3.5.0

ENV DEBIAN_FRONTEND noninteractive

# OS Packages
#   libibverbs is required by OpenMPI
#   openssl-dev is required by many easyconfigs
USER root
RUN apt-get update && apt-get install -y \
    libibverbs-dev

# Build a toolchain
# be root to install then remove build-essential around toolchain build
# this provides the 'dummy' toolchain needed for toolchain building
# restated EB dependencies: libc6-dev, unzip, bzip2, xz-utils
ENV EB_TOOLCHAIN=foss-2016b
RUN apt-get install -y build-essential && \
    su -c "source /app/lmod/lmod/init/bash && \
           module use /app/modules/all && \
           module load EasyBuild && \
           eb -l ${EB_TOOLCHAIN}.eb --robot" - neo && \
    apt-get remove -y --purge build-essential && \
    apt-get autoremove -y && \
    apt-get install -y \
        libc6-dev \
        bzip2 \
        make \
        unzip \
        xz-utils

USER neo
