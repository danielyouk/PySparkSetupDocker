FROM spark:3.5.1-scala2.12-java17-ubuntu

USER root

RUN set -ex; \
    apt-get update; \
    apt-get install -y python3 python3-pip; \
    apt-get install -y r-base r-base-dev; \
    apt-get install -y git && \
    apt-get install -y git lsb-release && \
    rm -rf /var/lib/apt/lists/*

RUN pip3 install --upgrade pip
RUN pip3 install pyspark
RUN pip install delta-spark==3.0.0
RUN pip install Flask requests pandas
RUN pip install PyMuPDF tabula-py
RUN pip install ipykernel -U --user --force-reinstall

# RUN pip3 install requests
# RUN pip3 install pandas
ENV R_HOME /usr/lib/R


# # # Modify permissions for the spark user
RUN mkdir -p /home/spark && \
    chown -R spark:spark /home/spark

RUN apt-get update && apt-get install -y \
    fuse \
    curl \
    ca-certificates \
    apt-transport-https \
    gnupg \
    sudo

# Add Microsoft package signing key and repository directly from the web
RUN curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /usr/share/keyrings/microsoft-archive-keyring.gpg > /dev/null && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/azure-cli.list && \
    apt-get update && apt-get install -y azure-cli

# Download and install packages-microsoft-prod.deb
RUN curl -sL https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb -o /tmp/packages-microsoft-prod.deb && \
    dpkg -i /tmp/packages-microsoft-prod.deb && \
    apt-get update && \
    apt-get install -y blobfuse2 && \
    rm /tmp/packages-microsoft-prod.deb

# Create necessary directories
RUN mkdir -p /home/spark/python-env/blobfuse/cache
RUN mkdir -p /home/spark/python-env/mycontainer
RUN mkdir -p /home/spark/python-env/config
# Ensure the mount point has the correct permissions and ownership
RUN chmod 777 /home/spark/python-env/mycontainer
RUN chown $(whoami):$(whoami) /home/spark/python-env/mycontainer
# Clear the cache directory
RUN rm -rf /home/spark/python-env/blobfuse/cache/*
# Copy the configuration file
COPY ./config.yml /home/spark/python-env/config/config.yaml