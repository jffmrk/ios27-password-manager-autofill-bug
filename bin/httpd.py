#!/usr/bin/env python3
"""Local HTTP server that serves apple-app-site-association as application/json."""

import argparse
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer


class Handler(SimpleHTTPRequestHandler):
    def guess_type(self, path):
        if path.rstrip("/").endswith("apple-app-site-association"):
            return "application/json"
        return super().guess_type(path)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Serve the current directory over HTTP."
    )
    parser.add_argument(
        "-p",
        "--port",
        type=int,
        default=8080,
        help="TCP port to listen on (default: 8080)",
    )
    args = parser.parse_args()

    server = ThreadingHTTPServer(("127.0.0.1", args.port), Handler)
    print(f"Serving {server.server_address[0]}:{args.port}")
    print("AASA: http://127.0.0.1:%s/.well-known/apple-app-site-association" % args.port)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nStopped.")


if __name__ == "__main__":
    main()
