# cleversafe-ansible/roles/builders

## Introduction
This ansible playbook is meant to demo a templated way for us to build packages for Debian systems

## Running
```shell
workon ursula
ursula --provisioner=vagrant envs/example/debian7-java8 debian7-java8.yml --ask-vault-pass
```

The run time will take a bit. If you want it to run faster increase the vm resources in envs/example/debian7-java8/vagrant.yml

## Ansible Vault
This role utilizes ansible vault as a demo. The vault password is: HM7QiN9xlklSUjrB

## TODO
 - Add in code to fetch vault password from a repo like Thycotic
 - Move fpm gem into common from java
 - Build better documents around utilizing fpm to build other debian packages
 - Better Version Control For OpenJDK Building
 - Set Install location of OpenJDK to /opt
 - Intergation to push new packages into Nexus
 - Any service we need great version control and build control over
