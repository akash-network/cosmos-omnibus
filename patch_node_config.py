import subprocess
import random
import os
import sys
import toml
import urllib.request
import urllib
import json

data = toml.load(sys.stdin)
sync_url = os.environ.get('RPC_LIST', '')
timeout = float(os.environ.get('HTTP_TIMEOUT', '30.0'))

def state_sync():
    if not sync_url:
        sys.stderr.write("Invalid RPC list url: %s\n" % (sync_url,))
        toml.dump(data, sys.stdout)
        exit()

    if 'statesync' in data.keys():
        sys.stderr.write("RPC Servers: %s\n" % (sync_url,))
        orig_sync_servers = [y for y in (
            x.strip() for x in sync_url.split(",")) if len(y) != 0]

        sync_servers = []
        for sync_server in orig_sync_servers:
            _, server = sync_server.split('://')
            sync_servers.append(server)
        random.shuffle(sync_servers)
        trust_height = None
        trust_hash = None
        for sync_server in sync_servers:
            sys.stderr.write(
                "Querying RPC server for latest block: %s\n" % (sync_server,))
            cmd = "/bin/node"
            args = ['', 'query', 'block', '--node',
                    'tcp://%s' % (sync_server,)]
            with open('/tmp/blocks.json', 'w') as fout:
                proc = subprocess.Popen(
                    executable=cmd, args=args, stdin=subprocess.DEVNULL, stdout=fout, shell=False)

                retcode = proc.wait()
            if retcode == 0:
                with open('/tmp/blocks.json') as fin:
                    blocks_data = json.load(fin)
                last_commit = blocks_data.get(
                    'block', {}).get('last_commit', {})
                trust_height = last_commit.get('height')
                trust_hash = last_commit.get('block_id', {}).get('hash')
            if trust_hash is not None and trust_height is not None:
                break

        if trust_hash is None or trust_height is None:
            sys.stderr.write(
                "Could not query an RPC node to get current blockchain height\n")
            sys.exit(1)
        trust_height = int(trust_height)
        sys.stderr.write("Latest block is %d:%s\n" %
                         (trust_height, trust_hash,))

        sync_servers_str = ','.join('http://%s' % (x,) for x in sync_servers)

        data['statesync'] = {
            'enable': True,
            'rpc_servers': sync_servers_str,
            'trust_height': trust_height,
            'trust_hash':  trust_hash,
            'trust_period': "168h0m0s"
        }


def enable_api():
    if 'api' in data.keys():
        data["api"]["enable"] = True
        data["api"]["swagger"] = True
    else:
        sys.stderr.write("No api config found in given app.toml\n")
        exit(1)


if len(sys.argv) < 2:
    sys.stderr.write("Please pass argument (state_sync/enable_api)\n")
    exit(1)
elif sys.argv[1] == "state_sync":
    state_sync()
elif sys.argv[1] == "enable_api":
    enable_api()
else:
    sys.stderr.write("Invalid argument: %s\n" % (sys.argv[1],))
    exit(1)

toml.dump(data, sys.stdout)
