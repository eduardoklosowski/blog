FROM r-base:4.2.3

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends libfontconfig-dev; \
    rm -rf /var/lib/apt/lists/*

RUN Rscript -e "install.packages('svglite')"
