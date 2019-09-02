"use strict";

var fs          = require('fs');
// var mongo       = require('mongodb');
var duplicates;  

var logParser = {};

logParser.parsedTweets      = 0;    // global because it should persist after file reading function returns
logParser.validCount        = 0;    // same
logParser.tweetArray        = [];
logParser.explicitLocations = [];
logParser.locationArray;
logParser.tweetPrototypes   = [];
logParser.mdbCollection     = null;
logParser.batchComplete;
logParser.skippedTweets     = 0;

// sorting tweets
logParser.sortedTweets      = [];
logParser.bufferedTweets    = [];
logParser.discardCount      = 0;
logParser.tweetsDumped      = 0;

// printing speed
logParser.speedString       = "";
logParser.speedStrCount     = 0;

    // Data paths are relative to the current working directory in console,
    // node modules paths (and 'require' calls) are relative to the location 
    // of the main .js file.

    // For extra memory, run with node --max-old-space-size=5000 *.js

// State College
// logParser.filePath = 'spritzerReader.2013.06.17.18.53.noDuplicates.sorted.out';

// US
// logParser.filePath = 'spritzerReader.US.2013.06.21.16.55.out';
// logParser.filePath = 'sorted.fixedHash.out';
// logParser.filePath = 'spritzerReader.2013.06.17.18.53.noDuplicates.sorted.out'; // State College

// big crawler
// logParser.filePath = '/Volumes/SanDisk64/distributedReader.2.0.minerThorin.2015.10.28.out';
// logParser.filePath = '/Volumes/Tera/distributedReader.2.1.twitterCrawler01.2017.12.merged.out';
logParser.filePath = '/media/aku/Data/andrei/movement/distributedReader.2.1.twitterCrawler01.2017.12.merged.out';

// logParser.filePath = '/Users/a_s899/Sasha/noBackup/bigData/twitterSpeedData/speedParser.sorted.fixedHash.out';

// logParser.filePath = "/Users/a_s899/Sasha/noBackup/bigData/experiment.solitude.out";


logParser.init = function () {

    console.log();

    // Initialize web server
    // this.initServer();

    // Load the duplicate file
    // logParser.uniqueDuplicates = require('./spritzerReader.US.2013.06.21.16.55.duplicates.fixedHash.js').uniqueDuplicates;

    // Open the data files
    
    var filePath = logParser.filePath,
        fileDesc = fs.openSync(filePath, 'r');

    // var duplicateFileName = filePath.slice(0, -4) + ".duplicates.out";
    // duplicates = require(duplicateFileName).duplicates;

    batchPrinter.fileName = logParser.filePath.slice(0, -4) + ".movement.out";
    

    // Read through data
    console.log((new Date).toLocaleTimeString() + " " + "Reading " + logParser.filePath);
    this.readData(fileDesc);

    // Read data to mongoDb
    // console.log((new Date).toLocaleTimeString() + " [SERVER] " + "Reading " + logParser.filePath);
    // duplicates = require('./duplicates.out.js').duplicates;
    // this.mdbCollection = logParser.getMongoCollection(fileDesc);

}





