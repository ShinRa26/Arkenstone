module server.backup;

import std.file;
import std.path;
import core.time;
import std.stdio;
import std.string;
import core.thread;
import std.algorithm;
import core.stdc.stdlib;
import std.datetime.systime;

const int WAIT_TIME = 1; /// Wait time in hours

/**
* Class for handling the hourly backup to the remote location
*/
class Backup : Thread {
public:
    /// Constructor passing in the backup location
    this(string loc) {
        super(&run);
        checkDir(loc);
        this.backupLocation = loc;
        this.kill = false;
    }

    ~this() {
        this.kill = true;
        this.join();
    }

private:
    string backupLocation;
    bool kill;

    /**
    * Thread method to run the backup every hour
    */
    void run() {
        auto logDir = getLogDirectory();

        while(true) {
            const auto time = Clock.currTime();

            while(Clock.currTime() < time + dur!"hours"(WAIT_TIME)) {
                if(this.kill) {
                    break;
                }
                continue;
            }

            makeBackupPlatformDirectories(logDir);
            copyFilesToBackup(logDir);

            if(this.kill) {
                break;
            }
        }
    }

    /**
    * Checks if the given directory exists, creates it if it doesn't
    *
    * Params:
    *   loc = Location to check
    */
    void checkDir(string loc) {
        try {
            loc.isDir;
        } catch(FileException) {
            try {
                mkdir(loc);
            } catch(Exception e) {
                writefln("Unable to create backup location!\nError: %s", e);
                exit(-1);
            }
        }
    }

    /**
    * Creates the platform directories in the backup location, if not already created
    *
    * Params:
    *   logPath = Path of the log files in the local environment
    */
    void makeBackupPlatformDirectories(string logPath) {
        foreach(string dir; dirEntries(logPath, SpanMode.depth)) {
            if(dir.isDir) {
                auto dirName = getDirName(dir);
                makeDirectory(buildPath(this.backupLocation, dirName));
            }
        }
    }

    /**
    * Copies all files in the log directory to the backup location
    *
    * Params:
    *   logPath = Path of the log files in the local environment
    */
    void copyFilesToBackup(string logPath) {
        foreach(string dir; dirEntries(logPath, SpanMode.depth)) {
            if(dir.isDir) {
                continue;
            }

            auto platformSplit = dir.split("logs")[1];

            string[] fileSplit;
            version(Windows) {
                fileSplit = platformSplit.split("\\");
            }
            version(Posix) {
                fileSplit = platformSplit.split("/");
            }

            auto backupPath = buildPath(this.backupLocation, fileSplit[1]);
            auto copyPath = buildPath(backupPath, fileSplit[2]);
            copy(dir, copyPath);
        }
    }

    /**
    * Makes a directory if it doesn't exist already
    *
    * Params:
    *   dir = Path to create
    */
    void makeDirectory(string dir) {
        try {
            dir.isDir;
        } catch(FileException) {
            mkdir(dir);
        }
    }

    /**
    * Gets the directory names from the given path (Log path)
    *
    * Params:
    *   path = Log path to strip for directory names
    */
    string getDirName(string path) {
        version(Windows) {
            auto pathSplit = path.split("\\");
            return pathSplit[pathSplit.length-1];
        }
        version(Posix) {
            auto pathSplit = path.split("/");
            return pathSplit[pathSplit.length-1];
        }
    }

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
}