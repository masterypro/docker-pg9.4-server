# docker-pg9.4-server

Being based on phusion\baseimage image (despite docker's best practices) this image contains postgres9.4 inside. sshd enabled.

# Usage

Just run

```
docker run fefelovgroup/docker-pg9.4-server

```

# Specific notes

You have to add your personal ssh keys (by default there are no keys).

You may add .sh or .sql files into container bootstrap folder which is /docker-entrypoint-initdb.d to support extension creation etc.

You also may add volume mapping on host system.
