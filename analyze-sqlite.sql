-- Sample queries for SQLite - requires REGEXP support
-- Execute them in a SQLite shell opened with `sqlite3 discord.db`

-- Count of messages with only a emotes, no text
SELECT COUNT(*) AS Count
FROM Messages
WHERE Contents REGEXP '<a?:\w*:\d*>'
ORDER BY Count DESC;

-- Count of messages with one or multiple emotes, no text
SELECT COUNT(*) AS Count
FROM Messages
WHERE Contents REGEXP '(<a?:\w*:\d*>(\s)*)+'
ORDER BY Count DESC;

-- Top single emotes
SELECT Contents, COUNT(*) AS Count
FROM Messages
WHERE Contents REGEXP '<a?:\w*:\d*>'
GROUP BY Contents
ORDER BY Count DESC;
