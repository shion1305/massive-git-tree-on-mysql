USE test;


DROP PROCEDURE GenerateCommits;
DROP PROCEDURE MassOperation;

DELIMITER //

CREATE PROCEDURE GenerateCommits(remain INT, parent_id CHAR(40), level INT)
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE max_commits INT DEFAULT 10;
    DECLARE commit_id CHAR(40);
    DECLARE generation_rate FLOAT DEFAULT 0.101;

    IF remain > 0 THEN
        WHILE i <= max_commits
            DO
                IF RAND() < generation_rate THEN
                    SET commit_id = SHA1(RANDOM_BYTES(40));
                    INSERT INTO commits (commit_id, parent_commit_id, commit_message, level)
                    VALUES (commit_id, parent_id, CONCAT('Commit ', commit_id), level);
                    CALL GenerateCommits(remain - 1, commit_id, level + 1);
                END IF;
                SET i = i + 1;
            END WHILE;
    END IF;
END //


CREATE PROCEDURE MassOperation()
BEGIN
    DECLARE i int DEFAULT 1;
    WHILE i < 2000
        DO
            CALL GenerateCommits(250, NULL, 1);
            SET i = i + 1;
        END WHILE;
END;

DELIMITER ;

CALL MassOperation;


# Fill all level column with zero value
UPDATE commits c
    JOIN (WITH RECURSIVE commit_levels AS (SELECT commit_id, parent_commit_id, 1 AS level
                                           FROM commits
                                           WHERE parent_commit_id IS NULL
                                             AND level = 0
                                           UNION ALL
                                           SELECT c.commit_id, c.parent_commit_id, cl.level + 1
                                           FROM commits c
                                                    INNER JOIN commit_levels cl ON c.parent_commit_id = cl.commit_id)
          SELECT commit_id, level
          FROM commit_levels) cl ON c.commit_id = cl.commit_id
SET c.level = cl.level