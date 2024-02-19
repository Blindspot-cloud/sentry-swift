FROM swift:5.9-jammy as build

RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

COPY ./Package.* ./
RUN --mount=type=ssh swift package resolve

# Copy entire repo into container
COPY . .

# Build everything, with optimizations
RUN --mount=type=ssh swift build -c release --static-swift-stdlib
