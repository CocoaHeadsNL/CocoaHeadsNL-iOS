"use strict";
var xmlreader = require('./xmlreader.js');
var Promise = require('promise');
var request = require('request');
var config = require('../config');

exports.load = function() {
  var loadJobInfoPromise = new Promise(function(resolve, reject) {
    var options = {
      url: 'http://jobs.cocoaheads.nl/feed.xml',
    }

    request(options, function(error, response, body){
      if (error) {
        reject(error);
        console.log("Error on fetching Job information: " + error)
        return;
      }

      if (response.statusCode != 200) {
        reject(response.statusCode);
        console.log("Invalid HTTP status code on Job information: " + response.statusCode)
        return;
      }

      var jobPostings = []

      xmlreader.read(body, function (err, res){
        if (err) {
          reject(err);
          return;
        }
        var rssChannel = res.rss.channel;
        rssChannel.item.each(function (i, newJobItem){
          var jobPosting = {
            link: newJobItem.link.text(),
            title: newJobItem.title.text(),
            content: newJobItem.description.text(),
            date: newJobItem.pubDate.text(),
            logo: newJobItem['atom:link'].attributes()['href']
          }

          jobPostings.push(jobPosting)
        });
      });

      resolve(jobPostings);
    });
  });

  return loadJobInfoPromise;
}
