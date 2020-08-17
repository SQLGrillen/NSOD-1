-- WHoIsActive demo

-- Install the script through dbatools. Not because you can, but because you will learn from it. Really.


-- What can be logged with whoisactive? Check it out!

exec sp_whoisactive @help = 1


-- Want to log WhoIsActive to a table?
-- https://www.brentozar.com/archive/2016/07/logging-activity-using-sp_whoisactive-take-2/


-- What can you find in my table?

Select *
from DBADMIN.dbo.whoisactive