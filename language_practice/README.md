# language_practice



Notes: 

From https://www.mongodb.com/docs/v7.0/tutorial/install-mongodb-on-os-x/
MongoDB community addition
Installed via brew
    brew install mongodb-community@7.0
    
Start/Stop    
    brew services start mongodb-community@7.0
    brew services stop mongodb-community@7.0

To run mongod
    mongod --config /opt/homebrew/etc/mongod.conf --fork


MongoDB Compass installed
From https://www.mongodb.com/try/download/compass
1. Downloaded and installed (overlaided older version - from AfA?)
2. Fired it up and created new connection string
   mongodb://localhost:27017/
3. 

Used mongo_dart for local connection
Testing via MacOS failed as couldn't get app to connect to Mongo
Found reference  https://stackoverflow.com/a/65866640
Needed to add the following to both
    macos/Runner/DebugProfile.entitlements
    macos/Runner/Release.entitlements
    <key>com.apple.security.network.client</key>
    <true/>


Mongo Setup for MongoDB Atlas (free Mongo server)

1.IP Whitelisting: If you are using MongoDB Atlas, 
you must whitelist your machine's IP address in the Atlas 
dashboard under Network Access. If you are developing locally, 
you may need to allow 0.0.0.0/0 (not recommended for production).

2.Special Characters: If your database password contains special characters 
(like @ or :), you must URL-encode them (e.g., @ becomes %40).

3.App Compatibility: The mongo_dart package uses dart:io, meaning it works on Android, 
iOS, Windows, macOS, and Linux, but not on Flutter Web. For Flutter Web, 
consider using the MongoDB Data API (HTTPS) or a backend middleware.

To pass a MongoDB connection string into the Dart/Flutter compile process 
securely (avoiding hardcoded credentials in your source code), 
you should use Environment Defines (--dart-define).
This allows you to inject the string at build time, which is then accessible 
via String.fromEnvironment.

Passing in Mongo connection string from command line
# For Development
flutter run --dart-define=MONGO_CONN_STR="mongodb+srv://user:pass@cluster.mongodb.net/dbname"

# For Release Build
flutter build apk --dart-define=MONGO_CONN_STR="mongodb+srv://user:pass@cluster.mongodb.net/dbname"