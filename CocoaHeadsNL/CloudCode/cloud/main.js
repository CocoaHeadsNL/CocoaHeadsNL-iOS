"use strict";
var Meetup = Parse.Object.extend("Meetup");
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
				meetupObject.set("description", event.description);
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
				var geoPoint = new Parse.GeoPoint({latitude: event.venue.lat, longitude: event.venue.lon});
				meetupObject.set("geoLocation", geoPoint);
				return meetupObject.save();
			}, function(error){
				console.log(error);
			}));
		});
		return Parse.Promise.when(promises);
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