-- Sample queries for Postgres

-- Top emotes
SELECT (REGEXP_MATCHES(contents, '<a?:[\w]+:\d{18}>', 'g'))[1] AS emote, COUNT(*) AS count
FROM messages
GROUP BY emote
ORDER BY count DESC;
