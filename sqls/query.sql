USE test;

SELECT *
FROM commits
WHERE parent_commit_id IS NULL;

SELECT commit_id
FROM commits
WHERE level = 1
ORDER BY RAND()
LIMIT 10000;


# 正探索 (子->親) 240件
WITH RECURSIVE commit_tree AS
                   (SELECT *
                    FROM commits
                    WHERE commit_id = '398fb57621e8cb491e808d41f862185df346d1f3'
                    UNION ALL
                    SELECT c.*
                    FROM commits c
                             INNER JOIN commit_tree ct ON ct.parent_commit_id = c.commit_id)
SELECT *
FROM commit_tree;

# 逆探索 (親->子), 件数膨大 184316件
WITH RECURSIVE commit_tree AS
                   (SELECT *
                    FROM commits
                    WHERE commit_id = 'eecce4095730595a050d11e1d1a9e904fd72a59f'
                    UNION ALL
                    SELECT c.*
                    FROM commits c
                             INNER JOIN commit_tree ct ON ct.commit_id = c.parent_commit_id)
SELECT COUNT(*)
FROM commit_tree;

