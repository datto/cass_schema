# CREATE KEYSPACE test_keyspace with replication = { 'class' : 'SimpleStrategy', 'replication_factor' : 1 }

CREATE TABLE test(
  id text,
  a text,
  b text,
  PRIMARY KEY(id, a))

# Comment
CREATE TABLE test2(
  id text,
  x text,
  y text,
  PRIMARY KEY(id, x))
