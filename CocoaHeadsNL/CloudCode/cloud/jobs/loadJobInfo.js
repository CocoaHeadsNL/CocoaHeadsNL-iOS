"use strict";
var xmlreader = require('cloud/xmlreader.js');


var Meetup = Parse.Object.extend("Meetup");
var Job = Parse.Object.extend("Job");
var APIKey = Parse.Object.extend("APIKey");

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
					return Parse.Promise.error(error);
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