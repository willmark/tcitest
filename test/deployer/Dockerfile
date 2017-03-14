FROM debian:latest
RUN echo 'deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main' >> /etc/apt/sources.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install python3 ansible ssh -y
RUN mkdir /app
#COPY roles /app/roles
#COPY main.yml /app
COPY hosts /app
COPY key /app
RUN chmod 400 /app/key
CMD cd /app && ansible-playbook -i hosts main.yml >> /app/report
