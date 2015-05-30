"use strict";

var Contributor = Parse.Object.extend("Contributor");
var APIKey = Parse.Object.extend("APIKey");

Parse.Cloud.job("loadContributorInfo", function(request, status) {
    // Set up to modify user data
    Parse.Cloud.useMasterKey();
	
	Parse.Cloud.httpRequest({
		url: 'https://api.github.com/repos/CocoaHeadsNL/CocoaHeadsNL-iOS/stats/contributors',
		headers: {
		    'User-Agent': 'CocoaHeadsNL-Parse-Cloud'
		  }
	}).then(function (httpResponse) {
		var promises = [];
		
		var contributorData = httpResponse.data;
		contributorData.forEach(function(contributorInfo) {
			var author = contributorInfo["author"];
			promises.push(Parse.Cloud.httpRequest({
				url: author.url,
				headers: {
				    'User-Agent': 'CocoaHeadsNL-Parse-Cloud'
				  }
				}).then(function (httpResponse) {
					var authorDetailData = httpResponse.data;
					
					var contributorQuery = new Parse.Query(Contributor);
					contributorQuery.equalTo("contributor_id", authorDetailData["id"])
					return contributorQuery.first().then(function(existingContributor) {
						if (existingContributor === undefined) {
							var newContributor = new Contributor();
							newContributor.set("contributor_id", authorDetailData["id"]);
							return Parse.Promise.as(newContributor);
						} else {
							return Parse.Promise.as(existingContributor)
						}
					}).then(function(contributorObject) {
						contributorObject.set("avatar_url", authorDetailData["avatar_url"]);
						contributorObject.set("name", authorDetailData["name"]);
						return contributorObject.save();
					}, function(error){
						return Parse.Promise.error(error);
					});
				})
			)
		})
		return Parse.Promise.when(promises);
	}).then(function() {
		status.success("loadContributorInfo completed successfully.");		
	}, function(error){
		console.log(error)
		var keyQuery = new Parse.Query(APIKey);
		keyQuery.equalTo("serviceName", "slack");
		return keyQuery.first().then(function(slackNotificationUrl) {
    		return Parse.Cloud.httpRequest({
	    		method: 'POST',
		    	url: slackNotificationUrl.get("apiKeyString"),
				headers: {
					'Content-Type': 'application/json;charset=utf-8'
				},
			    body: '{"username": "webhookbot", "text": "Parse Job: Contributor sync failed.", "icon_emoji": ":ghost:"}' 
	    	});
		}).then(function (httpResponse) {
			console.log("Post ERROR notification to slack succeeded");
			status.error('Contributor update JOB failed');
		}, function(githubError) {
			console.log(githubError);
			console.log("Post ERROR notification to slack failed ");
			status.error('Contributor update JOB failed, slack notification failed too');
			return Parse.Promise.error(error);
		});
	});
});