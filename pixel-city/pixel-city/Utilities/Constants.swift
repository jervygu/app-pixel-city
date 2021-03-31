//
//  Constants.swift
//  pixel-city
//
//  Created by Jeff Umandap on 3/29/21.
//

import Foundation


let apiKey = "525b42fe1d6cb351fbee1e99013dfdac"

func flickrUrl(forApiKey key: String, withAnnotation annotation: DroppaplePin, andNumberOfPhotos number: Int) -> String {
    return "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=mi&extras=views%2C+description%2C+date_taken%2C+owner_name&per_page=\(number)&format=json&nojsoncallback=1"
}
    
//   old     "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=mi&per_page=\(number)&format=json&nojsoncallback=1"


// extended API https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=9f4bb759c8fc5dcd2ec39b1ec96342d3&lat=1.2847013250468462&lon=103.86101252717083&radius=1&radius_units=mi&extras=views%2C+description%2C+date_taken%2C+owner_name&per_page=40&format=json&nojsoncallback=1

//https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=b3ba60621955d59389bc5022157b9490&lat=42.8&lon=122.3&radius=1&radius_units=mi&per_page=40&format=json&nojsoncallback=1

//singapore
//1.2847013250468462
//103.86101252717083

//https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=efd4f74ca4b97864297e177ca0ac6be9&lat=1.2847013250468462&lon=103.86101252717083&radius=1&radius_units=mi&per_page=40&format=json&nojsoncallback=1

// photo search url
//https://www.flickr.com/services/api/explore/flickr.photos.search
