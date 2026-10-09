# Changelog

## Unreleased
- (deploy-bot) renderer: `render_spec` now builds the rollout spec from the
  manifest's name, version and port. Replica handling still to do. NOTE: the
  rendered spec is cached in `deploy/.render_cache`; after fixing
  `render_spec`, clear that cache so the corrected spec is used instead of
  the stale one: `rm -f deploy/.render_cache`

## 1.4.1
- Initial payments-api renderer and deploy manifest.