logParser.readData = function (fileDesc) {
    
    //
    // Fetch and parse the data file
    //

    // low-level file reading
    var bufferSize  = 104857600,                        // 104857600 = 100MB, 524288000 = 500MB
        dataBuffer  = new Buffer(bufferSize),
        filePos     = null,
        bytesRead,
        separatorPos,
        // separator   = String.fromCharCode(0x0D) +       // CR
        //               String.fromCharCode(0x0A) +       // LF
        //               String.fromCharCode(0x2C) +       // ,
        //               String.fromCharCode(0x0A);        // LF
        separator   = String.fromCharCode(0x2C) +       // ,
                      String.fromCharCode(0x0A);        // LF

    var j,  // buffer character counter for locating the separator
        i;  // unparsed tweets counter

    // extracting and parsing tweets from the buffer
    var concatTweets,
        unparsedTweets,
        numTweets,
        parsedJson;

    // location duplicates
    var duplicateHashes     = [{}],
        hashesLen           = duplicateHashes.length;

    // tweet ID duplicates
    var duplicateIdHashes   = [{}];

    // sorting tweets
    var duplicatesRemoved   = 0;
    // var sortedTweets        = [],
    //     bufferedTweets      = [],
    //     discardCount        = 0;

    // extracting movement records

    var uniqueUsers = {},
        uniqueCount,
        uniqueSpeeds = {},
        lastTweetText,
        lastTweetId,
        tweetIds = {},
        tweetIdString,
        latestTimestamp = 0,
        tweetDelays = {},
        locationHash = {},
        // locationHashes = [{}],
        sortedLocations = [],
        coordCount = 0,
        profileLocationCount = 0,
        matchingCount = 0,
        rawLocationCount = 0;

    fileReaderLoop:
    while (bytesRead = fs.readSync(fileDesc, dataBuffer, 0, dataBuffer.length, filePos)) {

        console.log((new Date).toLocaleTimeString() + " " + dataBuffer.length + " bytes requested, " + bytesRead + " bytes read.");

        // Shrink buffer, if necessary
        if (bytesRead !== dataBuffer.length) {
            console.log((new Date).toLocaleTimeString() + " " + "Shrinking buffer to the number of bytes read.");
            dataBuffer = dataBuffer.slice(0, bytesRead);
        }

        // Locate the last separator
        separatorPos = 0;
        for (j = dataBuffer.length - 1; j > separator.length - 1; j--) {
            // if (dataBuffer[j] === 0x0A && dataBuffer[j - 1] === 0x2C && dataBuffer[j - 2] === 0x0A && dataBuffer[j - 3] === 0x0D) {
            if (dataBuffer[j] === 0x0A && dataBuffer[j - 1] === 0x2C) {
                // separatorPos = j - 3;
                separatorPos = j - 1;
                break;
            }
        }

        //separatorPos = dataBuffer.toString('ascii').lastIndexOf(separator);

        if (separatorPos > 0) {

            // Split the buffer into individual tweets
            concatTweets    = dataBuffer.slice(0, separatorPos).toString();
            unparsedTweets  = concatTweets.split(separator);
            numTweets       = unparsedTweets.length;

            // For each unparsed tweet in the buffer, ...
            for (i = 0; i < numTweets; i++) {

                try {

                    this.parsedTweets++;

                    // 1. Parse the tweet
                    parsedJson = JSON.parse(unparsedTweets[i]);


                    // 2. Check for non-tweets
                    
                    if (!parsedJson.id) {
                        console.log((new Date).toLocaleTimeString() + " [WARNING] " + "Record #" + this.parsedTweets + " following tweet #" + lastTweetId + " is not a tweet.");
                        continue;
                    }

                    this.validCount++;

                    tweetIdString   = parsedJson.id_str;
                    lastTweetId     = tweetIdString;


                    // 3. Locate duplicates

                    // var hashNumberExceeded = logParser.locateDuplicates(duplicateHashes, tweetIdString);

                    // if (hashNumberExceeded) {
                    //     console.log((new Date).toLocaleTimeString() + " [FATAL] " + "Maximum number of hashes exceeded, quitting.");
                    //     break fileReaderLoop;
                    // }


                    // 3.1 Check if duplicates have the same time stamp (should all print 0)

                    // if (duplicates[tweetIdString] === undefined) {

                    //     // do nothing

                    // } else if (duplicates[tweetIdString] === false) {

                    //     duplicates[tweetIdString] = Date.parse(parsedJson.created_at);

                    // } else {

                    //     console.error(duplicates[tweetIdString] - Date.parse(parsedJson.created_at));

                    // }


                    // 4. Skip duplicates

                    // var isDuplicate = duplicates[tweetIdString];

                    // if (isDuplicate !== undefined) {

                    //     if (isDuplicate) {

                    //         // this is a duplicate tweet — its original was spotted earlier
                    //         // console.log((new Date).toLocaleTimeString() + " [SERVER] " + "Skipping tweet #" + tweetIdString + " as a duplicate.");
                            
                    //         duplicatesRemoved++;
                    //         continue;

                    //     } else {

                    //         // this is an original tweet, keep it and update the flag to filter its duplicates
                    //         duplicates[tweetIdString] = true;
                    //     }
                    // }


                    // 5. Check for tweets coming in correct order

                    // currentTimestamp = Date.parse(parsedJson.created_at);

                    // if (currentTimestamp < latestTimestamp) {

                    //     if (tweetDelays[latestTimestamp - currentTimestamp]){
                    //         tweetDelays[latestTimestamp - currentTimestamp]++;
                    //     } else {
                    //         tweetDelays[latestTimestamp - currentTimestamp] = 1;
                    //     }

                    // } else {

                    //     latestTimestamp = currentTimestamp;
                    // }


                    // 6. Sort tweets
                    // logParser.sortTweets(parsedJson, tweetIdString, logParser.sortedTweets, logParser.bufferedTweets, separator);


                    // 7. Collect non-unique locations

                    // var userId = parsedJson.user.id;

                    if (parsedJson.coordinates) {

                        // discard duplicate tweets
                        if (logParser.isDuplicate(duplicateIdHashes, tweetIdString, this.parsedTweets)) {

                            continue;
                        }

                        // process unique tweets
                        rawLocationCount++;

                        var coordArray = parsedJson.coordinates.coordinates;
                        var locationKey = coordArray[0] + " " + coordArray[1];

                        // var placeName = null;
                        // if (parsedJson.place) {
                        //     placeName = parsedJson.place.name;
                        // }

                        // Run a bounding box check
                        // if (coordArray[0] < -77.892466 || coordArray[0] > -77.835732 ||
                        //     coordArray[1] <  40.769687 || coordArray[1] >  40.805494) {

                        //     continue;
                        // }

                        // Process duplicate locations
                        for (var k = 0; k < hashesLen; k++) {

                            var currentHash = duplicateHashes[k];
                            var currentLocation = currentHash[locationKey];

                            if (currentLocation) {

                                //console.log("Duplicate detected");

                                // currentLocation.count++;
                                currentHash[locationKey]++;

                                // if (currentLocation.names[placeName]){
                                //     currentLocation.names[placeName]++;
                                // } else {
                                //     currentLocation.names[placeName] = 1;
                                // }

                                // if (currentLocation.names[userId]){
                                //     currentLocation.names[userId]++;
                                // } else {
                                //     currentLocation.names[userId] = 1;
                                // }

                                break;

                            } else if (k == hashesLen - 1) {

                                currentLocation = 1;

                                // currentLocation = {
                                //     count: 1,
                                //     names: {}
                                // };
                                
                                // currentLocation.names[placeName] = 1;
                                // currentLocation.names[userId] = 1;

                                currentHash[locationKey] = currentLocation;
                            }
                        }
                        
                    }


                    // 7.1 Collect user IDs

                    // var userId = parsedJson.user.id;

                    // for (var k = 0; k < hashesLen; k++) {

                    //     var currentHash = duplicateHashes[k];

                    //     if (currentHash[userId]) {

                    //         currentHash[userId]++;
                    //         break;

                    //     } else if (k == hashesLen - 1) {

                    //         currentHash[userId] = 1;
                    //     }
                    // }


                    // 8. Check for non-empty profile location
                    // if (parsedJson.user.location) {
                    //     profileLocationCount++;
                    // }


                    // 9. Log movement records
                    // logParser.logMovement(parsedJson, uniqueUsers);
                    
                    // if (parsedJson.coordinates) {

                    //     if (uniqueUsers[parsedJson.user.id]) {

                    //         var time1 = uniqueUsers[parsedJson.user.id].time,
                    //             time2 = Date.parse(parsedJson.created_at) - 18000000;           // UTC - 5 hours (18,000,000 ms)

                    //         var lat1 = uniqueUsers[parsedJson.user.id].lat,
                    //             lon1 = uniqueUsers[parsedJson.user.id].lon,
                    //             lat2 = parsedJson.coordinates.coordinates[1],
                    //             lon2 = parsedJson.coordinates.coordinates[0];

                            

                    //         // Calculate distance, duration and speed

                    //         var dist = logParser.greatCircleDistance(lat1, lon1, lat2, lon2) / 1609.0;  // convert meters to miles
                    //         var dur  = (time2 - time1) / 1000.0;                                        // s
                    //         // var speed = Math.round(dist / dur);                                      // m/s
                    //         var speed = dist / (dur / 3600.0);                                          // MPH

                    //         // Round them off
                    //         dist  = Math.ceil(dist);
                    //         speed = Math.ceil(speed);
                            

                    //         // Sanity check

                    //         // var name = uniqueUsers[parsedJson.user.id].name,
                    //         //     msg = uniqueUsers[parsedJson.user.id].msg.replace(/(\r\n|\n|\r)/gm, "");

                    //         if (speed == Infinity) {
                                
                    //             // console.error("i|" + parsedJson.user.id + "|" + name + "|" + (lat1 - lat2) + "|" + (lon1 - lon2) + "|" + (time2 - time1) + "|" + dist + "|" + dur + "|" + msg);

                    //         } else if (isNaN(speed)) {
                                
                    //             // console.error("n|" + parsedJson.user.id + "|" + name + "|" + (lat1 - lat2) + "|" + (lon1 - lon2) + "|" + (time2 - time1) + "|" + dist + "|" + dur + "|" + msg);

                    //         } else if (speed === 0) {

                    //             // Do not include 0 speeds in the final output (0 speeds mean 0 distance - no movement between the two tweets)

                    //         } else {
                                
                    //             // Log movement record
                    //             console.error(time2 + " " + dur + " " + dist + " " + speed + " " + lat1 + " " + lon1 + " " + lat2 + " " + lon2); // time1 + " " + time2 + " " + lat1 + " " + lon1 + " " + lat2 + " " + lon2
                    //         }

                            

                    //         // if (uniqueSpeeds[speed]) {
                    //         //     uniqueSpeeds[speed]++;
                    //         // } else {
                    //         //     uniqueSpeeds[speed] = 1;
                    //         // }

                    //         // if (speed > 2.5) {
                    //         //     console.log((new Date).toLocaleTimeString() + " [SERVER] " + "[SPEED] " + speed + " m/s");
                    //         // }

                    //         // Update user movement record
                    //         uniqueUsers[parsedJson.user.id].time = time2;
                    //         uniqueUsers[parsedJson.user.id].lat  = lat2;
                    //         uniqueUsers[parsedJson.user.id].lon  = lon2;

                    //     } else {

                    //         // Create user movement record

                    //         uniqueUsers[parsedJson.user.id] = {

                    //             time:   Date.parse(parsedJson.created_at) - 18000000,   // UTC - 5 hours (18,000,000 ms)
                    //             lat:    parsedJson.coordinates.coordinates[1],
                    //             lon:    parsedJson.coordinates.coordinates[0],
                    //             msg:    parsedJson.text,
                    //             name:   parsedJson.user.screen_name
                    //         };
                    //     }

                    // }


                    // 10. Dump tweet as GeoJSON
                    // if (parsedJson.coordinates) {

                    //     var geoJsonFeature = {
                    //         type:       "Feature", 
                    //         geometry:   parsedJson.coordinates,
                    //         properties: parsedJson
                    //     };

                    //     console.error(JSON.stringify(geoJsonFeature) + ",\n");
                    // }

                    // if (this.validCount > 3000) {
                    //     break fileReaderLoop;
                    // }


                    // 11. Filter tweets by a timestamp and a bounding box
                    // if (parsedJson.coordinates) {

                    //     var lonFrom     = -98.5,
                    //         lonTo       = -96.5,
                    //         latFrom     =  34.5,
                    //         latTo       =  36.5;

                    //     if (lonFrom < parsedJson.coordinates.coordinates[0] && parsedJson.coordinates.coordinates[0] < lonTo &&
                    //         latFrom < parsedJson.coordinates.coordinates[1] && parsedJson.coordinates.coordinates[1] < latTo) {

                    //         var timeFrom    = Date.parse("Fri May 31 19:00:00 -0500 2013") - 86400000,  // 24 hours
                    //             timeTo      = Date.parse("Fri May 31 19:00:00 -0500 2013") + 86400000;

                    //         if (timeFrom < Date.parse(parsedJson.created_at) && Date.parse(parsedJson.created_at) < timeTo) {
                                
                    //             // Copy matching tweet to file

                    //             var fileName = "mooreTornado.out",
                    //                 tweetString = unparsedTweets[i] + ",\n";

                    //             fs.appendFileSync(fileName, tweetString);

                    //             // Count matching tweets
                    //             matchingCount++;
                    //         }
                    //     }

                    // }

                    // 12. Dump text and coordinates
                    // if (parsedJson.coordinates) {
                    //     console.log(parsedJson.coordinates.coordinates[0] + "  " + parsedJson.coordinates.coordinates[1] + "  " + parsedJson.text);
                    // }


                    // X. Compare the tweets' schema
                    // this.compareSchema(parsedJson);


                    // 14. Separate unique records
                    // logParser.separateUniqueRecords(parsedJson);
                    
                    

                    

                } catch (e) {

                    console.log((new Date).toLocaleTimeString() + " [SERVER] " + "[FATAL] " + "Exception in record #" + this.parsedTweets + " following tweet #" + lastTweetId + ": " + e);
                    console.log(unparsedTweets[i]);
                    //break fileReaderLoop;
                }

                

                // Rotate location hashes
                if (!(this.parsedTweets % 100000)) { 

                    // This guarantees that no hash will be bigger than 100,000
                    // records, but doesn't guarantee that they will be of any
                    // particular size.

                    // console.log("Location hash size check triggered, " + )

                    if (Object.keys(duplicateHashes[hashesLen - 1]).length > 1000000) {

                        hashesLen = duplicateHashes.push({});

                        // if (hashesLen > 5) {

                        //     var hashToTrim = locationHashes[hashesLen - 1 - 10];
                        //     var trimmedHash = {};

                        //     for (var key in hashToTrim) {
                        //         if (hashToTrim[key] > 1) {
                        //             trimmedHash[key] = hashToTrim[key];
                        //         }
                        //     }

                        //     locationHashes[hashesLen - 1 - 10] = trimmedHash;
                        // }

                        console.log((new Date).toLocaleTimeString() + " [SERVER] " + "New location hash added, " + hashesLen + " total.");
                    }
                }

            }

            filePos = (filePos) ? filePos + separatorPos + separator.length : separatorPos + separator.length;

            console.log((new Date).toLocaleTimeString() + " " + this.parsedTweets + " records parsed so far.");
            // console.log((new Date).toLocaleTimeString() + " [SERVER] " + matchingCount + " matching records found so far.");
            console.log((new Date).toLocaleTimeString() + " " + "Moving file position to " + filePos);
            console.log();

        } else {

            console.log((new Date).toLocaleTimeString() + " [FATAL] " + "Separator not found.");
            console.log();

            break;
        }

        // end of file reader loop
    }
    
    

    //
    // Print results
    //

    console.log((new Date).toLocaleTimeString() + " " + "Done reading file.");
    console.log((new Date).toLocaleTimeString() + " " + "A total of " + this.parsedTweets + " records parsed, " + this.validCount + " valid tweets found.")
    console.log((new Date).toLocaleTimeString() + " " + "Last tweet # is " + lastTweetId);
    console.log();

    // 3. Log duplicates to file
    // logParser.printDuplicates(duplicateHashes);

    // 6. Flush sorting buffers
    // logParser.flushSortingBuffers(logParser.sortedTweets, logParser.bufferedTweets, logParser.discardCount, duplicatesRemoved, separator);

    // 9. Flush movement records buffer
    // batchPrinter.flush();
    


    // console.log("Collected speeds:");
    // console.log("A total of " + Object.keys(uniqueUsers).length + " unique users found.");
    // for (var speed in uniqueSpeeds) {
    //     console.log(speed + " " + uniqueSpeeds[speed]);
    // }
    // console.log();


    // console.log("Collected prototypes:");
    // logParser.tweetPrototypes.sort(function(a, b) {
    //     return (b.count - a.count);
    // })
    // console.log(JSON.stringify(logParser.tweetPrototypes));
    // console.log();





    console.log("Duplicate locations are now printed to stderr ...");

    var duplicatesOnly = [];
    var hashLocationCount = 0;

    for (var k = 0; k < hashesLen; k++) {

        var currentHash = duplicateHashes[k];

        duplicatesOnly.push({});

        for (var locationKey in currentHash) {

            hashLocationCount += currentHash[locationKey];

            if (currentHash[locationKey] > 1) {

                duplicatesOnly[k][locationKey] = currentHash[locationKey];
            };
        };


        // for (var locationKey in currentHash) {

        //     if (currentHash[locationKey].count > 1) {

        //         var outputString = locationKey + "|" + currentHash[locationKey].count + "|" + Object.keys(currentHash[locationKey].names).length + "|";

        //         var countHash = {};

        //         for (var placeKey in currentHash[locationKey].names) {

        //             // outputString += "\"" + placeKey + "\" - " + currentHash[locationKey].names[placeKey]  + ", ";

        //             if (countHash[currentHash[locationKey].names[placeKey]]) {
        //                 countHash[currentHash[locationKey].names[placeKey]]++;
        //             } else {
        //                 countHash[currentHash[locationKey].names[placeKey]] = 1;
        //             }
        //         }

        //         outputString += "|";

        //         for (var countKey in countHash) {
        //             outputString += countKey + ": " + countHash[countKey] + ", ";
        //         }
                
        //         console.error(outputString);
        //     }
        // }

    };

    console.error(JSON.stringify(duplicatesOnly));

    console.log("Seen " + rawLocationCount + " locations in the original file, processed " + hashLocationCount + " locations when looking for duplicates.");

    console.log("... done.");
    console.log();


    // sortedLocations.sort(function (a, b) {
    //     return (b[1] - a[1]);
    // });
    // for (var k = 0; k < sortedLocations.length; k++) {
    //     console.log(sortedLocations[k][0] + " " + sortedLocations[k][1]);
    // }
    // console.log();


    // console.log("Count of tweets with 'coordinates' field: " + coordCount);
    // console.log();


    // console.log("Tweets with duplicate IDs:");
    // for (var tweetId in tweetIds) {
    //     if (tweetIds[tweetId] > 1) {
    //         console.log(tweetId + " " + tweetIds[tweetId]);
    //     }
    // }
    // console.log();


    // console.log("Tweet delays:");
    // for (var tweetDelay in tweetDelays) {
    //     console.log(tweetDelay + " " + tweetDelays[tweetDelay]);
    // }
    // console.log();


    
    
}


