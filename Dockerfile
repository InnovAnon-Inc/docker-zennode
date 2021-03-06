FROM innovanon/doom-base as builder-04
USER root
COPY --from=innovanon/zlib       /tmp/zlib.txz       /tmp/
COPY --from=innovanon/bzip2      /tmp/bzip2.txz      /tmp/
COPY --from=innovanon/xz         /tmp/xz.txz         /tmp/
COPY --from=innovanon/libpng     /tmp/libpng.txz     /tmp/
COPY --from=innovanon/jpeg-turbo /tmp/jpeg-turbo.txz /tmp/
COPY --from=innovanon/deutex     /tmp/deutex.txz     /tmp/
RUN extract.sh \
 && command -v                        deutex

FROM builder-04 as zennode
ARG LFS=/mnt/lfs
USER lfs
RUN sleep 31 \
 && command -v strip.sh                 \
 && git clone --depth=1 --recursive           \
      https://github.com/Doom-Utils/zennode.git \
 && cd                            zennode     \
 && sed -i                                    \
 -e 's/^DOCS=.*/DOCS=/'                       \
 -e '/	install -Dm 644 $(DOCS)/d'            \
 -e '/	for doc in $(DOCS)/d'                 \
 Makefile                                     \
 && make                                      \
 && make DESTDIR=/tmp/zennode install         \
 && cd           /tmp/zennode                 \
 && strip.sh .                                \
 && tar  pacf        ../zennode.txz .           \
 && rm -rf           $LFS/sources/zennode
      # TODO
#"${CONFIG_OPTS[@]}"                 \

FROM scratch as final
COPY --from=zennode /tmp/zennode.txz /tmp/

