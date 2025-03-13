# Kubernetes

## Nginx

### SSL
For the ssl deployment is is required you have the certificates in the folder of the nginx configuration and that you run the following kubeclt commands.
```shell kubectl create secret tls wildcard-cert-secret --cert=certificate.crt --key=key.key```
```shell kubectl rollout restart deployment ```

