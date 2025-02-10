FROM apache/spark:3.5.4-scala2.12-java17-python3-r-ubuntu


USER root

RUN pip3 install --upgrade pip
RUN pip3 install pyspark
RUN pip install delta-spark==3.0.0
RUN pip install ipykernel -U --user --force-reinstall

# # # Modify permissions for the spark user
RUN mkdir -p /home/spark && \
    chown -R spark:spark /home/spark

# Download and install packages-microsoft-prod.deb
# Add Microsoft packages repository
RUN wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && apt-get update

# Install libfuse3-dev and fuse3
RUN apt-get install -y libfuse3-dev fuse3

RUN apt-get install blobfuse2

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /packages-microsoft-prod.deb

# Create necessary directories
RUN mkdir -p /home/spark/python-env/blobfuse/cache
RUN mkdir -p /home/spark/python-env/mycontainer
RUN mkdir -p /home/spark/python-env/config

# Ensure the mount point has the correct permissions and ownership
RUN chmod 777 /home/spark/python-env/mycontainer
RUN chown $(whoami):$(whoami) /home/spark/python-env/mycontainer
# Clear the cache directory

# Copy the configuration file
COPY ./config.yml /home/spark/python-env/config/config.yaml