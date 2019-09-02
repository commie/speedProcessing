var dups = require("./duplicateLocations.02.js").duplicateLocations;

var outputString = "";

for (var locationKey in dups) {
	
	outputString += locationKey + "\t" + dups[locationKey] + "\n";
}

console.error(outputString);