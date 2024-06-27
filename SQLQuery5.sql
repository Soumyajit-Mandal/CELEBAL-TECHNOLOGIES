CREATE PROCEDURE UpdateSubjectAllotments
    @StudentID VARCHAR(50),
    @RequestedSubjectID VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if the student has any active subject allotment
    DECLARE @CurrentSubjectID VARCHAR(50);
    SELECT @CurrentSubjectID = SubjectID
    FROM SubjectAllotments
    WHERE StudentID = @StudentID
      AND Is_Valid = 1;

    IF @CurrentSubjectID IS NULL
    BEGIN
        -- If no active allotment exists, insert the requested subject as valid
        INSERT INTO SubjectAllotments (StudentID, SubjectID, Is_Valid)
        VALUES (@StudentID, @RequestedSubjectID, 1);
    END
    ELSE
    BEGIN
        -- If there is an active allotment, check if it's different from the requested subject
        IF @CurrentSubjectID <> @RequestedSubjectID
        BEGIN
            -- Invalidate the current allotment
            UPDATE SubjectAllotments
            SET Is_Valid = 0
            WHERE StudentID = @StudentID
              AND Is_Valid = 1;

            -- Insert the requested subject as valid
            INSERT INTO SubjectAllotments (StudentID, SubjectID, Is_Valid)
            VALUES (@StudentID, @RequestedSubjectID, 1);
        END
        -- If current subject is the same as requested subject, no action needed
    END
END;