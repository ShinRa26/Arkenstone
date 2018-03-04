import server.backup;
import server.arkenstone;
import server.filehandler;

import core.time;
import std.stdio;
import std.datetime.systime;

/// Connection address
static string ADDR = "127.0.0.1";

/// Port to bind to on address
static ushort PORT = 9000;


void main(string[] args) {
	if(args.length == 2) {
		auto backup = new Backup(args[1]);
		backup.start();
	}

	auto arkenstone = new Arkenstone(ADDR, PORT);
	arkenstone.run();
}
