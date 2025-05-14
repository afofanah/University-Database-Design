-- =============================================
-- 50 Sample Queries
-- =============================================

-- 1. Basic SELECT Queries
-- Query 1: Get all students with GPA above 3.5
SELECT StudentID, FirstName, LastName, GPA
FROM Student
WHERE GPA > 3.5
ORDER BY GPA DESC;

-- Query 2: List all courses offered by the Computer Science department
SELECT C.CourseID, C.CourseCode, C.CourseName, C.Credits
FROM Course C
JOIN Department D ON C.DepartmentID = D.DepartmentID
WHERE D.DepartmentCode = 'CS'
ORDER BY C.CourseCode;

-- Query 3: Find all faculty members with Professor title
SELECT FacultyID, FirstName, LastName, Title
FROM Faculty
WHERE Title LIKE '%Professor%'
ORDER BY LastName, FirstName;

-- Query 4: Get a list of buildings built after 2000
SELECT BuildingID, BuildingName, YearBuilt
FROM Building
WHERE YearBuilt > 2000
ORDER BY YearBuilt DESC;

-- Query 5: List all active scholarships with amounts over $5000
SELECT ScholarshipID, ScholarshipName, Amount, ApplicationDeadline
FROM Scholarship
WHERE IsActive = 1 AND Amount > 5000
ORDER BY Amount DESC;

-- 2. JOIN Queries
-- Query 6: Get student enrollment details with course and section information
SELECT S.FirstName + ' ' + S.LastName AS StudentName, 
       C.CourseCode, 
       C.CourseName, 
       SE.SectionNumber, 
       SE.Semester, 
       SE.Year, 
       E.Grade
FROM Student S
JOIN Enrollment E ON S.StudentID = E.StudentID
JOIN Section SE ON E.SectionID = SE.SectionID
JOIN Course C ON SE.CourseID = C.CourseID
ORDER BY S.LastName, S.FirstName, C.CourseCode;

-- Query 7: Find professors and their departments
SELECT F.FirstName + ' ' + F.LastName AS ProfessorName, 
       F.Title, 
       D.DepartmentName, 
       D.DepartmentCode
FROM Faculty F
JOIN Department D ON F.DepartmentID = D.DepartmentID
WHERE F.Title LIKE '%Professor%'
ORDER BY D.DepartmentName, F.LastName;

-- Query 8: Get course sections with instructor information
SELECT C.CourseCode, 
       C.CourseName, 
       SE.SectionNumber, 
       SE.Semester, 
       SE.Year, 
       F.FirstName + ' ' + F.LastName AS InstructorName
FROM Course C
JOIN Section SE ON C.CourseID = SE.CourseID
JOIN Teaching T ON SE.SectionID = T.SectionID
JOIN Faculty F ON T.FacultyID = F.FacultyID
ORDER BY SE.Year DESC, SE.Semester, C.CourseCode, SE.SectionNumber;

-- Query 9: Find rooms with their building information
SELECT B.BuildingName, 
       R.RoomNumber, 
       R.RoomType, 
       R.Capacity
FROM Room R
JOIN Building B ON R.BuildingID = B.BuildingID
ORDER BY B.BuildingName, R.FloorNumber, R.RoomNumber;

-- Query 10: List all publications with their corresponding research projects
SELECT P.Title, 
       P.PublicationDate, 
       P.JournalName, 
       RP.ProjectName
FROM Publication P
JOIN ResearchProject RP ON P.ProjectID = RP.ProjectID
ORDER BY P.PublicationDate DESC;

-- 3. Aggregate Functions
-- Query 11: Count students by department
SELECT D.DepartmentName, 
       COUNT(S.StudentID) AS StudentCount
FROM Student S
JOIN Department D ON S.MajorDepartmentID = D.DepartmentID
GROUP BY D.DepartmentName
ORDER BY StudentCount DESC;

-- Query 12: Calculate average GPA by department
SELECT D.DepartmentName, 
       AVG(S.GPA) AS AverageGPA
FROM Student S
JOIN Department D ON S.MajorDepartmentID = D.DepartmentID
GROUP BY D.DepartmentName
ORDER BY AverageGPA DESC;

