FROM  registry.cn-hangzhou.aliyuncs.com/itoms_niu/znyw_chgcheck:20220427_001

ENV TIMEZONE=Asia/Shanghai
ENV TNS_ADMIN=/oracle_client/instantclient_11_2
ENV NLS_LANG=SIMPLIFTED_CHINESE_CHINA_ZHS16GBK
ENV LD_LIBRARY_PATH=/oracle_client/instantclient_11_2


COPY ./instantclient-basic-linux.x64-11.2.0.4.0.zip  /
COPY ./cx_Oracle-8.3.0-cx_oracle.whl /


ENV GCC_PACKAGES="\
  gcc musl-dev g++ \
  libnsl \
  libaio \
"
 

## running
RUN echo "Begin" \
  && echo "********** 安装oracle驱动********************" \
  && mkdir /oracle_client && cd /oracle_client \
  && unzip /instantclient-basic-linux.x64-11.2.0.4.0.zip \
  && cd /oracle_client/instantclient_11_2 \
##  && ln -s /usr/lib/libnsl.so.2.0.0  /usr/lib/libnsl.so.1 \
##  && ln -s libclntsh.so.11.1  libclntsh.so \
  && echo "********** 安装相关的gcc依赖包*************************" \
  && apk add --no-cache $GCC_PACKAGES \
  && echo "********** 安装python包cx_oracle***********************" \
##  && pip install --no-cache-dir cx_Oracle==8.0.1 -i http://mirrors.aliyun.com/pypi/simple  --trusted-host mirrors.aliyun.com \  
  && pip install /cx_Oracle-8.3.0-cx_oracle.whl
  && echo "********** 删除依赖包" \
  && echo "End"
