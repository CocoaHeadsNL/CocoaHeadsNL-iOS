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

		console.log(meetupKeyObject.get("apiKeyString"));
		console.log(meetupKeyObject.apiKeyString);
		Parse.Cloud.httpRequest({
			url: 'https://api.meetup.com/2/events',
			params: {
				'key' : meetupKeyObject.get("apiKeyString"),
				'sign' : true,
				'photo-host' : 'public',
				'group_urlname' : 'cocoaheadsnl',
				'page' : 20
			},
			success: function(httpResponse) {
				var eventsData = httpResponse.data["results"];
				console.log(eventsData);
				eventsData.forEach(function(event) {
					var meetup = new Meetup();
					meetup.set("meetup_id", event.id);
					meetup.set("name", event.name);
					meetup.set("description", event.description);
					meetup.set("locationName", event.venue.name)
					var geoPoint = new Parse.GeoPoint({latitude: event.venue.lat, longitude: event.venue.lon});
					meetup.set("geoLocation", geoPoint);

					meetup.save(null, {
						success: function(event) {
							// The object was saved successfully.
						},
						error: function(event, error) {
							console.log(event);
							console.log(error);
							// The save failed.
							// error is a Parse.Error with an error code and message.
						}
					});
				});
				status.success("loadEventInfo completed successfully.");
			},
			error: function(httpResponse) {
				status.error('Request failed with response code ' + httpResponse.status);
			}
		});
	});
});