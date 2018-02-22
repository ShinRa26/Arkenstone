module server.handler;

import std.stdio;
import std.socket;
import core.thread;
import std.conv : to;

class Handler : Thread {
public:
    this(Socket client) {
        super(&run);
        this.client = client;
    }

    ~this() {

    }

private:
    Socket client;
    ubyte[] buffer = new ubyte[256];

    void run() {
        while(true) {
            string msg = readFromClient();
            parseMessage(msg);
            clearBuffer(buffer);

            /// TODO::Handle disconnects
        }
    }

    string readFromClient() {
        this.client.receive(buffer);
        return processBuffer(buffer);
    }

    void parseMessage(string msg) {
        /// TODO::Parse message for tags
        /// TODO::Create logs files/folders
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