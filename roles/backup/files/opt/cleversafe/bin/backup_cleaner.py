#!/usr/bin/env python
from ConfigParser import ConfigParser
import object_storage
from datetime import datetime
from datetime import date

# Setup config parser
config = ConfigParser()
config.read('../etc/config.ini')

# SL Username, key for Object Storage API calls, and other values loaded from config file
username = config.get('backup', 'ftp_username')
key = config.get('backup', 'ftp_password')
path = config.get('backup', 'ftp_path')
cutoff = config.get('backup', 'cutoff')
location = config.get('backup', 'datacenter')

# Get SL Object Store data
sl_storage = object_storage.get_client(username, key, datacenter=location)

# Iterate through every backup, deleting any backups older than the specified time (default=90 days)
for backup in sl_storage[path].objects():
    last_modified = sl_storage[path][backup.name].properties['last_modified']
    created = datetime.strptime(last_modified.replace(',', ''), '%a %d %b %Y %X %Z')
    delta = datetime.now() - created
    if delta.days > cutoff:
        sl_storage[path][backup.name].delete()
