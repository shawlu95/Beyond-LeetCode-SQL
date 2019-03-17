This directory contains the file that can be used to set up the world_x
database that is used in the guides of the MySQL Reference
Manual:

      Quick-Start Guide: MySQL Shell for JavaScript
      Quick-Start Guide: MySQL Shell for Python

These instructions assume that your current working directory is
the directory that contains the files created by unpacking the
world_x.zip or world_x.tar.gz distribution.

You must install MySQL Shell and MySQL Server 5.7.12 or higher 
with the X Plugin enabled. Start the server before you load the 
world_x database.

  Note: Releases issued prior to September 2016 used table
        names in mixed cases. Now table names are all
        lowercase. This is because MySQL Shell is case-sensitive.

Extract the installation archive to a temporary location such as /tmp/. 
Unpacking the archive results in a single file named world_x.sql.

Create or recreate the schema with one of the following commands:

Either use MySQL Shell:

      shell> mysqlsh -u root --sql --recreate-schema world_x < /tmp/world_x-db/world_x.sql
      
Or the standard MySQL command-line client:

  Connect to MySQL:
      shell> mysql -u root -p
  Load the file:
      mysql> SOURCE /tmp/world_x-db/world_x.sql;

Enter your password when prompted. A non-root account can be used as long as 
the account has privileges to create new databases.

Replace /tmp/ with the path to the world_x.sql file on your system.
