-- Create StudentDetails table
CREATE TABLE StudentDetails (
    Studentid INT PRIMARY KEY,
    StudentName VARCHAR(255),
    GPA FLOAT,
    BranchSection CHAR(1)
);

-- Create SubjectDetails table
CREATE TABLE SubjectDetails (
    Subjectid INT PRIMARY KEY,
    SubjectName VARCHAR(255),
    MaxSeats INT,
    RemainingSeats INT
);

-- Create StudentPreference table
CREATE TABLE StudentPreference (
    Studentid INT,
    Subjectid INT,
    Preference INT,
    FOREIGN KEY (Studentid) REFERENCES StudentDetails(Studentid),
    FOREIGN KEY (Subjectid) REFERENCES SubjectDetails(Subjectid),
    PRIMARY KEY (Studentid, Subjectid)
);

-- Create Allotments table
CREATE TABLE Allotments (
    Subjectid INT,
    Studentid INT,
    FOREIGN KEY (Subjectid) REFERENCES SubjectDetails(Subjectid),
    FOREIGN KEY (Studentid) REFERENCES StudentDetails(Studentid),
    PRIMARY KEY (Subjectid, Studentid)
);

-- Create UnallotedStudents table
CREATE TABLE UnallotedStudents (
    Studentid INT PRIMARY KEY,
    FOREIGN KEY (Studentid) REFERENCES StudentDetails(Studentid)
);

-- Create stored procedure AllocateSubjects
DELIMITER $$
CREATE PROCEDURE AllocateSubjects()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE student_id, subject_id, preference INT;
    DECLARE gpa FLOAT;
    DECLARE subject_remaining_seats INT;
    DECLARE cur CURSOR FOR SELECT Studentid, Subjectid, Preference FROM StudentPreference ORDER BY Studentid, Preference;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    -- Open the cursor
    OPEN cur;

    -- Loop through each student's preferences
    allocate_loop: LOOP
        FETCH cur INTO student_id, subject_id, preference;
        IF done THEN
            LEAVE allocate_loop;
        END IF;
        
        -- Get the student's GPA
        SELECT GPA INTO gpa FROM StudentDetails WHERE Studentid = student_id;
        
        -- Check if the student has already been allotted a subject
        IF NOT EXISTS (SELECT * FROM Allotments WHERE Studentid = student_id) THEN
            -- Get the remaining seats for the subject
            SELECT RemainingSeats INTO subject_remaining_seats FROM SubjectDetails WHERE Subjectid = subject_id;
            
            -- Check if there are available seats for the subject
            IF subject_remaining_seats > 0 THEN
                -- Allocate the subject to the student
                INSERT INTO Allotments (Subjectid, Studentid) VALUES (subject_id, student_id);
                -- Decrease the remaining seats for the subject
                UPDATE SubjectDetails SET RemainingSeats = RemainingSeats - 1 WHERE Subjectid = subject_id;
            ELSE
                -- Subject is full, try next preference
                CONTINUE;
            END IF;
        END IF;
    END LOOP;

    -- Close the cursor
    CLOSE cur;
END$$
DELIMITER ;

-- Example data insertion
INSERT INTO StudentDetails (Studentid, StudentName, GPA, BranchSection) VALUES
(159103036, 'Mohit Agarwal', 8.9, 'CCE'),
(159103037, 'Rohit Agarwal', 5.2, 'CCE'),
(159103038, 'Shohit Garg', 7.1, 'CCE'),
(159103039, 'Mrinal Malhotra', 7.9, 'CCE'),
(159103040, 'Mehreet Singh', 5.6, 'CCE'),
(159103041, 'Arjun Tehlan', 9.2, 'CCE');

INSERT INTO SubjectDetails (Subjectid, SubjectName, MaxSeats, RemainingSeats) VALUES
('PO1491', 'Basics of Political Science', 60, 2),
('PO1492', 'Basics of Accounting', 120, 119),
('PO1493', 'Basics of Financial Markets', 90, 90),
('PO1494', 'Eco philosophy', 60, 50),
('PO1495', 'Automotive Trends', 60, 60);

INSERT INTO StudentPreference (Studentid, Subjectid, Preference) VALUES
(159103036, 'PO1491', 1),
(159103036, 'PO1492', 2),
(159103036, 'PO1493', 3),
(159103036, 'PO1494', 4),
(159103036, 'PO1495', 5);

-- Call the stored procedure to allocate subjects
CALL AllocateSubjects();