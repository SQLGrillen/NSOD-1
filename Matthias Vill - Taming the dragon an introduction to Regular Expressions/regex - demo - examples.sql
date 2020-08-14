-- Can you spot all references to dbo.Tbl?
SELECT *
FROM Tbl;
SELECT *
FROM Tbl2
CROSS JOIN dbo.Tbl;
UPDATE [dbo].Tbl
SET Val = 42;
INSERT INTO dbo.[Tbl]
    (Id)
VALUES
    (42);
EXEC (N'SELECT * FROM [dbo].[Tbl]');
GO

-- Some procedures to rename
CREATE OR ALTER PROCEDURE my.sp_one
AS
BEGIN
    PRINT 'You called me';
END
GO
CREATE OR ALTER PROCEDURE [my].[sp_two]
AS
BEGIN
    PRINT 'You called me, too';
END
GO

-- So we have these UPDATEs for our DEV-stage, but we need INSERTs for PRD…
UPDATE V
SET Val = 42
FROM our.Vault V
WHERE V.Id = 42;

-- Ever needed/wanted to normalize line-endings to CR LF?
SELECT VDT.Input,
    Output = REPLACE(
        REPLACE(
            REPLACE(VDT.Input,
                CHAR(13)+CHAR(10),
                CHAR(10)),
            CHAR(13),
            CHAR(10)),
        CHAR(10),
        CHAR(13)+CHAR(10))
FROM (VALUES('a' + CHAR(13) + CHAR(10) --
            +'b' + CHAR(10) --
            +'c' + CHAR(13))) VDT(Input);

SELECT VDT.Input,
    Output = REPLACE(
        REPLACE(
            REPLACE(VDT.[Input],
                'RN',
                'N'),
            'R',
            'N'),
        'N',
        'RN')
FROM (VALUES('aRN' --
            +'bN' --
            +'cR')) VDT(Input);
