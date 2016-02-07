"use strict";

var Promise = require('promise');
var request = require('request');
var config = require('../config');

exports.load = function() {
  var loadEventInfoPromise = new Promise(function(resolve, reject) {
    
    var options = {
      url: 'https://api.meetup.com/2/events?&sign=true&photo-host=public&group_urlname=cocoaheadsnl&page=20&desc=true&status=upcoming,past&key='+config.meetupApiKey,
      headers: { 'User-Agent': 'CocoaHeadsNL-Cloud-Sync'},
    }
    
    request(options, function(error, response, body){
      if (error) {
        reject(error);
        console.log("Error on fetching meetup information: " + error)
        return;
      }
      
      if (response.statusCode != 200) {
        reject(response.statusCode);
        console.log("Invalid HTTP status code on meetup information: " + response.statusCode)
        return;
      }
      resolve(body);
    });
  }).then(function(body) {
    var meetupData = JSON.parse(body);
    return Promise.resolve(meetupData)
  })
  
  return loadEventInfoPromise
}
