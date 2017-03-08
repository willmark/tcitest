#!/usr/bin/env python

import argparse
import boto3
import botocore
import botocore.vendored.requests.packages.urllib3 as urllib3
import socket
import sys
import time
from botocore.client import Config

STATE_OK = 0
STATE_WARNING = 1
STATE_CRITICAL = 2

DEFAULT_SCHEME = socket.gethostname()

def print_metric(scheme, status, response_time, code, timestamp):
    print '%s.status %s %s' % (scheme, status, timestamp)
    print '%s.time %s %s' % (scheme, response_time, timestamp)
    print '%s.code %s %s' % (scheme, code, timestamp)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', '--ip-address', default=None, help='IP of accessor must be provided')
    parser.add_argument('-s', '--scheme', default=DEFAULT_SCHEME)
    parser.add_argument('-p', '--provisioning-code', default='dsnet_config_vault')
    parser.add_argument('-n', '--no-verify', action='store_false')
    parser.add_argument('-c', '--cert-loc', default='')
    parser.add_argument('-t', '--timeout', default=5)
    args = parser.parse_args()

    urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

    response_time = -5
    bucket_name = args.provisioning_code
    key_name = 'temp_data'

    if len(sys.argv) == 1:
        parser.print_help()
        sys.exit(STATE_WARNING)

    verification_setting = args.no_verify
    if args.no_verify and args.cert_loc != '':
        verification_setting = args.cert_loc

    timestamp = int(time.time())
    s3 = boto3.resource('s3', endpoint_url = "https://" + args.ip_address,
        verify = verification_setting,
        config = Config(connect_timeout=int(args.timeout),
                        s3={'addressing_style': 'path'})
    )

    try:
        bucket = s3.Bucket(bucket_name)
        try:
            s3.meta.client.head_bucket(Bucket=bucket_name)
        except botocore.exceptions.ClientError as e:
            if int(e.response['Error']['Code']) == 404:
                s3.create_bucket(Bucket=bucket_name)

        store_time = time.time()
        value_to_store = 'Time: %s' % int(time.time())
        key = s3.Object(bucket_name, key_name)
        key.put(Body=value_to_store)
        store_time = time.time() - store_time

        time.sleep(2)

        retrieve_time = time.time()
        found_object = s3.Object(bucket_name, key_name).get()
        found_value = found_object['Body'].read()
        retrieve_time = time.time() - retrieve_time

        response_time = store_time + retrieve_time

        if found_value == value_to_store:
            print_metric(args.scheme, 1, response_time, 200, timestamp)
        else:
            print_metric(args.scheme, 0, response_time, 600, timestamp)

        key.delete()
    except botocore.exceptions.ClientError as e:
        sys.stderr.write(str(e.response['Error']) + "\n")
        if 'httpStatusCode' in e.response['Error']:
            print_metric(args.scheme, 0, response_time, e.response['Error']['httpStatusCode'], timestamp)
        elif 'Code' in e.response['Error']:
            print_metric(args.scheme, 0, response_time, e.response['Error']['Code'], timestamp)
        else:
            print_metric(args.scheme, 0, response_time, 500, timestamp)
    except botocore.exceptions.NoCredentialsError:
        print_metric(args.scheme, 0, -10, 496, timestamp)
    except botocore.vendored.requests.exceptions.ConnectTimeout:
        print_metric(args.scheme, 0, -10, 408, timestamp)
    except botocore.vendored.requests.exceptions.ConnectionError as e:
        sys.stderr.write(str(e.message) + "\n")
        if e.message[1][0] == 111: # Connection refused (i.e. no accessor pool)
            print_metric(args.scheme, 0, -10, 501, timestamp)
        elif e.message[1][0] == 113: # No route to host
            print_metric(args.scheme, 0, -10, 523, timestamp)
        else:
            print_metric(args.scheme, 0, -10, 500, timestamp)
    except botocore.vendored.requests.exceptions.SSLError:
        print_metric(args.scheme, 0, -10, 495, timestamp)
    except botocore.exceptions.EndpointConnectionError:
        print_metric(args.scheme, 0, -10, 404, timestamp)

    sys.exit(STATE_OK)

if __name__ == "__main__":
    main()

