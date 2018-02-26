module server.handler;

import std.stdio;
import std.socket;
import core.thread;
import std.conv : to;
import std.array : split;

import server.filehandler;

/**
* Server handler for every connected client
*/
class Handler : Thread {
public:
    this(Socket client) {
        super(&run);
        this.client = client;
        this.fh = new FileHandler();
    }

    ~this() {
        this.client.shutdown(SocketShutdown.BOTH);
        this.client.close();
    }

private:
    Socket client; /// Client socket
    FileHandler fh; /// File Handler for logging
    ubyte[] buffer = new ubyte[256]; /// Buffer to read from

    /**
    * Thread method run upon connection
    * Parses the message and performs an action
    */
    void run() {
        while(true) {
            auto msg = readFromClient();
            if (msg is null) {
                break;
            }
            parseMessage(msg);
            clearBuffer(buffer);
        }
        cleanup();
    }

    /**
    * Reads a message from the client and converts it to a string
    * Returns:
    *   processedBuffer = Buffer converted to string
    */
    string readFromClient() {
        immutable auto recv = this.client.receive(buffer);
        if (recv == -1 || recv == 0) {
            writefln("Client %s has disconnected from the server.\n", this.client.remoteAddress().toString());
            return null;
        }
        return processBuffer(buffer);
    }

    /**
    * Parses a message from a client and performs an action
    * Params:
    *   msg = Message to parse
    */
    void parseMessage(string msg) {
        auto tags = msg.split("::");

        /// TODO::Split based off of [PLATFORM_NAME]::[TAG]::MESSAGE (IF ANY)
        switch(tags[1]) {
            case "INIT":
                writefln("New connection from %s (%s)", this.client.remoteAddress().toString(), tags[0]);
                this.fh.createClientFolder(tags[0]);
                break;
            case "LOG":
                this.fh.logMessage(tags[2]);
                break;
            default:
                break;
        }
    }

    /**
    * Converts a byte buffer into a string
    * Params:
    *   buf = Byte buffer to be converted
    *
    * Returns:
    *   msg = Message in string format
    */
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

    /**
    * Zeros the bute buffer
    * Params:
    *   buf = Byte buffer to zero
    */
    void clearBuffer(ubyte[] buf) {
        buf[0..$] = 0x00;
    }

    /**
    * Cleans up by calling the destructors for the filehandler and self
    */
    void cleanup() {
        destroy(this.fh);
        destroy(this);
    }
}