logParser.separateUniqueRecords = function (parsedJson) {

    if (parsedJson.coordinates) {

        var matchingUser = uniqueUsers[userId];

        if (matchingUser) {

            // Check for duplicates

            if (matchingUser.twId === parsedJson.id_str) {
                return;
            }


            // Calculate distance, duration and speed

            var time1 = matchingUser.time,
                time2 = Date.parse(parsedJson.created_at);// - 18000000;           // UTC - 5 hours (18,000,000 ms)

            var lat1 = matchingUser.lat,
                lon1 = matchingUser.lon,
                lat2 = parsedJson.coordinates.coordinates[1],
                lon2 = parsedJson.coordinates.coordinates[0];

            var cleanText = parsedJson.text.replace(/\r\n|\r|\n|\t/g, " ");

            var dist = logParser.greatCircleDistance(lat1, lon1, lat2, lon2) / 1609.0;  // convert meters to miles
            var dur  = (time2 - time1) / 1000.0;                                        // s
            // var speed = Math.round(dist / dur);                                      // m/s
            var speed = dist / (dur / 3600.0);                                          // MPH

            dist  = dist.toFixed(6);
            speed = speed.toFixed(6);


            // Extract additional variables
            var hashtags = "";
            parsedJson.entities.hashtags.forEach(function (currentHashtag) {
                hashtags += currentHashtag.text + " ";
            });

            var media = "";
            if (parsedJson.entities.media && parsedJson.entities.media[0]) {
                media = parsedJson.entities.media[0].media_url;
            }

            var userMention = "";
            if (parsedJson.entities.user_mentions && parsedJson.entities.user_mentions[0]) {
                userMention = true;
            }


            // Round them off

            // dist  = Math.ceil(dist);
            // speed = Math.ceil(speed);
            

            // Check for unusual speed records

            var name = matchingUser.name,
                msg = matchingUser.msg;

            // if (speed == Infinity) {
                
            //     // infinity means division by 0 - no time elapsed between the two tweets
            //     console.error("i|" + userId + "|" + name + "|" + (lat1 - lat2) + "|" + (lon1 - lon2) + "|" + (time2 - time1) + "|" + dist + "|" + dur + "|" + msg + "|" + cleanText);

            // } else if (isNaN(speed)) {
                
            //     console.error("n|" + userId + "|" + name + "|" + (lat1 - lat2) + "|" + (lon1 - lon2) + "|" + (time2 - time1) + "|" + dist + "|" + dur + "|" + msg + "|" + cleanText);

            // } else if (speed === 0) {

            //     // 0 speeds mean 0 distance - no movement between the two tweets
            //     console.error("z|" + userId + "|" + name + "|" + (lat1 - lat2) + "|" + (lon1 - lon2) + "|" + (time2 - time1) + "|" + dist + "|" + dur + "|" + msg + "|" + cleanText);

            // } else {
                
            //     // Log movement record
            //     // console.error(time2 + " " + dur + " " + dist + " " + speed + " " + lat1 + " " + lon1 + " " + lat2 + " " + lon2); // time1 + " " + time2 + " " + lat1 + " " + lon1 + " " + lat2 + " " + lon2

            //     var movementString = userId + "\t" + name + "\t" + time2 + "\t" + dur + "\t" + dist + "\t" + speed + "\t" + lat1 + "\t" + lon1 + "\t" + lat2 + "\t" + lon2 + "\t" + cleanText + "\n";
            //     batchPrinter.print(movementString);
            // }

            // var movementString = userId + "\t" + name + "\t" + time2 + "\t" + dur + "\t" + dist + "\t" + speed + "\t" + lat1 + "\t" + lon1 + "\t" + lat2 + "\t" + lon2 + "\t" + userMention + "\t" + media + "\t" + hashtags + "\t" + cleanText + "\n";
            var movementString = userId + "\t" + name + "\t" + time2 + "\t" + dur + "\t" + dist + "\t" + speed + "\t" + lat1 + "\t" + lon1 + "\t" + lat2 + "\t" + lon2 + "\n";
            batchPrinter.print(movementString);

            

            // if (uniqueSpeeds[speed]) {
            //     uniqueSpeeds[speed]++;
            // } else {
            //     uniqueSpeeds[speed] = 1;
            // }

            // if (speed > 2.5) {
            //     console.log((new Date).toLocaleTimeString() + " [SERVER] " + "[SPEED] " + speed + " m/s");
            // }

            // Update user movement record
            matchingUser.time    = time2;
            matchingUser.lat     = lat2;
            matchingUser.lon     = lon2;
            matchingUser.msg     = cleanText;

        } else {

            // Create user movement record

            uniqueUsers[userId] = {
                twId:   parsedJson.id_str,
                time:   Date.parse(parsedJson.created_at),// - 18000000,   // UTC - 5 hours (18,000,000 ms)
                lat:    parsedJson.coordinates.coordinates[1],
                lon:    parsedJson.coordinates.coordinates[0],
                msg:    "", //cleanText,
                name:   parsedJson.user.screen_name.replace(/\n|\t/g, " ")
            };
        }

    }

}


