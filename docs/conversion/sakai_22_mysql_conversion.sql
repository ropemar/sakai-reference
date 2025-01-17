-- SAK-40427
UPDATE SAKAI_SITE_TOOL SET TITLE = 'Discussions' WHERE REGISTRATION = 'sakai.forums' AND TITLE = 'Forums';
UPDATE SAKAI_SITE_PAGE SET TITLE = 'Discussions' WHERE TITLE = 'Forums';
-- End SAK-40427

-- SAK-44305
create table MFR_DRAFT_RECIPIENT_T
(ID bigint not null auto_increment,
 TYPE int not null,
 RECIPIENT_ID varchar(255) not null,
 DRAFT_ID bigint not null,
 BCC bit not null,
 primary key (ID));

create index MFR_DRAFT_REC_MSG_ID_I on MFR_DRAFT_RECIPIENT_T(DRAFT_ID);
-- End SAK-44305

-- SAK-45565
ALTER TABLE lesson_builder_groups CHANGE COLUMN `groups` item_groups LONGTEXT NULL DEFAULT NULL;
ALTER TABLE lesson_builder_items CHANGE COLUMN `groups` item_groups LONGTEXT NULL DEFAULT NULL;
ALTER TABLE tasks CHANGE COLUMN `SYSTEM` SYSTEM_TASK BIT(1) NOT NULL;
-- SAK-45565

-- SAK-44967
ALTER TABLE GB_GRADEBOOK_T ADD COLUMN ALLOW_COMPARE_GRADES BIT(1) DEFAULT FALSE NOT NULL;
ALTER TABLE GB_GRADEBOOK_T ADD COLUMN COMPARING_DISPLAY_FIRSTNAMES BIT(1) DEFAULT FALSE NOT NULL;
ALTER TABLE GB_GRADEBOOK_T ADD COLUMN COMPARING_DISPLAY_SURNAMES BIT(1) DEFAULT FALSE NOT NULL;
ALTER TABLE GB_GRADEBOOK_T ADD COLUMN COMPARING_DISPLAY_COMMENTS BIT(1) DEFAULT FALSE NOT NULL;
ALTER TABLE GB_GRADEBOOK_T ADD COLUMN COMPARING_DISPLAY_ALLITEMS BIT(1) DEFAULT FALSE NOT NULL;
ALTER TABLE GB_GRADEBOOK_T ADD COLUMN COMPARING_RANDOMIZEDATA BIT(1) DEFAULT FALSE NOT NULL;
-- End SAK-44967

-- SAK-46030

-- Create functions
INSERT INTO SAKAI_REALM_FUNCTION (FUNCTION_NAME) VALUES('dropbox.write.own');
INSERT INTO SAKAI_REALM_FUNCTION (FUNCTION_NAME) VALUES('dropbox.write.any');
INSERT INTO SAKAI_REALM_FUNCTION (FUNCTION_NAME) VALUES('dropbox.delete.own');
INSERT INTO SAKAI_REALM_FUNCTION (FUNCTION_NAME) VALUES('dropbox.delete.any');

