ARG DEBIAN_VERSION=12
ARG VERACRYPT_VERSION=1.16.14

FROM debian:$DEBIAN_VERSION-slim


# Install necessary packages and VeraCrypt
RUN apt-get update && \
    apt-get install -y wget gnupg && \
    wget -q https://launchpad.net/veracrypt/trunk/$VERACRYPT_VERSION/+download/veracrypt-$VERACRYPT_VERSION-Debian-$DEBIAN_VERSION-amd64.deb -O veracrypt.deb && \
    wget -q https://www.idrix.fr/VeraCrypt/VeraCrypt_PGP_public_key.asc -O veracrypt.asc && \
    gpg --import veracrypt.asc && \
    gpg --verify veracrypt.deb && \
    dpkg -i veracrypt.deb || true && \
    apt-get -f install -y && \
    rm -f veracrypt.deb veracrypt.asc && \
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