logParser.logMovement = function (parsedJson, uniqueUsers) {

    var userId = parsedJson.user.id_str;

    if (parsedJson.coordinates) {

        var matchingUser = uniqueUsers[userId];

        if (matchingUser) {

            // Check for duplicates

            if (matchingUser.twId === parsedJson.id_str) {
                return;
            }


            // Calculate distance, duration and speed

            var time1 = matchingUser.time,
                time2 = Date.parse(parsedJson.created_at);// - 18000000;           // UTC - 5 hours (18,000,000 ms)

            var lat1 = matchingUser.lat,
                lon1 = matchingUser.lon,
                lat2 = parsedJson.coordinates.coordinates[1],
                lon2 = parsedJson.coordinates.coordinates[0];

            var cleanText = parsedJson.text.replace(/\r\n|\r|\n|\t/g, " ");

            var dist = logParser.greatCircleDistance(lat1, lon1, lat2, lon2) / 1609.0;  // convert meters to miles
            var dur  = (time2 - time1) / 1000.0;                                        // s
            // var speed = Math.round(dist / dur);                                      // m/s
            var speed = dist / (dur / 3600.0);                                          // MPH

            dist  = dist.toFixed(6);
            speed = speed.toFixed(6);


            // Extract additional variables
            var hashtags = "";
            parsedJson.entities.hashtags.forEach(function (currentHashtag) {
                hashtags += currentHashtag.text + " ";
            });

            var media = "";
            if (parsedJson.entities.media && parsedJson.entities.media[0]) {
                media = parsedJson.entities.media[0].media_url;
            }

            var userMention = "";
            if (parsedJson.entities.user_mentions && parsedJson.entities.user_mentions[0]) {
                userMention = true;
            }


            // Round them off

            // dist  = Math.ceil(dist);
            // speed = Math.ceil(speed);
            

            // Check for unusual speed records

            var name = matchingUser.name,
                msg = matchingUser.msg;

            // if (speed == Infinity) {
                
            //     // infinity means division by 0 - no time elapsed between the two tweets
            //     console.error("i|" + userId + "|" + name + "|" + (lat1 - lat2) + "|" + (lon1 - lon2) + "|" + (time2 - time1) + "|" + dist + "|" + dur + "|" + msg + "|" + cleanText);

            // } else if (isNaN(speed)) {
                
            //     console.error("n|" + userId + "|" + name + "|" + (lat1 - lat2) + "|" + (lon1 - lon2) + "|" + (time2 - time1) + "|" + dist + "|" + dur + "|" + msg + "|" + cleanText);

            // } else if (speed === 0) {

            //     // 0 speeds mean 0 distance - no movement between the two tweets
            //     console.error("z|" + userId + "|" + name + "|" + (lat1 - lat2) + "|" + (lon1 - lon2) + "|" + (time2 - time1) + "|" + dist + "|" + dur + "|" + msg + "|" + cleanText);

            // } else {
                
            //     // Log movement record
            //     // console.error(time2 + " " + dur + " " + dist + " " + speed + " " + lat1 + " " + lon1 + " " + lat2 + " " + lon2); // time1 + " " + time2 + " " + lat1 + " " + lon1 + " " + lat2 + " " + lon2

            //     var movementString = userId + "\t" + name + "\t" + time2 + "\t" + dur + "\t" + dist + "\t" + speed + "\t" + lat1 + "\t" + lon1 + "\t" + lat2 + "\t" + lon2 + "\t" + cleanText + "\n";
            //     batchPrinter.print(movementString);
            // }

            // var movementString = userId + "\t" + name + "\t" + time2 + "\t" + dur + "\t" + dist + "\t" + speed + "\t" + lat1 + "\t" + lon1 + "\t" + lat2 + "\t" + lon2 + "\t" + userMention + "\t" + media + "\t" + hashtags + "\t" + cleanText + "\n";
            var movementString = userId + "\t" + name + "\t" + time2 + "\t" + dur + "\t" + dist + "\t" + speed + "\t" + lat1 + "\t" + lon1 + "\t" + lat2 + "\t" + lon2 + "\n";
            batchPrinter.print(movementString);

            

            // if (uniqueSpeeds[speed]) {
            //     uniqueSpeeds[speed]++;
            // } else {
            //     uniqueSpeeds[speed] = 1;
            // }

            // if (speed > 2.5) {
            //     console.log((new Date).toLocaleTimeString() + " [SERVER] " + "[SPEED] " + speed + " m/s");
            // }

            // Update user movement record
            matchingUser.time    = time2;
            matchingUser.lat     = lat2;
            matchingUser.lon     = lon2;
            matchingUser.msg     = cleanText;

        } else {

            // Create user movement record

            uniqueUsers[userId] = {
                twId:   parsedJson.id_str,
                time:   Date.parse(parsedJson.created_at),// - 18000000,   // UTC - 5 hours (18,000,000 ms)
                lat:    parsedJson.coordinates.coordinates[1],
                lon:    parsedJson.coordinates.coordinates[0],
                msg:    "", //cleanText,
                name:   parsedJson.user.screen_name.replace(/\n|\t/g, " ")
            };
        }

    }

}


