FROM ubuntu
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install python3 ansible ssh -y
COPY sshd_config /etc/ssh/sshd_config
RUN mkdir /root/.ssh
COPY key.pub /root/.ssh/authorized_keys
CMD /etc/init.d/ssh start && tail -F -n0 /etc/hosts
