FROM ubuntu
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install python3 ansible ssh -y
RUN mkdir /app
#COPY roles /app/roles
#COPY main.yml /app
COPY hosts /app
COPY key /app
RUN chmod 400 /app/key
CMD cd /app && ansible-playbook -i hosts main.yml | grep -e 'target.*ok=' >> /app/report
