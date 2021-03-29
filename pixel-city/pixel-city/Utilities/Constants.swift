//
//  Constants.swift
//  pixel-city
//
//  Created by Jeff Umandap on 3/29/21.
//

import Foundation


let apiKey = "525b42fe1d6cb351fbee1e99013dfdac"

func flickrUrl(forApiKey key: String, withAnnotation annotation: DroppaplePin, andNumberOfPhotos number: Int) -> String {
    return "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=mi&per_page=\(number)&format=json&nojsoncallback=1"
}

//https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=b3ba60621955d59389bc5022157b9490&lat=42.8&lon=122.3&radius=1&radius_units=mi&per_page=40&format=json&nojsoncallback=1
