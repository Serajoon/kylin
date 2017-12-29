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

# source me
hive_conf_dir="${KYLIN_HOME}/conf/kylin_hive_conf.xml"
### serajoon
# -n:使用安静(silent)模式。在一般 sed 的用法中，所有来自 STDIN的资料一般都会被列出到萤幕上。但如果加上 -n 参数后，则只有经过sed 特殊处理的那一行(或者动作)才会被列出来。
#  p:列印，亦即将某个选择的资料印出。-n选项和p命令一起使用表示只打印那些发生替换的行：
#  |:定界符
# \1:子串匹配标记
# echo this is digit 7 in a number | sed 's/digit \([0-9]\)/\1/' =>this is 7 in a number
# 命令中 digit 7，被替换成了 7。样式匹配到的子串是 7，\(..\) 用于匹配子串，对于匹配到的第一个子串就标记为 \1
# 's/ \+//g':一个或多个空格替换成空，即去除空格 echo this is digit 7 in a number | sed 's/ \+//g' =>thisisdigit7inanumber
names=(`sed -n 's|<name>\(.*\)</name>|\1|p'  ${hive_conf_dir} | sed 's/ \+//g'`)
values=(`sed -n 's|<value>\(.*\)</value>|\1|p'  ${hive_conf_dir} | sed 's/ \+//g'`)
###serajoon 获取数组的长度
len_names=${#names[@]}
len_values=${#values[@]}

[[ $len_names == $len_values ]] || quit "Current hive conf file: ${hive_conf_dir} has inconsistent key value pairs."

for((i=0;i<$len_names;i++))
do
    hive_conf_properties=${hive_conf_properties}" --hiveconf ${names[$i]}=${values[$i]} "
done
