
# Development in Vagrant

[We have setup Vagrant](local-installation.md) so that you can have the source codes and IDE on your native host machine, while running a full installation of the service in VirtualBox. Live changes can be made to the server from the host machine, as the project subdirectory modules/ is mapped as /src/ inside the virtual machine. After provisioning the virtual machine, it uses the static codes installed on the server (which you can ofcourse temporarily edit by SSHing into the server). To live-edit code from the host machine, you must manually choose to symlink individual modules to have the server use the code from the host machine.

Look at individual instructions for each project at Github project page.

## Linking a module from the host machine

The ytp-develop.py script is provided to help with linking the modules. This script is executed on the virtual machine (`vagrant ssh`).

    sudo /src/scripts/ytp-develop.py # help
    sudo /src/scripts/ytp-develop.py --list # list available projects
    sudo /src/scripts/ytp-develop.py --serve # serve CKAN via paster and access at http://10.10.10.10:5000/
    sudo /src/scripts/ytp-develop.py <project-name>... # switch project sources

Examples:

    sudo /src/scripts/ytp-develop.py ckanext-ytp-main # replace ckanext-ytp-main project
    sudo /src/scripts/ytp-develop.py ckanext-ytp-main ytp-assets-common # replace both ckanext-ytp-main and ytp-assets-common projects 

### Notes

- Serve command cannot reload all modification and need to restarted on some changes.
- Serve cannot access asset files currently so the layout is broken. You can disable ytp_theme plugin from `/etc/ckan/default/production.ini`. 
- For ckanext project if setup.py is changed or if some files are inserted you need to re-execute `ytp-develop.py` (executes correct python setup.py develop).

## Manually link Python packages (ckanext-*)

    vagrant ssh
    cd /src/<python-package>
    sudo /usr/lib/ckan/default/bin/pip uninstall <python-package>
    sudo /usr/lib/ckan/default/bin/python setup.py develop

- You must restart Apache after modifications to sources *sudo service apache2 restart*. 
- If you modify *setup.py* re-run *setup.py develop*. 

