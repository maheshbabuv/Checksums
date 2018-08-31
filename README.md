# Checksums
Integrates with Finder application on macOS to compute checksums.

Details:

* Uses FinderSync framework to integrate contextual menu item called Checksums for right click menu.
* When right clicked on any file present under user's directory, Checksums contextual menu item is presented.
* Computes checksum(SHA-1, SHA-256, MD5) of the files using OpenSSL.
* Contextual menu item is not shown for directory or when multiple files are selected and then right clicked.
* Requires OpenSSL library to be present under project directory for building.
* Requires minimum Xcode version 8.3.3.
