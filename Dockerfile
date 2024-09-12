ARG DEBIAN_VERSION=12

FROM debian:$DEBIAN_VERSION-slim

# NOTE: ARGs need to be redefined after FROM
ARG DEBIAN_VERSION
ARG VERACRYPT_VERSION=1.26.14

ARG VERACRYPT_URL="https://launchpad.net/veracrypt/trunk/${VERACRYPT_VERSION}/+download/veracrypt-${VERACRYPT_VERSION}-Debian-${DEBIAN_VERSION}-amd64.deb"
ARG VERACRYPT_SIG="${VERACRYPT_URL}.sig"

# Install necessary packages and VeraCrypt
RUN apt-get update && \
    apt-get install -y wget gnupg && \
    wget -q ${VERACRYPT_URL} -O veracrypt.deb && \
    wget -q ${VERACRYPT_SIG} -O veracrypt.sig && \
    wget -q https://www.idrix.fr/VeraCrypt/VeraCrypt_PGP_public_key.asc -O veracrypt.asc && \
    gpg --import veracrypt.asc && \
    gpg --verify veracrypt.sig veracrypt.deb && \
    apt-get install ./veracrypt.deb -y --no-install-recommends && \
    rm -f veracrypt.deb veracrypt.asc veracrypt.sig && \
    apt-get autoremove --purge -y wget gnupg && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create a folder to mount the encrypted volume inside the container and create a folder for the encrypted volume
RUN mkdir /encrypted-mount
RUN mkdir -p /encrypted-volume

# Add the entrypoint script
COPY entrypoint.sh /entrypoint.sh

# Make the entrypoint script executable and set it as the entrypoint
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
