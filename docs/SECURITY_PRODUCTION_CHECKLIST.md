# Security Production Checklist

Use this checklist before public production launch. Do not write real secrets into repository files.

## Secrets And Environment

- Use a strong `JWT_SECRET`.
- Never commit `.env` files.
- Keep `DATABASE_URL` secret.
- Keep SMS provider credentials secret.
- Keep admin credentials and bootstrap values out of logs and repository files.
- Use only `.env.example` or `.env.production.example` with placeholder values in Git.

## Transport And Network

- Use HTTPS only in production.
- Redirect HTTP traffic to HTTPS.
- Restrict CORS to known production origins.
- Enable and verify server firewall rules.
- Expose only required ports.

## Backend Security

- Keep rate limiting enabled.
- Keep Helmet enabled.
- Disable Swagger in production or restrict it to trusted access.
- SMS OTP must not be returned in production API response.
- Real SMS provider credentials must be stored only in server environment variables.
- Upload file size limits must remain enabled.
- Upload file type validation must remain enabled.
- Admin access must remain protected by authentication and role checks.
- Logs must not include tokens, OTP codes, secrets, provider credentials, or database passwords.

## Database Security

- PostgreSQL user permissions should be minimal for the app.
- Database should not be publicly exposed unless protected by firewall and strict access rules.
- Database backups must be scheduled.
- Backup restore should be tested periodically.

## Operational Security

- Rotate secrets if they are exposed.
- Monitor 4xx/5xx spikes and OTP provider errors.
- Keep server packages updated.
- Run dependency audit later before wider public release.
- Review production logs after every deploy.
