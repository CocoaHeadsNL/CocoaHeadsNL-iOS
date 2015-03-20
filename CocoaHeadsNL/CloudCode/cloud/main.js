require('cloud/app.js');

"use strict";

var xmlreader = require('cloud/xmlreader.js');

var Meetup = Parse.Object.extend("Meetup");
var Job = Parse.Object.extend("Job");
var APIKey = Parse.Object.extend("APIKey");

Parse.Cloud.job("loadEventInfo", function(request, status) {
    // Set up to modify user data
    Parse.Cloud.useMasterKey();
	
	//We first load the Meetup API key from the backing store to make sure we are not publishing the APIKey through a repository.
	var keyQuery = new Parse.Query(APIKey);
	keyQuery.equalTo("serviceName", "meetup");
	keyQuery.first().then(function(meetupKeyObject) {
		//https://api.meetup.com/2/events?&sign=true&photo-host=public&group_urlname=cocoaheadsnl&page=20
		return Parse.Cloud.httpRequest({
			url: 'https://api.meetup.com/2/events',
			params: {
				'key' : meetupKeyObject.get("apiKeyString"),
				'sign' : true,
				'photo-host' : 'public',
				'group_urlname' : 'cocoaheadsnl',
				'page' : 20,
				'status': 'upcoming,past'
			}});
	}).then(function(httpResponse){
		var eventsData = httpResponse.data["results"];
		// console.log("Data received from meetup: " + eventsData);
		
		var promises = [];
		
		eventsData.forEach(function(event) {
			var meetupQuery = new Parse.Query(Meetup);
			meetupQuery.equalTo("meetup_id", event.id)
			promises.push(meetupQuery.first().then(function(existingMeetup) {
				if (existingMeetup === undefined) {
					var newMeetup = new Meetup();
					newMeetup.set("meetup_id", event.id);
					return Parse.Promise.as(newMeetup);
				} else {
					return Parse.Promise.as(existingMeetup)
				}
			}).then(function(meetupObject) {
				meetupObject.set("name", event.name);
				meetupObject.set("meetup_description", event.description);
				meetupObject.set("locationName", event.venue.name);
				var timeValue = event.time;
				if (timeValue !== undefined) {
					timeValue = new Date(timeValue);
				}
				meetupObject.set("time", timeValue);
				meetupObject.set("duration", event.duration);
				meetupObject.set("yes_rsvp_count", event.yes_rsvp_count);
				meetupObject.set("rsvp_limit", event.rsvp_limit);
				meetupObject.set("meetup_url", event.meetup_url);
				meetupObject.set("nextEvent", false);
				var geoPoint = new Parse.GeoPoint({latitude: event.venue.lat, longitude: event.venue.lon});
				meetupObject.set("geoLocation", geoPoint);
				return meetupObject.save();
			}, function(error){
				console.log(error);
			}));
		});
		return Parse.Promise.when(promises);
	}).then(function() {
		var meetupQuery = new Parse.Query(Meetup);
		meetupQuery.greaterThan	("time", new Date());
		meetupQuery.ascending("time");
		return meetupQuery.first();
	}).then(function(nextMeetup) {
		nextMeetup.set("nextEvent", true);
		return nextMeetup.save();
	}).then(function() {
		status.success("loadEventInfo completed successfully.");
	}, function(error){
		var keyQuery = new Parse.Query(APIKey);
		keyQuery.equalTo("serviceName", "slack");
		return keyQuery.first().then(function(slackNotificationUrl) {
    		return Parse.Cloud.httpRequest({
	    		method: 'POST',
		    	url: slackNotificationUrl.get("apiKeyString"),
				headers: {
					'Content-Type': 'application/json;charset=utf-8'
				},
			    body: '{"username": "webhookbot", "text": "Parse Job: Meetup sync failed.", "icon_emoji": ":ghost:"}' 
	    	});
		}).then(function (httpResponse) {
			console.log("Post ERROR notification to slack succeeded");
			status.error('Meetup update JOB failed');
		}, function(slackError) {
			console.log(slackError);
			console.log("Post ERROR notification to slack failed ");
			status.error('Meetup update JOB failed, slack notification failed too');
			return Parse.Promise.error(error);
		});
	});
});


Parse.Cloud.job("loadJobInfo", function(request, status) {
    // Set up to modify user data
    Parse.Cloud.useMasterKey();
	
	Parse.Cloud.httpRequest({
		url: 'http://jobs.cocoaheads.nl/feed.xml'
	}).then(function (httpResponse) {
		var promises = [];
		
		xmlreader.read(httpResponse.text, function (err, res){
			var rssChannel = res.rss.channel;
			rssChannel.item.each(function (i, newJobItem){
				var jobQuery = new Parse.Query(Job);
				jobQuery.equalTo("link", newJobItem.link.text())
				promises.push(jobQuery.first().then(function(existingJob) {
					if (existingJob === undefined) {
						var newJob = new Job();
						newJob.set("link", newJobItem.link.text());
						return Parse.Promise.as(newJob);
					} else {
						return Parse.Promise.as(existingJob)
					}
				}).then(function(jobObject) {
					jobObject.set("title", newJobItem.title.text());
					jobObject.set("content", newJobItem.description.text());
					jobObject.set("date", newJobItem.pubDate.text());

					var logoHref = newJobItem['atom:link'].attributes()['href']
					if (logoHref === undefined || jobObject.has("logo")) {
						return jobObject.save();
					} else {
						console.log("Fetching a logo for " + jobObject.get("title"))
						return Parse.Cloud.httpRequest({
							url: logoHref
						}).then(function(httpResponse) {
							var imgFile = new Parse.File(logoHref.split('/').pop(), {base64: httpResponse.buffer.toString('base64', 0, httpResponse.buffer.length)});
							return imgFile.save();
						}).then(function(imageFile) {
							jobObject.set("logo", imageFile);
							return jobObject.save();
						});
					}
				}, function(error){
					console.log(error);
				}));
			});
		});
		
		return Parse.Promise.when(promises);
		
	}).then(function(){
		status.success('Fetched jobs from jobs.cocoaheads.nl');
	}, function (error) {
		var keyQuery = new Parse.Query(APIKey);
		keyQuery.equalTo("serviceName", "slack");
		return keyQuery.first().then(function(slackNotificationUrl) {
    		return Parse.Cloud.httpRequest({
	    		method: 'POST',
		    	url: slackNotificationUrl.get("apiKeyString"),
				headers: {
					'Content-Type': 'application/json;charset=utf-8'
				},
			    body: '{"username": "webhookbot", "text": "Parse Job: Job sync failed.", "icon_emoji": ":ghost:"}' 
	    	});
		}).then(function (httpResponse) {
			console.log("Post ERROR notification to slack succeeded");
			status.error('Job update JOB failed');
		}, function(slackError) {
			console.log(slackError);
			console.log("Post ERROR notification to slack failed ");
			status.error('Job update JOB failed, slack notification failed too');
			return Parse.Promise.error(error);
		});
	});
});