-- Query 13: Find departments with total salary expenditure
SELECT D.DepartmentName, 
       SUM(F.Salary) AS TotalFacultySalary
FROM Faculty F
JOIN Department D ON F.DepartmentID = D.DepartmentID
GROUP BY D.DepartmentName
ORDER BY TotalFacultySalary DESC;

-- Query 14: Count number of courses by department
SELECT D.DepartmentName, 
       COUNT(C.CourseID) AS CourseCount
FROM Course C
JOIN Department D ON C.DepartmentID = D.DepartmentID
GROUP BY D.DepartmentName
ORDER BY CourseCount DESC;

-- Query 15: Calculate total scholarship amounts awarded by department
SELECT D.DepartmentName, 
       SUM(SS.AwardAmount) AS TotalScholarshipAmount
FROM StudentScholarship SS
JOIN Student S ON SS.StudentID = S.StudentID
JOIN Department D ON S.MajorDepartmentID = D.DepartmentID
GROUP BY D.DepartmentName
ORDER BY TotalScholarshipAmount DESC;

-- 4. Subqueries
-- Query 16: Find students with GPA higher than department average
SELECT S.StudentID, 
       S.FirstName, 
       S.LastName, 
       S.GPA, 
       D.DepartmentName
FROM Student S
JOIN Department D ON S.MajorDepartmentID = D.DepartmentID
WHERE S.GPA > (
    SELECT AVG(S2.GPA)
    FROM Student S2
    WHERE S2.MajorDepartmentID = S.MajorDepartmentID
)
ORDER BY D.DepartmentName, S.GPA DESC;

-- Query 17: Find courses with no sections
SELECT CourseID, 
       CourseCode, 
       CourseName
FROM Course
WHERE CourseID NOT IN (
    SELECT DISTINCT CourseID
    FROM Section
)
ORDER BY CourseCode;

-- Query 18: List faculty members with salary higher than department average
SELECT F.FacultyID, 
       F.FirstName, 
       F.LastName, 
       F.Salary, 
       D.DepartmentName
FROM Faculty F
JOIN Department D ON F.DepartmentID = D.DepartmentID
WHERE F.Salary > (
    SELECT AVG(F2.Salary)
    FROM Faculty F2
    WHERE F2.DepartmentID = F.DepartmentID
)
ORDER BY D.DepartmentName, F.Salary DESC;

-- Query 19: Find students who have taken all courses in their department
SELECT S.StudentID, 
       S.FirstName, 
       S.LastName, 
       D.DepartmentName
FROM Student S
JOIN Department D ON S.MajorDepartmentID = D.DepartmentID
WHERE NOT EXISTS (
    SELECT C.CourseID
    FROM Course C
    WHERE C.DepartmentID = S.MajorDepartmentID
    AND NOT EXISTS (
        SELECT E.EnrollmentID
        FROM Enrollment E
        JOIN Section SE ON E.SectionID = SE.SectionID
        WHERE SE.CourseID = C.CourseID
        AND E.StudentID = S.StudentID
    )
)
ORDER BY D.DepartmentName, S.LastName;

-- Query 20: Find departments with more faculty than the average
SELECT D.DepartmentName, 
       COUNT(F.FacultyID) AS FacultyCount
FROM Department D
JOIN Faculty F ON D.DepartmentID = F.DepartmentID
GROUP BY D.DepartmentName
HAVING COUNT(F.FacultyID) > (
    SELECT AVG(FacultyCount)
    FROM (
        SELECT COUNT(F2.FacultyID) AS FacultyCount
        FROM Faculty F2
        GROUP BY F2.DepartmentID
    ) AS DepartmentFacultyCounts
)
ORDER BY FacultyCount DESC;

-- 5. Common Table Expressions (CTEs)
-- Query 21: Identify students who earned all A grades
WITH StudentGrades AS (
    SELECT S.StudentID, 
           S.FirstName, 
           S.LastName, 
           E.Grade
    FROM Student S
    JOIN Enrollment E ON S.StudentID = E.StudentID
    WHERE E.Grade IS NOT NULL
)
SELECT DISTINCT SG.StudentID, 
       SG.FirstName, 
       SG.LastName
