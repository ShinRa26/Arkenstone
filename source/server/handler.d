module server.handler;

import std.stdio;
import std.socket;
import core.thread;
import std.conv : to;
import std.array : split;

class Handler : Thread {
public:
    this(Socket client) {
        super(&run);
        this.client = client;
    }

    ~this() {
        this.client.shutdown(SocketShutdown.BOTH);
        this.client.close();
    }

private:
    Socket client;
    ubyte[] buffer = new ubyte[256];

    void run() {
        while(true) {
            auto msg = readFromClient();
            if (msg is null) {
                break;
            }
            parseMessage(msg);
            clearBuffer(buffer);
        }

        destroy(this);
    }

    string readFromClient() {
        immutable auto recv = this.client.receive(buffer);
        if (recv == -1 || recv == 0) {
            writefln("Client %s has disconnected from the server.\n", this.client.remoteAddress().toAddrString());
            return null;
        }
        return processBuffer(buffer);
    }

    void parseMessage(string msg) {
        auto tags = msg.split(": ");

        switch(tags[0]) {
            case "INIT":
                writefln("Init command received from %s\n", tags[1]);
                break;
            case "LOG":
                writefln("Logging message received from %s\n", tags[1]);
                break;
            default:
                break;
        }
    }

    string processBuffer(ubyte[] buf) {
        char[] msg;

        foreach(charByte; buf) {

            /// Null byte or new line
            if(charByte == 0 || charByte == 10) {
                break;
            }

            msg~=charByte;
        }

        return to!string(msg);
    }

    void clearBuffer(ubyte[] buf) {
        buf[0..$] = 0x00;
    }
}