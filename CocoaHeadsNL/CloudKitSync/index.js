"use strict";

/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 This node script uses a server-to-server key to make public database calls with CloudKit JS
 */
var Promise = require('promise');

// process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0";


(function() {
  var fetch = require('node-fetch');

  var CloudKit = require('./cloudkit');
  var config = require('./config');
  var iconv = require('iconv-lite');

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
      logger: undefined
    },
    containers: [ config.containerConfig ]
  });

  var container = CloudKit.getDefaultContainer();
  var database = container.publicCloudDatabase; // We'll only make calls to the public database.

  function syncEventsPromise() {
    var syncEventsPromise = new Promise(function(resolve, reject) {

      var eventsLoader = require('./jobs/loadEventInfo');

      //Load events from iCloud
      var cloudKitFetchPromise = database.performQuery({ recordType: 'Meetup' }).then(function(response) {
        return Promise.resolve(response.records)
      })
      //Load events from meetup
      var meetupFetchPromise = eventsLoader.load().then(function(meetupData){
        return Promise.resolve(meetupData)
      })

      return Promise.all([cloudKitFetchPromise, meetupFetchPromise]).then(events => {
        var cloudKitEvents = events[0];
        var meetupEvents = events[1];

        var mappedMeetupRecords = meetupEvents.map(function(meetupEvent) {
          var locationName = undefined;
          var geoLocation = undefined;
          var location = undefined;
          if (meetupEvent.venue !== undefined) {
            locationName =  meetupEvent.venue.name;
            geoLocation = {latitude: meetupEvent.venue.lat, longitude: meetupEvent.venue.lon};
            location = meetupEvent.venue.city;
          }

          return {recordType: 'Meetup',
            fields: {
              meetup_id: {value: meetupEvent["id"]},
              name: {value: meetupEvent["name"]},
              meetup_description: {value: meetupEvent["description"]},
              locationName: {value: locationName },
              geoLocation: {value: geoLocation },
              location: {value: location },
              time: {value: meetupEvent.time},
              duration: {value: meetupEvent.duration},
              yes_rsvp_count: {value: meetupEvent.yes_rsvp_count},
              rsvp_limit: {value: meetupEvent.rsvp_limit},
              meetup_url: {value: meetupEvent["event_url"]},
              nextEvent: {value: 0}
            }
          }
        });

        for (var mappedMeetupRecord of mappedMeetupRecords) {
          var meetupId = mappedMeetupRecord["fields"]["meetup_id"]["value"]
          var filteredCloudRecords = cloudKitEvents.filter(function(cloudKitRecord) {
            var cloudKitMeetupId = cloudKitRecord.fields.meetup_id
            if (cloudKitMeetupId === undefined) {return false}
            return (meetupId === cloudKitMeetupId.value)
          })

          for (var filteredCloudRecord of filteredCloudRecords) {
            if(filteredCloudRecord.recordChangeTag) {
              mappedMeetupRecord.recordChangeTag = filteredCloudRecords[0].recordChangeTag;
            }
            if(filteredCloudRecord.recordName) {
              mappedMeetupRecord.recordName = filteredCloudRecords[0].recordName;
            }
          }
        }

        return database.saveRecords(mappedMeetupRecords);
      }).then(function(response) {
        resolve(response)
      }).catch(function(error) {
        reject(error)
    });
    })

    return syncEventsPromise
  }

  function syncContributorsPromise() {
    var syncContributorsPromise = new Promise(function(resolve, reject) {

      var contributorsLoader = require('./jobs/loadContributorInfo');

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
      }).catch(function(error) {
        reject(error)
      });
    })

    return syncContributorsPromise
  }

  function syncJobsPromise() {
    var syncJobsPromise = new Promise(function(resolve, reject) {
      var jobsLoader = require('./jobs/loadJobInfo');

      //Load jobs from iCloud
      var cloudKitFetchPromise = database.performQuery({ recordType: 'Job' }).then(function(response) {
        return Promise.resolve(response.records)
      })
      //Load jobs from RSS feed on jobs site
      var jobFetchPromise =  jobsLoader.load().then(function(jobs) {
        return Promise.resolve(jobs)
      })

      return Promise.all([cloudKitFetchPromise, jobFetchPromise]).then(jobs => {
        var cloudKitJobs = jobs[0];
        var feedJobs = jobs[1];
        
        var cloudkitJobsToUpdate = []
        
        for (var feedJob of feedJobs) {
          var filteredCloudJobs = cloudKitJobs.filter(function(cloudKitJob) {
            var cloudKitJobLink = cloudKitJob.fields.link
            if (cloudKitJobLink === undefined) {return false}
            return (feedJob.link === cloudKitJobLink.value)
          })
          
          for (var filteredCloudJob of filteredCloudJobs) {
            if(filteredCloudJob.recordChangeTag) {
              feedJob.recordChangeTag = filteredCloudJob[0].recordChangeTag;
            }
            if(filteredCloudRecord.recordName) {
              feedJob.recordName = filteredCloudJob[0].recordName;
            }
            cloudKitJobs.remove(filteredCloudJob)
          }
        }
        
        console.log("update " + feedJobs.length)
        console.log("delete " + cloudKitJobs.length)

        // var updateJobsPromise = database.saveRecords(feedJobs).then(function(response) {
        // console.log("..")
        // return Promise.resolve(response)
        // })

        // var removeJobsPromise = database.removeRecords(cloudKitJobs).then(function(response) {
        //   console.log("...")
        //   return Promise.resolve(response)
        // })
        console.log(".")
        
        // return Promise.all(updateJobsPromise, removeJobsPromise)
        
        // return Promise.all(updateJobsPromise, database.removeRecords(cloudKitJobs));
        return database.saveRecords(feedJobs)
      }).then(function(response) {
        console.log("x")
        resolve(response)
      }).catch(function(error) {
        console.log("y")
        reject(error)
      });
    })

    return syncJobsPromise
    //     var rssKeysToBeRetained = []
    //
    //    xmlreader.read(httpResponse.text, function (err, res){
    //       var rssChannel = res.rss.channel;
    //       rssChannel.item.each(function (i, newJobItem){
    //         var jobQuery = new Parse.Query(Job);
    //         rssKeysToBeRetained.push(newJobItem.link.text())
    //         jobQuery.equalTo("link", newJobItem.link.text())
    //         promises.push(jobQuery.first().then(function(existingJob) {
    //           if (existingJob === undefined) {
    //             var newJob = new Job();
    //             newJob.set("link", newJobItem.link.text());
    //             return Parse.Promise.as(newJob);
    //           } else {
    //             return Parse.Promise.as(existingJob)
    //           }
    //         }).then(function(jobObject) {
    //           jobObject.set("title", newJobItem.title.text());
    //           jobObject.set("content", newJobItem.description.text());
    //           jobObject.set("date", newJobItem.pubDate.text());
    //
    //           var logoHref = newJobItem['atom:link'].attributes()['href']
    //           if (logoHref === undefined || jobObject.has("logo")) {
    //             return jobObject.save();
    //           } else {
    //             console.log("Fetching a logo for " + jobObject.get("title"))
    //             return Parse.Cloud.httpRequest({
    //               url: logoHref
    //             }).then(function(httpResponse) {
    //               var imgFile = new Parse.File(logoHref.split('/').pop(), {base64: httpResponse.buffer.toString('base64', 0, httpResponse.buffer.length)});
    //               return imgFile.save();
    //             }).then(function(imageFile) {
    //               jobObject.set("logo", imageFile);
    //               return jobObject.save();
    //             });
    //           }
    //         }, function(error){
    //           console.log(error);
    //           return Parse.Promise.error(error);
    //         }));
    //       });
    //       var oldJobQuery = new Parse.Query(Job);
    //       oldJobQuery.notContainedIn("link", rssKeysToBeRetained)
    //       promises.push(oldJobQuery.each(function(oldJob){
    //         oldJob.destroy({ wait : true });
    //       }))
    //     });
    //
    //     return Parse.Promise.when(promises);
    //
    //   }).then(function(){
    //     status.success('Fetched jobs from jobs.cocoaheads.nl');
    //   }, function (error) {
    //     var keyQuery = new Parse.Query(APIKey);
    //     keyQuery.equalTo("serviceName", "slack");
    //     return keyQuery.first().then(function(slackNotificationUrl) {
    //         return Parse.Cloud.httpRequest({
    //           method: 'POST',
    //           url: slackNotificationUrl.get("apiKeyString"),
    //         headers: {
    //           'Content-Type': 'application/json;charset=utf-8'
    //         },
    //           body: '{"username": "webhookbot", "text": "Parse Job: Job sync failed.", "icon_emoji": ":ghost:"}'
    //         });
    //     }).then(function (httpResponse) {
    //       console.log("Post ERROR notification to slack succeeded");
    //       status.error('Job update JOB failed');
    //     }, function(slackError) {
    //       console.log(slackError);
    //       console.log("Post ERROR notification to slack failed ");
    //       status.error('Job update JOB failed, slack notification failed too');
    //       return Parse.Promise.error(error);
    //     });
    //   });
    // });
  }

// Sign in using the keyID and public key file.
  container.setUpAuth()
    .then(function(userInfo){
        return syncContributorsPromise()
    }).then(function(response) {
        return syncEventsPromise()
    }).then(function(response) {
        return syncJobsPromise()
    }).then(function(response) {
      console.log("Done");
      process.exit();
    })
    .catch(function(error) {
      console.warn(error);
      process.exit(1);
    });
})();
