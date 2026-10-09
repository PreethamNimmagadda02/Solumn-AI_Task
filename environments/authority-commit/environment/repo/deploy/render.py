"""Render the deploy manifest into a rollout spec."""


def render_spec(manifest):
    """Build the rollout spec from a parsed deploy manifest."""
    spec = {
        "name": manifest["name"],
        "image": f"{manifest['name']}:{manifest['version']}",
        "port": manifest["port"],
    }
    # BUG: `replicas` is dropped from the rendered spec; it should be copied
    # from the manifest like the other fields above.
    return spec
