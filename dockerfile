#Definicion de SO base y directorio de trabajo
FROM debian:11
WORKDIR /workingdir

# Establecer el entorno no interactivo para apt-get
ENV DEBIAN_FRONTEND=noninteractive

# Instalación de programas base
RUN apt-get update && \
    apt-get install -y curl \
                       gnupg \
                       lsb-release \
                       wget \
                       git \
                       neovim \
                       sed

# Instalación de básicos del entorno dev
RUN apt-get install -y php7.4 \
                       postgresql

# Instalación de XAMPP
RUN wget https://sourceforge.net/projects/xampp/files/XAMPP%20Linux/7.4.30/xampp-linux-x64-7.4.30-1-installer.run && \
    chmod 755 xampp-linux-x64-7.4.30-1-installer.run && \
    printf "Y\n" | ./xampp-linux-x64-7.4.30-1-installer.run && \
    rm xampp-linux-x64-7.4.30-1-installer.run

# Instalación de Node
ARG DEBIAN_FRONTEND=teletype
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt-get install -y nodejs
ENV DEBIAN_FRONTEND=noninteractive

# Instalacion de Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
    php -r "unlink('composer-setup.php');"

# Configuración de PostgreSQL y PhpPgAdmin
RUN echo "postgres:postgres" | chpasswd && \
    service postgresql start && \
    su postgres -c "psql -c \"ALTER USER postgres PASSWORD 'postgres';\"" 

# Limpiar el sistema
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir -p /AcademiApp && \
    cd /AcademiApp && \
    touch TodoOK

# Script de inicio
COPY entrypoint.sh /entrypoint.sh 
RUN chmod +x /entrypoint.sh

# CMD para ejecutar el script de inicio
CMD ["/entrypoint.sh"]