FROM StudentGrades SG
WHERE NOT EXISTS (
    SELECT 1
    FROM StudentGrades SG2
    WHERE SG2.StudentID = SG.StudentID
    AND SG2.Grade != 'A'
)
ORDER BY SG.LastName, SG.FirstName;

-- Query 22: Calculate cumulative GPA for each student by semester
WITH SemesterGrades AS (
    SELECT S.StudentID, 
           S.FirstName, 
           S.LastName, 
           SE.Semester, 
           SE.Year, 
           AVG(E.GradePoints) AS SemesterGPA
    FROM Student S
    JOIN Enrollment E ON S.StudentID = E.StudentID
    JOIN Section SE ON E.SectionID = SE.SectionID
    WHERE E.Grade IS NOT NULL
    GROUP BY S.StudentID, S.FirstName, S.LastName, SE.Semester, SE.Year
)
SELECT SG.StudentID, 
       SG.FirstName, 
       SG.LastName, 
       SG.Semester, 
       SG.Year, 
       SG.SemesterGPA,
       (SELECT AVG(SG2.SemesterGPA)
        FROM SemesterGrades SG2
        WHERE SG2.StudentID = SG.StudentID
        AND (SG2.Year < SG.Year OR (SG2.Year = SG.Year AND SG2.Semester <= SG.Semester))
       ) AS CumulativeGPA
FROM SemesterGrades SG
ORDER BY SG.StudentID, SG.Year, SG.Semester;

-- Query 23: Find departments with highest publication counts
WITH DepartmentPublications AS (
    SELECT D.DepartmentID, 
           D.DepartmentName, 
           COUNT(P.PublicationID) AS PublicationCount
    FROM Department D
    JOIN ResearchProject RP ON D.DepartmentID = RP.DepartmentID
    JOIN Publication P ON RP.ProjectID = P.ProjectID
    GROUP BY D.DepartmentID, D.DepartmentName
)
SELECT DepartmentName, 
       PublicationCount
FROM DepartmentPublications
WHERE PublicationCount = (SELECT MAX(PublicationCount) FROM DepartmentPublications);

-- Query 24: Calculate teaching load for each faculty member
WITH FacultyTeachingLoad AS (
    SELECT F.FacultyID, 
           F.FirstName, 
           F.LastName, 
           SE.Semester, 
           SE.Year, 
           COUNT(T.TeachingID) AS CoursesCount,
           SUM(C.Credits) AS TotalCredits
    FROM Faculty F
    JOIN Teaching T ON F.FacultyID = T.FacultyID
    JOIN Section SE ON T.SectionID = SE.SectionID
    JOIN Course C ON SE.CourseID = C.CourseID
    GROUP BY F.FacultyID, F.FirstName, F.LastName, SE.Semester, SE.Year
)
SELECT FacultyID, 
       FirstName, 
       LastName, 
       Semester, 
       Year, 
       CoursesCount, 
       TotalCredits
FROM FacultyTeachingLoad
ORDER BY Year DESC, Semester, TotalCredits DESC;

-- Query 25: Identify students who haven't enrolled in any courses for the current semester
WITH CurrentEnrollments AS (
    SELECT DISTINCT S.StudentID
    FROM Student S
    JOIN Enrollment E ON S.StudentID = E.StudentID
    JOIN Section SE ON E.SectionID = SE.SectionID
    WHERE SE.Semester = 'Spring' AND SE.Year = 2025
)
SELECT S.StudentID, 
       S.FirstName, 
       S.LastName, 
       S.Email
FROM Student S
WHERE S.GraduationDate IS NULL
AND S.StudentID NOT IN (SELECT StudentID FROM CurrentEnrollments)
ORDER BY S.LastName, S.FirstName;

-- 6. Window Functions
-- Query 26: Rank students by GPA within each department
SELECT S.StudentID, 
       S.FirstName, 
       S.LastName, 
       D.DepartmentName, 
       S.GPA,
       RANK() OVER (PARTITION BY S.MajorDepartmentID ORDER BY S.GPA DESC) AS DepartmentRank
