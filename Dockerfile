FROM       ubuntu:trusty
MAINTAINER Abe Voelker <abe@abevoelker.com>

# Provide a custom nginx.conf, tweaked for Docker use
COPY nginx.conf /data/conf/

# Ensure UTF-8 locale
COPY locale /etc/default/locale
RUN \
  locale-gen en_US.UTF-8 &&\
  DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales &&\
# Install build dependencies
  apt-get update &&\
  DEBIAN_FRONTEND=noninteractive apt-get install -y software-properties-common &&\
# Add nginx PPA
  apt-add-repository ppa:nginx/development &&\
# Update apt cache with PPA
  apt-get update &&\
# Install nginx and pip
  DEBIAN_FRONTEND=noninteractive apt-get install -y \
  nginx \
  python-software-properties \
  python-pip \
  software-properties-common &&\
# Install AWS CLI
  pip install awscli &&\
# Copy default config files to /data
  /bin/bash -c "cp -a /etc/nginx/{conf.d,sites-enabled} /data/" &&\
# Create conf directories
  mkdir -p /data/conf/ &&\
  chmod 0755 /data/conf/ &&\
  mkdir -p /data/sites-templates &&\
  chmod 0755 /data/sites-templates &&\
# Clean up APT and temporary files when done
  apt-get clean &&\
  DEBIAN_FRONTEND=noninteractive apt-get remove --purge -y software-properties-common &&\
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add nginx templating helper scripts
COPY bin/ /usr/bin/

VOLUME ["/var/cache/nginx", "/var/log/nginx"]

ENTRYPOINT ["entrypoint.sh"]
CMD ["nginx", "-c", "/data/conf/nginx.conf"]

EXPOSE 80 443
