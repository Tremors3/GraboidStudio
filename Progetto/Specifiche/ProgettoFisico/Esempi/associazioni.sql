
-- Many to Many

create table teacher (
  id SERIAL PRIMARY KEY
);

create table teacher_office (
    teacher integer REFERENCES teacher(id) 
    office integer REFERENCES office(id)
);

create table office (
  id SERIAL PRIMARY KEY
);




-- One to Many

create table teacher (
  id SERIAL PRIMARY KEY
);

create table office (
  id SERIAL PRIMARY KEY
  teacher INTEGER REFERENCES teacher(id)
);








-- One to One V1

create table teacher (
  id SERIAL PRIMARY KEY

  office SERIAL REFERENCES office(id) UNIQUE DEFERRABLE INITIALLY DEFERRED
);

create table office (
  id INTEGER PRIMARY KEY

  teacher INTEGER REFERENCES teacher(id) UNIQUE NOT NULL
);