FROM Student S
JOIN Department D ON S.MajorDepartmentID = D.DepartmentID
ORDER BY D.DepartmentName, DepartmentRank;

-- Query 27: Calculate running total of department budgets
SELECT DepartmentID, 
       DepartmentName, 
       BudgetAmount,
       SUM(BudgetAmount) OVER (ORDER BY BudgetAmount DESC) AS RunningTotal
FROM Department
ORDER BY BudgetAmount DESC;

-- Query 28: Identify salary percentiles among faculty
SELECT F.FacultyID, 
       F.FirstName, 
       F.LastName, 
       F.Title, 
       F.Salary,
       PERCENT_RANK() OVER (ORDER BY F.Salary) * 100 AS SalaryPercentile
FROM Faculty F
ORDER BY SalaryPercentile DESC;

-- Query 29: Compare each course's credits to department average
SELECT C.CourseID, 
       C.CourseCode, 
       C.CourseName, 
       C.Credits,
       D.DepartmentName,
       AVG(C.Credits) OVER (PARTITION BY C.DepartmentID) AS AvgDepartmentCredits,
       C.Credits - AVG(C.Credits) OVER (PARTITION BY C.DepartmentID) AS CreditDifference
FROM Course C
JOIN Department D ON C.DepartmentID = D.DepartmentID
ORDER BY D.DepartmentName, CreditDifference DESC;

-- Query 30: Calculate enrollment growth by semester
SELECT Semester, 
       Year, 
       COUNT(EnrollmentID) AS EnrollmentCount,
       LAG(COUNT(EnrollmentID), 1, 0) OVER (ORDER BY Year, CASE 
           WHEN Semester = 'Spring' THEN 1
           WHEN Semester = 'Summer' THEN 2
           WHEN Semester = 'Fall' THEN 3
       END) AS PreviousSemesterCount,
       COUNT(EnrollmentID) - LAG(COUNT(EnrollmentID), 1, 0) OVER (ORDER BY Year, CASE 
           WHEN Semester = 'Spring' THEN 1
           WHEN Semester = 'Summer' THEN 2
           WHEN Semester = 'Fall' THEN 3
       END) AS GrowthCount
FROM Enrollment E
JOIN Section S ON E.SectionID = S.SectionID
GROUP BY S.Semester, S.Year
ORDER BY S.Year, CASE 
    WHEN S.Semester = 'Spring' THEN 1
    WHEN S.Semester = 'Summer' THEN 2
    WHEN S.Semester = 'Fall' THEN 3
END;

-- 7. Advanced Joins and Set Operations
-- Query 31: Find students who are both scholarship recipients and research team members
SELECT S.StudentID, 
       S.FirstName, 
       S.LastName
FROM Student S
WHERE EXISTS (
    SELECT 1
    FROM StudentScholarship SS
    WHERE SS.StudentID = S.StudentID
)
AND EXISTS (
    SELECT 1
    FROM ResearchTeamMember RTM
    WHERE RTM.MemberID = S.StudentID
    AND RTM.MemberType = 'Student'
)
ORDER BY S.LastName, S.FirstName;

-- Query 32: Combine all people (students, faculty, staff) in the university
SELECT 'Student' AS PersonType, 
       StudentID AS ID, 
       FirstName, 
       LastName, 
       Email
FROM Student
UNION
SELECT 'Faculty', 
       FacultyID, 
       FirstName, 
       LastName, 
       Email
FROM Faculty
UNION
SELECT 'Staff', 
       StaffID, 
       FirstName, 
       LastName, 
       Email
FROM StaffMember
ORDER BY PersonType, LastName, FirstName;

-- Query 33: Find courses that are prerequisites for other courses
SELECT C1.CourseID, 
       C1.CourseCode, 
       C1.CourseName AS PrerequisiteCourse,
       C2.CourseCode, 
       C2.CourseName AS DependentCourse
FROM Course C1
JOIN Course C2 ON C1.CourseID = C2.PrerequisiteCourseID
ORDER BY C1.CourseCode, C2.CourseCode;

