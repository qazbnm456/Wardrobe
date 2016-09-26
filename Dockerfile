FROM phusion/passenger-customizable
MAINTAINER Boik Su "boik@tdohacker.org"

ENV HOME /root
ENV RAILS_ENV production

CMD ["/sbin/my_init"]

#   Build system and git.
RUN /pd_build/utilities.sh
#   Ruby support.
RUN /pd_build/ruby-2.3.1.sh

WORKDIR /tmp
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN chown -R app.app /tmp \
  && gem install bundler \
  && bundle install --jobs 40 --retry 10

# Enable the Nginx service.
RUN rm -f /etc/service/nginx/down \
  && rm /etc/nginx/sites-enabled/default

COPY wardrobe.conf /etc/nginx/sites-available/wardrobe.conf
COPY rails-env.conf /etc/nginx/main.d/rails-env.conf

COPY . /home/app/wardrobe
WORKDIR /home/app/wardrobe
RUN chown -R app:app /home/app/wardrobe \
  && sudo -u app RAILS_ENV=production bundle exec rake assets:precompile \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
