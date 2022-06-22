FROM  registry.cn-hangzhou.aliyuncs.com/itoms_niu/znyw_chgcheck:20220427_001

ENV TIMEZONE=Asia/Shanghai
ENV TNS_ADMIN=/oracle_client/instantclient_21_6
ENV NLS_LANG=SIMPLIFTED_CHINESE_CHINA_ZHS16GBK
ENV LD_LIBRARY_PATH=/oracle_client/instantclient_21_6

COPY ./instantclient_21_6.zip.001 ./instantclient_21_6.zip.002 ./instantclient_21_6.zip.003 ./instantclient_21_6.zip.004  /


ENV GCC_PACKAGES="\
  libnsl \
  libaio \
"

ENV GCC_PACKAGES="\
  gcc \
  g++ \
  libcec-dev \
"
 

## running
RUN echo "Begin" \
  && echo "********** 安装oracle驱动********************" \
  && mkdir /oracle_client \
  && mv /instantclient_21_6.zip.001 /oracle_client \
  && mv /instantclient_21_6.zip.002 /oracle_client \
  && mv /instantclient_21_6.zip.003 /oracle_client \
  && mv /instantclient_21_6.zip.004 /oracle_client \
  && cd /oracle_client \
  && cat instantclient_21_6.zip.00* > instantclient_21_6.zip \
  && unzip instantclient_21_6.zip \
  && rm -rf instantclient_21_6.zip.001 \
  && rm -rf instantclient_21_6.zip.002 \
  && rm -rf instantclient_21_6.zip.003 \
  && rm -rf instantclient_21_6.zip.004 \
  && rm -rf instantclient_21_6.zip \
  && cd /oracle_client/instantclient_21_6 \
##  && ln -s libclntsh.so.11.1  libclntsh.so \
  && ln -s /usr/lib/libnsl.so.2.0.0  /usr/lib/libnsl.so.1 \
  && echo "********** 安装相关的gcc依赖包*************************" \
  && apk add --no-cache --virtual=.build-deps $GCC_PACKAGES \
  && apk add --no-cache $PACKAGES \
  && echo "********** 安装python包cx_oracle***********************" \
  && pip install --no-cache-dir cx_Oracle==8.0.1 -i http://mirrors.aliyun.com/pypi/simple  --trusted-host mirrors.aliyun.com \  
  && echo "********** 删除依赖包" \
  && apk del .build-deps \
  && echo "End"
