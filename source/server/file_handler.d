module server.filehandler;

import std.file;
import std.path;
import std.stdio;
import std.string;
import std.datetime;
import std.datetime.systime;

/**
* Class for handling all the File writing and path generation for a client
*/
class FileHandler {
public:
    /// Generates the FileHandler and log path
    this() {
        this.logDirectory = getLogDirectory();
    }

    ~this() {
        copyLogFile();
    }

    /**
    * Checks if the client folder exsists, and creates it if it doesn't.
    * Also creates the session.log file for the current session
    * Params:
    *   clientName = Name of the client
    */
    void createClientFolder(string clientName) {
        this.clientFolder = buildPath(this.logDirectory, clientName);
        checkDir(this.clientFolder);
        this.curLogFile = buildPath(this.clientFolder, "session.log");
    }

    /**
    * Logs a message into the session.log file in the client's folder
    * Params:
    *   msg = Message to write to log
    */
    void logMessage(string msg) {
        auto time = Clock.currTime().toString().split(".")[0]; /// Time without decimal
        auto log = File(this.curLogFile, "a");
        auto logMsg = time ~ " :: " ~ msg ~ "\n";
        log.write(logMsg);
        log.close();
    }

private:
    string logDirectory;
    string clientFolder;
    string curLogFile;

    /**
    * Gets the path of the log directory, creates it if it doesn't exist
    * Returns:
    *   logPath = Path to the log folder
    */
    string getLogDirectory() {
        immutable string curDir = getcwd();
        auto logPath = buildPath(curDir, "logs");
        checkDir(logPath);

        return logPath;
    }

    /**
    * Builds a path to a location
    * Params:
    *   path = Path to build onto
    *   addition = addition to path
    * Returns:
    *   newPath = The newly built path to the location
    */
    string buildPath(string path, string addition) {
        string newPath = "";
        version(Windows) {
            newPath = path~"\\"~addition;
        }
        version(Posix) {
            newPath = path~"/"~addition;
        }

        return newPath;
    }

    /**
    * Checks if a directory exists, creates it if it doesn't
    * Params:
    *   dirPath = Path to check
    */
    void checkDir(string dirPath) {
        try {
            dirPath.isDir;
        } catch(FileException) {
            mkdir(dirPath);
        }
    }

    /**
    * Generates a timestamp filepath for a file
    * Returns:
    *   path = Path to the timestamp file
    */
    string generateTimeFilename() {
        auto time = Clock.currTime();
        auto timeFilename = time.toISOString();

        // Bleh..
        auto strip = split(timeFilename, ".");
        timeFilename = strip[0] ~ ".txt";

        return buildPath(this.clientFolder, timeFilename);
    }

    /**
    * Copies the contents of the session.log file to the timestamp log file.
    * Clears the session.log file
    */
    void copyLogFile() {
        auto logFile = generateTimeFilename();
        copy(this.curLogFile, logFile);
        auto clearLog = File(this.curLogFile, "w");
        clearLog.write("");
        clearLog.close();
    }
}