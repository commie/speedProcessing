"use strict";

var fs = require('fs');

var init = function () {

	// helper function

	var dumpString = "",
		dumpCount = 0,
		separator =	String.fromCharCode(0x0D) +       // CR
                    String.fromCharCode(0x0A) +       // LF
                    String.fromCharCode(0x2C) +       // ,
                    String.fromCharCode(0x0A);        // LF;

	var dumpRecords = function (fileName, latestString, flush) {

	    if (flush) {

	        // dump remaining speed records
	        fs.appendFileSync(fileName, dumpString);

	        // just in case
	        dumpString	= "";
	        dumpCount	= 0;

	        return;
	    }

	    dumpString += latestString + separator;
	    dumpCount++;

	    if (dumpCount > 30000) {

	        // dump 30,000 tweets at a time
	        fs.appendFileSync(fileName, dumpString);

	        dumpString	= "";
	        dumpCount	= 0;
	    }
	};




	//

	// var filePaths = [
	// 	"/Users/a_s899/Sasha/noBackup/bigData/speedAnalysisData/hemisphere/distributedReader.2.1.twitterCrawler01.2017.12.18.out",
	// 	"/Users/a_s899/Sasha/noBackup/bigData/speedAnalysisData/hemisphere/distributedReader.2.1.twitterCrawler02.2017.12.18.out",
	// 	"/Users/a_s899/Sasha/noBackup/bigData/speedAnalysisData/hemisphere/distributedReader.2.1.twitterCrawler03.2017.12.18.out",
	// 	"/Users/a_s899/Sasha/noBackup/bigData/speedAnalysisData/hemisphere/distributedReader.2.1.twitterCrawler04.2017.12.18.out"
	// ];

	var filePaths = [
		"/home/dude/dataDrive/andrei/covidMovement/distributedReader.2.1.twitterCrawler01.2019.04.out",
		"/home/dude/dataDrive/andrei/covidMovement/distributedReader.2.1.twitterCrawler02.2019.04.out",
		"/home/dude/dataDrive/andrei/covidMovement/distributedReader.2.1.twitterCrawler03.2019.04.out",
		"/home/dude/dataDrive/andrei/covidMovement/distributedReader.2.1.twitterCrawler04.2019.04.out"
	];

	// var filePaths = [
	// 	"/home/dude/dataDrive/andrei/covidMovement/distributedReader.2.1.twitterCrawler01.2020.04.out",
	// 	"/home/dude/dataDrive/andrei/covidMovement/distributedReader.2.1.twitterCrawler02.2020.04.out",
	// 	"/home/dude/dataDrive/andrei/covidMovement/distributedReader.2.1.twitterCrawler03.2020.04.out",
	// 	"/home/dude/dataDrive/andrei/covidMovement/distributedReader.2.1.twitterCrawler04.2020.04.out"
	// ];

	var currentRecords = new Array(filePaths.length),
		i;


	// grab the first record from every file

	for (i = 0; i < filePaths.length; i++) {
		
		currentRecords[i] = {
			reader:  fileReaderFactory(filePaths[i], i),
			counter: 0,
			tweet:   undefined
		};

		currentRecords[i].tweet = currentRecords[i].reader.nextRecord();
	}

	
	// dummy-check check for empty / broken files
	currentRecords = currentRecords.filter(function (record) {
		
		if (record.tweet) {
		
			return true;
		
		} else {
			
			console.log("Bad - reader " + record.reader.id + " couldn't get any data.");
			return false;
		}
	});

	
	// merge data

	var gotRecord 		= true,
		lastTimestamp,
		lastId,
		writtenCount 	= 0,
		skippedCount 	= 0,
		dumpPath 		= filePaths[0].slice(0, -4) + ".merged.out",
		readerDone		= false;	// triggered when one or more readers finish reading their file; triggers trimming of the currentRecords array

	while (gotRecord) {

		// sort records by time
		currentRecords.sort(function(a, b) {
			
			var timestampA = Date.parse(a.tweet.created_at),
				timestampB = Date.parse(b.tweet.created_at);

			return timestampA - timestampB;
		});



		// write the first one, count
		dumpRecords(dumpPath, JSON.stringify(currentRecords[0].tweet));
		writtenCount++;
		
		// remember it
		lastTimestamp 	= currentRecords[0].tweet.created_at;
		lastId 			= currentRecords[0].tweet.id_str;

		// get next, update "readerDone" flag
		currentRecords[0].tweet = currentRecords[0].reader.nextRecord();
		if (!(currentRecords[0].tweet)) {
			readerDone = true;
		}

			

		// for all remaining records,
		for (i = 1; i < currentRecords.length; i++) {

			// if timestamp equal to 1st,
			if (currentRecords[i].tweet.created_at === lastTimestamp) {

				// but not the same tweet ..
				if (currentRecords[i].tweet.id_str !== lastId) {

					// write and count
					dumpRecords(dumpPath, JSON.stringify(currentRecords[i].tweet));
					writtenCount++;

				// alternatively, if the same tweet ..
				} else {

					// don't write, count identical
					skippedCount++;
				}

				// late records will still be embedded as late
				// this means there's no guarantee of perfect order
				// late records, however, don't cause for any data to be dropped

				// not all duplicates will be removed by this approach, either
				// the id_str is remembered only from the "first" reader, but other readers can contain their own duplicates

				// for the processed records, get next tweet and update "readerDone" flag
				currentRecords[i].tweet = currentRecords[i].reader.nextRecord();
				if (!(currentRecords[i].tweet)) {
					readerDone = true;
				}

			// if timestamp is past the 1st, skip the rest
			} else {

				break;
			}
		}

		
			
		// if "readerDone" flag was set,
		if (readerDone) {

			// only keep file readers with data remaining
			currentRecords = currentRecords.filter(function (record) {
				
				if (record.tweet) {
				
					return true;
				
				} else {
					
					console.log("Reader " + record.reader.id + " ran out of data.");
					return false;
				}
			});

			// reset the "readerDone" flag
			readerDone = false;

			// update "gotRecord" flag
			if (currentRecords.length === 0) {

				// this terminates the main loop, as we're out of data
				gotRecord = false;
			}
		}
			


		// debug
		if (writtenCount % 100000 === 0) {
			console.log(writtenCount + " written, " + skippedCount + " skipped as a duplicate.");
		}


		// end of while loop	
	}

	// flush remaining records
	dumpRecords(dumpPath, null, true);
	console.log(writtenCount + " total written, " + skippedCount + " skipped as a duplicate.");

};


