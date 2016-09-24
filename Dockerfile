FROM debian:jessie

COPY . /go/src/github.com/bobrik/collectd-docker

#RUN /go/src/github.com/bobrik/collectd-docker/docker/build.sh


RUN groupadd -g 99 nobody &&\
    usermod -u 99 -g 99 nobody 

RUN echo "APT::Install-Recommends              false;" >> /etc/apt/apt.conf.d/recommends.conf \
    && echo "APT::Install-Suggests                false;" >> /etc/apt/apt.conf.d/recommends.conf \
    && echo "APT::AutoRemove::RecommendsImportant false;" >> /etc/apt/apt.conf.d/recommends.conf \
    && echo "APT::AutoRemove::SuggestsImportant   false;" >> /etc/apt/apt.conf.d/recommends.conf

RUN apt-get update -qqy \
    && apt-get install -qqy git curl ca-certificates make wget unzip \
    && wget --no-check-certificate https://repo.percona.com/apt/percona-release_0.1-4.jessie_all.deb \
    && dpkg -i percona-release_0.1-4.jessie_all.deb \
    && apt-get update -qqy \
    && apt-get install percona-server-client-5.6 -qqy


WORKDIR /tmp
RUN apt-get update && apt-get install -y \
      autoconf \
      automake \
      autotools-dev \
      bison \
      build-essential \
      curl \
      flex \
      git \
      iptables-dev \
      libcurl4-gnutls-dev \
      libdbi0-dev \
      libesmtp-dev \
      libganglia1-dev \
      libgcrypt11-dev \
      libglib2.0-dev \
      libhiredis-dev \
      libltdl-dev \
      liblvm2-dev \
      libmemcached-dev \
      libmnl-dev \
      libmodbus-dev \
      libopenipmi-dev \
      liboping-dev \
      libow-dev \
      libpcap-dev \
      libperl-dev \
      libpq-dev \
      libperconaserverclient18.1-dev \
      libprotobuf-c-dev \
      librabbitmq-dev \
      librrd-dev \
      libsensors4-dev \
      libsnmp-dev \
      libtokyocabinet-dev \
      libtokyotyrant-dev \
      libtool \
      libupsclient-dev \
      libvirt-dev \
      libxml2-dev \
      libyajl-dev \
      linux-libc-dev \
      pkg-config \
      protobuf-c-compiler \
      python-dev && \
      rm -rf /usr/share/doc/* && \
      rm -rf /usr/share/info/* && \
      rm -rf /tmp/* && \
      rm -rf /var/tmp/*

WORKDIR /usr/src
RUN wget --no-check-certificate https://github.com/xinity/collectdng/archive/master.zip \
    && unzip master.zip
WORKDIR /usr/src/collectdng-master
RUN ./build.sh
RUN ./configure \
    --prefix=/usr \
    --sysconfdir=/etc/collectd \
    --without-libstatgrab \
    --without-included-ltdl \
    --disable-static
RUN make all
RUN make install
RUN make clean

RUN export GOLANG_VERSION="1.6" \
    && export GOLANG_DOWNLOAD_URL="https://golang.org/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz" \
    && export GOLANG_DOWNLOAD_SHA256="5470eac05d273c74ff8bac7bef5bad0b5abbd1c4052efbdbc8db45332e836b0b" \
    && export GOLANG_DOWNLOAD_DESTINATION="/tmp/go${GOLANG_VERSION}.linux-amd64.tar.gz" \
    && curl -sL "${GOLANG_DOWNLOAD_URL}" > "${GOLANG_DOWNLOAD_DESTINATION}" \
    && echo "${GOLANG_DOWNLOAD_SHA256}  ${GOLANG_DOWNLOAD_DESTINATION}" | sha256sum -c \
    && tar -C /usr/local -xzf "${GOLANG_DOWNLOAD_DESTINATION}" \
    && rm "${GOLANG_DOWNLOAD_DESTINATION}" \
    && export GOPATH="/go" \
    && export PATH="${GOPATH}/bin:/usr/local/go/bin:${PATH}" \
    && go get github.com/docker-infra/reefer \
    && go get github.com/tools/godep \
    && cd /go/src/github.com/bobrik/collectd-docker/collector \
    && godep restore \
    && go get github.com/bobrik/collectd-docker/collector/... \
    && cd / \
    && cp /go/bin/collectd-docker-collector /usr/bin/collectd-docker-collector \
    && cp /go/bin/reefer /usr/bin/reefer 

COPY docker/collectd.conf.tpl /etc/collectd/collectd.conf.tpl
COPY docker/run.sh /run.sh

RUN apt-get remove -y git ca-certificates \
    && apt-get autoremove -y

RUN rm -rf /go /usr/local/go \
    && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/run.sh"]
