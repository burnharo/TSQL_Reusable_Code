IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_NAME = 'convertSFID' AND SPECIFIC_SCHEMA = 'dbo') BEGIN
	DROP FUNCTION dbo.convertSFID;
END
GO

CREATE FUNCTION dbo.convertSFID (@sfid nvarchar(max)) RETURNS nvarchar(18) AS

/********************************************************************************
created:		2018-05-25
author:			Ross Burnham (burharo@gmail.com)
description:	15-digit salesforce ids are converted to 18 digits by checking each character to see if it's uppercase.
				Uppercase characters are assigned a different value depending on location in the string.
				Each group of 5 characters determines the final 3 characters
********************************************************************************/

BEGIN

	-- ensure there are no blank characters in string

		SET @sfid = RTRIM(LTRIM(@sfid));

	-- checks to see if the variable is at least 15 characters but not exactly 18
	
		IF LEN(@sfid) = 18 OR LEN(@sfid) < 15 OR @sfid IS NULL BEGIN 

			RETURN @sfid;

		END

	-- calculate the full Id

		DECLARE @currentChar tinyint = 15; 
		DECLARE @charValue tinyint = 0;
		DECLARE @charAppend nvarchar(3) = '';
		DECLARE @charString nchar(32) = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ012345';

		WHILE @currentChar > 0 BEGIN

			SET @charValue = (2 * @charValue) + CASE WHEN BINARY_CHECKSUM(SUBSTRING(@sfid,@currentChar,1)) = BINARY_CHECKSUM(LOWER(SUBSTRING(@sfid,@currentChar,1))) THEN 0 ELSE 1 END;

			IF @currentChar % 5 = 1 BEGIN
				SET @charAppend = SUBSTRING(@charString, @charValue + 1, 1) + @charAppend;
				SET @charValue = 0; 
			END			
			
			SET @currentChar = @currentChar - 1;	

		END

		SET @sfid = LEFT(@sfid, 15) + @charAppend; -- use the left just in case there are more than 15 characters

		RETURN @sfid;

END

