// skaled trusts loopback for some methods, and every proxied call reaches it from loopback.
// With $rpc_limits on, non-peer calls also get gating and a batch cap, public ones budgets too.

const LOOPBACK_TRUSTED_METHODS = ['setSchainExitTime'];
const GATED_METHODS = [
    'skale_getSnapshot',
    'skale_downloadSnapshotFragment',
    'skale_getSnapshotSignature',
    'skale_shutdownInstance',
];
const GATED_PREFIXES = ['debug_', 'admin_', 'personal_', 'miner_', 'skale_performanceTracking'];
const HEAVY_METHODS = ['eth_getLogs', 'eth_call', 'eth_estimateGas'];

function isGated(method) {
    return GATED_METHODS.includes(method) || GATED_PREFIXES.some((prefix) => method.startsWith(prefix));
}

function limit(r, name) {
    return Number(r.variables[name]);
}

function exceeded(r, key, weight, name) {
    return ngx.shared.rpc_counters.incr(key, weight, 0) > limit(r, name);
}

function reject(r, status, id, code, message) {
    r.headersOut['Content-Type'] = 'application/json';
    r.headersOut['Access-Control-Allow-Origin'] = '*';
    if (status === 429) {
        r.headersOut['Retry-After'] = '1';
    }
    const error = { jsonrpc: '2.0', id: id === undefined ? null : id, error: { code: code, message: message } };
    r.return(status, JSON.stringify(error));
}

// True when the client is over a budget; going over its own budget also bans it.
function limited(r, calls, heavy) {
    const now = Math.floor(Date.now() / 1000);
    const chain = r.variables.rpc_chain;
    const client = `${chain}:${r.remoteAddress}`;
    const bans = ngx.shared.rpc_bans;

    if ((bans.get(client) || 0) > now) {
        return true;
    }
    // the chain-wide cap bans no one, skaled's own global limit backs it up
    if (exceeded(r, `${chain}:*:${now}`, calls, 'rpc_global_rps')) {
        return true;
    }
    if (exceeded(r, `${client}:${now}`, calls, 'rpc_client_rps') ||
        (heavy > 0 && exceeded(r, `${client}:h:${now}`, heavy, 'rpc_heavy_rps'))) {
        bans.set(client, now + limit(r, 'rpc_ban'));
        return true;
    }
    return false;
}

function handle(r) {
    const peer = r.variables.rpc_class === 'peer';
    const upstream = peer ? '@rpc_peer' : '@rpc_upstream';
    if (r.method === 'OPTIONS') {
        // CORS preflight, skaled answers it without reading a body
        return r.internalRedirect(upstream);
    }

    let body;
    try {
        body = JSON.parse(r.requestText);
    } catch (e) {
        // skaled may read what njs cannot, so nothing unchecked goes through
        return reject(r, 400, null, -32700, 'parse error');
    }
    const calls = Array.isArray(body) ? body : [body];
    const limits = r.variables.rpc_limits === 'on' && !peer;
    if (limits && (calls.length === 0 || calls.length > limit(r, 'rpc_max_batch'))) {
        return reject(r, 400, null, -32600, 'invalid batch size');
    }

    let heavy = 0;
    for (let i = 0; i < calls.length; i++) {
        const call = calls[i];
        // skaled reads the method as a C string, up to the first NUL
        const method = call && typeof call.method === 'string' ? call.method.split('\0')[0] : '';
        if (LOOPBACK_TRUSTED_METHODS.includes(method) || (limits && isGated(method))) {
            return reject(r, 403, call.id, -32601, 'method not allowed');
        }
        if (HEAVY_METHODS.includes(method)) {
            heavy += 1;
        }
    }

    if (limits && r.variables.rpc_class === 'public' && limited(r, calls.length, heavy)) {
        return reject(r, 429, null, -32005, 'rate limited');
    }
    r.internalRedirect(upstream);
}

export default { handle: handle };
