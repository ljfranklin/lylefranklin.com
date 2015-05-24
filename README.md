## lylefranklin.com

<a href="https://travis-ci.org/ljfranklin/middleman-homepage"><img src="https://travis-ci.org/ljfranklin/middleman-homepage.svg" alt="Build Status"></a>

A static middleman app deployed as my personal homepage. My main focus was making the site load as fast as possible. To that end, the app includes the following filesize optimizations:

- The two largest components, angular and bootstrap, are fetched from a CDN.
- All other JS/CSS are combined and minified into two files, `all.js` and `all.css`.
- All HTML files are also minified.
- Top-level pages (home, work, etc.) are embedded as angular templates within index.html, so they don't require an http request.
  - All nested pages are fetched via AJAX.
- Custom nginx.conf is included to enable the following:
  - On build, finger prints are attached to filenames. Nginx is configured so that the cache for these files never expires.
  - On build, a precompiled gzip file is generated beside each normal file. Nginx is configured to serve these .gz files instead for clients that support gzip.

### Prerequisites

1. Install Docker: https://docs.docker.com/installation/
2. Pull docker image: `docker pull ljfranklin/middleman`

### Commands

Run middleman server with live reload:

```
PORT=4567 ./scripts/docker ./scripts/run-server
```

Compile all files into ./build:
```
./scripts/docker ./scripts/build
```

Clean ./build:
```
./scripts/docker ./scripts/clean
```

Rebuild docker image (required if adding new gems):
```
docker build -t ljfranklin/middleman .
docker push ljfranklin/middleman
```

Push the app to Cloud Foundry (w/zero downtime plugin):
```
go get github.com/concourse/autopilot
cf install-plugin $GOPATH/bin/autopilot
./scripts/push-app YOUR_APP_NAME YOUR_MANIFEST_FILE
```
