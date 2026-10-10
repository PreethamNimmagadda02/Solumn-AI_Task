# Release checklist

Owner: ops-team. Applies to every change under `deploy/`.

1. Regenerate `deploy/rendered.yaml` with `bin/render` before you finish. The
   release job reads that file, not the renderer.
