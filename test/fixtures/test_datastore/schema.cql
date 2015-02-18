CREATE KEYSPACE test2 with replication = { 'class' : 'SimpleStrategy', 'replication_factor' : 1 }

CREATE TABLE test2.test(
  id text,
  a text,
  b text,
  PRIMARY KEY(id, a))

# Comment
CREATE TABLE test2.test2(
  id text,
  x text,
  y text,
  PRIMARY KEY(id, x))
