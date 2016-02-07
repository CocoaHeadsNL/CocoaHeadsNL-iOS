"use strict";

var Promise = require('promise');
var request = require('request');
var config = require('../config');



exports.load = function() {
  var loadContributorsPromise = new Promise(function(resolve, reject) {
    

    var options = {
      url: 'https://api.github.com/repos/CocoaHeadsNL/CocoaHeadsNL-iOS/stats/contributors',
      headers: { 'User-Agent': 'CocoaHeadsNL-Cloud-Sync'},
      auth: config.githubAuthOptions
    }
    
    request(options, function(error, response, body){
      if (error) {
        reject(error);
        console.log("Error on fetching contributors: " + error)
        return;
      }
      
      if (response.statusCode != 200) {
        reject(response.statusCode);
        console.log("Invalid HTTP status code on fetching contributors: " + response.statusCode)
        return;
      }
      resolve(body);
    });
  }).then(function(body) {
    var contributorData = JSON.parse(body);
    
    var promises = []
    var authorDetails = []
    
    contributorData.forEach(function(contributorInfo) {
      var detailPromise = new Promise(function(resolve, reject) {
        var author = contributorInfo["author"];
        request({url: author.url,headers: { 'User-Agent': 'CocoaHeadsNL-Cloud-Sync'}, auth: config.githubAuthOptions}, function(error, response, body){
          if (error) {
            console.log("Error on fetching contributor details: " + error)
            reject(error);
            return;
          }
      
          if (response.statusCode != 200) {
            console.log("Invalid HTTP status code on fetching contributor details: " + response.statusCode)
            reject(response.statusCode);
            return;
          }
          
          var authorDetailData = JSON.parse(body)
          authorDetailData.commit_count = contributorInfo.total
          authorDetails.push(authorDetailData)
          resolve(authorDetailData)
        })
      })
      
      promises.push(detailPromise)
    })
    
    return Promise.all(promises)
  })
  
  return loadContributorsPromise
}
