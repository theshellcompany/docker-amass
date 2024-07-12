FROM debian:bookworm
LABEL maintainer="erik@theshell.company"

# environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV GOPATH /opt/amass
ENV PATH "$PATH:/usr/local/go/bin"
ENV GO_VERSION 1.22.4
ENV LANG C.UTF-8
ENV LANGUAGE C.UTF-8
ENV HOME /home/nonroot
ENV USER nonroot

# installation as root
USER root

RUN apt-get update -y && apt-get upgrade -y
RUN apt-get install -yq --no-install-recommends ca-certificates wget

# Installation of Go
WORKDIR /tmp
RUN wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz &&\
    tar xvf go${GO_VERSION}.linux-amd64.tar.gz -C /usr/local/ &&\
    rm /tmp/go${GO_VERSION}.linux-amd64.tar.gz

WORKDIR /opt
RUN go install -v github.com/owasp-amass/amass/v4/...@master

# creation of nonroot user
RUN groupadd -r nonroot && \
    useradd -m -g nonroot -d /home/nonroot -s /usr/sbin/nologin -c "nonroot user" nonroot && \
    mkdir -p /home/nonroot && \
    chown -R nonroot:nonroot /home/nonroot

# switching to nonroot
USER nonroot

ENTRYPOINT ["/opt/amass/bin/amass"]
