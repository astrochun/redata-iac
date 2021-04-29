ReDATA Linux Account Creator
============================

This role easily allow for the creation of a linux account.
Default configurations is intended for ReDATA purposes.


Requirements
------------

A Linux virtual machine. This works with Ubuntu and CentOS.


Role Variables
--------------

<!-- A description of the settable variables for this role should go here, including any variables that are in defaults/main.yml, vars/main.yml, and any variables that can/should be set via parameters to the role. Any variables that are read from other roles and/or the global scope (ie. hostvars, group vars, etc.) should be mentioned here as well. -->

Variables specified in [defaults/main.yml](defaults/main.yml) include:

| Variables        | Description                                 | Defaults   |
| ---------------- | ------------------------------------------- | ---------- |
| user             | User name                                   | user       |
| password         | Size of swap file                           | ***        |
| update_password  | File system tab to update                   | on_create  |
| state            | State of account (present/absent)           | present    |
| shell            | Set the user's shell                        | /bin/bash  |
| system           | Make this account a system account          | no         | 
| create_home      | Create a home directory at /home/{{ user }} | yes        | 
| generate_ssh_key | Generate a SSH key for user in question     | yes        |


Tags
----

There is only one tag, `account.create`


Dependencies
------------

<!-- A list of other roles hosted on Galaxy should go here, plus any details in regards to parameters that may need to be set for other roles, or variables that are used from other roles. -->

Built-in Ansible dependencies are only used:
 1. `user`


Example Playbook
----------------

An easy playbook. Note that `become` is required

    hosts: hostname
    become: yes
    roles:
      - role: 'roles/redata-account-create'
        vars:
          user: "{{ user }}"
          password: "{{ password }}"
          update_password: always


Note that an [ansible playbook](../../account_create.yml) to run this script is present in this repository.


TODO
----

1. Enable deletion of account
2. Enable adding existing ssh key


License
-------

MIT


Author Information
------------------

Created by Chun Ly ([@astrochun](https://github.com/astrochun))
<!-- An optional section for the role authors to include contact information, or a website (HTML is not allowed).-->