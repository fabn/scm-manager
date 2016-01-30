# SCM Manager

Docker image used to provide a ready to run [SCMManager](https://bitbucket.org/sdorra/scm-manager/wiki/Home) instance.

Heavily inspired by [this repository](https://github.com/sonatype/docker-nexus).

Simply run

```
docker run -d -p 8080:8080 --name scm-manager fabn/scm-manager
```

### Persist Data

See [Managing Data in Containers](https://docs.docker.com/userguide/dockervolumes/) for additional information.

  1. *Use a data volume container*.  Since data volumes are persistent
  until no containers use them, a container can created specifically for
  this purpose.  This is the recommended approach.

  ```
  $ docker run -d --name scm-data fabn/scm-manager echo "data-only container for SCM"
  $ docker run -d -p 8081:8080 --name scm-manager --volumes-from scm-data fabn/scm-manager
  ```

To take a volume backup see https://docs.docker.com/engine/userguide/dockervolumes/#backup-restore-or-migrate-data-volumes

### To import initial data from an existing installation

```
# This will create the data container if not already created
docker run -d --name scm-data fabn/scm-manager echo "data-only container for SCM"

# This will give your pwd mounted at /source and destination directory mounted as /data (coming from VOLUME in Dockerfile)
# when copying data remember to change the uid for files to 300 (also coming from Dockerfile)
docker run --rm -it --volumes-from scm-data -v $(pwd):/source centos:centos7 bash

# In docker bash
rsync -avz /source/ /data
chown -R 300 /data
```

