#!/bin/sh

# Generates import SQL commands to load all CSV files into a database.
# Uses SQLite syntax by default, add -p for Postgres support.

###

POSTGRES=0

while getopts ":p" opt; do
  case "${opt}" in
  p)
    POSTGRES=1
    ;;
  *)
    exit 1
    ;;
  esac
done

# Setup database
echo "
DROP TABLE IF EXISTS Messages;
CREATE TABLE Messages
(
    Guild       BIGINT NOT NULL,
    Channel     BIGINT NOT NULL,
    ID          BIGINT PRIMARY KEY,
    Timestamp   TEXT    NOT NULL,
    Contents    TEXT,
    Attachments TEXT
);
CREATE INDEX IF NOT EXISTS Messages_Guild ON Messages (Guild);
CREATE INDEX IF NOT EXISTS Messages_Channel ON Messages (Channel);
CREATE INDEX IF NOT EXISTS Messages_Timestamp ON Messages (Timestamp);
"

if [[ $POSTGRES -eq 1 ]]; then
  echo "
  CREATE TEMPORARY TABLE IF NOT EXISTS MessageImport
  (
      ID          BIGINT,
      Timestamp   TEXT,
      Contents    TEXT,
      Attachments TEXT
  );"
fi

# Import messages
for FOLDER in messages/*/; do
  GUILD=$(jq -r ".guild.id" ${FOLDER}channel.json)
  if [[ "$GUILD" == "null" ]]; then
    GUILD=-1
  fi
  CHANNEL=$(jq -r ".id" ${FOLDER}channel.json)

  echo "-- Importing $GUILD/$CHANNEL"

  if [[ $POSTGRES -eq 1 ]]; then
    sed 's/\r//' ${FOLDER}messages.csv >${FOLDER}messages_nocrlf.csv
    echo "\copy MessageImport FROM '${FOLDER}messages_nocrlf.csv' DELIMITER ',' CSV HEADER;"
    echo "INSERT INTO Messages SELECT $GUILD, $CHANNEL, ID, Timestamp, Contents, Attachments FROM MessageImport;"
    echo "TRUNCATE MessageImport;"
  else
    echo ".mode csv"
    echo ".import '${FOLDER}messages.csv' _csv_import"
    echo "INSERT INTO Messages SELECT $GUILD, $CHANNEL, ID, Timestamp, Contents, Attachments FROM _csv_import;"
    echo "DROP TABLE _csv_import;"
  fi
done
