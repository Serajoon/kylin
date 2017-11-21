#!/bin/bash

#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

source $(cd -P -- "$(dirname -- "$0")" && pwd -P)/header.sh
###serajoon $# 传给脚本的参数个数
###serajoon 校验传递的参数个数
if [ $# != 1 ]
then
    echo 'invalid input'
    exit -1
fi

tool_jar=$(ls $KYLIN_HOME/tool/kylin-tool-*.jar)
result=`java -cp $tool_jar -Dlog4j.configuration=file:${KYLIN_HOME}/conf/kylin-tools-log4j.properties org.apache.kylin.tool.KylinConfigCLI $1 2>/dev/null`
echo "$result"
