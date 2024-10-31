`SSH Port Forwarding`: Set up port forwarding to access Keycloak from your local machine's browser.

```bash
ssh -i /path/to/your-key.pem -L 8080:localhost:8080 ubuntu@your-aws-instance-ip
```
