#!/usr/bin/env python

import BaseHTTPServer
import SimpleHTTPServer
import SocketServer
import os
import logging
import json

#Setup logging
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)
handler = logging.FileHandler('/var/log/microservice.log')
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
handler.setFormatter(formatter)
logger.addHandler(handler)

os.chdir('/opt/clev_microservice')

logger.info('Gathering node information')
path_dict = json.loads(open('devices.json').read())

logger.info('Dictionary built')
logger.debug('\n' + str(path_dict))

#Create concurrent server
class ThreadingSimpleServer(SocketServer.ThreadingMixIn, BaseHTTPServer.HTTPServer):
    pass

#Overiding do_GET to remove MAC config file based on IP of incoming request machine
class PxeHandler(SimpleHTTPServer.SimpleHTTPRequestHandler):
    def do_GET(self):
        logger.info(self.path + " is being requested from " + self.client_address[0])

        if self.path in path_dict and 'answers.cfg' in self.path:
            path = self.path
            try:
                os.remove("/var/lib/tftpboot/pxelinux.cfg/%s" % path_dict[path])
                logger.info('Removing ' + path + 's MAC Adress: ' + path_dict[path])
                path_dict.pop(path, None)
            except OSError as e:
                logger.info(e)

        return SimpleHTTPServer.SimpleHTTPRequestHandler.do_GET(self)

server = ThreadingSimpleServer(('{{ pxe.tftp_server }}', 8080), PxeHandler)

#Start the server in the correct directory
logger.info('Starting server')
server.serve_forever()
