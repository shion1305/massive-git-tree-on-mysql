CREATE DATABASE IF NOT EXISTS test;
USE test;

CREATE TABLE IF NOT EXISTS commits
(
    commit_id        CHAR(40) PRIMARY KEY UNIQUE,
    parent_commit_id CHAR(40),
    commit_message   VARCHAR(255),
    level            INT,
    INDEX index_commit_id (commit_id),
    INDEX index_parent_commit_id (parent_commit_id)
);

