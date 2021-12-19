#!/bin/sh
FILE=discord.db

# Start SQLite process and setup named fifo as input
mkfifo sql_fifo
sqlite3 $FILE <sql_fifo &
exec 6>sql_fifo

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
" >&6

# Import messages
for FOLDER in messages/*/; do
  GUILD=$(jq -r ".guild.id" ${FOLDER}channel.json)
  if [[ "$GUILD" == "null" ]]; then
    GUILD=-1
  fi
  CHANNEL=$(jq -r ".id" ${FOLDER}channel.json)

  echo "Importing $GUILD/$CHANNEL"

  echo ".mode csv" >&6
  echo ".import '${FOLDER}messages.csv' _csv_import" >&6
  echo "INSERT INTO Messages SELECT $GUILD, $CHANNEL, ID, Timestamp, Contents, Attachments FROM _csv_import;" >&6
  echo "DROP TABLE _csv_import;" >&6
done

exec 6>&-
rm -f sql_fifo
