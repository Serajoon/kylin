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

## ${dir} assigned to $KYLIN_HOME/bin in header.sh
source ${dir}/find-hadoop-conf-dir.sh
###serajoon if [ -z String] String长度为0则为真
if [ -z "${kylin_hadoop_conf_dir}" ]; then
    hadoop_conf_param=
else
    hadoop_conf_param="--config ${kylin_hadoop_conf_dir}"
fi
###serajoon 判断KYLIN_HOME是否为空值
if [ -z "$KYLIN_HOME" ]
then
    quit 'Please make sure KYLIN_HOME has been set'
else
    echo "KYLIN_HOME is set to ${KYLIN_HOME}"
fi

if [ -z "$(command -v hbase version)" ]
then
    quit "Please make sure the user has the privilege to run hbase shell"
fi

if [ -z "$(command -v hive --version)" ]
then
    quit "Please make sure the user has the privilege to run hive shell"
fi

if [ -z "$(command -v hadoop version)" ]
then
    quit "Please make sure the user has the privilege to run hadoop shell"
fi
### serajoon kylin.env.hdfs-working-dir=/kylin hdfs上kylin的存储目录
WORKING_DIR=`bash $KYLIN_HOME/bin/get-properties.sh kylin.env.hdfs-working-dir`
if [ -z "$WORKING_DIR" ]
then
    quit "Please set kylin.env.hdfs-working-dir in kylin.properties"
fi
###serajoon
# hadoop --config ${HADOOP_HOME}/etc/hadoop
# 在profile文件中配置好hadoop的环境变量后,当执行hadoop命令时,可以带参数来执行相关的操作比如我们有好几个版本的hadooop,
# 那么我们在执行hadoop的时候,到底运行哪个呢？那么这样就可以执行hadoop命令时加上后面的参数来指定具体要执行那个版本的hadoop
hadoop ${hadoop_conf_param} fs -mkdir -p $WORKING_DIR
### $?:上个命令的退出状态,0 表示没有错误
if [ $? != 0 ]
then
    quit "Failed to create $WORKING_DIR. Please make sure the user has right to access $WORKING_DIR"
fi
###serajoon /kylin/spark-history
hadoop ${hadoop_conf_param} fs -mkdir -p $WORKING_DIR/spark-history
if [ $? != 0 ]
then
    quit "Failed to create $WORKING_DIR/spark-history. Please make sure the user has right to access $WORKING_DIR"
fi