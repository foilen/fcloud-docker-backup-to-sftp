FROM ubuntu:18.04

RUN export TERM=dumb ; \
  apt-get update && apt-get install -y \
    curl less vim \
    cron=3.0pl1-128.1ubuntu1 \
    openssh-client \
    supervisor=3.3.1-1.1 \
  && apt-get clean && rm -rf /var/lib/apt/lists/* \
  rm /etc/cron.daily/* /etc/cron.hourly/* /etc/cron.monthly/* /etc/cron.d/* /etc/cron.weekly/*
  
COPY /assets/* /

VOLUME /backupRoot

CMD /backup.sh