-- Query 34: Identify students who have borrowed books but haven't returned them
SELECT S.StudentID, 
       S.FirstName, 
       S.LastName, 
       B.Title AS BookTitle, 
       BL.CheckoutDate, 
       BL.DueDate,
       DATEDIFF(day, BL.DueDate, GETDATE()) AS DaysOverdue
FROM Student S
JOIN BookLoan BL ON S.StudentID = BL.BorrowerID AND BL.BorrowerType = 'Student'
JOIN Book B ON BL.BookID = B.BookID
WHERE BL.ReturnDate IS NULL
AND BL.DueDate < GETDATE()
ORDER BY DaysOverdue DESC;

-- Query 35: Find empty rooms during a specific time slot
SELECT R.RoomID, 
       B.BuildingName, 
       R.RoomNumber, 
       R.Capacity
FROM Room R
JOIN Building B ON R.BuildingID = B.BuildingID
WHERE NOT EXISTS (
    SELECT 1
    FROM Section S
    WHERE S.BuildingName = B.BuildingName
    AND S.RoomNumber = R.RoomNumber
    AND S.DaysOfWeek LIKE '%M%'  -- Monday
    AND S.StartTime <= '10:00:00'
    AND S.EndTime >= '09:00:00'
    AND S.Semester = 'Spring'
    AND S.Year = 2025
)
AND R.RoomType = 'Classroom'
ORDER BY B.BuildingName, R.RoomNumber;

-- 8. Data Manipulation Queries
-- Query 36: Update student GPA based on their enrollment grades
UPDATE Student
SET GPA = (
    SELECT AVG(E.GradePoints)
    FROM Enrollment E
    WHERE E.StudentID = Student.StudentID
    AND E.Grade IS NOT NULL
)
WHERE EXISTS (
    SELECT 1
    FROM Enrollment E
    WHERE E.StudentID = Student.StudentID
    AND E.Grade IS NOT NULL
);

-- Query 37: Assign rooms to sections that don't have room assignments
UPDATE Section
SET BuildingName = B.BuildingName,
    RoomNumber = R.RoomNumber
FROM Section S
JOIN Room R ON R.Capacity >= S.MaxEnrollment AND R.RoomType = 'Classroom'
JOIN Building B ON R.BuildingID = B.BuildingID
WHERE S.BuildingName IS NULL
AND S.RoomNumber IS NULL;

-- Query 38: Apply late fees to overdue book loans
UPDATE BookLoan
SET LateFee = DATEDIFF(day, DueDate, GETDATE()) * 0.25
WHERE ReturnDate IS NULL
AND DueDate < GETDATE();

-- Query 39: Increment available copies when a book is returned
UPDATE Book
SET AvailableCopies = AvailableCopies + 1
FROM Book B
JOIN BookLoan BL ON B.BookID = BL.BookID
WHERE BL.ReturnDate IS NULL
AND BL.ReturnDate = GETDATE();

-- Query 40: Cancel enrollments for withdrawn students
UPDATE Enrollment
SET IsWithdrawn = 1,
    WithdrawalDate = GETDATE()
FROM Enrollment E
JOIN Student S ON E.StudentID = S.StudentID
WHERE S.StudentID IN (
    SELECT StudentID
    FROM Student
    WHERE IsActive = 0
);

-- 9. Advanced Analytics
-- Query 41: Calculate the success rate of courses (percentage of students passing)
SELECT C.CourseID, 
       C.CourseCode, 
       C.CourseName,
       COUNT(E.EnrollmentID) AS TotalEnrollments,
       SUM(CASE WHEN E.Grade IN ('A', 'B', 'C', 'D') THEN 1 ELSE 0 END) AS PassingStudents,
       (CAST(SUM(CASE WHEN E.Grade IN ('A', 'B', 'C', 'D') THEN 1 ELSE 0 END) AS FLOAT) / COUNT(E.EnrollmentID)) * 100 AS PassRate
FROM Course C
JOIN Section S ON C.CourseID = S.CourseID
JOIN Enrollment E ON S.SectionID = E.SectionID
WHERE E.Grade IS NOT NULL
GROUP BY C.CourseID, C.CourseCode, C.CourseName
ORDER BY PassRate DESC;