var fileReaderFactory = function (filePath, readerId) {

	// open the file
	
	var fileDesc 	= fs.openSync(filePath, 'r');

    var bufferSize  = 104857600,                        // 104857600 = 100MB, 524288000 = 500MB
        dataBuffer  = new Buffer(bufferSize),
        filePos     = 0,
        bytesRead;
        
    var unparsedTweets,		// would this be a problem since there will be multiple instances of file readers?..
    	nextTweetIndex;		// shouldn't be - they're re-initialized on every call and kept in closure


    // initialize the file reader

	var fileReader = {};

	fileReader.id = readerId;

	fileReader.init = function () {

		var nextBatch = fileReader.readNextBatch();

		if (nextBatch) {
			
			unparsedTweets = nextBatch;
			nextTweetIndex = 0;

		} else {

			console.log(fileReader.id + " " + (new Date).toLocaleTimeString() + " [FATAL] " + "Failed to initialize.");
		}

	};

	fileReader.nextRecord = function () {

		var nextRecord;

		// check if there are unprocessed records
		if (nextTweetIndex < unparsedTweets.length) {

			try {

				var parsedJson = JSON.parse(unparsedTweets[nextTweetIndex++]);

				// check for non-tweets

				if (!parsedJson.id) {
					
					console.log(fileReader.id + " " + (new Date).toLocaleTimeString() + " [WARNING] " + "This record is not a tweet: " + JSON.stringify(parsedJson));
					nextRecord = fileReader.nextRecord();

				} else {

					nextRecord = parsedJson;
				}

			} catch (e) {

                console.log(fileReader.id + " " + (new Date).toLocaleTimeString() + " [WARNING] " + "Exception while parsing a record: " + e);
                console.log(unparsedTweets[nextTweetIndex - 1]);

                nextRecord = fileReader.nextRecord();
            }

		// if not, grab more
		} else {

			var nextBatch = fileReader.readNextBatch();

			if (nextBatch) {
				
				unparsedTweets = nextBatch;
				nextTweetIndex = 0;

				nextRecord = fileReader.nextRecord();

			} else {

				// unless there aren't any more left
				// console.log(fileReader.id + " " + "bump");
			}

		}

		return nextRecord;
	};

	fileReader.readNextBatch = function () {

		var bytesRead	= fs.readSync(fileDesc, dataBuffer, 0, dataBuffer.length, filePos),	// all parameters global
			newBatch 	= null;

		if (bytesRead) {

			console.log(fileReader.id + " " + (new Date).toLocaleTimeString() + " " + dataBuffer.length + " bytes requested, " + bytesRead + " bytes read.");


			// Shrink buffer, if necessary
	        
	        if (bytesRead !== dataBuffer.length) {
	            console.log(fileReader.id + " " + (new Date).toLocaleTimeString() + " " + "Shrinking buffer to the number of bytes read.");
	            dataBuffer = dataBuffer.slice(0, bytesRead);
	        }


	        // Locate the last separator

	        var separatorPos	= 0,
	        	j,
	        	separator 		= String.fromCharCode(0x0D) +       // CR
								  String.fromCharCode(0x0A) +       // LF
								  String.fromCharCode(0x2C) +       // ,
								  String.fromCharCode(0x0A);        // LF
				// separator   	= String.fromCharCode(0x2C) +       // ,
    //                   			  String.fromCharCode(0x0A);        // LF

	        for (j = dataBuffer.length - 1; j > separator.length - 1; j--) {
	            if (dataBuffer[j] === 0x0A && dataBuffer[j - 1] === 0x2C && dataBuffer[j - 2] === 0x0A && dataBuffer[j - 3] === 0x0D) {
	            // if (dataBuffer[j] === 0x0A && dataBuffer[j - 1] === 0x2C) {    
	                separatorPos = j - 3;
	                // separatorPos = j - 1;
	                break;
	            }
	        }

	        
	        // Split the buffer at separator locations

			if (separatorPos > 0) {

	            // split the buffer into individual tweets
	            var concatTweets    = dataBuffer.slice(0, separatorPos).toString(),
	            	unparsedTweets  = concatTweets.split(separator);
	            
	            // update the return value
	            newBatch = unparsedTweets;

	            // advance the file position
	            filePos = (filePos) ? filePos + separatorPos + separator.length : separatorPos + separator.length;

	            // console.log((new Date).toLocaleTimeString() + " " + this.parsedTweets + " records parsed so far.");
	            console.log(fileReader.id + " " + (new Date).toLocaleTimeString() + " " + "Moving file position to " + filePos + " (" + (filePos / 1073741824).toFixed(2) + " GB)");
	            // console.log();

	        } else {

	            console.log(fileReader.id + " " + (new Date).toLocaleTimeString() + " [FATAL] " + "Separator not found.");
	            // console.log();

	            // break;
	        }


		} else {

			// failed to read
			// console.log(fileReader.id + " " + (new Date).toLocaleTimeString() + " " + "Done reading file.");
		    
		    // console.log((new Date).toLocaleTimeString() + " " + "A total of " + this.parsedTweets + " records parsed, " + this.validCount + " valid tweets found.")
		    // console.log((new Date).toLocaleTimeString() + " " + "Last tweet # is " + lastTweetId);
		    // console.log();
		}

		return newBatch;
	};


	fileReader.init();

	return fileReader;
};





init();