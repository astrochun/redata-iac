Digital Ocean Ubuntu Swap Space Creator
=======================================

This here creates a swap file for Ubuntu 18.04 and Ubuntu 20.04 LTS machines.

It follows instructions from: 
 [18.04](https://www.digitalocean.com/community/tutorials/how-to-add-swap-space-on-ubuntu-18-04)
 [20.04](https://www.digitalocean.com/community/tutorials/how-to-add-swap-space-on-ubuntu-20-04)

Requirements
------------

A Digital Ocean droplet with Ubuntu distribution


Role Variables
--------------

<!-- A description of the settable variables for this role should go here, including any variables that are in defaults/main.yml, vars/main.yml, and any variables that can/should be set via parameters to the role. Any variables that are read from other roles and/or the global scope (ie. hostvars, group vars, etc.) should be mentioned here as well. -->

Variables specified in [defaults/main.yml](defaults/main.yml) include:

| Variables | Description               | Defaults   |
| --------- | ------------------------- | ---------- |
| swap_file | Full path of swap file    | /swapfile  |
| size      | Size of swap file         | 1G         |
| fstab     | File system tab to update | /etc/fstab |


Dependencies
------------

<!-- A list of other roles hosted on Galaxy should go here, plus any details in regards to parameters that may need to be set for other roles, or variables that are used from other roles. -->

None

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: hostname
      become: yes
      roles:
         - 'roles/do-ubuntu-swapspace'

To override `size` variable, for example, specify after the role:

    - hosts: hostname
      become: yes
      roles:
         - 'roles/do-ubuntu-swapspace'
      vars:
        size: '2GB'

Note that an [ansible playbook](../../add_swap_space.yml) to run this script is present in this repostory.

TODO
----

1. Add option to remove swap via `swapoff`
2. ~~Fix debug to avoid skips. Find a way to make it succinct based on file status, etc.~~

License
-------

MIT

Author Information
------------------

Created by Chun Ly ([@astrochun](https://github.com/astrochun))
<!-- An optional section for the role authors to include contact information, or a website (HTML is not allowed).-->