logParser.printSpeed = function (latestString, flush) {

    var fileName = logParser.filePath.slice(0, -4) + ".speed.out";

    if (flush) {

        // dump remaining speed records
        fs.appendFileSync(fileName, logParser.speedString);

        // just in case
        logParser.speedString       = "";
        logParser.speedStrCount     = 0;

        return;
    }

    logParser.speedString += latestString + "\n";
    logParser.speedStrCount++;

    if (logParser.speedStrCount > 30000) {

        // dump 30,000 tweets at a time
        fs.appendFileSync(fileName, logParser.speedString);

        logParser.speedString       = "";
        logParser.speedStrCount     = 0;
    }

    
}


logParser.sortTweets = function (parsedJson, tweetIdString, sortedTweets, bufferedTweets, separator) {

    var sortedStart         = -Infinity,    // could be changed to latest timestamp in the previous dump, e.g. 1371840933000 
        bufferedStart       = -Infinity,
        bufferedEnd         = -Infinity,
        currentTimestamp,
        currentLength       = bufferedTweets.length,
        fileName            = logParser.filePath.slice(0, -4) + ".sorted.out",
        outputString        = "";

    // console.log("cur len = " + currentLength);

    // Get timestamp
    currentTimestamp = Date.parse(parsedJson.created_at);

    // Log the most recent timestamp
    if (currentTimestamp > bufferedEnd) {
        bufferedEnd = currentTimestamp;
    }

    // Populate sorting buffers
    if (currentTimestamp < sortedStart) {

        // If behind sortStart, discard, log
        logParser.discardCount++;
        console.log((new Date).toLocaleTimeString() + " " + "Skipping tweet #" + tweetIdString + " as too old.");

        // Out of 100,000,000 tweets, only 14 were
        // discarded (at buffer size of 180000).

    } else if (currentTimestamp < bufferedStart) {

        // If behind bufferedStart, push to the sort buffer
        sortedTweets.push(parsedJson);

    } else {

        // Otherwise push to the current buffer
        // var currentLength = bufferedTweets.push(parsedJson);
        currentLength = bufferedTweets.push(parsedJson);
    }
    
    // Once current buffer is filled,
    if (currentLength > 180000) {

        console.log((new Date).toLocaleTimeString() + " " + "Switching sorting buffers ...");
        console.log((new Date).toLocaleTimeString() + " " + "... " + sortedTweets.length + " tweets in the sorting buffer ...");

        // Sort the sort buffer
        sortedTweets.sort(function (a, b) {
            return (Date.parse(b.created_at) - Date.parse(a.created_at));
        });

        var k = sortedTweets.length - 1,
            tweetsPerString = 0;

        if (k >= 0) {

            // Dump the sort buffer
            do {
                
                // console.error(JSON.stringify(sortedTweets[k]) + separator);

                if (tweetsPerString < 30000) {

                    outputString += JSON.stringify(sortedTweets[k]) + separator;
                    tweetsPerString++;

                    // keep count of total number of tweets written to sorted file
                    logParser.tweetsDumped++;

                } else {

                    // dump 30,000 tweets at a time
                    fs.appendFileSync(fileName, outputString);
                    // console.log("dumped " + tweetsPerString + " tweets");

                    // start a new output string
                    outputString    = JSON.stringify(sortedTweets[k]) + separator;
                    tweetsPerString = 1;
                    logParser.tweetsDumped++;
                }

            } while (k--);  // This requires an inverted sort

            // dump leftover tweets in the outputString
            fs.appendFileSync(fileName, outputString);
            // console.log("dumped " + tweetsPerString + " tweets");

            // Update sortedStart mark
            sortedStart = Date.parse(sortedTweets[0].created_at);   // set to "sortedEnd"
        }

        // Update bufferedStart mark
        bufferedStart = bufferedEnd;

        // Make current buffer be sort buffer
        logParser.sortedTweets = bufferedTweets;

        // Start a new buffer for current
        logParser.bufferedTweets = [];
        // currentLength = 0;

        console.log((new Date).toLocaleTimeString() + " " + "... done.");
    }
}


