# Demoscript 1.
# Use for demonstrations only.
# do not run on a production environment without prior testing!
# Both VSCode and Terminal will connect to the latest version of Powershell.
# If you haven't installed core 6 or 7, it will run the regular 5.x build.
# In the Windows Terminal you can choose the version that's used. 
# Remember that the installation of a module is version-specific. Installing a module in 5x
# makes it available only to 5.x, not to 6 or 7 if you installed those versions.

# To check your version of Powershell, run this command:
# Whether you do this in ISE, VSCode, Terminal or the PS Core application shouldn't matter. Or does it.

$PSVersionTable


# first up, let's install the DBA Tools commandlets.
# to get these, just run the following command and accept the repository. It's safe, trust them. 
Start-Process https://dbatools.io/secure

Install-Module dbatools



# In VS Code, this is easy, but you're not bound to Code.

# You can also use Windows Terminal. 

Install-Module dbachecks 



# In Windows Terminal, you can choose between different environments, really cool and this can be very handy.



# If you want to use the modules, you first have to import them :)
# importing modules is easy too!

Import-Module dbatools

Import-Module dbachecks




# Cool! Now we have two of the best Powershell modules ready to use.
# these modules run on any system that has WinRM enabled and where you have the right to log in.

# Because Powershell eanbles you to use variables, we just enter our logins once and reference them through the variables, just like the servernames

# local VMWare env.
$ServerList = "WIN-NAJQHOBU8QD\SQL2016DEVELOPER", "WIN-NAJQHOBU8QD\AXIANS_SQL2012_D"
$password = ConvertTo-SecureString 'yourPW' -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ('sa_admin', $password)

# Azure Env
$ServerList = "10.4.0.4\sql_nsod", "10.4.0.4\SQLEXPRESS2012", "10.4.0.4\SQLEXPRESS2017"
$password = ConvertTo-SecureString 'yourPW' -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ('NSOD-Admin', $password)


# One of the first things we want to do is import Ola Hallengrens scripts. 
#You can go to his site, download the scripts and install them on every server you've got.


# but.. boring!

# And if i think so, i won't be alone, so let's see if there's a command for that.
# you can find all the commands online:

Start-Process https://dbatools.io/commands/

# Type in Ola in the search box and see what happens!






Install-DbaMaintenanceSolution -SqlInstance $ServerList -SqlCredential $credential -ReplaceExisting






# Check out your instance and presto! The software is installed. 

# Now, to control Ola's scripts can be a bit of a nuisance because you have to apply some kind of filtering to them.
# You have to either tell the script that you're going for the user databases, systemdatabases or enter a list of databases.
# But, databases come and go on some servers and remembering to update the script... Yup

# So I've come up with a small solution that you get to see here first.

# switch over to SSMS!

# A really good blog on settings for statistics maintenance by Erin Stellato:

Start-Process https://www.sqlskills.com/blogs/erin/updating-statistics-with-ola-hallengrens-script/



# Something that can really come in handy are Glenn Allan Berry's diagnostic scripts
# To create those scripts, check out the following link 

Start-Process https://spaghettidba.com/2019/03/20/generating-a-jupyter-notebook-for-glenn-berrys-diagnostic-queries-with-powershell/

# if you've managed to create the notebook, open it in ADS and check out all the goodies in it.




# Remember I said someting about a free toolkit from Brent Ozar?

# Same thing as with the Ola solution:

Install-DbaFirstResponderKit -SqlInstance $ServerList -SqlCredential $credential -Database master -Force



# run it on your machines and done.


# oh, you want results?

# hang on


Invoke-DbaQuery -SqlInstance $ServerList -SqlCredential $credential -Database master -Query "EXEC sp_blitz @CheckServerInfo = 1" | Out-GridView


# Let's check out the DBA Checks. There are many many many options and you'll really see what it's capable of when you run it on multiple servers.
# Again, Rob Sewell has a great session on the details of this tooling. 
# But let's do a simple check. 

#last Backups
Invoke-DbcCheck -SqlInstance $ServerList -SqlCredential $credential -Tags LastBackup -Show Failed

#Last Good DBCC CheckDB
Invoke-DbcCheck -SqlInstance $ServerList -SqlCredential $credential -Tags LastGoodCheckDb -Show Failed

# These are two simple examples on how to use the DBA Checks module. 


# final demo for now: Plan Explorer.

# I've prepared a deadlock and will open this in SSMS. You'll see that it's readable, but only just.
# When we open the same file in Plan Explorer, we can see what happens and where the deadlocks appear!
# note that the order it is shown in the plan explorer isn't by default what you did.



# end of demo part 1













# demo part 2


# wait stats, how to capture them
# cool script by Enrico van der Laar
# Let's start in SSMS to check out what to capture and how!









# Who is Active, cool script by Adam Machanic

Install-DbaWhoIsActive -SqlInstance $ServerList -SqlCredential $credential -Database master



# Let's see if we can see anything happening on one or more of our servers.

Invoke-DbaWhoIsActive -SqlInstance $ServerList -SqlCredential $credential | Out-GridView




# If you want to log the data from WhoIsActive to a table, check out the accompanying sql file.


