FROM deployblue/tcitest:latest
COPY hosts /app
COPY key /app
RUN chmod 400 /app/key
CMD cd /app && ansible-playbook -i hosts main.yml