logParser.flushSortingBuffers = function (sortedTweets, bufferedTweets, discardCount, duplicatesRemoved, separator) {

    var fileName        = logParser.filePath.slice(0, -4) + ".sorted.out",
        outputString    = "";

    //
    // Dump data from current buffers
    //

    console.log((new Date).toLocaleTimeString() + " " + "Flushing sorting buffers ...");
    console.log((new Date).toLocaleTimeString() + " " + "... " + sortedTweets.length + " tweets in the sorting buffer, " + bufferedTweets.length + " tweets in the current buffer ...");

    // Sort the buffers

    sortedTweets.sort(function (a, b) {
        return (Date.parse(b.created_at) - Date.parse(a.created_at));
    });

    bufferedTweets.sort(function (a, b) {
        return (Date.parse(b.created_at) - Date.parse(a.created_at));
    });


    // Dump the buffers

    // 1

    var k = sortedTweets.length - 1,
        tweetsPerString = 0;

    if (k >= 0) {

        do {
            
            // console.error(JSON.stringify(sortedTweets[k]) + separator);

            if (tweetsPerString < 30000) {

                    outputString += JSON.stringify(sortedTweets[k]) + separator;
                    tweetsPerString++;

                    // keep count of total number of tweets written to sorted file
                    logParser.tweetsDumped++;

                } else {

                    // dump 30,000 tweets at a time
                    fs.appendFileSync(fileName, outputString);

                    // start a new output string
                    outputString    = JSON.stringify(sortedTweets[k]) + separator;
                    tweetsPerString = 1;
                    logParser.tweetsDumped++;
                }

            } while (k--);  // This requires an inverted sort

            // dump leftover tweets in the outputString
            fs.appendFileSync(fileName, outputString);
    }


    // 2

    k = bufferedTweets.length - 1;
    tweetsPerString = 0;

    if (k >= 0) {

        do {
            
            // console.error(JSON.stringify(bufferedTweets[k]) + separator);

            if (tweetsPerString < 30000) {

                    outputString += JSON.stringify(bufferedTweets[k]) + separator;
                    tweetsPerString++;

                    // keep count of total number of tweets written to sorted file
                    logParser.tweetsDumped++;

            } else {

                // dump 30,000 tweets at a time - roughly the amount read in 100MB buffer
                fs.appendFileSync(fileName, outputString);

                // start a new output string
                outputString    = JSON.stringify(bufferedTweets[k]) + separator;
                tweetsPerString = 1;
                logParser.tweetsDumped++;
            }

        } while (k--);  // This requires an inverted sort

        // dump leftover tweets in the outputString
        fs.appendFileSync(fileName, outputString);
    }

    console.log((new Date).toLocaleTimeString() + " " + "... done.");
    console.log("Skipped a total of " + discardCount + " tweets as too old.");
    console.log("Skipped a total of " + duplicatesRemoved + " tweets as duplicate.");
    console.log("Wrote a total of " + logParser.tweetsDumped + " tweets to the sorted file.");
}


logParser.isDuplicate = function (duplicateHashes, tweetIdString, parsedTweets) {

    var isDuplicate = false;

    var hashesLen = duplicateHashes.length,
        currentHash,
        k;

    // Check every hash for a match with current tweet id
    for (k = 0; k < hashesLen; k++) {

        currentHash = duplicateHashes[k];

        if (currentHash[tweetIdString]) {

            isDuplicate = true;
            break;

        } else if (k == hashesLen - 1) {

            // if no matches found, add this tweet id to the last hash
            currentHash[tweetIdString] = true;
        }
    }


    // Add new hash when current is full

    var maxHashLen          = 1000000,
        maxHashNum          = 90; // this sets max tweet count to about 90,000,000

    if (parsedTweets % 100000) { 

        // every 100,000 tweets, check if the current hash size exceeded max hash length.
        if (Object.keys(duplicateHashes[hashesLen - 1]).length > maxHashLen) {

            hashesLen = duplicateHashes.push({});

            console.log((new Date).toLocaleTimeString() + " " + "New tweet ID hash added, " + hashesLen + " total.");
        }
    }

    return isDuplicate;
};



logParser.locateDuplicates = function (duplicateHashes, tweetIdString) {

    var hashesLen = duplicateHashes.length,
        currentHash,
        k;

    // Check every hash for a match with current tweet id
    for (k = 0; k < hashesLen; k++) {

        currentHash = duplicateHashes[k];

        if (currentHash[tweetIdString]) {

            currentHash[tweetIdString]++;
            break;

        } else if (k == hashesLen - 1) {

            // if no matches found, add this tweet id to the last hash
            currentHash[tweetIdString] = 1;
        }
    }

    var maxHashLen          = 1000000,
        maxHashNum          = 90, // this sets max tweet count to about 90,000,000
        hashNumberExceeded  = false;

    // for solitude project, it's reasonable to expect about 23,000,000 tweets
    // for speed project, 90,000,000 is a reasonable number

    // Rotate duplicate hashes
    if (!(this.parsedTweets % 100000)) { 

        // every 100,000 tweets, check if the current hash size exceeded max hash length.
        if (Object.keys(duplicateHashes[hashesLen - 1]).length > maxHashLen) {

            hashesLen = duplicateHashes.push({});

            if (hashesLen > maxHashNum) {

                // a. Dump the oldest hash to stderr

                // var overflowHash = duplicateHashes[0];

                // for (var key in overflowHash) {
                //     if (overflowHash[key] > 1) {
                //         console.error(key + " " + overflowHash[key]);
                //     }
                // }
                // console.error();

                // duplicateHashes.shift();
                // hashesLen--;


                // b. Trim the oldest hash of non-duplicates

                // var hashToTrim = duplicateHashes[hashesLen - 1 - maxHashNum];
                // var trimmedHash = {};

                // for (var key in hashToTrim) {
                //     if (hashToTrim[key] > 1) {
                //         trimmedHash[key] = hashToTrim[key];
                //     }
                // }

                // duplicateHashes[hashesLen - 1 - maxHashNum] = trimmedHash;


                // c. Panic
                hashNumberExceeded = true;
            }

            console.log((new Date).toLocaleTimeString() + " " + "New hash added, " + hashesLen + " total.");
        }
    }

    return hashNumberExceeded;
}


logParser.printDuplicates = function (duplicateHashes) {

    var fileName    = logParser.filePath.slice(0, -4) + ".duplicates.out",
        newLine     = String.fromCharCode(0x0A), // LF
        currentHash,
        duplicateString,
        key,
        k;

    console.log((new Date).toLocaleTimeString() + " " + "Printing duplicates to " + fileName);

    var prefix = "module.exports = { duplicates: {" + newLine,
        suffix = "}};";

    // create a file with given name, deleting the previous one if present
    fs.writeFileSync(fileName, prefix);

    for (k = 0; k < duplicateHashes.length; k++) {

        currentHash = duplicateHashes[k];

        for (key in currentHash) {
            if (currentHash[key] > 1) {

                // print records with at least one duplicate

                // console.error(key + " " + currentHash[key]);

                duplicateString = '"' + key + '": false,' + newLine;
                fs.appendFileSync(fileName, duplicateString);
            }
        }
    }

    // add a dummy record to avoid the last line ending with a comma
    fs.appendFileSync(fileName, '"notAnId": false' + newLine);

    // close the JSON object
    fs.appendFileSync(fileName, suffix);

    console.log((new Date).toLocaleTimeString() + " " + ".. done.");
}


logParser.greatCircleDistance = function (lat1, lon1, lat2, lon2) {

    var radius = 6370315.0;   // 6,370,315 m - average radius of the WGS84 spheroid between 24 and 50 degrees

    lat1 = (lat1 * Math.PI) / 180.0;
    lon1 = (lon1 * Math.PI) / 180.0;
    lat2 = (lat2 * Math.PI) / 180.0;
    lon2 = (lon2 * Math.PI) / 180.0;

    var dLon = Math.abs(lon1 - lon2);

    var numerator = Math.sqrt( Math.pow(( Math.cos(lat2) * Math.sin(dLon) ), 2) + Math.pow(( Math.cos(lat1) * Math.sin(lat2) - Math.sin(lat1) * Math.cos(lat2) * Math.cos(dLon) ), 2) );
    var denominator = Math.sin(lat1) * Math.sin(lat2) + Math.cos(lat1) * Math.cos(lat2) * Math.cos(dLon);

    var centralAngle = Math.atan2(numerator, denominator);

    var arcLength = radius * centralAngle;

    return arcLength;
}


