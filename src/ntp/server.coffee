'use strict';
const udp = require('dgram');
const EventEmitter = require('events');
const Packet = require('./packet');
/**
 * [NTPServer description]
 * @param {[type]} options [description]
 */
class NTPServer extends EventEmitter {
  constructor(options, onRequest) {
    super();
    if (typeof options === 'function') {
      onRequest = options;
      options = {};
    }
    Object.assign(this, {
      port: 123
    }, options);
    this.socket = udp.createSocket('udp4');
    this.socket.on('message', this.parse.bind(this));
    if (onRequest) this.on('request', onRequest);
    return this;
  }
  listen(port, address) {
    this.socket.bind(port || this.port, address);
    return this;
  }
  address() {
    return this.socket.address();
  }
  send(rinfo, message, callback) {
    if (message instanceof Packet) {
      message.mode = Packet.MODES.SERVER; // mark mode as server
      message = message.toBuffer();
    }
    this.socket.send(message, rinfo.port, rinfo.server, callback);
    return this;
  }
  parse(message, rinfo) {
    const packet = Packet.parse(message);
    packet.receiveTimestamp = Date.now();
    this.emit('request', packet, this.send.bind(this, rinfo));
    return this;
  }
}


module.exports = NTPServer;