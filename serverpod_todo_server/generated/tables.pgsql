--
-- Class Todo as table todos
--

CREATE TABLE "todos" (
  "id" serial,
  "user_id" integer NOT NULL,
  "title" text NOT NULL,
  "completed" boolean NOT NULL
);

ALTER TABLE ONLY "todos"
  ADD CONSTRAINT todos_pkey PRIMARY KEY (id);


