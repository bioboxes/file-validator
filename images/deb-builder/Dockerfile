FROM debian:jessie
MAINTAINER Michael Barton, mail@michaelbarton.me.uk

ENV PACKAGES xz-utils
RUN apt-get update -y && apt-get install -y --no-install-recommends ${PACKAGES}

ADD build /usr/local/bin/

CMD ["build"]