logParser.compareSchema = function (tweet) {

    // console.log("Prototypes:");
    // console.log(JSON.stringify(this.tweetPrototypes));
    // console.log();

    var i,
        prototypeTweet,
        matchFound = false;

    if (this.tweetPrototypes.length === 0) {

        // the list of prototypes is empty

        console.log("No prototypes yet, adding the first one");
        // console.log();

        this.tweetPrototypes.push({
                "tweet": tweet,
                "count": 1
        });

        return;
    }

    // For each of the prototypes, ..
    for (i = 0; i < this.tweetPrototypes.length; i++) {

        prototypeTweet = this.tweetPrototypes[i];
        
        if (logParser.match(prototypeTweet.tweet, tweet) && logParser.match(tweet, prototypeTweet.tweet)) {

            // match found
            // console.log("Match found at " + i);
            // console.log();
            prototypeTweet.count++;
            matchFound = true;
            break;

        } else {
            // console.log("No match at " + i);
            // console.log();
        }
    }

    if (!matchFound) {

        // no match found

        console.log("No match at all, adding new prototype");
        // console.log();

        this.tweetPrototypes.push({
            "tweet": tweet,
            "count": 1
        });
    }

}


logParser.match = function (prototypeObject, currentObject) {

    // console.log("[MATCH] " + "Prototype: " + JSON.stringify(prototypeObject));
    // console.log("[MATCH] " + "Current:   " + JSON.stringify(currentObject));

    var key;

    // For each of the keys in the prototype, ..
    for (key in prototypeObject) {
        if (prototypeObject.hasOwnProperty(key)){

            // If such key exists on the current object, ..
            if (currentObject[key] !== undefined) {

                // .. but the type of the value it refers is shown as 'object', ..
                if (typeof prototypeObject[key] === 'object' && typeof currentObject[key] === 'object') {

                    // Check for either of 'null', array, or a true 'object'.

                    // null
                    if (prototypeObject[key] === null && currentObject[key] === null) {
                        // console.log("[MATCH] " + "null - null");
                        continue;
                    }

                    // array
                    if (logParser.isArray(prototypeObject[key]) && logParser.isArray(currentObject[key])) {
                        // console.log("[MATCH] " + "array - array");
                        continue;
                    }

                    // object - check recursively
                    if (
                        prototypeObject[key] !== null && 
                        currentObject[key] !== null && 
                        !logParser.isArray(prototypeObject[key]) && 
                        !logParser.isArray(currentObject[key])
                    ) {
                        // console.log("[MATCH] " + "objects, going recursive");
                        if (this.match(prototypeObject[key], currentObject[key])) {
                            continue;
                        }
                    }

                    return false;

                } else {

                    // Otherwise, do a direct type comparison.

                    // Can be either of 'boolean', 'number' or 'string'. Theoretically, 
                    // 'undefined' and 'function' are also possible, but not in JSON.

                    if (typeof prototypeObject[key] !== typeof currentObject[key]) {
                        // console.log("[MATCH] " + "non-objects, type mismatch");
                        return false;
                    }
                }

            } else {
                
                // If a key doesn't exist on the current object, it's a no-match.
                // console.log("[MATCH] " + "key not found");
                return false;
            }

        }
    }

    // console.log("[MATCH] " + "all checks out");
    return true;
}


logParser.isArray = function (value, stringify) {

    // Check if 'value' is an array

    if (stringify === undefined) {
        stringify = false;
    }

    if (stringify) {
        return Object.prototype.toString.apply(value) === '[object Array]'; // more robust but might be slower
    } else {
        return value && typeof value === 'object' && value.constructor === Array;
    }

}




//
// Server code
//

logParser.initServer = function() {
    
    // Imports
    var socketServer = require('websocket').server;
    var http         = require('http');

    
    // Variables
    var port = 8080;
    
    
    // Create an HTTP server to which WebSocket server will be attached
    
    var server = http.createServer(function(request, response) {
        console.log((new Date).toLocaleTimeString() + " [SERVER] " + "Received request for " + request.url);
        response.writeHead(404);
        response.end();
    });
    
    server.listen(port, function() {
        console.log((new Date).toLocaleTimeString() + " [SERVER] " + "HTTP server is listening on port " + port + ".");
    });
    
    
    // Create a WebSocket server
    
    var wsServer = new socketServer({
        httpServer: server                                                      // the http server instance to attach WebSocket server to
    });
    
    
    // Register event listeners for the WebSocket server
    
    wsServer.on('request', function(wsRequest) {
        
        var acceptedProtocol = 'http';                                          // protocol MUST be the same as requested by the client
        
        // Test for the request to come from an allowed origin
        if (!logParser.originIsAllowed(wsRequest.origin)) {
            wsRequest.reject();
            console.log((new Date).toLocaleTimeString() + " [SERVER] " + 'Connection from origin ' + wsRequest.origin + ' rejected.');
            return;
        }
        
        // Accept the incoming connection
        var wsConnection = wsRequest.accept(acceptedProtocol, wsRequest.origin);
        console.log((new Date).toLocaleTimeString() + " [SERVER] " + 'Connection from origin ' + wsRequest.origin + ' at ' + wsConnection.remoteAddress + ' accepted.');
        
        
        // Register event listeners for the connection
        
        wsConnection.on('message', function(message) {
            
            // Send a file to the client
            
            console.log((new Date).toLocaleTimeString() + " [SERVER] " + 'Received Message: ' + message.utf8Data);
            
            if (logParser.locationArray) {
                
                // Send location array to the client
                console.log((new Date).toLocaleTimeString() + " [SERVER] " + "Sending file..");
                wsConnection.sendUTF(JSON.stringify(logParser.locationArray));
                
                // Write a copy of location to the file
                //console.log((new Date).toLocaleTimeString() + " [SERVER] " + "Writing a copy of file to disk..");
                //fs.writeFileSync('dataPayload.out', JSON.stringify(logParser.locationArray));
                //console.log((new Date).toLocaleTimeString() + " [SERVER] " + ".. done writing file.");
            }
            
            
        });
        
        wsConnection.on('close', function(reasonCode, description) {
            console.log((new Date).toLocaleTimeString() + " [SERVER] " + 'Peer ' + wsConnection.remoteAddress + ' disconnected.');
        });
        
    });
    
}


logParser.originIsAllowed = function(origin) {
    
    var allowed = false;
    var okOrigin = "http://www.personal.psu.edu"

    console.log((new Date).toLocaleTimeString() + " [SERVER] " + "Request origin is " + origin);

    if (origin == okOrigin) {
        allowed = true;
    }

    return allowed;
}




//
// Read file to database
//

logParser.getMongoCollection = function (fileDesc) {

    // TODO: rename this method;

    var hostName = "localhost",
        dbName = "tweets",
        collectionName = "sample";

    var mClient = mongo.MongoClient;

    mClient.connect("mongodb://localhost:27017/" + dbName, {auto_reconnect: true}, function(err, mDb) {

        if(!err) {

            console.log((new Date).toLocaleTimeString() + " [SERVER] " + "We are connected to MongoDB.");

            mDb.collection(collectionName, function(err, collection) {

                if(!err) {

                    console.log((new Date).toLocaleTimeString() + " [SERVER] " + "Collection \"" + collectionName + "\" retrieved.");

                    logParser.mdbCollection = collection;
                    logParser.readDataToDb(fileDesc, null, logParser.mdbCollection);

                } else {

                    console.log((new Date).toLocaleTimeString() + " [SERVER] " + "[FATAL] " + "Error fetching collection \"" + collectionName + "\":");
                    console.log(err);
                }

            });

        } else {

            console.log((new Date).toLocaleTimeString() + " [SERVER] " + "[FATAL] " + "Error connecting to MongoDB:");
            console.log(err);
        }

    });

}


