# Download base image for rolling Ubuntu LTSrelease
FROM ubuntu:18.04

# LABEL about the custom image
LABEL version="0.1"
LABEL description="Custom image to run Buckeye cam on Linux container"

# Disable Prompt During Packages Installation
ARG DEBIAN_FRONTEND=noninteractive

# Update Ubuntu Software repository
RUN apt update

# Install curl as an example package
RUN apt install -y wget bzip2 && \
    rm -rf /var/lib/apt/lists/* && \
    apt clean

# Extract the Buckeye cam MultiBase Server Edition software to /usr/local/sbin
RUN wget -O /tmp/mbse-latest.tbz -q http://www.buckeyecam.com/main/Files/mbse-13.6-x86_64.tbz && \
    mkdir /tmp/mbse && tar --directory /tmp/mbse -xjf /tmp/mbse-latest.tbz && \
    mv /tmp/mbse/mbse/* /usr/local/sbin && rm -f /tmp/mbse-latest.tbz
# # Make executable runnable by all users, but not writeable
RUN chmod ugo+rx /usr/local/sbin/mbasectl
RUN chmod -w /usr/local/sbin/mbasectl

# # Copy config file to container
COPY ./becmbse.conf /etc/becmbse.conf

# Create a user called appuser (UID 1000) for Buckeye to run as 
# and add user to default linux user group 'users' (GID 100)  
RUN useradd -m -g 100 -u 1000 appuser
# Switch Docker user to Appuser (rather than root) for security - disable for debug
# USER appuser

# Make a directory for MBase to store its data
RUN mkdir /home/appuser/mbasedata

WORKDIR /usr/local/sbin

# use for debugging with `docker build -t buckeye6 azure/qberd/containers/buckeye_cellbase && docker run -d buckeye6`
# CMD ["sleep", "infinity"]
CMD ["run_mbase", "-debug", "-d", "/home/appuser/mbasedata", "-u", "1000", "-g", "100"]
