#
#    Dockerized http://mediagoblin.org/
#    Copyright (C) Loic Dachary <loic@dachary.org>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as published
#    by the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#FROM debian:jessie
FROM ubuntu:xenial
RUN apt-get update \
&& apt-get install -yqq git-core \
  python python-dev python-lxml \
  python-imaging python-virtualenv \
  npm nodejs-legacy automake nginx \
  sudo \
  python-gi python3-gi \
  gstreamer1.0-tools \
  gir1.2-gstreamer-1.0 \
  gir1.2-gst-plugins-base-1.0 \
  gstreamer1.0-plugins-base \
  gstreamer1.0-plugins-good \
  gstreamer1.0-plugins-ugly \
  gstreamer1.0-plugins-bad \
  gstreamer1.0-libav \
  python-gst-1.0 \
  libsndfile1-dev libasound2-dev \
  libgstreamer-plugins-base1.0-dev \
  python-numpy python-scipy \
  poppler-utils \
&& apt-get autoremove -y \ 
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/* \
&& rm /etc/nginx/sites-enabled/default \
&& useradd -c "GNU MediaGoblin system account" -d /var/lib/mediagoblin -m -r -g www-data mediagoblin \
&& groupadd mediagoblin && sudo usermod --append -G mediagoblin mediagoblin \
&& mkdir -p /var/log/mediagoblin && chown -hR mediagoblin:mediagoblin /var/log/mediagoblin \
&& mkdir -p /srv/mediagoblin.example.org && chown -hR mediagoblin:www-data /srv/mediagoblin.example.org \
&& cd /srv/mediagoblin.example.org \
&& git clone http://git.savannah.gnu.org/r/mediagoblin.git \
&& cd /srv/mediagoblin.example.org/mediagoblin \
&& git checkout stable \
&& git submodule sync \
&& git submodule update --force --init --recursive \
&& ./bootstrap.sh \
&& ./configure –with-python3 \
&& make \
&& bin/easy_install flup \
&& ln -s /var/lib/mediagoblin user_dev \
&& bash -c 'cp -av mediagoblin.ini mediagoblin_local.ini && cp -av paste.ini paste_local.ini' \
&& perl -pi -e 's|.*sql_engine = .*|sql_engine = sqlite:////var/lib/mediagoblin/mediagoblin.db|' mediagoblin_local.ini \
&& cd /srv/mediagoblin.example.org/mediagoblin \
#
# Video plugin
#
&& echo '[[mediagoblin.media_types.video]]' | tee -a mediagoblin_local.ini \
#
# Audio plugin
#
&& echo '[[mediagoblin.media_types.audio]]' | tee -a mediagoblin_local.ini \
&& bin/pip install scikits.audiolab \
#
# PDF plugin
#
&& echo '[[mediagoblin.media_types.pdf]]' | tee -a mediagoblin_local.ini \
# cleanup
&& chown -R mediagoblin. /srv/mediagoblin.example.org \
&& echo 'ALL ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
#

ADD docker-nginx.conf /etc/nginx/sites-enabled/nginx.conf

EXPOSE 80

ADD docker-entrypoint.sh /entrypoint.sh

CMD ["/entrypoint.sh"]
