/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 This node script uses a server-to-server key to make public database calls with CloudKit JS
 */
var Promise = require('promise');

var contributorsLoader = require('./jobs/loadContributorInfo');
var eventsLoader = require('./jobs/loadEventInfo');
process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0";


(function() {
  var fetch = require('node-fetch');

  var CloudKit = require('./cloudkit');
  var config = require('./config');

  // A utility function for printing results to the console.
  var println = function(key,value) {
    console.log("--> " + key + ":");
    console.log(value);
    console.log();
  };

  //CloudKit configuration
  CloudKit.configure({
    services: {
      fetch: fetch,
      logger: console
    },
    containers: [ config.containerConfig ]
  });


  var container = CloudKit.getDefaultContainer();
  var database = container.publicCloudDatabase; // We'll only make calls to the public database.


// Sign in using the keyID and public key file.
container.setUpAuth()
  .then(function(userInfo){
    
      var syncContributorsPromise = new Promise(function(resolve, reject) {
        //Load contributors from iCloud
        var cloudKitFetchPromise = database.performQuery({ recordType: 'Contributor' }).then(function(response) {
          return Promise.resolve(response.records)
        })
        //Load contributors from Github
        var githubFetchPromise =  contributorsLoader.load().then(function(contributors) {
          return Promise.resolve(contributors)
        })
      
        return Promise.all([cloudKitFetchPromise, githubFetchPromise]).then(contributors => {
          var cloudKitContributors = contributors[0];
          var githubContributors = contributors[1];
    
          var mappedGithubRecords = githubContributors.map(function(gitHubRecord) {
            return {recordType: 'Contributor',
              fields: {
                contributor_id: {value: gitHubRecord["id"]},
                avatar_url: {value: gitHubRecord["avatar_url"]},
                name: {value: gitHubRecord["name"]},
                commit_count: {value: gitHubRecord["commit_count"]},
                url: {value: gitHubRecord["html_url"]}
              }
            }
          })
    
          for (var mappedGithubRecord of mappedGithubRecords) {
            var contributorId = mappedGithubRecord["fields"]["contributor_id"]["value"]
            var filteredCloudRecords = cloudKitContributors.filter(function(cloudKitRecord) {
              var cloudKitContributorId = cloudKitRecord.fields.contributor_id
              if (cloudKitContributorId === undefined) {return false}
              return (contributorId === cloudKitContributorId.value)
            })

            for (var filteredCloudRecord of filteredCloudRecords) {
              if(filteredCloudRecord.recordChangeTag) {
                mappedGithubRecord.recordChangeTag = filteredCloudRecords[0].recordChangeTag;
              }
              if(filteredCloudRecord.recordName) {
                mappedGithubRecord.recordName = filteredCloudRecords[0].recordName;
              }
            }
          }
    
          return database.saveRecords(mappedGithubRecords);
        }).then(function(response) {
          resolve(response)
        })
      })

      return syncContributorsPromise
    }).then(function(response) {
      console.log("Done");
      process.exit();
    })
    .catch(function(error) {
      console.warn(error);
      process.exit(1);
    });
})();