-- Project sites - maintainers get .any permissions, accessors get .own permissions
INSERT INTO SAKAI_REALM_RL_FN (REALM_KEY, ROLE_KEY, FUNCTION_KEY) VALUES (
    (SELECT REALM_KEY FROM SAKAI_REALM WHERE REALM_ID = '!site.template'),
    (SELECT ROLE_KEY FROM SAKAI_REALM_ROLE WHERE ROLE_NAME = 'maintain'),
    (SELECT FUNCTION_KEY FROM SAKAI_REALM_FUNCTION WHERE FUNCTION_NAME = 'dropbox.write.any')
);
INSERT INTO SAKAI_REALM_RL_FN (REALM_KEY, ROLE_KEY, FUNCTION_KEY) VALUES (
    (SELECT REALM_KEY FROM SAKAI_REALM WHERE REALM_ID = '!site.template'),
    (SELECT ROLE_KEY FROM SAKAI_REALM_ROLE WHERE ROLE_NAME = 'maintain'),
    (SELECT FUNCTION_KEY FROM SAKAI_REALM_FUNCTION WHERE FUNCTION_NAME = 'dropbox.delete.any')
);
INSERT INTO SAKAI_REALM_RL_FN (REALM_KEY, ROLE_KEY, FUNCTION_KEY) VALUES (
    (SELECT REALM_KEY FROM SAKAI_REALM WHERE REALM_ID = '!site.template'),
    (SELECT ROLE_KEY FROM SAKAI_REALM_ROLE WHERE ROLE_NAME = 'access'),
    (SELECT FUNCTION_KEY FROM SAKAI_REALM_FUNCTION WHERE FUNCTION_NAME = 'dropbox.write.own')
);
INSERT INTO SAKAI_REALM_RL_FN (REALM_KEY, ROLE_KEY, FUNCTION_KEY) VALUES (
    (SELECT REALM_KEY FROM SAKAI_REALM WHERE REALM_ID = '!site.template'),
    (SELECT ROLE_KEY FROM SAKAI_REALM_ROLE WHERE ROLE_NAME = 'access'),
    (SELECT FUNCTION_KEY FROM SAKAI_REALM_FUNCTION WHERE FUNCTION_NAME = 'dropbox.delete.own')
);
-- Give instructor the '.any' permissions in !site.template.course
INSERT INTO SAKAI_REALM_RL_FN (REALM_KEY, ROLE_KEY, FUNCTION_KEY) VALUES (
    (SELECT REALM_KEY FROM SAKAI_REALM WHERE REALM_ID = '!site.template.course'),
    (SELECT ROLE_KEY FROM SAKAI_REALM_ROLE WHERE ROLE_NAME = 'Instructor'),
    (SELECT FUNCTION_KEY FROM SAKAI_REALM_FUNCTION WHERE FUNCTION_NAME = 'dropbox.write.any')
);
INSERT INTO SAKAI_REALM_RL_FN (REALM_KEY, ROLE_KEY, FUNCTION_KEY) VALUES (
    (SELECT REALM_KEY FROM SAKAI_REALM WHERE REALM_ID = '!site.template.course'),
    (SELECT ROLE_KEY FROM SAKAI_REALM_ROLE WHERE ROLE_NAME = 'Instructor'),
    (SELECT FUNCTION_KEY FROM SAKAI_REALM_FUNCTION WHERE FUNCTION_NAME = 'dropbox.delete.any')
);
-- Give student and TA the '.own' permissions in !site.template.course
INSERT INTO SAKAI_REALM_RL_FN (REALM_KEY, ROLE_KEY, FUNCTION_KEY) VALUES (
    (SELECT REALM_KEY FROM SAKAI_REALM WHERE REALM_ID = '!site.template.course'),
    (SELECT ROLE_KEY FROM SAKAI_REALM_ROLE WHERE ROLE_NAME = 'Student'),
    (SELECT FUNCTION_KEY FROM SAKAI_REALM_FUNCTION WHERE FUNCTION_NAME = 'dropbox.write.own')
);
INSERT INTO SAKAI_REALM_RL_FN (REALM_KEY, ROLE_KEY, FUNCTION_KEY) VALUES (
    (SELECT REALM_KEY FROM SAKAI_REALM WHERE REALM_ID = '!site.template.course'),
    (SELECT ROLE_KEY FROM SAKAI_REALM_ROLE WHERE ROLE_NAME = 'Student'),
    (SELECT FUNCTION_KEY FROM SAKAI_REALM_FUNCTION WHERE FUNCTION_NAME = 'dropbox.delete.own')
);
INSERT INTO SAKAI_REALM_RL_FN (REALM_KEY, ROLE_KEY, FUNCTION_KEY) VALUES (
    (SELECT REALM_KEY FROM SAKAI_REALM WHERE REALM_ID = '!site.template.course'),
    (SELECT ROLE_KEY FROM SAKAI_REALM_ROLE WHERE ROLE_NAME = 'Teaching Assistant'),
    (SELECT FUNCTION_KEY FROM SAKAI_REALM_FUNCTION WHERE FUNCTION_NAME = 'dropbox.write.own')
);
INSERT INTO SAKAI_REALM_RL_FN (REALM_KEY, ROLE_KEY, FUNCTION_KEY) VALUES (
    (SELECT REALM_KEY FROM SAKAI_REALM WHERE REALM_ID = '!site.template.course'),
    (SELECT ROLE_KEY FROM SAKAI_REALM_ROLE WHERE ROLE_NAME = 'Teaching Assistant'),
    (SELECT FUNCTION_KEY FROM SAKAI_REALM_FUNCTION WHERE FUNCTION_NAME = 'dropbox.delete.own')
);