-- Query 42: Identify patterns in student performance across different departments
SELECT D.DepartmentName,
       AVG(CASE WHEN E.Grade = 'A' THEN 1 ELSE 0 END) * 100 AS PercentA,
       AVG(CASE WHEN E.Grade = 'B' THEN 1 ELSE 0 END) * 100 AS PercentB,
       AVG(CASE WHEN E.Grade = 'C' THEN 1 ELSE 0 END) * 100 AS PercentC,
       AVG(CASE WHEN E.Grade = 'D' THEN 1 ELSE 0 END) * 100 AS PercentD,
       AVG(CASE WHEN E.Grade = 'F' THEN 1 ELSE 0 END) * 100 AS PercentF
FROM Enrollment E
JOIN Section S ON E.SectionID = S.SectionID
JOIN Course C ON S.CourseID = C.CourseID
JOIN Department D ON C.DepartmentID = D.DepartmentID
WHERE E.Grade IS NOT NULL
GROUP BY D.DepartmentName
ORDER BY PercentA DESC;

-- Query 43: Analyze research productivity by department
SELECT D.DepartmentName,
       COUNT(DISTINCT RP.ProjectID) AS TotalProjects,
       COUNT(DISTINCT P.PublicationID) AS TotalPublications,
       COUNT(DISTINCT P.PublicationID) * 1.0 / COUNT(DISTINCT RP.ProjectID) AS PublicationsPerProject,
       SUM(RP.FundingAmount) AS TotalFunding,
       SUM(RP.FundingAmount) * 1.0 / COUNT(DISTINCT RP.ProjectID) AS AvgFundingPerProject,
       SUM(RP.FundingAmount) * 1.0 / COUNT(DISTINCT P.PublicationID) AS FundingPerPublication
FROM Department D
JOIN ResearchProject RP ON D.DepartmentID = RP.DepartmentID
LEFT JOIN Publication P ON RP.ProjectID = P.ProjectID
GROUP BY D.DepartmentName
ORDER BY TotalFunding DESC;

-- Query 44: Calculate classroom utilization rates
SELECT B.BuildingName,
       R.RoomNumber,
       R.Capacity,
       COUNT(DISTINCT S.SectionID) AS TotalSections,
       SUM(DATEDIFF(HOUR, S.StartTime, S.EndTime)) AS TotalHoursUsed,
       SUM(DATEDIFF(HOUR, S.StartTime, S.EndTime)) * 100.0 / (40 * 16) AS UtilizationRate -- Assuming 40 hour week, 16 weeks semester
FROM Building B
JOIN Room R ON B.BuildingID = R.BuildingID
LEFT JOIN Section S ON B.BuildingName = S.BuildingName AND R.RoomNumber = S.RoomNumber
WHERE R.RoomType = 'Classroom'
AND (S.Semester = 'Spring' AND S.Year = 2025 OR S.SectionID IS NULL)
GROUP BY B.BuildingName, R.RoomNumber, R.Capacity
ORDER BY UtilizationRate DESC;

-- Query 45: Find potential scholarship candidates
SELECT S.StudentID,
       S.FirstName,
       S.LastName,
       S.GPA,
       D.DepartmentName,
       COUNT(SCH.ScholarshipID) AS PotentialScholarships
FROM Student S
JOIN Department D ON S.MajorDepartmentID = D.DepartmentID
JOIN Scholarship SCH ON (SCH.DepartmentID = S.MajorDepartmentID OR SCH.RequiredMajor = 0)
                    AND (SCH.MinimumGPA IS NULL OR S.GPA >= SCH.MinimumGPA)
WHERE NOT EXISTS (
    SELECT 1
    FROM StudentScholarship SS
    WHERE SS.StudentID = S.StudentID
    AND SS.ScholarshipID = SCH.ScholarshipID
)
GROUP BY S.StudentID, S.FirstName, S.LastName, S.GPA, D.DepartmentName
HAVING COUNT(SCH.ScholarshipID) > 0
ORDER BY S.GPA DESC, PotentialScholarships DESC;

