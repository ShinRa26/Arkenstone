import server.arkenstone;
import server.filehandler;

/// Connection address
static string ADDR = "127.0.0.1";

/// Port to bind to on address
static ushort PORT = 9000;

/// TODO::Add in the periodic backup to a remote location
void main() {
	auto arkenstone = new Arkenstone(ADDR, PORT);
	arkenstone.run();
}
