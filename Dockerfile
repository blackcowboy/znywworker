FROM alpine:3.12

ENV ALPINE_VERSION=3.12
ENV TIMEZONE=Asia/Shanghai
ENV TNS_ADMIN=/oracle_client/instantclient_21_6
ENV NLS_LANG=SIMPLIFTED_CHINESE_CHINA_ZHS16GBK
ENV LD_LIBRARY_PATH=/oracle_client/instantclient_21_6

COPY ./github_hosts ./entrypoint.sh ./Dockerfile  /
COPY ./instantclient_21_6.zip.001 ./instantclient_21_6.zip.002 ./instantclient_21_6.zip.003 ./instantclient_21_6.zip.004  /
COPY Shanghai /etc/localtime


ENV PACKAGES="\
  dumb-init tzdata bash vim tini ncftp busybox-extras \
  python3 \
  mysql-dev \
  openblas \
  libgomp \
  lapack \
  blas \
"

ENV BUILD_PACKAGES="\
  build-base \
  linux-headers \
  python3-dev \
  openblas-dev \
  lapack-dev \
  blas-dev \
"

ENV GCC_PACKAGES="\
  gcc \
  g++ \
  libcec-dev \
"

## running
RUN echo "Begin" \
  && echo "${TIMEZONE}" > /etc/timezone \
  && echo "********** 安装oracle驱动" \
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
  && ln -s libclntsh.so.11.1  libclntsh.so \
  && ln -s /usr/lib/libnsl.so.2.0.0  /usr/lib/libnsl.so.1 \
  && chmod +x /entrypoint.sh \
  && ls -l /entrypoint.sh \
  && sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
  && echo "********** 安装临时依赖" \
  && apk add --no-cache --virtual=.build-deps $BUILD_PACKAGES \
  && echo "********** 安装永久依赖" \
  && apk add --no-cache $PACKAGES \
  && echo "********** 安装相关的gcc依赖包*************************" \
  && apk add --no-cache $GCC_PACKAGES 
  && echo "********** 更新python信息" \
  && sed -i 's:mouse=a:mouse-=a:g' /usr/share/vim/vim82/defaults.vim \
  && { [[ -e /usr/bin/python ]] || ln -sf /usr/bin/python3.8 /usr/bin/python; } \
  && python -m ensurepip \
  && python -m pip install --upgrade --no-cache-dir pip \
  && { [[ -e /usr/bin/pip ]] || ln -sf /usr/bin/pip3 /usr/bin/pip; } \
  && cd /usr/bin \
  && ls -l python* pip* \
  && echo "********** 安装python包" \
  && speed="-i http://mirrors.aliyun.com/pypi/simple  --trusted-host mirrors.aliyun.com" \
  && pip install --no-cache-dir wheel ${speed} \
  && pip install --no-cache-dir requests==2.25.1 ${speed} \
  && pip install --no-cache-dir Django==3.1.2 ${speed} \
  && pip install --no-cache-dir uwsgi==2.0.19.1 ${speed} \
  && pip install --no-cache-dir uwsgitop==0.11 ${speed} \
  && pip install --no-cache-dir celery[redis]==5.0.1 ${speed} \
  && pip install --no-cache-dir django-celery-results==2.0.1 ${speed} \
  && pip install --no-cache-dir django-celery-beat==2.2.0 ${speed} \
  && pip install --no-cache-dir mysqlclient==2.0.1 ${speed} \
  && echo "********** 下载whl并安装" \
  && QINIU_URL='http://pubftp.qn.fplat.cn/alpine3.12/' \
  && mkdir /whl && cd /whl \
  && name="numpy-1.20.2-cp38-cp38-linux_x86_64.whl" && wget -O ${name} --timeout=600 -t 5 "${QINIU_URL}/${name}" && pip install --no-cache-dir ${name} \
  && name="pandas-1.2.3-cp38-cp38-linux_x86_64.whl" && wget -O ${name} --timeout=600 -t 5 "${QINIU_URL}/${name}" && pip install --no-cache-dir ${name} \
  && name="scipy-1.6.2-cp38-cp38-linux_x86_64.whl" && wget -O ${name} --timeout=600 -t 5 "${QINIU_URL}/${name}" && pip install --no-cache-dir ${name} \
  && name="scikit_learn-0.24.1-cp38-cp38-linux_x86_64.whl" && wget -O ${name} --timeout=600 -t 5 "${QINIU_URL}/${name}" && pip install --no-cache-dir ${name} \
  && pip install --no-cache-dir nltk==3.7 ${speed} \
  && pip install --no-cache-dir jieba==0.42.1 ${speed} \
  && pip install --no-cache-dir jieba_fast==0.53 ${speed} \
  && pip install --no-cache-dir Jinja2==3.1.1 ${speed} \
  && pip install --no-cache-dir flask==2.1.2 ${speed} \
  && pip install --no-cache-dir sqlalchemy==1.4.36 ${speed} \
  && pip install --no-cache-dir cx_Oracle==8.0.1 ${speed} \
  && echo "********** 删除依赖包" \
  && apk del .build-deps \
  && rm -rf /whl \
  && echo "End"

EXPOSE 8080-8089
ENTRYPOINT ["/entrypoint.sh"]
CMD ["tail", "-f", "/dev/null"]