-- --------------------------------------------------------------------------------------------------------------------------------------
-- backfill new permission into existing realms
-- --------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE PERMISSIONS_SRC_TEMP (ROLE_NAME VARCHAR(99), FUNCTION_NAME VARCHAR(99));

INSERT INTO PERMISSIONS_SRC_TEMP VALUES('maintain','dropbox.write.any');
INSERT INTO PERMISSIONS_SRC_TEMP VALUES('maintain','dropbox.delete.any');
INSERT INTO PERMISSIONS_SRC_TEMP VALUES('access','dropbox.write.own');
INSERT INTO PERMISSIONS_SRC_TEMP VALUES('access','dropbox.delete.own');
INSERT INTO PERMISSIONS_SRC_TEMP VALUES('Instructor','dropbox.write.any');
INSERT INTO PERMISSIONS_SRC_TEMP VALUES('Instructor','dropbox.delete.any');
INSERT INTO PERMISSIONS_SRC_TEMP VALUES('Student','dropbox.write.own');
INSERT INTO PERMISSIONS_SRC_TEMP VALUES('Student','dropbox.delete.own');
INSERT INTO PERMISSIONS_SRC_TEMP VALUES('Teaching Assistant','dropbox.write.own');
INSERT INTO PERMISSIONS_SRC_TEMP VALUES('Teaching Assistant','dropbox.delete.own');

-- lookup the role and function number
CREATE TABLE PERMISSIONS_TEMP (ROLE_KEY INTEGER, FUNCTION_KEY INTEGER);
INSERT INTO PERMISSIONS_TEMP (ROLE_KEY, FUNCTION_KEY)
SELECT SRR.ROLE_KEY, SRF.FUNCTION_KEY
FROM PERMISSIONS_SRC_TEMP TMPSRC
JOIN SAKAI_REALM_ROLE SRR ON (TMPSRC.ROLE_NAME = SRR.ROLE_NAME)
JOIN SAKAI_REALM_FUNCTION SRF ON (TMPSRC.FUNCTION_NAME = SRF.FUNCTION_NAME);

