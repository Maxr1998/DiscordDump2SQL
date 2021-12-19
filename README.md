# Discord data dump to SQL

Simple helper script to import your Discord data dump to a SQLite or PostgreSQL database for further analysis.  
Requires sqlite3 or a Postgres database as well as [jq](https://stedolan.github.io/jq/) for JSON parsing.

Simply unpack your data dump into the same folder as the script and execute it with:

```bash
# SQLite
./process.sh | sqlite3 discord.db

### or ###

# Postgres
./process.sh -p | psql -h <host> -p <port> -U postgres
```

Some sample queries are included as `analyze-sqlite.sql` and `analyze-pg.sql` as a starting point.
