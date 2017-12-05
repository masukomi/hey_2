# ENV["DATABASE_URL"]="sqlite3:/Users/masukomi/Dropbox/apps/hey/database/hey.test.db"
ENV["DATABASE_URL"] = "sqlite3:/Users/masukomi/workspace/hey_2/spec/test_copy.db"
ENV["HEY_DB_PATH"] = "/Users/masukomi/workspace/hey_2/spec/test_copy.db"
`cp spec/test_seed.db spec/test_copy.db`

ENV["IN_SPEC_TEST"] = "true"
require "spec"
require "../src/hey"
