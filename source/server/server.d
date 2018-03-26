module server.arkenstone;

import std.stdio;
import std.socket;
import std.string;

import server.handler;

/// Server class for handling incoming connections
class Arkenstone {
public:
    /***
    * Constructs the server with the address and port
    * Params:
    *   addr = Address to connect to
    *   port = Port to bind to
    */
    this(string addr, ushort port) {
        this.server = new TcpSocket();
        this.address = addr;
        this.port = port;
    }

    ~this() {
        server.shutdown(SocketShutdown.BOTH);
        server.close();
    }

    /***
    * Run the server and accept clients
    */
    void run() {
        assert(this.server.isAlive);
        this.server.blocking = true;
        this.server.bind(new InternetAddress(this.address, this.port));
        writefln("\t\n\t    The king beneath the mountains, the king of carven stone.\t\n
            The lord of silver fountains, shall come into his own.\t\n
            \t*** Arkenstone online %s:%d ***\n", this.address, this.port);
        this.server.listen(1);

        while(true) {
            auto handler = new Handler(server.accept());
            handler.start();
        }
    }

private:
    TcpSocket server;
    string address;
    ushort port;
}