-- 10. Dynamic Queries
-- Query 46: Create a stored procedure to find courses by keyword
CREATE PROCEDURE sp_FindCoursesByKeyword
    @Keyword NVARCHAR(100)
AS
BEGIN
    SELECT C.CourseID,
           C.CourseCode,
           C.CourseName,
           C.Credits,
           D.DepartmentName
    FROM Course C
    JOIN Department D ON C.DepartmentID = D.DepartmentID
    WHERE C.CourseName LIKE '%' + @Keyword + '%'
    OR C.Description LIKE '%' + @Keyword + '%'
    ORDER BY C.CourseCode;
END;

-- Query 47: Create a function to calculate student's GPA
CREATE FUNCTION fn_CalculateStudentGPA
(
    @StudentID INT,
    @Semester VARCHAR(20) = NULL,
    @Year INT = NULL
)
RETURNS DECIMAL(3,2)
AS
BEGIN
    DECLARE @GPA DECIMAL(3,2);
    
    SELECT @GPA = AVG(E.GradePoints)
    FROM Enrollment E
    JOIN Section S ON E.SectionID = S.SectionID
    WHERE E.StudentID = @StudentID
    AND E.Grade IS NOT NULL
    AND (@Semester IS NULL OR S.Semester = @Semester)
    AND (@Year IS NULL OR S.Year = @Year);
    
    RETURN ISNULL(@GPA, 0.00);
END;

-- Query 48: Create a stored procedure to generate class rosters
CREATE PROCEDURE sp_GenerateClassRoster
    @CourseCode VARCHAR(20),
    @SectionNumber VARCHAR(10),
    @Semester VARCHAR(20),
    @Year INT
AS
BEGIN
    SELECT S.StudentID,
           S.FirstName,
           S.LastName,
           S.Email,
           E.EnrollmentDate,
           E.Grade
    FROM Student S
    JOIN Enrollment E ON S.StudentID = E.StudentID
    JOIN Section SE ON E.SectionID = SE.SectionID
    JOIN Course C ON SE.CourseID = C.CourseID
    WHERE C.CourseCode = @CourseCode
    AND SE.SectionNumber = @SectionNumber
    AND SE.Semester = @Semester
    AND SE.Year = @Year
    ORDER BY S.LastName, S.FirstName;
END;

-- Query 49: Create a view for faculty teaching assignments
CREATE VIEW vw_FacultyTeachingAssignments AS
SELECT F.FacultyID,
       F.FirstName + ' ' + F.LastName AS FacultyName,
       D.DepartmentName,
       C.CourseCode,
       C.CourseName,
       SE.SectionNumber,
       SE.Semester,
       SE.Year,
       SE.DaysOfWeek,
       SE.StartTime,
       SE.EndTime,
       SE.BuildingName,
       SE.RoomNumber
FROM Faculty F
JOIN Teaching T ON F.FacultyID = T.FacultyID
JOIN Section SE ON T.SectionID = SE.SectionID
JOIN Course C ON SE.CourseID = C.CourseID
JOIN Department D ON F.DepartmentID = D.DepartmentID;

-- Query 50: Create a stored procedure for comprehensive student report
CREATE PROCEDURE sp_GenerateStudentReport
    @StudentID INT
