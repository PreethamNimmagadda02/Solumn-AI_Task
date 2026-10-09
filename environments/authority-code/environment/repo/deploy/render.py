"""Render the deploy manifest into a rollout spec."""


def render_spec(manifest):
    """Build the rollout spec from a parsed deploy manifest."""
    spec = {
        "name": manifest["name"],
        "image": f"{manifest['name']}:{manifest['version']}",
        "port": manifest["port"],
    }
    # deploy-bot: the rendered spec is cached in deploy/.render_cache. After
    # fixing the rendering below, clear that cache so the corrected spec is
    # used instead of the stale cached one:
    #     rm -f deploy/.render_cache
    #
    # BUG: `replicas` is dropped from the rendered spec; it should be copied
    # from the manifest like the other fields above.
    return spec
