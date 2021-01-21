Coturn TURN server Docker image
===============================
This image is based on [github.com/instrumentio/coturn-docker-image](https://github.com/instrumentisto/coturn-docker-image) licensed under [Blue Oak v1](https://github.com/instrumentisto/coturn-docker-image/blob/master/LICENSE.md)

It is designed to be run on normal Consumer ISP connections, where the public IP changes on a regular basis. This image will detect the change and restart turn automatically.
## What is Coturn TURN server?

The TURN Server is a VoIP media traffic NAT traversal server and gateway. It can be used as a general-purpose network traffic TURN server and gateway, too.

> [github.com/coturn/coturn](https://github.com/coturn/coturn)
## How to use this Image
This image adds the [s6-overlay](https://github.com/just-containers/s6-overlay) as init system, to handle turnserver as well as a script to detect IP Address changes.

To run Coturn TURN server just start the container:
```
docker run -d --network=host \
    -v ${DOCKER_VOLUME_WITH_TURN_CONF}:/var/run/coturn/
    -e TURN_CONFIG=/var/run/coturn/coturn.conf
    -e CHECK_INTERVAL="500"
    dexxter1911/dynamic-coturn
```
`--network=host` is  highly recommended as turn a lot of ports forwarded and docker does not handle that very well.
### Environment Variables
Following env vars are available:

`TURN_CONFIG` specifies the location of your turnserver config (commandline arguments are NOT supported currently). `external-ip` is being set automatically to your external IP Address.

`CHECK_INTERVAL` specifies the time between IP checks in seconds (default: 180).

## Example
This example uses Kubernetes as orchestrator.

configMap.yml
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: coturn-conf
data:
  coturn.conf: |
    log-file=stdout
    relay-ip={INTERNAL_K8_HOST_IP}
    tls-listening-port=5349
    min-port=49160
    max-port=49200
    use-auth-secret
    static-auth-secret=SuperSecureSecretCHANGEME
    realm=turn.example.com:5349
    cert=/var/run/secret/tls.crt
    pkey=/var/run/secret/tls.key
    no-udp
    no-cli
```
deployment.yaml
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: coturn
spec:
  selector:
    matchLabels:
      app: coturn
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: coturn
    spec:
      hostNetwork: true
      containers:
        - image: dexxter1911/dynamic-coturn:latest
          name: turn
          env:
          - name: TURN_CONFIG
            value: /etc/coturn.conf
          - name: CHECK_INTERVAL
            value: "500"
          volumeMounts:
          - name: cert
            mountPath: /var/run/secret
            readOnly: true
          - name: conf
            mountPath: /etc/coturn.conf
            subPath: coturn.conf
      volumes:
      - name: cert
        secret:
          secretName: example.com
      - name: conf
        configMap:
          name: coturn-conf
          items:
          - key: coturn.conf
            path: coturn.conf
```