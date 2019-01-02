db = db.getSiblingDB("admin");
print("db:" + db);

rs.initiate({
  _id: rsName,
  members: [
    { _id: 0, host: opsman0 + ":" + port, priority: 2 },
    { _id: 1, host: opsman1 + ":" + port },
    { _id: 2, host: opsman2 + ":" + port }
  ]
});

while (!db.isMaster().ismaster) {
  print("is master:" + db.isMaster().ismaster + "...");
  sleep(1000);
}
print("is master:" + db.isMaster().ismaster);

db.createUser({
  user: "bob_userAdmin",
  pwd: "supersecret1.",
  roles: [{ role: "userAdminAnyDatabase", db: "admin" }]
});

db.auth("bob_userAdmin", "supersecret1.");

db.createUser({
  user: "john_admin",
  pwd: "supersecret1.",
  roles: [{ role: "root", db: "admin" }]
});

db.createUser({
  user: "opsman",
  pwd: "supersecret1.",
  roles: [
    { role: "readWriteAnyDatabase", db: "admin" },
    { role: "dbAdminAnyDatabase", db: "admin" },
    { role: "clusterAdmin", db: "admin" },
    { role: "clusterMonitor", db: "admin" }
  ]
});
