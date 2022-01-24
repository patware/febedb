# https://docs.microsoft.com/en-us/sql/connect/odbc/linux-mac/installing-the-microsoft-odbc-driver-for-sql-server?view=sql-server-ver15#17

# --------------------------------------------------------
FROM mcr.microsoft.com/powershell:latest

ENV ACCEPT_EULA=y
ENV SA_PASSWORD=Pass@w0rd
ENV DEBIAN_FRONTEND noninteractive

# Install curl, unzip, and gpg
RUN apt update \
  && apt-get install -y curl unzip wget gnupg software-properties-common
#    && apk add --no-cache curl \
#    && apk add --no-cache unzip \
#    && apk add --no-cache gnupg

RUN echo DOTNET_CLI_TELEMETRY_OPTOUT=1 >> /etc/environment

# RUN locale-gen en_US.UTF-8 \
#  && printf 'LANGUAGE=en_US.UTF-8\nLC_ALL=en_US.UTF-8\n' >> /etc/default/locale

RUN mkdir -p /opt/downloads
WORKDIR /opt/downloads


RUN echo Update apt-get packages with MS packages \
  && curl -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O \
  && dpkg -i packages-microsoft-prod.deb \
  && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
  && add-apt-repository "$(curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list)"


RUN echo Download and install mssql-tools \
  && apt-get update -qq \
  && apt-get install -y mssql-tools \
  && echo PATH="$PATH:/opt/mssql-tools/bin" >> ~/.bash_profile \
  && echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc

RUN echo Download and install SqlPackage \
  && wget -q -O sqlpackage.zip https://aka.ms/sqlpackage-linux \
  && ls -alh \
  && unzip -qq sqlpackage.zip -d /opt/sqlpackage \
  && chmod +x /opt/sqlpackage/sqlpackage \
  && rm sqlpackage.zip

EXPOSE 1433/tcp

COPY ["/febedb.db.init/init.ps1", "/init/init.ps1"]
COPY ["/febedb.db.init/seed.sql", "/init/seed.sql"]

WORKDIR /dacpacs

ENTRYPOINT ["pwsh", "/init/init.ps1"]