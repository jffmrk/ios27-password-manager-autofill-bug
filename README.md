# iOS Password Manager AutoFill bug demo

Minimal UIKit app for reproducing an iOS Password Manager AutoFill bug.

## Demo

https://github.com/user-attachments/assets/dcf89954-63ca-42f4-8fe2-6242b4d545cb

## Requirements

Install Python 3 and Cloudflare's tunnel client with Homebrew:

```bash
brew install python cloudflared
```

You also need Xcode 27.

## Run order

1. From the repo root, start the local AASA server and a Cloudflare tunnel:

   ```bash
   ./bin/serve-docs
   ```

   Quick tunnels get a new `*.trycloudflare.com` hostname each time. To use a named tunnel you already routed to a custom domain:

   ```bash
   ./bin/serve-docs --tunnel YOUR_TUNNEL_NAME --host your.custom.domain
   ```

   This serves `docs/` on localhost, publishes it through `cloudflared`, and writes the hostname into `Constants.xcconfig`. Named-tunnel metrics do not include the public hostname, so `--host` is required in that mode.

2. Open `AutoFillBugDemo.xcodeproj` in Xcode. In Signing & Capabilities, pick your Development Team, then run the app.

   The build writes `docs/.well-known/apple-app-site-association` using your Team ID and bundle ID. Keep `serve-docs` running so Apple and the device can fetch that file.

Each time a quick tunnel restarts, Cloudflare assigns a new hostname. Rebuild and run the demo app after that so the associated-domain entitlement matches the new host. A named tunnel with a stable `--host` only needs a rebuild when that hostname changes.

## Feedback Assistant

https://feedbackassistant.apple.com/feedback/24795131
