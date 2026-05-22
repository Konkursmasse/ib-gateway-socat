#!/bin/bash
# Custom entrypoint: launch gnzsnz/ib-gateway upstream entrypoint in background,
# then socat-bridge 0.0.0.0:4003 -> 127.0.0.1:4001 (live)
# so other Railway containers can reach the IB Gateway API socket via internal DNS.

# Start original entrypoint in background.
# gnzsnz's run.sh lives at $HOME/scripts/run.sh
/home/ibgateway/scripts/run.sh &
UPSTREAM_PID=$!

# Wait until IB Gateway is listening on 127.0.0.1:4001 (live) or :4002 (paper)
echo "[socat-bridge] waiting for IB Gateway API socket..."
for i in $(seq 1 600); do
  if ss -tln 2>/dev/null | grep -qE '127\.0\.0\.1:400[12]'; then
    echo "[socat-bridge] IB Gateway listening — starting bridges"
    break
  fi
  sleep 2
done

# Bridge: 0.0.0.0:4003 -> 127.0.0.1:4001 (live)
#         0.0.0.0:4004 -> 127.0.0.1:4002 (paper)
socat TCP-LISTEN:4003,bind=0.0.0.0,reuseaddr,fork TCP:127.0.0.1:4001 &
socat TCP-LISTEN:4004,bind=0.0.0.0,reuseaddr,fork TCP:127.0.0.1:4002 &
echo "[socat-bridge] bridges active: 4003->4001 (live), 4004->4002 (paper)"

# Wait on upstream — if it exits, container exits too
wait $UPSTREAM_PID
