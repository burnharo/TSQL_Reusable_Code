IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_NAME = 'calculateWorkDays') BEGIN
	DROP FUNCTION calculateWorkDays;
END
GO

CREATE FUNCTION calculateWorkDays (@sDate date, @eDate date) returns int AS

/********************************************************************************
created:		2018-05-25
author:			Ross Burnham (burharo@gmail.com)
description:	finds the total work days between 2 dates inclusive of the start and end date
				does not take holidays into consideration
********************************************************************************/

BEGIN

-- use a known saturday and sunday date to determine regional settings for work days

	DECLARE @numSaturday smallint = DATEPART(dw, '2018-01-06');
	DECLARE @numSunday smallint = DATEPART(dw, '2018-01-07');

-- return 0 if start date greater than end date

	IF @sDate > @eDate BEGIN
		RETURN 0;
	END

-- declare initial values

	DECLARE @totalDifference int = DATEDIFF(dd, @sDate, @eDate) + 1; -- add 1 to count start date
	DECLARE @daysRemaining smallint = @totalDifference % 7;
	DECLARE @workDays int = FLOOR(@totalDifference / 7.00) * 5;
	DECLARE @loopCounter smallint = 0;

-- determine work days in modulus

	IF @daysRemaining > 0 BEGIN

		WHILE @loopCounter < @daysRemaining BEGIN

			IF DATEPART(dw, DATEADD(dd, @loopCounter * -1, @eDate)) NOT IN (@numSaturday,@numSunday) BEGIN 
				SET @workDays = @workDays + 1
			END
			
			SET @loopCounter = @loopCounter + 1

		END

	END

-- return the value

	RETURN @workDays;

END