logParser.readDataToDb = function (fileDesc, filePos, mdbCollection) {

    // Fetch and parse some of the data file

    var bufferSize  = 16777216,                         // 16,777,216 = BSON document size limit
        dataBuffer  = new Buffer(bufferSize),
        separator   = String.fromCharCode(0x0D) +       // CR
                      String.fromCharCode(0x0A) +       // LF
                      String.fromCharCode(0x2C) +       // ,
                      String.fromCharCode(0x0A),        // LF
        separatorPos,
        concatTweets,
        unparsedTweets,
        numTweets,
        tweetIdString,
        lastTweetId,
        lastTweetText,
        i,
        j,
        parsedJson,
        insertBuffer;

    fs.read(fileDesc, dataBuffer, 0, dataBuffer.length, filePos, function (err, bytesRead, buffer){

        if (bytesRead && !err) {

            //
            // File read ok, now parse the data and initiate the commit
            //

            console.log((new Date).toLocaleTimeString() + " [SERVER] " + buffer.length + " bytes requested, " + bytesRead + " bytes read.");

            // Shrink buffer, if necessary
            if (bytesRead !== buffer.length) {
                console.log((new Date).toLocaleTimeString() + " [SERVER] " + "Shrinking buffer to the number of bytes read.");
                buffer = buffer.slice(0, bytesRead);
            }

            // Locate the last separator
            // separatorPos = buffer.toString().lastIndexOf(separator);
            separatorPos = 0;
            for (j = dataBuffer.length - 1; j > separator.length - 1; j--) {

                if (dataBuffer[j] === 0x0A && dataBuffer[j - 1] === 0x2C && dataBuffer[j - 2] === 0x0A && dataBuffer[j - 3] === 0x0D) {
                    separatorPos = j - 3;
                    break;
                }
            }

            if (separatorPos > 0) {

                insertBuffer = [];

                //
                // Perform by-element parse
                //

                concatTweets = buffer.slice(0, separatorPos).toString();
                unparsedTweets = concatTweets.split(separator);
                numTweets = unparsedTweets.length;

                for (i = 0; i < numTweets; i++) {

                    try {

                        logParser.parsedTweets++;

                        // 1. Parse the tweet
                        parsedJson = JSON.parse(unparsedTweets[i]);

                        // 2. Check for non-tweets
                        if (!parsedJson.id) {
                            console.log((new Date).toLocaleTimeString() + " [SERVER] " + "[FATAL] " + "Record #" + this.parsedTweets + " following tweet #" + lastTweetId + " is not a tweet.");
                            continue;
                        }

                        tweetIdString = parsedJson.id_str;
                        lastTweetId = tweetIdString;

                        // 3. Push tweets into the db insert buffer
                        if (duplicates[tweetIdString] === undefined) {

                            parsedJson._id = new mongo.Long.fromString(tweetIdString, 10);  
                            insertBuffer.push(parsedJson);

                        } else if (duplicates[tweetIdString] === true) {

                            // this tweet is a duplicate, do not add it to mongo
                            logParser.skippedTweets++;

                        } else if (duplicates[tweetIdString] === false) {

                            // this tweet is a duplicate, but this is its first occurrence

                            duplicates[tweetIdString] = true;

                            parsedJson._id = new mongo.Long.fromString(tweetIdString, 10);  
                            insertBuffer.push(parsedJson);

                        } else {

                            console.log("This shouldn't happen..");
                        }



                        

                        // Tweet ids are 58 bit long (at least), whereas the maximum 
                        // integer value in jScript is at 53 bit, according to 
                        // 
                        //     http://mongodb.github.com/node-mongodb-native/api-articles/nodekoarticle1.html#mongo-db-data-types
                        // 
                        // Thus, mongo.Long is used, otherwise id will be stored as a 
                        // float and lose three digits due to rounding.

                        // lastTweetText = parsedJson.text;

                    } catch (e) {

                        console.log((new Date).toLocaleTimeString() + " [SERVER] " + "[FATAL] " + "Exception in record #" + logParser.parsedTweets + " following tweet #" + lastTweetId + ": " + e);
                        console.log(unparsedTweets[i]);
                        // return;
                    }

                }

                // Push tweets to the db
                if (insertBuffer.length > 0) {

                    // console.log((new Date).toLocaleTimeString() + " [SERVER] " + "Attempting to insert " + insertBuffer.length + " records..");

                    mdbCollection.insertMany(insertBuffer, function(err, result) { 

                        // Maximum allowed BSON size is set to 16,777,216 bytes (16,384 KB), or roughly 6500 tweets

                        if (!err) {

                            console.log((new Date).toLocaleTimeString() + " [SERVER] " + result.insertedCount + " records inserted.");
                            console.log((new Date).toLocaleTimeString() + " [SERVER] " + logParser.parsedTweets + " records parsed so far.");
                            console.log((new Date).toLocaleTimeString() + " [SERVER] " + logParser.skippedTweets + " records skipped so far.");
                            console.log();

                        } else {

                            // TODO: this only reports the last error, there might be multiple in the batch

                            // console.log((new Date).toLocaleTimeString() + " [SERVER] " + "[CRITICAL] " + "Error inserting tweets into the database: " + err);

                            // console.error((new Date).toLocaleTimeString() + " [SERVER] " + "[CRITICAL] " + "Error inserting tweets into the database:");
                            // console.error(err);
                            // console.error();

                            console.error("" + err);  // dump errors as one-liners
                        }

                        // Insert is over, now update the filePos and run the next batch

                        filePos = (filePos) ? filePos + separatorPos + separator.length : separatorPos + separator.length;

                        logParser.readDataToDb(fileDesc, filePos, mdbCollection);
                        
                    });
                }

            } else {

                console.log((new Date).toLocaleTimeString() + " [SERVER] " + "[FATAL] " + "Separator not found.");
                console.log();
            }

        } else {

            if (err) {

                console.log((new Date).toLocaleTimeString() + " [SERVER] " + "[FATAL] " + "Error reading file:");
                console.log(err);

            } else {

                console.log((new Date).toLocaleTimeString() + " [SERVER] " + "No bytes read");
            }
            
        }

    // end of fs.read()
    });
}


var batchPrinter = {

    stringCount:        0,
    maxCount:           1000, 
    outputString:       "",
    fileName:           "",

    print:  function (newString) {

        if (this.stringCount < this.maxCount) {

            this.outputString += newString;
            this.stringCount++;

            // keep count of total number of tweets written to sorted file
            logParser.tweetsDumped++;

        } else {

            // dump x tweets at a time
            fs.appendFileSync(this.fileName, this.outputString);
            // console.log("dumped " + stringCount + " tweets");

            // start a new output string
            this.outputString = newString;
            this.stringCount = 1;

            logParser.tweetsDumped++;
        }

    },

    flush:  function () {

        fs.appendFileSync(this.fileName, this.outputString);

        // just in case
        this.outputString = "";
        this.stringCount = 0;
    }

};


//
// Init
//

logParser.init();
