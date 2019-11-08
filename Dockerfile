FROM google/dart

WORKDIR /app

ADD pubspec.* /app/
RUN pub get
ADD . /app
RUN pub get --offline

CMD dart --enable-experiment=non-nullable /app/bin/server.dart
