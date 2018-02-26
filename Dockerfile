FROM openshift/base-centos7

MAINTAINER John Wass <jwass3@gmail.com>

ENV MATLAB_BUILDER_VERSION 0.1
ENV PATH="$PATH:/usr/local/matlab/bin"

LABEL io.k8s.description="Platform for building MATLAB Libraries and Applications" \
      io.k8s.display-name="MATLAB Builder" \
      io.openshift.tags="builder,MATLAB"

RUN yum install -y nano xauth libxt6 redhat-lsb-core \
 && yum clean all -y

COPY ./s2i/bin/ /usr/libexec/s2i

RUN mkdir /usr/local/matlab \
 && chown -R 1001:1001 /usr/local/matlab

USER 1001

CMD ["/usr/libexec/s2i/usage"]
