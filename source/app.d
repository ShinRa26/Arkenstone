import std.stdio;
import std.socket;
import std.string;
import core.thread;

import server.arkenstone;

static string ADDR = "127.0.0.1";
static ushort PORT = 9000;

void main(string[] args) {
	auto ark = new Arkenstone(ADDR, PORT);
	ark.run();
	
}
