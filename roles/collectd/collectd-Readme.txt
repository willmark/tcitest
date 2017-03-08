# This readme file is focussed on current way of setting up collectd and future enhancements needed to install custom built collectd agent

1. Right now the collectd agent installed on vagrant kafka node is 5.1.0

2. We use collectd version 5.6.1-2.1 built package on servers

3. Once local repo is setup we should be pulling the package from the repo

4. collecd-role vars/main.yml has the variables defined for version and mirror repo

4. Ansible supports version control during installing. name: collectd=version ensure installation of only that particular version and ignore others

5. We use custom plugin for some of our monitors. The current assumption is if we use the same collectd package via ansible they should be loaded clean in collectd.conf file. This anyway needs to be tested out once the mirror repo is setup. Part of that task can be loading collectd-exec plugin and executing a custom script via collectd version 5.6.1-2.1
