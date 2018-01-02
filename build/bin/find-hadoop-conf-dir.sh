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

echo Retrieving hadoop conf dir...

function find_hadoop_conf_dir() {
#serajoon kylin.env.hadoop-conf-dir:spark引擎需要配置
    override_hadoop_conf_dir=`bash ${KYLIN_HOME}/bin/get-properties.sh kylin.env.hadoop-conf-dir`
    
    if [ -n "$override_hadoop_conf_dir" ]; then
        verbose "kylin_hadoop_conf_dir is override as $override_hadoop_conf_dir"
        export kylin_hadoop_conf_dir=${override_hadoop_conf_dir}
        return
    fi
    
    hbase_classpath=`hbase classpath`
###serajoon
# cut:是一个选取命令，默认以行为单位，就是将一段数据经过分析，取出我们想要的
#  -d:自定义分隔符，默认为制表符
#  -f:与-d一起使用，指定显示哪个区域，下标从1开始。 -f 1- 从第一项一直到行尾
# sed
# s: 替换
# 使用后缀 /g 标记会替换每一行中的所有匹配，最后的g是global的意思，也就是全局替换，如果不加g，则只会替换本行的第一个line
# sed 's/:/ /g' 替换所有的冒号为空格
# sed 's/要替换的字符串/新的字符串/g'
# 命令中字符 / 在sed中作为定界符使用，也可以使用任意的定界符sed 's:test:TEXT:g' sed 's|test|TEXT|g'
    arr=(`echo $hbase_classpath | cut -d ":" -f 1- | sed 's/:/ /g'`)
    kylin_hadoop_conf_dir=
##serajoon
# grep
# -v 显示不包括查找字符的所有行
# -E 选项使用扩展正则表达式
# grep -v -E ".*jar" 查找所有不带.jar的即查找所有文件夹
# kylin_hadoop_conf_dir=${HADOOP_HOME}/etc/hadoop
# return 如果某函数中有return命令，执行到return时就返回
    for data in ${arr[@]}
    do
        result=`echo $data | grep -v -E ".*jar"`
        if [ $result ]
        then
            valid_conf_dir=true
            
            if [ ! -f $result/yarn-site.xml ]#不存在continue继续循环
            then
                verbose "$result is not valid hadoop dir conf because yarn-site.xml is missing"
                valid_conf_dir=false
                continue
            fi
            
            if [ ! -f $result/mapred-site.xml ]
            then
                verbose "$result is not valid hadoop dir conf because mapred-site.xml is missing"
                valid_conf_dir=false
                continue
            fi
            
            if [ ! -f $result/hdfs-site.xml ]
            then
                verbose "$result is not valid hadoop dir conf because hdfs-site.xml is missing"
                valid_conf_dir=false
                continue
            fi
            
            if [ ! -f $result/core-site.xml ]
            then
                verbose "$result is not valid hadoop dir conf because core-site.xml is missing"
                valid_conf_dir=false
                continue
            fi
            
            verbose "kylin_hadoop_conf_dir is $result"
            export kylin_hadoop_conf_dir=$result
            return
        fi
    done
}
find_hadoop_conf_dir