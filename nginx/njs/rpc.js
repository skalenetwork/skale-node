const LOOPBACK_TRUSTED_METHODS = ['setSchainExitTime'];
const METHOD_NOT_FOUND = 'METHOD_NOT_FOUND: The method being requested is not available on this server';
const METHOD_NOT_ALLOWED = 'method not allowed';
const NOT_EXECUTED = 'not executed: the batch has a refused call';
const GATED_METHODS = [
    'skale_getSnapshot',
    'skale_downloadSnapshotFragment',
    'skale_getSnapshotSignature',
    'skale_shutdownInstance',
];
const GATED_PREFIXES = ['debug_', 'admin_', 'personal_', 'miner_', 'skale_performanceTracking'];
const HEAVY_METHODS = ['eth_getLogs', 'eth_getFilterLogs', 'eth_call', 'eth_estimateGas'];

function isGated(method) {
    return GATED_METHODS.includes(method) || GATED_PREFIXES.some((prefix) => method.startsWith(prefix));
}

// skaled reads the method as a C string, up to the first NUL
function methodOf(call) {
    return call && typeof call.method === 'string' ? call.method.split('\0')[0] : '';
}

function refusal(method, limits) {
    if (LOOPBACK_TRUSTED_METHODS.includes(method)) {
        return METHOD_NOT_FOUND;
    }
    return limits && isGated(method) ? METHOD_NOT_ALLOWED : '';
}

function limit(r, name) {
    return Number(r.variables[name]);
}

function exceeded(r, key, weight, name) {
    return ngx.shared.rpc_counters.incr(key, weight, 0) > limit(r, name);
}

// in skaled's key order; an id a JS number cannot hold exactly is answered as null
function rpcError(call, code, message) {
    const id = call !== null && typeof call === 'object' ? call.id : null;
    const echoed = typeof id === 'string' || Number.isSafeInteger(id) ? id : null;
    return { error: { code: code, message: message }, id: echoed, jsonrpc: '2.0' };
}

function reply(r, status, body) {
    r.headersOut['Content-Type'] = 'application/json';
    r.headersOut['Access-Control-Allow-Origin'] = '*';
    if (status === 429) {
        r.headersOut['Retry-After'] = '1';
    }
    r.return(status, JSON.stringify(body));
}

// True when the client is over a budget; going over its own budget also bans it.
function limited(r, calls, heavy) {
    const now = Math.floor(Date.now() / 1000);
    const chain = r.variables.rpc_chain;
    const client = `${chain}:${r.remoteAddress}`;
    const bans = ngx.shared.rpc_bans;

    if (bans.has(client)) {
        return true;
    }
    if (exceeded(r, `${client}:${now}`, calls, 'rpc_client_rps') ||
        (heavy > 0 && exceeded(r, `${client}:h:${now}`, heavy, 'rpc_heavy_rps'))) {
        const ban = limit(r, 'rpc_ban') * 1000;
        if (ban > 0) {
            bans.set(client, 1, ban);
        }
        return true;
    }
    // only calls within their client's budget count here, and the chain-wide cap bans no one
    return exceeded(r, `${chain}:*:${now}`, calls, 'rpc_global_rps');
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
        return reply(r, 400, rpcError(null, -32700, 'parse error'));
    }
    const batch = Array.isArray(body);
    const calls = batch ? body : [body];
    const limits = r.variables.rpc_limits === 'on' && !peer;
    if (limits && (calls.length === 0 || calls.length > limit(r, 'rpc_max_batch'))) {
        return reply(r, 400, rpcError(null, -32600, 'invalid batch size'));
    }

    const methods = calls.map(methodOf);
    const refusals = methods.map((method) => refusal(method, limits));
    if (refusals.some((message) => message)) {
        const answers = calls.map((call, i) =>
            refusals[i] ? rpcError(call, -32601, refusals[i]) : rpcError(call, -32000, NOT_EXECUTED));
        return reply(r, refusals.includes(METHOD_NOT_ALLOWED) ? 403 : 200, batch ? answers : answers[0]);
    }

    const heavy = methods.filter((method) => HEAVY_METHODS.includes(method)).length;
    if (limits && r.variables.rpc_class === 'public' && limited(r, calls.length, heavy)) {
        return reply(r, 429, rpcError(null, -32005, 'rate limited'));
    }
    r.internalRedirect(upstream);
}

export default { handle: handle };
