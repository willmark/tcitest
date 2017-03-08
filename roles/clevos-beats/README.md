ClevOS-Beats
=========

This role pulls down the base beats package defined in the _agents_ hash.  Then configures them based on the given template for later installation as an external agent on Cleversafe devices.

Requirements
------------

A base package built and store in a repo containing:
 * The program and it's dependencies
 * Start, Stop, and Status scripts require by Cleversafe

The **kafka** group is defined in the hosts inventory. This is used to build the outputs for the template auto-magically.

Role Variables
--------------
_agents_  - Hash should contain the name of the beat as defined in the repo and contain the following
* **version** - with the version number as defined in the repo tags without the prepended **v**
* **conf_template** - name of the template file (i.e. sometemplate.j2)
* **ext** - what exention the configuration file should have (i.e. **.yml** for YAML files)

###### Example
```
agents:
  filebeat:
    version: "5.2.1"
    conf_template: "clev-config.j2"
    ext: ".yml"
```

##### Filebeat
_filebeat_prospector_ - Hash should contain keys with the _host_type_ (accesser, slicestor, etc...) then under those keys the a list of inputs for filebeat should be defined.  The following are required for each input:
 * **input_type** - must be defined 
 * **path** - contains a list of files or paths to look at. At least one must be defined for an input
 * **doc_type** - Defines the topic for kafka

We also support _encoding_ and _exclude_files_, See the filebeat's [official documentation](https://www.elastic.co/guide/en/beats/filebeat/current/filebeat-getting-started.html) for more details.

###### Example
```
filebeat_prospector:
  slicestor:
    - input_type: log
      paths:
        - "/var/log/*.log"
        - "/var/log/dsnet-core/*.log"
      doc_type: syslog
      exclude_files: "['.gz$']"
```

Dependencies
------------

A list of other roles hosted on Galaxy should go here, plus any details in regards to parameters that may need to be set for other roles, or variables that are used from other roles.

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:
```
- name: "Build Filebeat"
  hosts: "pkgbuilder"
  gather_facts: true
  become: true
  any_errors_fatal: true
  roles:
    - role: builders/beats

- name: "Create filebeat agent"
  hosts: "utility"
  gather_facts: true
  become: true
  any_errors_fatal: true
  roles:
    - {role: filebeat, host_type: "slicestor", when: stack_env == 'dev' or stack_env == 'local-dev' or stack_env == 'staging'}
    - {role: filebeat, host_type: "accesser", when: stack_env == 'dev' or stack_env == 'local-dev' or stack_env == 'staging'}
```