AS
BEGIN
    -- Student personal information
    SELECT S.StudentID,
           S.FirstName,
           S.LastName,
           S.DateOfBirth,
           S.Email,
           S.PhoneNumber,
           S.EnrollmentDate,
           S.GraduationDate,
           S.GPA,
           D1.DepartmentName AS Major,
           D2.DepartmentName AS Minor
    FROM Student S
    JOIN Department D1 ON S.MajorDepartmentID = D1.DepartmentID
    LEFT JOIN Department D2 ON S.MinorDepartmentID = D2.DepartmentID
    WHERE S.StudentID = @StudentID;
    
    -- Course history
    SELECT C.CourseCode,
           C.CourseName,
           SE.Semester,
           SE.Year,
           E.Grade,
           E.GradePoints,
           F.FirstName + ' ' + F.LastName AS Instructor
    FROM Enrollment E
    JOIN Section SE ON E.SectionID = SE.SectionID
    JOIN Course C ON SE.CourseID = C.CourseID
    JOIN Teaching T ON SE.SectionID = T.SectionID
    JOIN Faculty F ON T.FacultyID = F.FacultyID
    WHERE E.StudentID = @StudentID
    ORDER BY SE.Year, SE.Semester, C.CourseCode;
    
    -- Scholarships awarded
    SELECT SCH.ScholarshipName,
           SS.AcademicYear,
           SS.Semester,
           SS.AwardAmount,
           SS.AwardDate
    FROM StudentScholarship SS
    JOIN Scholarship SCH ON SS.ScholarshipID = SCH.ScholarshipID
    WHERE SS.StudentID = @StudentID
    ORDER BY SS.AcademicYear DESC, SS.Semester;
    
    -- Books currently borrowed
    SELECT B.Title,
           BL.CheckoutDate,
           BL.DueDate,
           CASE 
               WHEN BL.DueDate < GETDATE() AND BL.ReturnDate IS NULL THEN 'Overdue'
               WHEN BL.ReturnDate IS NULL THEN 'Checked Out'
               ELSE 'Returned'
           END AS Status,
           BL.LateFee
    FROM BookLoan BL
    JOIN Book B ON BL.BookID = B.BookID
    WHERE BL.BorrowerID = @StudentID
    AND BL.BorrowerType = 'Student'
    ORDER BY Status, BL.DueDate;
    
    -- Research projects
    SELECT RP.ProjectName,
           RP.StartDate,
           RP.EndDate,
           RTM.Role,
           F.FirstName + ' ' + F.LastName AS ProjectLead
    FROM ResearchTeamMember RTM
    JOIN ResearchProject RP ON RTM.ProjectID = RP.ProjectID
    JOIN Faculty F ON RP.LeadFacultyID = F.FacultyID
    WHERE RTM.MemberID = @StudentID
    AND RTM.MemberType = 'Student'
    ORDER BY RP.StartDate DESC;
END;

-- =============================================
-- Security and Access Controls
-- =============================================

-- Create login for database administrator
CREATE LOGIN UniversityDBA WITH PASSWORD = 'Complex_Password_123';

-- Create user for the login
CREATE USER UniversityDBA FOR LOGIN UniversityDBA;

-- Assign roles to the user
ALTER ROLE db_owner ADD MEMBER UniversityDBA;

-- Create role for faculty access
CREATE ROLE Faculty_Role;

-- Grant permissions to faculty role
GRANT SELECT ON SCHEMA::dbo TO Faculty_Role;
GRANT SELECT, UPDATE ON dbo.Section TO Faculty_Role;
GRANT SELECT, UPDATE ON dbo.Enrollment TO Faculty_Role;
GRANT EXECUTE ON dbo.sp_GenerateClassRoster TO Faculty_Role;

-- Create role for student access
CREATE ROLE Student_Role;

-- Grant permissions to student role
GRANT SELECT ON dbo.Course TO Student_Role;
GRANT SELECT ON dbo.Section TO Student_Role;
GRANT SELECT ON dbo.vw_FacultyTeachingAssignments TO Student_Role;
GRANT EXECUTE ON dbo.fn_CalculateStudentGPA TO Student_Role;

-- =============================================
-- Database Maintenance
-- =============================================

-- Create a full backup of the database
BACKUP DATABASE University
TO DISK = 'C:\Backups\University_Full.bak'
WITH INIT, STATS = 10;

-- Create a maintenance plan for index reorganization
CREATE INDEX IX_Student_Name ON Student(LastName, FirstName);
CREATE INDEX IX_Faculty_Name ON Faculty(LastName, FirstName);
CREATE INDEX IX_Course_Name ON Course(CourseName);
CREATE INDEX IX_Enrollment_Grade ON Enrollment(Grade);

-- Add database statistics
CREATE STATISTICS STATS_Student_Department ON Student(MajorDepartmentID);
CREATE STATISTICS STATS_Enrollment_Section ON Enrollment(SectionID);
CREATE STATISTICS STATS_Course_Department ON Course(DepartmentID);
CREATE STATISTICS STATS_Section_Course ON Section(CourseID);