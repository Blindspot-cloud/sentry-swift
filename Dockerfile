FROM swift:5.9-jammy as build

WORKDIR /build

COPY ./Package.* ./
RUN --mount=type=ssh swift package resolve

# Copy entire repo into container
COPY . .

# Build everything, with optimizations
RUN --mount=type=ssh swift build -c release --static-swift-stdlib