-- insert the new function into the roles of any existing realm that has the role (don't convert the "!site.helper")
INSERT INTO SAKAI_REALM_RL_FN (REALM_KEY, ROLE_KEY, FUNCTION_KEY)
SELECT
    SRRFD.REALM_KEY, SRRFD.ROLE_KEY, TMP.FUNCTION_KEY
FROM
    (SELECT DISTINCT SRRF.REALM_KEY, SRRF.ROLE_KEY FROM SAKAI_REALM_RL_FN SRRF) SRRFD
    JOIN PERMISSIONS_TEMP TMP ON (SRRFD.ROLE_KEY = TMP.ROLE_KEY)
    JOIN SAKAI_REALM SR ON (SRRFD.REALM_KEY = SR.REALM_KEY)
    WHERE SR.REALM_ID != '!site.helper'
    AND NOT EXISTS (
        SELECT 1
            FROM SAKAI_REALM_RL_FN SRRFI
            WHERE SRRFI.REALM_KEY=SRRFD.REALM_KEY AND SRRFI.ROLE_KEY=SRRFD.ROLE_KEY AND SRRFI.FUNCTION_KEY=TMP.FUNCTION_KEY
    );

-- clean up the temp tables
DROP TABLE PERMISSIONS_TEMP;
DROP TABLE PERMISSIONS_SRC_TEMP;

-- END SAK-46030

-- SAK-46022
ALTER TABLE COMMONS_POST ADD COLUMN PRIORITY BIT(1) DEFAULT FALSE NOT NULL;
-- End SAK-46022

-- SAK-46685
ALTER TABLE ASN_ASSIGNMENT ADD ESTIMATE_REQUIRED CHAR(1) DEFAULT '0' NOT NULL;
ALTER TABLE ASN_ASSIGNMENT ADD ESTIMATE VARCHAR(255) NULL;
ALTER TABLE ASN_SUBMISSION_SUBMITTER ADD TIME_SPENT VARCHAR(255) NULL;
ALTER TABLE ASN_ASSIGNMENT ADD CONSTRAINT CHECK_IS_ESTIMATE_REQUIRED CHECK (ESTIMATE_REQUIRED IN ('0', '1'));

CREATE TABLE TIMESHEET_ENTRY (
ID BIGINT(20) NOT NULL AUTO_INCREMENT,
REFERENCE VARCHAR(255) NOT NULL,
USER_ID VARCHAR(99),
START_TIME DATETIME NOT NULL,
DURATION VARCHAR(255) NOT NULL,
TEXT_COMMENT VARCHAR(4000) NULL,
PRIMARY KEY (ID)
);

CREATE INDEX IDX_TIMESHEETENTRY_REF_USER ON TIMESHEET_ENTRY(REFERENCE, USER_ID);
-- End SAK-46685

-- SAK-46021
CREATE TABLE COMMONS_LIKE (
USER_ID VARCHAR(99) NOT NULL,
POST_ID CHAR(36) NOT NULL,
VOTE bit(1) DEFAULT FALSE NOT NULL,
MODIFIED_DATE datetime,
PRIMARY KEY (USER_ID, POST_ID)
);
--End SAK-46021

-- SAK-46137
ALTER TABLE SAKAI_PERSON_T ADD PRINCIPAL_NAME_PRIOR varchar(255) DEFAULT NULL;
ALTER TABLE SAKAI_PERSON_T ADD SCOPED_AFFILIATION varchar(255) DEFAULT NULL;
ALTER TABLE SAKAI_PERSON_T ADD TARGETED_ID varchar(255) DEFAULT NULL;
ALTER TABLE SAKAI_PERSON_T ADD ASSURANCE varchar(255) DEFAULT NULL;
ALTER TABLE SAKAI_PERSON_T ADD UNIQUE_ID varchar(255) DEFAULT NULL;
ALTER TABLE SAKAI_PERSON_T ADD ORCID varchar(255) DEFAULT NULL;
-- End SAK-46137 

-- SAK-46085
ALTER TABLE PROFILE_SOCIAL_INFO_T ADD COLUMN INSTAGRAM_URL VARCHAR(255) NULL;
--End SAK-46085

-- SAK-46686
ALTER TABLE GB_GRADE_RECORD_T ADD COLUMN ENTERED_POINTS double;
--End SAK-46686

-- SAK-46920
ALTER TABLE RBC_EVALUATION ADD COLUMN STATUS INT NOT NULL;
-- End SAK-46920

-- SAK-45987
CREATE TABLE RBC_RETURNED_CRITERION_OUT (
  ID BIGINT(20) NOT NULL,
  COMMENTS LONGTEXT DEFAULT NULL,
  CRITERION_ID BIGINT(20) DEFAULT NULL,
  POINTS DOUBLE DEFAULT NULL,
  POINTSADJUSTED BIT(1) NOT NULL,
  SELECTED_RATING_ID BIGINT(20) DEFAULT NULL,
  PRIMARY KEY (ID),
  CONSTRAINT FK_RBC_RETURNED_CRITERION_ID FOREIGN KEY (CRITERION_ID) REFERENCES RBC_CRITERION (ID)
);

CREATE SEQUENCE RBC_RET_CRIT_OUT_SEQ;


CREATE TABLE RBC_RETURNED_EVALUATION (
  ID BIGINT(20) NOT NULL,
  ORIGINAL_EVALUATION_ID BIGINT(20) NOT NULL,
  OVERALLCOMMENT VARCHAR(255) DEFAULT NULL
);

CREATE SEQUENCE RBC_RET_EVAL_SEQ;

CREATE INDEX RBC_RET_ORIG_ID ON  RBC_RETURNED_EVALUATION(ORIGINAL_EVALUATION_ID);

CREATE TABLE RBC_RETURNED_CRITERION_OUTS (
  RBC_RETURNED_EVALUATION_ID BIGINT(20) NOT NULL,
  RBC_RETURNED_CRITERION_OUT_ID BIGINT(20) NOT NULL UNIQUE,
  CONSTRAINT RETURNED_CRITERION_OUT_ID_FK FOREIGN KEY (RBC_RETURNED_CRITERION_OUT_ID) REFERENCES RBC_RETURNED_CRITERION_OUT (ID),
  CONSTRAINT RETURNED_EVALUTION_ID_FK FOREIGN KEY (RBC_RETURNED_EVALUATION_ID) REFERENCES RBC_RETURNED_EVALUATION (ID)
);

CREATE INDEX RETURNED_EVALUATION_ID_KEY ON RBC_RETURNED_CRITERION_OUTS(RBC_RETURNED_EVALUATION_ID);
-- End SAK-45987