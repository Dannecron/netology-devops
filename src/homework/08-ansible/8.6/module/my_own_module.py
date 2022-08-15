#!/usr/bin/python

# Copyright: (c) 2018, Terry Jones <terry.jones@example.org>
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)
from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: my_own_module

short_description: Netology devops test module

# If this is part of a collection, you need to use semantic versioning,
# i.e. the version is of the form "2.5.0" and not "2.4".
version_added: "1.0.0"

description: Создание тестового файла на удалённом хосте по определённому пути с определённым содержимым

options:
    path:
        description: Путь до файла
        required: true
        type: str
    new:
        description: Содержимое файла
        required: true
        type: str
# Specify this value according to your collection
# in format of namespace.collection.doc_fragment_name
extends_documentation_fragment:
    - my_namespace.my_collection.my_doc_fragment_name

author:
    - Denis Savosin (@Dannecron)
'''

EXAMPLES = r'''
# Pass in a message
- name: Test with a message
  my_namespace.my_collection.my_test:
    name: hello world

# pass in a message and have changed true
- name: Test with a message and changed output
  my_namespace.my_collection.my_test:
    name: hello world
    new: true

# fail the module
- name: Test failure of the module
  my_namespace.my_collection.my_test:
    name: fail me
'''

RETURN = r'''
'''

import os

from ansible.module_utils.basic import AnsibleModule

def run_module():
    # define available arguments/parameters a user can pass to the module
    module_args = dict(
        path=dict(type='str', required=True),
        content=dict(type='str', required=True)
    )

    # seed the result dict in the object
    # we primarily care about changed and state
    # changed is if this module effectively modified the target
    # state will include any data that you want your module to pass back
    # for consumption, for example, in a subsequent task
    result = dict(changed=False)

    # the AnsibleModule object will be our abstraction working with Ansible
    # this includes instantiation, a couple of common attr would be the
    # args/params passed to the execution, as well as if the module
    # supports check mode
    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True
    )

    # if file does not exists then set changed to True
    # else get content of file and compare it with content variable
    # if contents are not equal, then changed=True

    file_exists = os.path.exists(module.params['path'])
    file_content = ''

    if not file_exists:
        result['changed'] = True
    else:
        file = open(module.params['path'], mode='r')
        file_content = file.read()
        file.close()

        if file_content != module.params['content']:
            result['changed'] = True

    if module.check_mode:
        module.exit_json(**result)

    if result['changed'] == False:
        module.exit_json(**result)

    file = open(module.params['path'], mode='w')
    file.write(module.params['content'])
    file.close()

    module.exit_json(**result)


def main():
    run_module()


if __name__ == '__main__':
    main()
