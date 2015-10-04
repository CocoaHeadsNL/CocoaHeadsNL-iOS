Parse.Cloud.afterSave("Meetup", function(request) {
  if (request.object.existed()) {
    return;
  }

  Parse.Push.send({
    channels: ["meetup"],
    data: {
      alert: "New Meetup: " + request.object.get("title"),
      badge: "Increment",
      "content-available": 1,
      t: 2
    }
  }, {
    success: function() {
      console.log("iOS Push succeeded for Meetup " + request.object.get("title"));
    },
    error: function(error) {
      console.error("iOS Push failed for Meetup " + request.object.get("title") + " with error code: " + error.code + "and message: " + error.message);
    }
  });
});

Parse.Cloud.afterSave("Company", function(request) {
  if (request.object.existed()) {
    return;
  }

  Parse.Push.send({
    channels: ["company"],
    data: {
      alert: "New Company: " + request.object.get("title"),
      badge: "Increment",
      "content-available": 1,
      t: 2
    }
  }, {
    success: function() {
      console.log("iOS Push succeeded for Company " + request.object.get("title"));
    },
    error: function(error) {
      console.error("iOS Push failed for Company " + request.object.get("title") + " with error code: " + error.code + "and message: " + error.message);
    }
  });
});

Parse.Cloud.afterSave("Job", function(request) {
  if (request.object.existed()) {
    return;
  }

  Parse.Push.send({
    channels: ["job"],
    data: {
      alert: "New Job: " + request.object.get("title"),
      badge: "Increment",
      "content-available": 1,
      t: 2
    }
  }, {
    success: function() {
      console.log("iOS Push succeeded for Job " + request.object.get("title"));
    },
    error: function(error) {
      console.error("iOS Push failed for Job " + request.object.get("title") + " with error code: " + error.code + "and message: " + error.message);
    }
  });
});
