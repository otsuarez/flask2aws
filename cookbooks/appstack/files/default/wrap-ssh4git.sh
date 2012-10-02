#!/usr/bin/env bash
/usr/bin/env ssh -o "StrictHostKeyChecking=no" -i "/tmp/.appstack_deploy/.ssh/id_deploy" $1 $2
